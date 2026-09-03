---
name: diagnose
description: >-
  Diagnoses a support card the way a clinician works up a case — triage first, then only the tests triage
  could not answer: imaging of the code, pathology on the local anonymised data, vitals from instrumentation
  MCPs, chart review of prior cards. Builds a differential of competing diagnoses, challenges it, and turns
  it into a plan. Concludes bug, user error, feature request, or inconclusive. Read-only local exploration —
  nothing is fixed, nothing is posted, nothing goes near production — built to run across many cards at once.
---

# Diagnose a support card

A support card says something is wrong. This skill finds out what is actually true, and what to do about it.

It runs as a clinical workup. **Triage** takes the history and looks once at the code and once at prior
cards → it either closes the case on a citation or names the tests that would change its answer → those
tests run, blind to each other → the attending builds a **differential** of competing candidate diagnoses →
further tests rule them out or complete them → a **second opinion** attacks what survives → the conclusion
is unpacked into a plan for the human.

The conclusion is one of **bug**, **user error**, **feature request**, or **inconclusive**.

## The metaphor, once, plainly

| Term | Means |
|---|---|
| **Patient** | The account, tenant, or provider the card is about |
| **Presenting complaint** | The support card |
| **Reporter** | Whoever described the symptoms — a claim to test, not a chart |
| **Attending** | You: orders the workup, reads the results, owns the differential, makes the call |
| **Triage** | The first pass: how much workup does this need, and what is already answerable cheaply |
| **Acuity** | What being wrong would cost — the other half of how much to spend |
| **Imaging** | The code: can it produce this symptom at all, by which path |
| **Pathology** | Specimens from the patient's records in the local anonymised copy |
| **Vitals** | What instrumentation recorded — Datadog and any other observability MCP |
| **Chart review** | Prior cards, decisions, and commits: has this presented before |
| **Provocation test** | An attempt to make the mechanism actually fire — the one test a human must order |
| **Impression** | The short read an agent returns; the detail stays in its results file |
| **Differential** | The competing candidate diagnoses, `Dx1`, `Dx2`, … |
| **Rule out** | Kill a candidate on higher-tier evidence — `r/o Dx2` |
| **Criteria** | What a diagnosis needs to be proven, which is also what the write-up needs to be useful |
| **Second opinion** | Another clinician, same results, asked whether they would conclude the same |
| **Discharge** | Closing a case at triage on a citation, without a workup |
| **Specimen label** | On any results drawn from a system: what was drawn, from where, when, and that nothing was written |
| **Blast radius** | How many other patients present the same way |

## Proportionate by construction

A clinic that ordered an MRI, bloods, and a second opinion for every patient would not be a thorough
clinic. It would be a bad one. Most presentations resolve on history alone.

So the workup is **graded**. Every case gets triage — one cheap pass that takes the history, looks once at
the code, and looks once at prior cards. Triage either closes the case on a citation or says exactly which
tests would change its answer. Only what it names gets ordered.

Two independent things set the spend:

- **Uncertainty** — how far triage got. A case it closes on a card URL costs one agent. A case it cannot
  read at all costs the full four.
- **Acuity** — what being wrong would cost. Money is wrong, data is lost or exposed across tenants, work is
  blocked with no workaround, a compliance obligation is in play, or several patients are named.
  **High acuity never discharges at triage** and always gets a second opinion, however obvious the answer
  looks.

The asymmetry is the whole design. Escalating a case that did not need it costs tokens, and you get them
back on the next card. Discharging a case that did need it sends a wrong answer to a customer. So triage is
written to make escalation the easy thing to say, and every discharge has to be backed by something the
attending can open and check for itself.

## Safe by construction

This skill only reads. It is built so that many cases can run at once, unattended, without any of them
affecting each other, the repo, or anything outside their own case folder.

- **Nothing is written except the case folder.** Not the repo, not a database, not the card, not a monitor
  or dashboard. The only artifacts are the files under `<scratchpad>/case-<id>/`, keyed by the card id, so
  concurrent cases cannot collide.
