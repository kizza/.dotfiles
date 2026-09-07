# Global Claude Code instructions

These apply in every project, in addition to any project-level `CLAUDE.md`.

## Naming and assignment

- **Spell things out — avoid abbreviations.** Prefer `subscription_provider_identifier` over
  `sp_identifier`, `membership_commenced_on` over `commenced_on`. A longer, descriptive
  name beats a terse one; never coin an abbreviated alias just to shorten a call site.
- **Name locals and `let`s to match the attribute/keyword they feed, then use shorthand
  assignment.** Prefer `create(:x, account_owner_id:, billing_plan:)` over
  `create(:x, account_owner_id: account_owner_id, billing_plan: billing_plan)` — Ruby's
  hash value shorthand (and the equivalent in other languages) should carry the assignment. This
  pairs with the rule above: choosing the full, matching name is what makes the shorthand read well.

## Comments

A comment earns its place by carrying what the code cannot. Write it small, then smaller than that.

- **Meaning immediately.** The first few words carry the point. No preamble, no restating the
  signature, no narrating what the next line plainly does.
- **Two shapes, mostly.** A couple of words trailing the line they qualify, or one sentence above a
  small block. Reach for anything longer only to record a real decision or trade-off.
- **Not on every line.** A note against each of four lines is noise — the reader stops telling
  signal from habit. Annotate the one or two that need it.
- **Full width, not narrow.** Wrap around 120 columns; fewer dense lines read better than many
  fragments. Keep method comments succinct — the how and why in as few lines as it takes.
- **A stale comment is worse than none.** If it no longer describes what happens, the code is the
  truth: rewrite the comment to match reality, or remove it.

## Voice intent before gated work

Before running any Bash command, edit, or fetch you are not **certain** is already allowlisted,
speak ONE short line (≤ ~8 words) stating the WHY/WHERE via `piper_say '...'`, then make the call.

- **Err toward speaking** — don't try to predict which calls prompt. If you're unsure whether a
  call is allowlisted, speak first. Over-speaking costs a second of audio; a silent prompt defeats
  the whole point. The only calls that stay silent are the obviously-routine allowlisted loop
  (rspec, linters, `ls` in the repo).
- **Intent, not mechanics** — "can I dig into the DB for rollback patterns?", never "execute bin/bash psql...".
- **One line per unit of work, not per command** — a single investigation that runs six gated
  commands gets one spoken line, not six.
- `piper_say` is allowlisted so speaking never itself prompts; the osascript visual notification
  stays as the can't-miss fallback if a line is ever missed.

Documented in full as the `voice-intent` skill under `programs/agentic/skills/`.

## Test clarity

A test's job is to be read. A reviewer must be able to judge the scenario from one screen —
without resolving setup declared above the example, or opening a helper defined elsewhere.
Where rules conflict, ask what the reviewer needs to see, not what the runtime needs to pass.

- **State preconditions directly** — don't produce them by running the system under test, and
  check whether the fixture layer already names the state before writing it by hand.
- **Arrange, act, assert — a blank line between each.** A slab of setup under one small
  assertion is the failure mode: no story, not reviewable, not scalable.
- **Share setup only when every example needs it**, and don't extract helpers for a single
  call site. Duplication beats a reference the reader has to chase.
- **Anchor time to a literal**, then derive periods by name; never make the reader simulate a clock.
- **Fewer tests, not more.**

Documented in full as the `test-clarity` skill under `programs/agentic/skills/` — read it
before writing or editing any test file. It carries the tier rule: at the end-to-end tier the
helper guidance inverts, because there the named helper is what buys the one-screen read.
