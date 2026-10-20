"""Speak text posted to it, one utterance at a time, with the voice already loaded.

POST / with the text as the body; `?voice=<name>` picks another voice from the voices directory. It
answers 202 straight away and speaks in the background, so callers never wait on the audio.

POST /stop silences it: the current utterance is cut off and anything queued is dropped. It answers
`speaking` or `idle`, for what it was doing when the stop arrived.
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
FRAMES_PER_WRITE = 2048  # ~0.1s of audio, so a stop lands within that

_LOGGER = logging.getLogger("piper-server")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--voices-directory", type=Path, required=True)
    parser.add_argument("--default-voice", required=True)
    arguments = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

    voices = Voices(arguments.voices_directory, arguments.default_voice)
    speaker = Speaker()

    threading.Thread(target=speaker.speak_forever, daemon=True).start()

    server = ThreadingHTTPServer(("127.0.0.1", arguments.port), handler_for(voices, speaker))
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


class Speaker:
    """Plays queued utterances in turn; a stop bumps the generation, which everything older gives way to."""

    def __init__(self) -> None:
        self.utterances: "queue.Queue[tuple[int, PiperVoice, str]]" = queue.Queue()
        self.generation = 0
        self.speaking = False
        self.stream = None

    def say(self, voice: PiperVoice, text: str) -> None:
        self.utterances.put((self.generation, voice, text))

    def stop(self) -> bool:
        was_speaking = self.speaking or not self.utterances.empty()
        self.generation += 1
        return was_speaking

    def speak_forever(self) -> None:
        while True:
            try:
                generation, voice, text = self.utterances.get(timeout=IDLE_SECONDS_BEFORE_RELEASING_AUDIO)
            except queue.Empty:
                self.release()
                continue

            if generation != self.generation:
                continue

            self.speaking = True
            try:
                self.speak(generation, voice, text)
            except Exception:
                _LOGGER.exception("Couldn't speak %r", text)
                self.release()
            finally:
                self.speaking = False

    def speak(self, generation: int, voice: PiperVoice, text: str) -> None:
        stream = self.stream_for(voice.config.sample_rate)

        for chunk in voice.synthesize(text):  # One chunk per sentence, so long text starts speaking early
            audio = chunk.audio_float_array.reshape(-1, 1)
            for start in range(0, len(audio), FRAMES_PER_WRITE):
                if generation != self.generation:
                    return
                stream.write(audio[start : start + FRAMES_PER_WRITE])

    def stream_for(self, sample_rate: int) -> sounddevice.OutputStream:
        if self.stream is not None and self.stream.samplerate == sample_rate:
            return self.stream

        self.release()
        sounddevice._terminate()  # PortAudio reads the default output once, at init, so re-init to follow the Mac's
        sounddevice._initialize()
        self.stream = sounddevice.OutputStream(samplerate=sample_rate, channels=1, dtype="float32")
        self.stream.start()
        return self.stream

    def release(self) -> None:
        if self.stream is not None:
            self.stream.close()
            self.stream = None


def handler_for(voices: Voices, speaker: Speaker):
    class Handler(BaseHTTPRequestHandler):
        def do_POST(self) -> None:
            url = urlparse(self.path)
            if url.path == "/stop":
                return self.respond(200, "speaking" if speaker.stop() else "idle")

            text = self.rfile.read(int(self.headers.get("Content-Length", 0))).decode().strip()
            voice_name = parse_qs(url.query).get("voice", [voices.default_name])[0]

            if not text:
                return self.respond(400, "No text to speak")

            try:
                voice = voices.get(voice_name)
            except Exception as error:
                return self.respond(404, f"No voice {voice_name}: {error}")

            speaker.say(voice, text)
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
