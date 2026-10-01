---
summary: The spec lens — whether the change builds the thing that was asked for.
read_when:
  - Running the spec lens
---

# Spec

Every other lens judges the code as written. This one asks whether it is the right code at all. A change
that follows every convention and implements the wrong thing passes expression and fails here — and this is
the category a human reviewer catches, because a human knows what was wanted.

## Find the intent first

Take the first of these that exists, and say which you used:

1. A **Basecamp card** or issue referenced in the branch name, a commit message or the pull request body.
   Read it, including the comments — the requirement frequently moves in the thread rather than the body.
2. The **pull request description**, where it states behaviour rather than narrating the diff.
3. The **commit bodies**. The house standard puts the why there, so a branch's messages are a specification
   written by the author.
4. A **wireframe**, spec or design note in the repository — `docs/`, `.scratch/`, anything matching the
   feature name.
5. **What the user tells you**, if you ask.

**If none of these exists, stop and say so.** Report that the spec lens did not run and why. Do not
reconstruct the intent from the diff and then check the diff against it — that is a tautology dressed as a
review, and it will agree with anything.

## What to check

- **Every stated requirement has code.** Walk the intent clause by clause and find what implements each.
  The requirement with nothing behind it is the finding, and it is the one most worth catching.
- **Every behavioural claim has a test**, and the test would fail without the change. A test asserting what
  the code already did before is worse than none — it reports success forever.
- **The code does no more than was asked.** Scope that arrived uninvited is a finding: it was not specified,
  so it was not thought through, and it will be reviewed by nobody.
- **The edge cases named in the intent are handled.** A card saying "unless the member has already been
  invoiced" is a requirement, not colour.
- **Where the implementation diverges from what was described, the divergence is deliberate and recorded.**
  Often it should be — the spec was written before the code was understood. What is missing is the note
  saying so, in the commit body or on the card.
- **The stated non-goals are respected.** "We are not changing the export for now" is a constraint.

## Do not flag

- Requirements the intent does not carry. You are checking against what was asked, not against what you
  would have asked for.
- Implementation choices the spec left open. How is the author's call; what is the spec's.
- Anything the other lenses own. Wrong logic is correctness; unclear naming is expression; a missing
  `ORDER BY` is guarantees. Here, only the gap between intent and behaviour.
- A spec that has plainly been superseded, where the code is the newer decision. Note it and move on.

## Reporting

Each finding names **the requirement** and **what is missing or different**, with the source quoted. Where
the requirement is met, say nothing — a spec lens that reports its passes buries its failures.

Close with the shape of it: how many clauses you checked, how many have code, how many have a test that
earns its keep.
