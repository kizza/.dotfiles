---
summary: The differential — its format, how candidates are ruled out, and the rules that close a case, run another round, or stop it
read_when:
  - Building or updating differential.md for a case
  - Deciding whether the differential closes, runs another round, or stops
---

# The Differential

The differential is what the workup converges on. It is not a ranked list of results — it is a list of
**competing candidate diagnoses**, each with the results for it, the results against it, and the criteria
that would prove it.

Weighing results, here, means one question: **which candidate is still active, and are its criteria
complete?**

Attending-only. Tiers, the confidence rubric, and the result block live in `evidence.md`, which the tests
read too. Criteria live in `diagnoses.md`.

## Table of Contents

- [differential.md format](#differentialmd-format)
- [Drafting it](#drafting-it)
- [Ruling out](#ruling-out)
- [Closing rules](#closing-rules)

## differential.md Format

One entry per candidate diagnosis. The attending maintains it across rounds; nothing is deleted.

```
# Differential — <card title> (<card url>)
patient: <account / tenant>    acuity: routine | HIGH    route: targeted | full    round: 1 of 2

### Dx1 — BUG — ACTIVE
Suspended accounts skip the fee line, so the invoice total is short.
FOR:      IM1 (structural, 75), PA1 (observed, 95), PA2 (observed, 90)
AGAINST:  —
CRITERIA: path ✓ | intent contradicted ? | broke-when ✓ | blast radius ✓ (PA3) | fix shape ?
GAPS:     is the guard reachable with this patient's flags? where is the intent written?

### Dx2 — USER ERROR — r/o by PA1
The report only counts approved lines, as designed.
FOR:      CH2 (observed, 90) — the module README states approved-only
AGAINST:  PA1 (observed, 95) — the line was approved and still absent
NOTE:     CH2 stands as documented intent for a different behaviour; it does not explain this complaint.

### Dx3 — FEATURE REQUEST — r/o by IM1
There is no per-fee invoicing at all.
AGAINST:  IM1 (structural, 75) — the builder does append fee lines, on the non-suspended path

## OPEN GAPS -> next round
- Dx1 intent: find where anyone decided suspended accounts should still be invoiced (chart review)
- Dx1 reachability: confirm the guard is hit for this patient given flags and policies (imaging)
```

## Drafting It

- **Carry at least one candidate per conclusion** in the first draft, wherever the results permit — bug,
  user error, feature request. This is what stops a case anchoring on bug because bug is the interesting
  answer.
- **File a candidate as ruled-out immediately** if a result already in hand kills it. Carrying a dead
  candidate as ACTIVE manufactures gaps, and gaps become tests. The anti-anchoring rule is about
  considering each conclusion, not about paying to investigate all three.
- **Ruled-out candidates stay**, with the result that ruled them out, so no round re-investigates a dead
  end.
- **Every candidate states what would rule it out.** A candidate nothing could falsify is not a candidate.
- **Conflicts are recorded, not smoothed.** Where pathology disagrees with imaging, or vitals disagree with
  the reporter, the conflict is the interesting part.
- **Open gaps are written as tasks**, each naming the test that would close it. That list is the next
  round's order set — so a gap nothing could answer is not a gap, it is a limit, and belongs in the
  handover instead.
- Open a results file only where an impression line is too thin to file accurately. The impressions are
  meant to be enough.

## Ruling Out

A candidate is **ruled out** by:

- A contradicting result at a **higher tier** than anything supporting it
- A contradicting result at the **same tier** with materially higher confidence
- A required condition shown to be false — the path is unreachable for this patient, the flag was off, the
  record never entered that state
- Its own criteria being unmeetable — a user error candidate where no intent is documented anywhere cannot
  be proven, and the differential says so rather than assuming it

A candidate is **weakened**, not ruled out, by a contradicting result at a lower tier. Record it in AGAINST
and keep going; a lower-tier contradiction usually means one of the two results is about a different thing
than it appears.

Never rule out a candidate because another looks better. Rule it out on evidence, or leave it active.

## Closing Rules

Applied after every round.

- **Closes** — exactly one candidate is active and its criteria are complete → second opinion
- **Continue** — the round ruled something out or completed a criterion, and gaps remain → order further
  tests
- **Unrevealing round** — a round that neither ruled anything out nor completed a criterion → stop;
  further tests are not converging
- **Cap** — **two** rounds of further tests after the initial workup, then stop whatever the state
- **Escalate the route** — a targeted workup whose results show triage misread the shape of the case orders
  the tests it skipped. That is round one of the cap, not a fresh start

Stopping with more than one candidate active, or with criteria unmet, is the **inconclusive** conclusion.
It is a real result: the differential, with what ruled out what and what is still missing, is a genuinely
useful handover. Never launder it into one of the other three because three sounded like the answer.
