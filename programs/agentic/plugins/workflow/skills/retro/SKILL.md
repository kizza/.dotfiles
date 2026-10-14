---
name: retro
description: >
  Takes one correction — "this shouldn't happen again", said while reviewing a branch, reading a
  proposal or watching a standup — to the single place in the workflow it belongs, and makes the
  smallest edit there that would have prevented it. The on-demand sibling of `remarks-retro`, which
  sweeps the archive monthly. Use whenever the human corrects the mechanics rather than the leaf: "make
  sure that doesn't happen again", "the engineer keeps doing X", "update the right skill", "that's a
  process thing".
---

# Retro

Read the **`workflow:contract`** skill first, and `remarks-retro` second — its six failure modes are the
diagnosis this role runs, on one correction instead of a month of them.

The leaf is a branch, and a correction left there gets made again on the next one. This role exists so
that saying it once, from wherever the human is standing, lands it in the mechanics.

## 1. Take the correction as said

They are mid-review, mid-standup, mid-something. Take what they said and what they were looking at — the
remark, the proposal, the brief, the board — and restate the correction in one sentence as the thing
to do, not the thing to stop. Confirm that sentence before going further; everything after depends on
it.

## 2. Find its one home

Every correction has exactly one place it belongs, and the test is *who would have had to read it to
not make the mistake*:

| It was about | Home |
|---|---|
| how a commit, PR, test or review is made | that **craft skill** — `commit`, `pr`, `test-clarity`, `code-reviews`, `remarks` |
| what a role reads, produces, or hands over | that **role skill** in this plugin, `skills/<role>/` |
| a stage, a gate, the limit, where state lives | the **contract**, `skills/contract/SKILL.md` |
| what "valuable" means, or where the piles are | the effort note (`Effort*/<Effort>.md`) — which is theirs to edit, so say so and stop |
| this repository's conventions | its `CLAUDE.md` or `REVIEW.md`, never a skill |
| the words a skill triggers on | that skill's `description` — a routing fix, not a wording one |

A correction that seems to belong in two places belongs in the more specific one, and the other gets a
pointer at most. Global `CLAUDE.md` is for what holds in every repository and every language, and
almost nothing new qualifies.

## 3. Diagnose before editing

Open the home and look for the rule. Usually it is already there, and the correction is being made
anyway — which is `remarks-retro`'s whole point. Apply its modes: never stated; not in the room; stated
as taste; stated without its counter-example; outvoted by the file; crowded out. Mode 4 is the common
one here, and the fix is to paste the thing they were looking at in as the anti-example, with the
correction beside it. Mode 6 means the edit is a deletion elsewhere in the same file.

Re-asserting an existing rule, harder, is not an edit. If the diagnosis is that the rule is fine and was
not loaded, the edit is to routing — the `description`, or the role that should have read it.

## 4. Show the diff, then make it

One edit, written in the voice of the file it lands in, shown with what it displaces, and not applied
until they say so. Skills take effect wherever this directory is installed from — if that needs a sync
or a switch step, say so, so the next engineer behaving as before is not a surprise.

## 5. Leave it where the monthly retro will find it

Append one row to `~/.local/share/remarks/retro.md`, as `remarks-retro` does: the correction in a few
words, today, the diagnosed mode, where the edit landed, and the check — what the next month's archive
will not contain if it worked. That is what lets the monthly sweep mark it as worked or escalate it,
instead of discovering the same objection fresh.

## Never

- Apply an edit before showing it.
- Edit the effort note. It is where their head is; the finding is reported to them instead.
- Add without saying what comes out, or why nothing does.
- Make two edits for one correction. Pick the home.
- Skip the `retro.md` row. An unrecorded edit cannot be measured, so it will be rewritten.
