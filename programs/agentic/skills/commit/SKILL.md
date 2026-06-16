---
name: commit
description: >
  Turn a working tree into a clean commit history by grouping related changes into logical,
  reviewable commits and generating commit messages that explain why each commit exists.
---

Review the uncommitted changes, determine how they naturally group into a set of reviewable commits, then make those commits.

# Guidelines:

* Group changes by intent, not by file.
* Use the fewest commits that still clearly separate unrelated concerns.
* Do not create commits for incidental fixes made while developing the branch (typos, formatting, small corrections).
* Create separate commits when a change solves a different problem, represents an important design decision, or would reasonably be reverted independently.
- Specs covering a change MUST always be within the commit that they are covering, they are a coherent and logic change.
* Each commit should be understandable in isolation and answer:
  * What changed?
  * Why did it change?

## Commit messages should:

* Use a concise single-line subject that describes the intent of the change.
* Add a body only when it provides useful context.
* When a body is used, prefer bullet points and explain noteworthy decisions or trade-offs.

Before committing, briefly explain the proposed commit plan and why the chosen boundaries exist.

## Output

A set of commits that are ready to be pushed to the remote repository, each with a clear message and a well-defined scope.
