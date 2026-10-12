---
summary: The history lens — whether a branch of several commits reads as a series a reviewer can trust, one commit at a time.
read_when:
  - Running the history lens
---

# History

A branch read commit by commit is judged at every stop, not just at its tip. Each commit makes claims — in
its code, its specs and its message — about the state of the system at that point, and a reviewer stepping
through takes them at their word. This lens checks that every stop holds up on its own.

## What to look for

- **A promise one commit early.** Copy, a comment or an interface describing behaviour a later commit
  delivers. Reorder so the behaviour lands first, or fold the promise into the commit that keeps it.
- **A commit red at its own stage.** Specs that only pass once a later commit lands, or a call to something
  not yet defined. Read the commit's own diff against its parent, not the branch's.
- **A body that says something untrue.** Commit bodies are a specification (see `spec.md`), and they can be
  wrong. Check each claim against the commit's diff — which job, which path, what is excluded.
- **Preparation after the change that needs it.** An extraction, rename or new method used before the
  commit that introduces it.
- **Urgencies bundled.** A fix that could ship today held behind riskier work in the same branch. Name where
  it would split; whether to split is the author's call.

## Do not flag

- Message format a hook or CI enforces.
- Granularity taste where each commit is already one reviewable idea.

## Severity

- **Major** — a commit red at its own stage, or a body that states something the code does not do.
- **Minor** — a promise one commit early, preparation out of order, urgencies bundled.
