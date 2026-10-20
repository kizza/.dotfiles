---
name: speaking
description: >
  How to say something out loud to Keiran: the `piper_say` command, how it behaves, and the Spoken
  English every spoken sentence follows. The mechanics other voice skills build on — `voice-intent`
  for a working agent's one-line asides, `conversation` for a session that is all speech. Load
  whenever words are about to be spoken rather than written.
---

# Speaking

Keiran hears what you say through text-to-speech. He hears each sentence once, cannot scroll back, and
is often looking at something else while you talk.

## How to speak

- **`piper_say` is a shell command.** Run it with the Bash tool: `piper_say "Your words here."`
  There is no tool named `piper_say`.
- **Double-quote the words.** Keep `$`, backticks and `"` out of them; an apostrophe is fine.
- **It returns at once.** A server keeps the voice loaded and plays in the background, so one call
  costs you nothing. Several calls play in the order you make them, one at a time.
- **He can cut you off.** Anything not yet played is dropped when he does. Put the point first, so
  an early cut still leaves him with the answer.
- **Speech is not a transcript.** What you print still shows in the terminal. Speak what he needs to
  hear, and do not write it out again afterwards.

## What to say

Word every spoken sentence by Spoken English (`references/spoken-english.md`): one idea a sentence,
twenty words at most, active, plain verbs, names said as words, no symbols or code, every hedge kept.