- **Nothing goes near production.** No production database, no remote console, no staging copy of
  production. Specimens come from the local anonymised copy; vitals come from read queries against
  instrumentation. A test whose only available path reaches production stops and says so.
- **The working tree is never touched.** No edits, and no `git` command that changes state — no checkout,
  stash, commit, branch, reset, or clean. Ten cases may share one repo, and none of them may surprise the
  other nine.
- **Nothing is installed, started, or migrated.** No package installs, no dev servers, no migrations, no
  seeds, no enqueued jobs.
- **The provocation test is opt-in only.** It is the one test that mutates local state — a temporary spec,
  the test database — so it is never ordered autonomously and never during a batch. The attending
  recommends it in the handover instead, and a human orders it.
- **Nothing is posted.** `summary.md` is written and left on disk; updating the card is a human step.

A case that cannot proceed safely stops and says why. It never trades the boundary for an answer.

## Reference Files

The attending reads only the left column. **Briefs are never copied into a dispatch** — an agent is given
the path to its own brief and reads it itself, so a four-test workup costs the attending four paths rather
than four briefs.

| Attending reads | When |
|---|---|
| `references/evidence.md` | Once, at the differential — tiers and the confidence rubric |
| `references/differential.md` | Building or updating the differential, and applying the closing rules |
| `references/diagnoses.md` | Confirming which diagnosis, routing to a plan, handing over — owns the criteria |

| Agents read | Who |
|---|---|
| `references/briefs/shared.md` | Every test — the house rules |
| `references/evidence.md` | Every test — the output contract |
| `references/briefs/triage.md` | Triage |
| `references/briefs/{imaging,pathology,vitals,chart-review}.md` | The four tests |
| `references/briefs/further-test.md` | A targeted round, alongside its angle's brief |
| `references/briefs/provocation.md` | Human-ordered only |
| `references/briefs/second-opinion.md` | The second opinion |
| `references/briefs/plans.md` | The plan specialist — its own section only |

The criteria in `diagnoses.md` are the hinge of the whole skill: what makes a diagnosis **provable** and
what makes the write-up **useful** are the same list. Blast radius proves how much a bug matters and tells
the reader how much it matters. The differential tracks that list while the workup runs; the plan fills it in.

## How It Works

Autonomous until the case is ready or the attending hits a wall a human has to break.

- **Attending** (you) — takes the presentation, routes the case, orders every test, owns the differential,
  confirms the diagnosis, hands over. Never runs a test directly, and never carries evidence it does not need.
- **Triage** — one pass, time-boxed. Closes the case on a citation, or names the order set. Its findings
  carry into the case as `TR` results and are never re-derived.
- **The workup** — the tests triage named, or all four, ordered in parallel and blind to each other. Each
  writes a results file and returns an impression.
- **Further tests** — targeted: ordered to rule out a named candidate or complete a named criterion. These
  see the differential.
- **Second opinion** — attacks the surviving diagnosis and tries to revive the ruled-out ones.
- **The plan** — one specialist, chosen by the diagnosis, that turns it into something actionable.

Results live on disk, not in the attending's context.

The case folder is the only place this skill writes. Nothing else on the machine changes.

```
<scratchpad>/case-<card-id>/
  presentation.md     attending — the complaint and the claim, given to every test
  attachments/        attending — screenshots and files from the card
  triage-results.md   TR1, TR2 …  facts only — imaging and chart review read this
  triage.md           the first pass's read, route, and citation — attending and second opinion only
  imaging.md          IM1, IM2 …
  pathology.md        PA1 …   specimen label required
  vitals.md           VI1 …   specimen label required
  chart-review.md     CH1 …
  provocation.md      PV1 …   human-ordered only
  differential.md     attending — Dx1, Dx2, Dx3, maintained across rounds
  second-opinion.md   the challenge and what survived it
  case-notes.md       the full write-up
  summary.md          succinct, card-ready, NOT posted
```

## Which Model Runs What

