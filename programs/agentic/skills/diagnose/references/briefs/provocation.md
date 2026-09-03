---
summary: Make the proposed mechanism actually fire — the one test that mutates local state, and the only one a human must order
read_when:
  - A human has explicitly ordered a provocation test
---

# Provocation Test

Read the house rules first: `programs/agentic/skills/diagnose/references/briefs/shared.md` — with one
exception, below.

`results_file: provocation.md` — id prefix `PV` — **human-ordered only**

> This is the one test that mutates local state: it writes a temporary spec and runs against the local
> test database. The attending **never orders it autonomously and never during a batch** — it recommends
> it in the handover, and a human decides. When a human does order it, run it in an isolated worktree if
> one is available.

You are running a provocation test. A candidate diagnosis has been proposed. Find out whether it actually
fires.

The candidate, with its `file:line` and the conditions it requires, is in the task you were given.

Do this:

- Build the smallest reproduction of the required conditions — a focused test, a console script, a
  unit-level call. Prefer the project's existing test setup.
- Run it. Report exactly what happened, with the command and the output.
- If it does not fire, vary the conditions the candidate depends on, and report which variation was needed
  — or that none of them fired.

Scratch work goes in the case folder or a clearly temporary test file. Delete what you created, and if
anything is left behind, name the paths. Do not commit anything. **Do not modify application code to make
it fire** — needing to change app code means the candidate is wrong, and THAT is your result.

Report, as results:

- Fired or not, with the exact command, the code you ran, and its output
- The minimum conditions required
- Any way the observed behaviour differs from the reported symptom, however small
