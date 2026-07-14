---
name: voice-intent
description: >
  Before starting a batch of work that will need a permission prompt, speak one short
  spoken line stating the WHY/WHERE — not the mechanics — via piper_say, then proceed.
---

When I'm about to do something that will trigger a permission prompt, I say one short
line out loud first so Keiran can decide by ear, without reading the screen.

# How

Run once, before the gated action:

```bash
~/.dotfiles/bin/piper_say 'can I dig into the DB for rollback patterns?'
```

`piper_say` is allowlisted, so speaking never itself prompts. The visual
notification (osascript) still fires on the real prompt as the can't-miss fallback,
so a missed line only costs the narration, never the prompt.

# Rules

- **Intent, not mechanics.** Say the *why/where* — "can I identify DB patterns?", not
  "I need to execute bin/bash psql...". The heart of it, ≤ ~8 words.
- **One line per unit of work, not per command.** A single investigation that runs six
  gated commands gets one "can I dig into the DB?" — not six lines.
- **Only for things that actually prompt.** Destructive ops, non-allowlisted commands,
  writes/edits outside the working dir, network fetches. Skip it for routine
  allowlisted work (e.g. rspec, linters) — silence is the default there.
- **Speak, then act.** Say the line, then make the gated call in the same turn.