Subagents inherit the attending's model unless told otherwise, so pass `model` on every one. Getting this
wrong in the cheap direction is the main way a graded workup stops being trustworthy.

The principle: **pay for judgement that is expensive to check.** A wrong mechanism poisons every round
downstream and reads as perfectly plausible on the way past. A missed log line does not. Gathering, against
a brief that already names what to look for and what the traps are, is not where cases go wrong.

| Role | Model | Why |
|---|---|---|
| **Attending** | Opus | Owns the differential — where tiers get weighed and anchoring gets caught |
| **Triage** | Sonnet | Routes rather than concludes, and its discharge needs a citation the attending re-checks |
| **Imaging** | Opus | Tracing reachability through real code is the hardest test, and its errors travel furthest |
| **Pathology** | Sonnet | Scoped `SELECT`s and honest reporting, against a brief that names the traps |
| **Vitals** | Sonnet | MCP querying; the cost here is tool surface, not reasoning |
| **Chart review** | Sonnet | Search, read, quote |
| **Further tests** | Match the angle | A targeted imaging round is still imaging |
| **Second opinion** | Opus | A weaker challenger concurs agreeably — the exact failure it exists to prevent |
| **Plans** | Sonnet | The thinking is done; this is composition against a fixed outline |

Two of these are load-bearing and should not be economised: **imaging** and the **second opinion**. If a
budget has to give, give up a round of further tests instead — an inconclusive case with an honest
differential is a better artifact than a confident case built on a cheap trace.

## Budget

| Route | Agents | The case it fits |
|---|---|---|
| **Discharged at triage** | 1 | A duplicate, an already-shipped fix, or documented intent squarely on point |
| **Targeted workup** | 3–5 | Triage has a read and one or two open questions |
| **Full workup** | 7–11 | Triage is at sea, the case contradicts itself, or acuity is high |

Further-test rounds are capped at **two** after the initial workup, targeted or full. That cap is the outer
bound; the closing rules in `references/differential.md` usually stop a case sooner.

## Workflow

### Phase 1: Take the presentation

The attending does this itself — it cannot route a case without the complaint. (In a batch, triage does it;
see **Running a batch**.)

1. **Get the canonical source.** Every case is anchored to one, and one exists — a support card URL, or
   another canonical record of the complaint: a ticket, an issue, an email or chat thread, a written report
   with identifiers in it.
   - Given a card URL, use the `basecamp` skill: parse it, then fetch the card, its comments, and its
     attachments.
   - Given another canonical source, read it in full and treat it exactly as a card.
   - **Given nothing, ask for one and stop.** Do not work from a remembered symptom, a passing description,
     or a hunch. A workup with no canonical source has nothing to check itself against and nothing to hand
     back to.
2. **Pull the attachments down** into `attachments/`. Screenshots are often the only precise statement of
   the symptom, and the tests can open them.
3. **Write `presentation.md`** — the one context every test receives:
   - The card: title, URL, reporter, date, the complaint **quoted verbatim**, relevant comments
   - Expected vs observed, as the reporter states it
   - **The patient**: which account, tenant, or provider this is about
   - When: the timestamps, and whether it is ongoing or one-off
   - Every identifier available: record ids, URLs, error text, amounts, dates
   - Attachment paths with a line on what each shows
   - What is **asserted** vs what is **observed** — the reporter's theory is a claim to test
   - The repo under diagnosis and any relevant `CLAUDE.md` conventions
4. **Keep your hypothesis out of `presentation.md`.** A test handed a hypothesis goes looking for it.
5. **If the source is unusable, stop** — no symptom, no identifiers, no time frame, nothing to search on.
   Ask the human if one is there. If nobody is, write `summary.md` as inconclusive, naming exactly what the
   source is missing, and end the case.

### Phase 2: Triage and route

Order **one** triage agent, on **Sonnet**, with `references/briefs/triage.md` and `presentation.md`. It
writes two files and returns about twenty-five lines: acuity, its route, its provisional read, its `TR`
results, its citation if it has one, and the check most likely to prove it wrong.

