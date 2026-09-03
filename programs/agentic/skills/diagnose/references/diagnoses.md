---
summary: Criteria for each conclusion, severity and confidence, the handover, and summary.md
read_when:
  - Drafting or updating the differential's criteria
  - Confirming the surviving candidate's conclusion
  - Routing to a plan and handing over to the human
  - Writing case-notes.md as a plan specialist — your conclusion's criteria are your outline
---

# Diagnoses

Four possible conclusions: **bug**, **user error**, **feature request**, **inconclusive**.

Each has **criteria**. The criteria are the same list twice over: what makes the diagnosis provable, and
what the write-up must contain to be worth reading. Blast radius proves how much a bug matters and tells the
reader how much it matters. So the differential tracks the criteria while the workup runs, and the plan
fills them in once it stops.

Nothing here is a judgement about a person. User error is a statement about a path through a system — the
clinical equivalent of technique, not of character — and if the system set the patient up, that is part of
the diagnosis.

## Table of Contents

- [Bug](#bug)
- [User error](#user-error)
- [Feature request](#feature-request)
- [Inconclusive](#inconclusive)
- [Severity and confidence](#severity-and-confidence)
- [The plans](#the-plans)
- [The handover](#the-handover)
- [summary.md](#summarymd)

## Bug

The system did something that contradicts its intended behaviour.

**Criteria**

| Item | Met when |
|---|---|
| `path` | A code path that produces the symptom is traced, with file:line |
| `intent contradicted` | A statement of intended behaviour it violates is quoted — a spec, a validation, a comment, a README, a `CLAUDE.md` rule, a decision on a card. Or the invariant is self-evident: a crash, data loss, wrong money, one tenant seeing another's data |
| `observed` | At least one supporting result at `observed` or `population` tier, or the candidate is carried as explicitly unconfirmed |
| `broke-when` | The onset is established, or its being unknown is stated |
| `blast radius` | How many other patients present the same way, with the query that counted them |
| `fix shape` | What a fix would change, and which files it touches — shape, not a patch |

**Sub-cases, named in the write-up:**

- **Acute** — the defect is in the code now and will recur
- **Historical** — the code is already correct; past data was damaged and needs repair. The treatment is a backfill, not a patch
- **Fixed but unreleased** — the fix exists on a branch or an unreleased commit. Say which

## User Error

The system behaved as intended, and the patient's path produced the outcome they did not want.

**Criteria**

| Item | Met when |
|---|---|
| `path taken` | The path that produces what they saw is traced, with file:line |
| `path designed` | The path that produces what they expected is identified — or shown not to exist |
| `intent documented` | Somewhere a person actually decided this is correct, quoted with its source |
| `not contradicted` | Nothing in pathology or vitals disagrees |
| `advice` | What the reporter is told, in plain language, drafted |
| `invited?` | Whether the system set them up for it, and how |

**If `intent documented` cannot be met, the conclusion is not user error.** "The code does this" and "the
code should do this" are different claims and only one of them is in the repo. Undocumented intent is an
open question for a human — escalate rather than defaulting to the patient being wrong.

**Sub-cases:**

- **Plain** — they had what they needed and got it wrong
- **With a design smell** — a misleading label, a silent failure, a state with no explanation, a destructive action with no confirmation. The conclusion stays user error; the recommendation is a design change
- **Recurrence** — the same path has presented before. Stop calling it user error and escalate it as a design decision

## Feature Request

There is no behaviour here to be wrong about. The patient wants something the system does not do.

**Criteria**

| Item | Met when |
|---|---|
| `absence` | No code path implements the requested behaviour — imaging's negative result, with what it searched |
| `no intent` | Nothing documents that it should exist. If a decision says it should and it does not, that is a bug of omission, not a request |
| `boundary` | What exists closest to the request today, with file:line, and why it cannot do this |
| `prior asks` | Whether other patients have asked before, with card URLs, or that nobody has |
| `gap size` | Whether this is a gap in an existing feature or new ground |

## Inconclusive

The differential never closed: more than one candidate is still active, or the survivor's criteria could not
be completed, and a round came back unrevealing or the cap was reached.

Hand over:

- What is established, with its evidence
- What is not, and precisely which criteria are unmet
- What would close it: an access, a specimen, a decision only a person holds
- The differential itself

No plan is written. The attending hands this over directly.

## Severity and Confidence

Three independent things, all three reported:

- **Conclusion** — which of the four
- **Severity** — blast radius × consequence. One patient with a cosmetic annoyance is not forty with wrong money
- **Confidence** — how sure the diagnosis is, and what would raise it

A high-severity, low-confidence diagnosis is not a treatment instruction. It is a reason to get a human
involved quickly.

## The Plans

The three plan briefs live in `briefs/plans.md`, one section each — treatment plan for a bug, advice for
user error, referral for a feature request. The attending does not read them: it names the section and the
specialist reads its own.

## The Handover

The human gets this in the terminal, and nothing is published anywhere.

```
## {card title}

**Diagnosis:** {bug (acute) | user error (design smell) | feature request | inconclusive}
**Confidence:** {n} — {what would raise it}
**Severity:** {blast radius × consequence}

{The mechanism, or the ask, in one or two sentences — with the strongest result behind it.}

**Blast radius:** {n other patients, or unknown because …}
**Excluded:** {ruled-out candidate} — {what ruled it out}
**Next step:** {treatment | send the advice | write the pitch | the access needed}

summary.md ready (not posted) — {case folder path}
```

Keep it short enough to act on without opening anything. The detail is in `case-notes.md` on disk.

Then offer the next step and wait. Fix it, send the advice, write the pitch, repair the data, update the
card. The skill takes none of them.

## summary.md

**The deliverable.** Terse enough to read at a glance when ten cases land at once, complete enough to act
on without opening anything else.

**Under 200 words. Hard limit.** If the conclusion does not fit in 200 words, it is not sharp enough yet —
tighten it rather than spilling over.

```
# {card title}

**{Bug (acute) | User error (design smell) | Feature request | Inconclusive}** — confidence {n}

{One or two sentences: what actually happens, and why. Plain language.}

- {The mechanism, or the ask, in one line}
- {Blast radius: how many other patients present this way}
- {What was ruled out, and what ruled it out}
- {The next step}

{card url} · full case notes: {case folder}
```

Rules:

- Written for the reporter and the team, not for an engineer with the codebase open
- No results tables, no result ids, no file:line, no workup bookkeeping — that is `case-notes.md`
- A handful of bullets that conclude the case, not a list of everything found
- An inconclusive case still gets one: what is established, what is missing, what would close it
- A case discharged at triage still gets one, and it cites the citation that discharged it — the card URL,
  the commit sha, or the quoted decision. A discharge with nothing to point at is not a discharge
- **Never posted anywhere.** Updating the card is a separate, human-initiated step
