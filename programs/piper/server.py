"""Speak text posted to it, one utterance at a time, with the voice already loaded.

POST / with the text as the body; `?voice=<name>` picks another voice from the voices directory. It
answers 202 straight away and speaks in the background, so callers never wait on the audio.
"""

import argparse
import logging
import queue
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

import sounddevice
from piper import PiperVoice

IDLE_SECONDS_BEFORE_RELEASING_AUDIO = 10  # Reopening costs ~0.1s; holding it keeps the device awake

_LOGGER = logging.getLogger("piper-server")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--voices-directory", type=Path, required=True)
    parser.add_argument("--default-voice", required=True)
    arguments = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

    voices = Voices(arguments.voices_directory, arguments.default_voice)
    utterances: "queue.Queue[tuple[PiperVoice, str]]" = queue.Queue()

    threading.Thread(target=speak_forever, args=(utterances,), daemon=True).start()

    server = ThreadingHTTPServer(("127.0.0.1", arguments.port), handler_for(voices, utterances))
    _LOGGER.info("Listening on %s with %s", arguments.port, arguments.default_voice)
    server.serve_forever()


class Voices:
    """Loads each voice once, on first use; the default up front so the first line is quick."""

    def __init__(self, directory: Path, default_name: str) -> None:
        self.directory = directory
        self.default_name = default_name
        self.loaded: dict[str, PiperVoice] = {}
        self.lock = threading.Lock()
        self.get(default_name)

    def get(self, name: str) -> PiperVoice:
        with self.lock:
            if name not in self.loaded:
                self.loaded[name] = PiperVoice.load(self.directory / f"{name}.onnx")
            return self.loaded[name]


def speak_forever(utterances: "queue.Queue[tuple[PiperVoice, str]]") -> None:
    stream = None

    while True:
        try:
            voice, text = utterances.get(timeout=IDLE_SECONDS_BEFORE_RELEASING_AUDIO)
        except queue.Empty:
            stream = release(stream)
            continue

        try:
            stream = stream_for(stream, voice.config.sample_rate)
            for chunk in voice.synthesize(text):  # One chunk per sentence, so long text starts speaking early
                stream.write(chunk.audio_float_array.reshape(-1, 1))
        except Exception:
            _LOGGER.exception("Couldn't speak %r", text)
            stream = release(stream)


def stream_for(stream, sample_rate: int) -> sounddevice.OutputStream:
    if stream is not None and stream.samplerate == sample_rate:
        return stream

    release(stream)
    sounddevice._terminate()  # PortAudio reads the default output once, at init, so re-init to follow the Mac's
    sounddevice._initialize()
    stream = sounddevice.OutputStream(samplerate=sample_rate, channels=1, dtype="float32")
    stream.start()
    return stream


def release(stream) -> None:
    if stream is not None:
        stream.close()


def handler_for(voices: Voices, utterances: "queue.Queue[tuple[PiperVoice, str]]"):
    class Handler(BaseHTTPRequestHandler):
        def do_POST(self) -> None:
            text = self.rfile.read(int(self.headers.get("Content-Length", 0))).decode().strip()
            voice_name = parse_qs(urlparse(self.path).query).get("voice", [voices.default_name])[0]

            if not text:
                return self.respond(400, "No text to speak")

            try:
                voice = voices.get(voice_name)
            except Exception as error:
                return self.respond(404, f"No voice {voice_name}: {error}")

            utterances.put((voice, text))
            self.respond(202, "")

        def respond(self, status: int, message: str) -> None:
            self.send_response(status)
            self.end_headers()
            self.wfile.write(message.encode())

        def log_message(self, *args) -> None:
            pass  # One line per utterance is noise; failures are logged where they happen

    return Handler


if __name__ == "__main__":
    main()