It writes two files because the workup still has to stay blind. `triage-results.md` holds the `TR` result
blocks and nothing else — imaging and chart review read it so they do not repeat searches triage already
ran. `triage.md` holds triage's provisional read, its route, and its citation, and **only you and the
second opinion ever see it.** A test handed a hypothesis goes looking for it, and the first pass is the
cheapest agent in the case — it is the last one whose guess should steer the expensive ones.

Triage may **close** a case. It may never **convict the code** — a bug needs a traced mechanism, quoted
intent it contradicts, and a blast radius, and triage gathers none of those. A triage that thinks it has
found a bug has found an escalation, and the thing it found is where imaging starts.

It may discharge on exactly four shapes, each requiring a citation:

| Shape | Citation |
|---|---|
| **Duplicate** | A prior card with the same symptom and a recorded conclusion — URL |
| **Already fixed** | The commit or PR that fixes it — sha, and its date against the card's |
| **Documented intent** | The quoted decision, plus the file:line of the path the reporter took |
| **Unusable source** | What the card is missing — no symptom, no identifiers, no time frame |

**Verify the citation yourself.** Open the card, read the file:line, check the commit date. This is the
entire check on a cheaper model running the first pass, and it costs one read. A citation that does not
hold sends the case to a workup, and the failure goes in `differential.md` — triage misreading something is
a finding about the case, not just about triage.

Then route:

| Triage returned | Acuity | Route |
|---|---|---|
| Discharge, citation holds | routine | Write `summary.md` and hand over. Done — one agent |
| Discharge, citation holds | HIGH | **Targeted workup anyway** — confirm the citation holds *for this patient* |
| Discharge, citation fails | any | Full workup |
| A read, plus named open questions | routine | **Targeted workup** — only the tests it named, at most two |
| A read, plus named open questions | HIGH | Full workup |
| No read, or it contradicts itself | any | Full workup |

`TR` results carry into the case as real results. Nothing re-derives them — but nothing inherits triage's
theory either.

### Phase 3: The workup

Order the named tests **in parallel, in a single message**, each on the model from the table above. The
dispatch is five lines — the brief is read by the agent, not carried by you:

```
You are running the {test} test on case {case_dir}.
Read your brief:   programs/agentic/skills/diagnose/references/briefs/{test}.md
Your results file: {case_dir}/{results_file}
{imaging and chart review only: Triage has already searched some of this ground —
 read {case_dir}/triage-results.md and start past it. Do not read triage.md.}
{targeted only: the one question this test must answer}
```

Pathology and vitals are given neither triage file. Triage did no work in their domain, so there is nothing
to save, and `observed`-tier results are exactly the ones that must arrive uncontaminated — they are what
outranks a structural story when the two disagree.

| Test | Writes | Answers |
|---|---|---|
| **Imaging** | `imaging.md` | Can this code produce the symptom at all, by which path, under which conditions — and where is intended behaviour written down? |
| **Pathology** | `pathology.md` | What is the patient's data actually like, and how many other patients are in the same shape? |
| **Vitals** | `vitals.md` | Did it happen, what did the system record, and when did it start? |
| **Chart review** | `chart-review.md` | Has this presented before — reported, decided, or fixed? |

**A full workup runs all four.** Each is the sole source of something a diagnosis needs: without chart
review there is no documented intent, so user error and feature request become unreachable; without
imaging's negative finding, a feature request cannot be proven. Once you are in a full workup, dropping one
to save time silently chooses the diagnosis.

**A targeted workup runs what triage named** — and that is only honest because triage already did the
imaging-lite and chart-review-lite pass and reported what it found. A targeted workup that ignores `TR`
results is not a saving, it is a smaller full workup with the same blind spots. If the tests you skipped
were the ones that would have supplied a criterion, you are heading for inconclusive, not for cheap.

A test that finds nothing returns **what it searched** as a negative result. That is a finding, often the
strongest one available.

**Reject a pathology or vitals impression with no specimen label** and re-order it.
If any test reports touching production, **abort the case and tell the human.**

