"""Talk something through with a Claude agent, out loud.

Type a line and the agent answers by speaking, for itself, through `piper_say`. Ctrl-C mid-reply
silences it and interrupts its turn. Ctrl-D ends the conversation.
"""

import argparse
import asyncio
import json
import os
import re
import sys
import time
import urllib.request
from pathlib import Path

from prompt_toolkit import PromptSession, print_formatted_text
from prompt_toolkit.formatted_text import FormattedText
from prompt_toolkit.patch_stdout import patch_stdout

STATE_DIRECTORY = Path.home() / ".local/state/conversation"

READ_ONLY_TOOLS = [
    "Bash(piper_say *)",
    "Bash(gh pr view *)",
    "Bash(gh pr diff *)",
    "Bash(gh pr checks *)",
    "Bash(gh pr list *)",
    "Bash(git log *)",
    "Bash(git show *)",
    "Bash(git diff *)",
    "Bash(git blame *)",
    "Read",
    "Grep",
    "Glob",
]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--instructions", type=Path, required=True)
    parser.add_argument("--piper-url", required=True)
    parser.add_argument("--model", default=os.environ.get("CONVERSATION_MODEL", "sonnet"))
    parser.add_argument("topic", nargs="*", help="What you're looking at, said as the first message")
    arguments = parser.parse_args()

    asyncio.run(Conversation(arguments).run())


class Conversation:
    def __init__(self, arguments: argparse.Namespace) -> None:
        self.arguments = arguments
        self.agent: asyncio.subprocess.Process
        self.turn_in_flight = False
        self.interrupted = False

    async def run(self) -> None:
        self.agent = await self.start_agent()
        asyncio.create_task(self.relay_agent())

        say("conversation", "Type to talk. Ctrl-C interrupts, Ctrl-D ends.")
        if self.arguments.topic:
            self.send(" ".join(self.arguments.topic))

        await self.converse()

        self.stop_speaking()
        self.agent.terminate()

    async def start_agent(self) -> asyncio.subprocess.Process:
        STATE_DIRECTORY.mkdir(parents=True, exist_ok=True)

        return await asyncio.create_subprocess_exec(
            "claude", "-p",
            "--input-format", "stream-json", "--output-format", "stream-json", "--verbose",
            "--model", self.arguments.model, "--effort", "low",
            "--system-prompt", self.arguments.instructions.read_text(),
            # Without the user's settings, MCP servers and memory a session starts in ~1.5s, not ~6s
            "--setting-sources", "", "--strict-mcp-config", "--mcp-config", '{"mcpServers": {}}',
            "--tools", "Bash,Read,Grep,Glob", "--allowedTools", *READ_ONLY_TOOLS,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=open(STATE_DIRECTORY / "agent.log", "w"),
            limit=16 * 1024 * 1024,  # A tool result arrives as one line, and a diff can be large
        )

    def interrupt(self) -> None:
        was_speaking = self.stop_speaking()
        if self.turn_in_flight:
            request_id = f"interrupt-{time.monotonic_ns()}"
            self.write_to_agent({"type": "control_request", "request_id": request_id, "request": {"subtype": "interrupt"}})
        self.interrupted = was_speaking or self.turn_in_flight

    def stop_speaking(self) -> bool:
        try:
            request = urllib.request.Request(f"{self.arguments.piper_url}/stop", method="POST")
            with urllib.request.urlopen(request, timeout=0.5) as response:
                return response.read() == b"speaking"
        except OSError:
            return False

    def write_to_agent(self, message: dict) -> None:
        self.agent.stdin.write((json.dumps(message) + "\n").encode())

    async def relay_agent(self) -> None:
        async for line in self.agent.stdout:
            event = json.loads(line)

            if event["type"] == "assistant":
                for block in event["message"]["content"]:
                    show(block)
            elif event["type"] == "result":
                self.turn_in_flight = False
                if event.get("is_error") and event.get("result"):
                    say("error", event["result"])

        say("conversation", f"The agent has stopped; see {STATE_DIRECTORY / 'agent.log'}.")

    def send(self, text: str) -> None:
        if self.interrupted:
            text = f"[Interrupted] {text}"
            self.interrupted = False

        self.write_to_agent({"type": "user", "message": {"role": "user", "content": text}})
        self.turn_in_flight = True

    async def converse(self) -> None:
        session = PromptSession()

        with patch_stdout(raw=True):
            while True:
                try:
                    text = await session.prompt_async("you › ")
                except KeyboardInterrupt:
                    self.interrupt()
                    continue
                except EOFError:
                    return

                if text.strip():
                    self.send(text.strip())


def show(block: dict) -> None:
    if block["type"] == "text":
        return say("aside", block["text"])
    if block["type"] != "tool_use":
        return

    command = block["input"].get("command")
    if not command:
        return say("looking", f"{block['name']} {json.dumps(block['input'])}")

    # It chains speech with lookups (`piper_say "..."; gh pr view ...`), so pick the spoken parts out
    for _quote, spoken in SPOKEN.findall(command):
        say("claude", spoken)

    looking = SPOKEN.sub("", command).strip(" ;&\n")
    if looking:
        say("looking", looking)


SPOKEN = re.compile(r"""piper_say\s+(["'])(.*?)\1""", re.DOTALL)


STYLES = {
    "claude": ("ansicyan", "claude › "),
    "aside": ("ansibrightblack", "  "),
    "looking": ("ansibrightblack", "  ⋯ "),
    "error": ("ansired", "error › "),
    "conversation": ("ansibrightblack", ""),
}


def say(kind: str, text: str) -> None:
    style, prefix = STYLES[kind]
    print_formatted_text(FormattedText([(style, prefix + text.strip())]))


if __name__ == "__main__":
    sys.exit(main())
