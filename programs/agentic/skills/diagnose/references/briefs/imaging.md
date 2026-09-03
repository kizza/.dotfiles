---
summary: Can this code produce the symptom at all, by which path, under which conditions — and where is intended behaviour written down
read_when:
  - You are the imaging agent on a diagnose case
---

# Imaging

Read the house rules first: `programs/agentic/skills/diagnose/references/briefs/shared.md`

`results_file: imaging.md` — id prefix `IM`

You are imaging the code. Determine whether this codebase can produce the reported symptom at all, by
which path, under which conditions — and where its intended behaviour is written down.

If `{case_dir}/triage-results.md` exists, read it. Triage already found the entry point and looked once
at the path; its `TR` results are established and you start from them rather than repeating them.

**Do not read `{case_dir}/triage.md`.** That file holds triage's provisional read, and it is deliberately
kept from you — the whole value of this test is that it traces the code without a theory to confirm. If
triage was right you will arrive there anyway; if it was wrong you are the test most likely to notice.

Do this:

- Find the code that owns the behaviour the reporter touched. Start at the entry point: the controller
  action, background job, webhook handler, mailer, scheduled task, or command their action would reach.
- Trace the path from entry to outcome, following the calls that matter to the symptom.
- Identify every branch, guard, validation, authorisation check, tenancy or account scope, and feature
  flag on that path. For each, state which way it must fall for the symptom to appear. A symptom that
  needs three unlikely conditions is a different result from one that needs none.
- Look for the mechanisms that produce this class of symptom: a condition that silently returns early, a
  rescue that swallows, a nil defaulting to something wrong, a scope that excludes rows, a stale cache, a
  rounding or timezone conversion, an ordering assumption, a race between a job and a request.
- Check history near that path — commit log and blame on the files involved. Note changes inside the
  card's time window, and note reverts and prior fixes.
- Hunt for intended behaviour and QUOTE it: a comment, a spec name, a validation message, a module or
  component README, a `CLAUDE.md` rule, a doc. Whether the code is "wrong" depends entirely on this, and it
  is the single most useful thing you can bring back. If no statement of intent exists anywhere, say so
  explicitly — that absence is itself a result.

Report, as results:

- Each candidate mechanism: the path, the conditions it requires, file:line evidence
- Whether the symptom is reachable AT ALL through this code. A firm "no path produces this" reframes the
  entire case, so give it its own result and say what you searched to be sure
- Every statement of intended behaviour you found, quoted, with its source — or its absence

Do NOT:

- Fix, refactor, or improve anything
- Review code quality; this is not a code review
- Assume the reporter is right about which feature they used — check the path they describe AND the path
  that produces what they saw
- Present a mechanism you did not trace as though you traced it