### Phase 4: Build the differential

Load `references/evidence.md` for the tiers and `references/differential.md` for the format;
`references/diagnoses.md` owns the criteria.

Write `differential.md` from triage's results and the impressions. Each entry is one **candidate
diagnosis**: the explanation in a sentence, the conclusion it implies, the results FOR it, the results
AGAINST it, and its criteria marked met, unmet, or unknown.

Carry at least one candidate per conclusion wherever the results permit — and file one as ruled-out
immediately where a result in hand already kills it. The point is to consider each conclusion, not to pay
to investigate all three.

Open a results file only where an impression line is too thin to file accurately.

### Phase 5: Further tests

Read the differential's open gaps and order targeted tests, in parallel where independent. Each gets
`briefs/further-test.md` plus its angle's brief, `presentation.md`, `differential.md`, and one job phrased
as a task, not a topic:

- "Rule out Dx1: is that guard reachable for this patient, given their flags and policies?"
- "Complete Dx1's blast radius: count how many patients are in the same shape."
- "Dx2 is user error only if intent is documented. Find where anyone decided this, or establish that nobody did."

A provocation test would belong here, but it is never ordered from inside a run: it writes a temporary spec
and touches the local test database, which is shared with every other case in flight. When a candidate is
concrete enough to provoke, note it as a recommendation for the handover and carry on without it.

After each round, apply the closing rules in `references/differential.md` — closes, continue, unrevealing,
or the two-round cap.

Ruled-out candidates stay on the differential with the result that ruled them out, so nothing is
re-investigated.

### Phase 6: Second opinion

Runs on the closed differential, before any plan is written — a broken diagnosis invalidates the whole
plan, and it is cheaper to re-open than to rewrite. Order it with `briefs/second-opinion.md`, on **Opus**.

**Skip it only when** the case was discharged at triage on a citation you verified, or the conclusion is
inconclusive — there is nothing to attack, and the differential is the handover. **High acuity never
skips.** When unsure, run it: one agent is cheap against a wrong answer reaching a person.

- **Concurs** → Phase 7
- **Doubts** → one more targeted round against the named weakness, then re-close (counts toward the cap)
- **Dissents** → rule the candidate out, re-open the differential, and if nothing else stands the conclusion
  is inconclusive

### Phase 7: The plan

The surviving candidate carries its conclusion. Confirm it against the criteria in
`references/diagnoses.md`, then order one specialist on **Sonnet**, pointed at its section of
`briefs/plans.md`:

| Conclusion | Plan | Produces |
|---|---|---|
| **Bug** | Treatment plan | Mechanism chain, file:line, when it broke, blast radius, what a fix would touch, whether existing damage needs repair |
| **User error** | Advice | The path taken vs the path designed, where intent is written down, a draft reply, and whether the system set the patient up |
| **Feature request** | Referral | What exists at the boundary today, why it cannot do this, who else has asked, the size of the gap, the case for building it |
| **Inconclusive** | None | The attending hands over the differential itself |
| **Discharged at triage** | None | The attending writes `summary.md` from triage's impression and its citation |

The specialist reads the differential, the results files, and `second-opinion.md`, then writes
`case-notes.md` and `summary.md`. It fills the criteria it was given — that list is the write-up's outline,
so nothing has to be gathered at the end.

### Phase 8: Hand over

Two forms of the same conclusion.

**`summary.md` — the deliverable.** Terse, **under 200 words**, a sentence or two and a handful of bullets
that bring the case to a conclusion. This is what gets read when ten cases finish at once, and it is the
file a future step would post to the card. Its shape is in `references/diagnoses.md`. It is **never posted**
by this skill.

**The terminal** — the same conclusion in a few lines for whoever is watching:

- The conclusion and its sub-case, with confidence
- The mechanism in one sentence, with the strongest result behind it
- The blast radius
- **How far the case was worked up** — discharged, targeted, or full — so the reader knows what was and was
  not looked at
- The recommended next step
- The case folder path, and that `summary.md` is ready

