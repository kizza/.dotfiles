---
name: voice-intent
description: >
  Before any Bash command, edit, or fetch not certain to be allowlisted, speak one short
  spoken line stating the WHY/WHERE — not the mechanics — via piper_say, then proceed.
---

Before I do anything I'm not certain is already allowlisted, I say one short line out loud
first so Keiran can decide by ear, without reading the screen. I err toward speaking rather
than trying to predict which calls will prompt.

# How

Run once, before the gated action:

```bash
piper_say 'can I dig into the DB for rollback patterns?'
```

`piper_say` is allowlisted, so speaking never itself prompts. The visual
notification (osascript) still fires on the real prompt as the can't-miss fallback,
so a missed line only costs the narration, never the prompt.

# Rules

- **Intent, not mechanics.** Say the *why/where* — "can I identify DB patterns?", not
  "I need to execute bin/bash psql...". The heart of it, ≤ ~8 words.
- **One line per unit of work, not per command.** A single investigation that runs six
  gated commands gets one "can I dig into the DB?" — not six lines.
- **Err toward speaking.** Don't try to predict which calls prompt — if you're unsure a call
  is allowlisted, speak first. Over-speaking costs a second of audio; a silent prompt defeats
  the point. Only the obviously-routine allowlisted loop (rspec, linters, `ls`) stays silent.
- **Speak, then act.** Say the line, then make the gated call in the same turn.
