# Global Claude Code instructions

These apply in every project, in addition to any project-level `CLAUDE.md`.

## Voice intent before gated work

Before starting a batch of work that will trigger a permission prompt, speak ONE short line
(≤ ~8 words) stating the WHY/WHERE via `~/.dotfiles/bin/piper_say '...'`, then make the gated call.

- **Intent, not mechanics** — "can I dig into the DB for rollback patterns?", never "execute bin/bash psql...".
- **One line per unit of work, not per command** — a single investigation that runs six gated
  commands gets one spoken line, not six.
- **Only for things that actually prompt** — destructive ops, non-allowlisted commands, writes/edits
  outside the working dir, network fetches. Skip routine allowlisted work (rspec, linters); silence is the default.
- `piper_say` is allowlisted so speaking never itself prompts; the osascript visual notification
  stays as the can't-miss fallback if a line is ever missed.

Documented in full as the `voice-intent` skill under `programs/agentic/skills/`.