Then offer the next step and wait: fix it, send the advice, write the pitch, repair the data, order a
provocation test. The skill takes none of them.

## Running a Batch

Two dozen cards at once is the case this skill is built for, and the saving is not in running each case more
cheaply. It is in **not running most of them at all.**

1. **Triage everything first**, in parallel, on Sonnet. In batch mode triage also takes the presentation:
   give it the card URL, and it fetches the card and writes `presentation.md` **before it looks at anything
   else**, then investigates and does not revise it. The hypothesis goes in `triage.md`, never in
   `presentation.md` — the blinding still has to hold for the tests that follow.
2. **Cluster the triage results.** Cards matching on **symptom and code path** — not merely on feature area
   — are one problem presenting several times. This is the largest saving available, and it is the one thing
   a per-card pipeline can never find: twenty-four cards are rarely twenty-four problems.
3. **Nominate a lead per cluster** — the card with the most identifiers, the clearest time window, or the
   highest acuity — and work up only the lead.
4. **Discharge the rest against the lead** once it closes, citing the lead case and its conclusion. If a
   member's symptom turns out not to match the lead's mechanism, it leaves the cluster and gets its own
   workup. A cluster is a hypothesis about the batch, and it can be wrong.
5. **Nobody is watching.** Every "ask a human and stop" degrades to: write `summary.md` as inconclusive,
   naming exactly what is missing and who would have to answer it, and end the case. Do not hang, and do not
   guess.
6. **Never order a provocation test** — it writes to the local test database every other case is using.

Report the batch as one table — card, conclusion, confidence, acuity, route, next step — with cluster leads
marked and members pointing at their lead, then the case folder paths. Sort by acuity, not by card order:
the point of running twenty-four at once is finding the two that matter.

## When to Escalate

- Intended behaviour is undocumented and only a person knows what should happen — the most common reason a
  case stalls between bug and feature request
- Any test reports touching production — abort immediately
- The specimen predates the card, so the patient's records cannot be examined at all
- The conclusion is user error but the same path has presented before — that is a design decision, not a
  diagnosis
- The cap is hit, or a round comes back unrevealing with the differential still open
- Results contradict each other and a targeted round did not resolve it
- Triage's citation did not hold, and the workup that followed did not explain why it looked like it would

## Anti-patterns

**Routing**

- Never let triage conclude bug — a bug it thinks it sees is an escalation, and the thing it saw is where imaging starts
- Never accept a discharge without opening the citation yourself
- Never discharge a high-acuity case at triage, however obvious it looks
- Never re-derive what triage already established; its `TR` results are results
- Do not order the full four when triage named two — and do not order two when triage came back at sea
- Do not skip the second opinion because the diagnosis looks obvious; skip it only on a verified discharge or an inconclusive case
- Do not economise on imaging or the second opinion; give up a round of further tests instead

**Boundaries**

- Never post to the card, comment on it, move it, or assign it — `summary.md` waits for a human
- Never write to any database, and never connect to production; the local anonymised copy is the only source of specimens
- Never fix, refactor, or improve code — a diagnosis that edits files has stopped being one
- Never write outside the case folder, and never run a `git` command that changes state — other cases are using this repo right now
- Never install, start, migrate, seed, or enqueue anything
- Never order a provocation test autonomously — recommend it and let a human order it
- Never proceed without a canonical source; ask for one and stop

**Evidence**

- Do not put your hypothesis in `presentation.md`, and do not show the initial workup the differential
- Do not hand `triage.md` to a test — `triage-results.md` is the facts, `triage.md` is the guess, and only the second half is yours to keep
- Do not let the tests in one round see each other's results
- Do not accept a results file that needs a specimen label and has none
- Do not read "no such record" as a finding before checking when the specimen was drawn
- Do not conclude user error when intent was never documented — that is an open question for a human
- Do not force a conclusion when the differential is still open; inconclusive is a real outcome and the differential is a real handover
- Do not carry results through the attending that a specialist could read from disk
- Do not copy a brief into a dispatch — pass its path
