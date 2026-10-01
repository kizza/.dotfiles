---
summary: Whether a finding is worth a remark — the confidence rubric and the exclusions.
read_when:
  - Deciding whether a finding survives into a remark
---

# Confidence

A remark costs the reader a round trip: they stop, read the line, reconstruct the context and decide. A
finding that turns out to be nothing spends that for nothing, and spends the credibility of the next one
with it. Two false positives and the reader starts skimming; four and they stop reading.

So the bar is deliberately high. **Better to miss a minor finding than to write a remark that does not hold
up.** Score every finding before it becomes a remark.

## Rubric

| Score | Meaning | Action |
|-------|---------|--------|
| **0** | Does not survive scrutiny, or the line was not touched by this change. | Discard |
| **25** | Might be real. Could not verify it from the code in front of you. | Discard |
| **50** | Verified, but a nitpick, or unlikely to matter against the rest of the change. | Discard |
| **70** | Verified and real. Has a workaround, or needs an edge case to bite. | Remark |
| **75** | Double-checked. Likely to be hit. Directly affects behaviour, or a rule in `CLAUDE.md`/`REVIEW.md` names it. | Remark |
| **100** | Certain, with the evidence to prove it. | Remark |

**Discard below 70.** If a run produces nothing above the bar, say so — "no findings above the bar" is a
result, and a real one.

## Verify before you score

A finding is verified when you have read the code that makes it true, not when the diff suggests it. Open
the caller. Check whether the constraint exists in the schema. Confirm the method does what its name says.

For guarantees findings in particular: **a behavioural claim needs a `file:line` citation, not an inference
from naming.** "This looks like it might not be scoped" is a 25. "`Claim.where(status:)` at claims_controller.rb:31
has no account scope, where every other query in this controller goes through `current_account.claims`" is a 100.

## Never a finding

Score these 0 whatever they look like:

- **Untouched lines.** If it is not in a `+` hunk, it is out of scope — unless the change is what made it
  load-bearing, and then write the finding about the change.
- **What CI catches.** Missing imports, type errors, formatting, unused variables, indentation. Flagging
  them costs a round trip and tells the author nothing they will not learn in ninety seconds.
- **Pedantry.** Subjective naming taste, blank lines, import ordering. Unless `CLAUDE.md` or `REVIEW.md`
  names it, it is not a finding.
- **Deliberate suppressions.** A `rubocop:disable`, a `# noqa`, an `eslint-disable`. Someone decided that.
- **Intentional behaviour change.** A new parameter, a changed default, a different return value is usually
  the point of the change, not a regression in it.
- **General quality wishes.** "Could use more tests", "consider logging here", "might want error handling."
  Opinions. If a specific requirement demands it, that is a spec finding with a source behind it.
- **Anything already said.** Check `remarks list` before writing: a remark already standing on that line
  does not need a second voice.

## Deduplication

Same file, within three lines, same underlying issue — one finding. Keep the highest score; on a tie keep
the one whose description is more concrete. Note where two lenses found it independently, which is itself
evidence.

Two lenses flagging the *same line* for *different reasons* are two findings. A missing tiebreak in an
`ORDER BY` and a method name that lies about what it returns are unrelated, and collapsing them helps
nobody.

## Severity is not confidence

They are independent, and only one of them filters.

- **Severity** — how bad if it is real. Drives what the author does first.
- **Confidence** — how sure you are that it is real. Drives whether it gets written at all.

A critical-severity finding at 40 confidence is discarded: probably not real, and a wrong critical costs
more credibility than any other kind. A minor finding at 100 is written: definitely real, just small.
