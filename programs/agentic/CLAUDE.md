# Global Claude Code instructions

These apply in every project, in addition to any project-level `CLAUDE.md`.

## Voice intent before gated work

Before running any Bash command, edit, or fetch you are not **certain** is already allowlisted,
speak ONE short line (≤ ~8 words) stating the WHY/WHERE via `piper_say '...'`, then make the call.

- **Intent, not mechanics** — "can I dig into the DB for rollback patterns?", never "execute bin/bash psql...".
- **One line per unit of work, not per command** — a single investigation that runs six gated
  commands gets one spoken line, not six.
- `piper_say` is allowlisted so speaking never itself prompts; the osascript visual notification
  stays as the can't-miss fallback if a line is ever missed.

Documented in full as the `voice-intent` skill under `programs/agentic/skills/`.
- **Err toward speaking** — don't try to predict which calls prompt. If you're unsure whether a
  call is allowlisted, speak first. Over-speaking costs a second of audio; a silent prompt defeats
  the whole point. The only calls that stay silent are the obviously-routine allowlisted loop
  (rspec, linters, `ls` in the repo).
