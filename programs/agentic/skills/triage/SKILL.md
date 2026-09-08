---
name: triage
description: >-
  Triages a support report in one pass and hands back a diagnostic packet — symptom and known facts, up to
  three competing hypotheses including user error and missing-capability, evidence for and against each with
  file:line, the single cheapest discriminating check, and a recommended next action with confidence. Read-only,
  one context, no subagents, deliberately cheap. Names the check rather than running the whole workup; says
  inconclusive rather than inferring a root cause. Use for a first read on any report, and when a full
  `diagnose` workup is more than the report is worth.
---

# Triage a report

A report says something is wrong. This skill spends one cheap pass establishing what is actually known,
what could explain it, and the one check that would tell those explanations apart — then stops and hands over.

It is the fast sibling of the `diagnose` skill. Same discipline about evidence, none of the workup: one
context, no subagents, no case folder, no differential maintained across rounds. Where `diagnose` orders
tests until a diagnosis closes, triage names the test and gives it back.

**Investigate without changing code.** Read, grep, and reason. Nothing is edited, nothing is posted,
nothing goes near production.

## Budget — the whole point

Triage that sprawls is just a worse `diagnose`. Hold the line:

- **One context.** No subagents, ever. Spawning one costs more than the packet is worth.
- **Grep before read.** Read only the files a search actually implicated, and read the relevant span, not
  the file.
- **Roughly a dozen tool calls.** If the twelfth has not produced a hypothesis set, that finding *is* the
  packet: say what could not be established and what would establish it.
- **Name the discriminating check; don't run the workup.** Run it yourself only when it is one or two
  read-only local commands. Anything needing a spec, a database, a deploy window, or a person goes in the
  packet as steps for whoever picks it up.
- **Escalate rather than grind.** High stakes — money is wrong, data crosses tenants, work is blocked with
  no workaround, several accounts named — means recommending `diagnose`, not doing it here.

## Evidence, compressed

Every fact gets a source and a tier. The tier is how it is known, and higher tiers beat lower ones:

| Tier | Means |
|---|---|
| **observed** | Seen for this account, in a system of record — a query result, a trace, a screenshot |
| **population** | Many cases summarised — an error count, "31 records in the same shape" |
| **structural** | Traced in the code, not seen running — `file.rb:112`, the guard that returns early |
| **circumstantial** | Reasoned from pattern, precedent, or absence — "it started at the deploy" |

A hypothesis standing on `structural` alone is a hypothesis, not an answer. Say so.

Four things never count as evidence, however true they feel: a correlation with no mechanism; a mechanism
nobody traced to a line; the reporter's own theory repeated back; a restatement of the complaint.

**The reporter's account is a claim to test, not a chart.** Separate what they observed from what they
inferred, and keep your own hunch out of the facts section.

## The packet

The deliverable, in the terminal, under 300 words. Five parts, in order:

1. **Symptom and known facts** — the complaint in a sentence, then the facts with source and tier. What is
   observed, what is asserted, and the identifiers, timestamps, and error text available.
2. **Up to three competing hypotheses** — and where each is applicable, cover the three shapes explicitly:
   **user error** (the system behaves as designed; the path taken was not the path designed),
   **defect** (the code cannot do what it intends), and
   **intended-but-missing capability** (nothing is broken; the thing does not exist yet).
   Reaching for defect first is the standard failure; carry the other two unless a fact in hand kills them.
3. **For and against each**, by source location — `file:line`, a query, a card URL. A hypothesis with
   nothing against it has usually not been tested.
4. **The single cheapest discriminating check** — one check, chosen because it splits the hypotheses rather
   than because it confirms the favourite. Give the exact query, test, or repro steps, and the outcome each
   hypothesis predicts. If it does not predict different outcomes, it is not discriminating; pick another.
5. **Recommended next action, with confidence** — a percentage and the one fact carrying it. Then whether
   this is enough or wants a full `diagnose`.

**If the evidence cannot tell the hypotheses apart, say exactly that.** Do not infer a root cause. An honest
"inconclusive, and here is the check that would settle it" is the correct output and a genuinely useful one —
a confident wrong answer costs the reporter far more than a second pass costs in tokens.

## Rules

- **Read-only.** No edits, no `git` command that changes state, no installs, no migrations, no dev server.
- **Nothing posted.** The packet goes to the terminal and stops there; updating the card is a human step.
- **No production.** Local anonymised data and instrumentation reads only. If the only path to an answer is
  production, say so and stop.
- **Label data you drew** — what, from where, and when the snapshot dates from. A snapshot older than the
  report makes "no such record" a fact about the snapshot.
- **Cite or drop it.** A claim with no `file:line`, URL, or query behind it does not go in the packet.
- **Three hypotheses is a ceiling, not a quota.** Two well-evidenced beats three with one padded.
- **Hand over, don't continue.** Offer the next step — run the check, escalate to `diagnose`, reply to the
  reporter — and wait.
