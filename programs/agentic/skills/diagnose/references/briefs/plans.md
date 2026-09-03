---
summary: The three plan briefs — treatment plan for a bug, advice for user error, referral for a feature request
read_when:
  - You are the plan specialist on a closed diagnose case — read only your own section
---

# Plans

One specialist, chosen by the conclusion. The workup is over: **order no new tests, and treat nothing.**

Every plan reads, in this order:

    {case_dir}/differential.md   — the surviving candidate is the diagnosis; the ruled-out ones show what was excluded
    {case_dir}/second-opinion.md — the challenge and what survived it (absent if the case was discharged at triage)
    the results files the surviving candidate cites in FOR and AGAINST

and uses the criteria for its conclusion, in `references/diagnoses.md`, as the outline of `case-notes.md`.
That list was tracked while the workup ran, so nothing has to be gathered now.

Every plan then writes `summary.md` — the shape and the hard 200-word limit are in
`references/diagnoses.md`. **Nothing is posted anywhere.**

## Treatment Plan — for a bug

```
Write case-notes.md, using the bug criteria as your outline:
- Presentation: what actually happens, as observed fact rather than as reported
- Mechanism: the causal chain from trigger to symptom, every link citing a result id and its file:line,
  query result, or trace. Where a link rests only on structural reasoning, say so on that link
- Broke when: the onset, and what changed near it — and if the correlation has no mechanism connecting it,
  say that plainly
- Blast radius: how many other patients present this way, and the query that counted them
- Treatment: what would change and which files it touches. Shape, not a patch. If more than one approach
  is reasonable, give the trade-off in a sentence each
- Repair: whether records already damaged need a backfill, scoped by the blast radius query
- Excluded: each ruled-out candidate and the result that ruled it out
- Results table: id, finding, tier, confidence, source
- Residual doubt: the weakest link the second opinion named, and what would settle it

Do not edit application code. Do not write a migration or a patch. Do not post anything anywhere.
```

## Advice — for user error

```
Your job is twofold: give the human what to say back, and be honest about whether the system set this
patient up.

Write case-notes.md, using the user error criteria as your outline:
- What actually happened: the path the patient took, traced, and the outcome it produces by design
- What they expected: the path that would have produced it, or the fact that no such path exists
- Where intent is written: quote it with its source. This is the load-bearing part of this conclusion
- Draft reply: what the reporter is told, in plain language, no jargon, no blame, and never "working as
  intended" as a sentence on its own. Explain what the system did, why, and what to do instead
- Did the system set them up? Be direct. A misleading label, a silent failure, an unexplained state, a
  destructive action with no confirmation. If so, name the design change worth making — the conclusion
  stays user error and the recommendation is a change
- Has this presented before? If chart review found an earlier card on the same path, say so and flag that
  a recurrence makes this a design decision rather than a diagnosis
- Results table: id, finding, tier, confidence, source

The reply is a draft for a human to send. Do not post it anywhere.
```

## Referral — for a feature request

```
Your job is to turn "we don't do that" into the case for someone building it.

Write case-notes.md, using the feature request criteria as your outline:
- The ask: what the patient wants, in their terms, and then in the system's terms
- Absence: the evidence that nothing implements this, including what imaging searched
- The boundary: what exists closest to it today, with file:line, and precisely why it cannot do this. This
  is the most useful part of the document — it is where a pitch would start
- Prior asks: earlier cards or messages from other patients asking for the same thing, with URLs, or the
  fact that this is the first
- Gap size: a gap in an existing feature, or new ground. Say which, and what makes you say it
- The case for building it: the problem worth solving in one paragraph, the appetite it plausibly
  deserves, and the parts of the system it would touch
- Not a bug because: the documented intent, or documented absence of intent, that keeps this out of bug
  territory
- Results table: id, finding, tier, confidence, source

Do not build the feature. Do not post anything anywhere.
```
