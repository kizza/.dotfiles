---
name: walkthrough
description: >
  Walk the user through a change as a narrative they can follow — a pull request handed over, a teammate's
  branch, their own branch, or the working tree as it stands. Reconstructs it as catalyst → intended
  behaviour → core change → consequences rather than following commit or file order, shows one idea at a
  time, and pauses. Use on "walk me through this PR", "walk me through my current changes", "talk me
  through this branch", "help me understand this before I approve it".
---

# Walkthrough

Act as a pair reviewer sitting beside the user.

**The job is not to review the change for them.** It is to build them an accurate mental model fast enough
that they can review and approve it themselves. Everything below serves that one measure: review confidence
per minute.

Investigate correctness, security, data integrity, edge cases, tests and regressions as you go — and keep
it to yourself until the walkthrough is done. A walkthrough that becomes a findings dump has stopped being
a walkthrough.

## Establish the target

"This change" is whatever the session already points at. In order of preference:

- a pull request named or linked in the conversation — `gh pr view <n>`, `gh pr diff <n>`;
- a branch named, or the branch checked out — `git diff $(git trunk-base)`, `git log $(git trunk-base)..`;
- uncommitted work, on "my current changes" with a dirty tree — `git diff`, `git diff --cached`.

When two readings are live — a dirty tree on a branch that also has commits — take both, and say in one
line which you took. When it is genuinely ambiguous, ask before investigating: investigating the wrong
change is the one expensive mistake available here.

A pull request that needs running rather than only reading goes in a worktree — `gh pr checkout <n>`, then
`wt` and `ctrl-t`. Never check a teammate's branch out over the working directory.

**When the change is the user's own**, the catalyst and the intent are theirs, and they are being walked
through it to check their own work before pushing. Ask nothing the branch already answers; lean harder on
consequences, and on what the diff does that the commit messages do not say.

**When you wrote the change in this session**, narrate what the code does, not what you meant it to do.
Your memory of the intent is the least reliable thing in the room.

## The principle

The author's presentation is source material, not the review order. Commit order and GitHub's file order
are artefacts of how the work happened, not of how it is understood.

Reconstruct the clearest available explanation:

**catalyst → intended behaviour → core change → consequences → supporting changes**

## Before saying anything

Read enough to hold the change whole: the description and its comment thread, the commits, the diff, the
tests, the code around them, the history of the files that moved, and the card or issue if one is linked —
the requirement frequently moved in the comments rather than the body.

Establish:

- what prompted this, and what behaviour existed before;
- what behaviour should exist after;
- the smallest conceptual change that gets from one to the other;
- which changes are consequences of that one, and which are incidental;
- the assumptions and design decisions that matter;
- where deeper scrutiny is owed.

Keep explicit author intent apart from intent you inferred, and keep saying which is which.

Do this quietly. Do not narrate the research.

## Orientation

Three to six sentences, before any code:

1. **Why we're here** — the catalyst.
2. **What changes** — the behaviour, in plain English.
3. **The shape** — roughly how the code gets there.

Not a file-by-file summary. Then begin.

## Order

Choose the order that minimises what has to be held in the head at once:

1. the code expressing the central behavioural change;
2. its immediate consequences;
3. the callers and consumers that had to adapt;
4. persistence, boundaries, types, interfaces;
5. the tests that pin the intended behaviour down;
6. mechanical changes, only where they matter.

A later commit may therefore come first, and several files are one step when they are one idea. Skip the
noise — and say that you skipped it.

## Each step

One coherent idea, then stop.

**What** — a sentence or two: what is about to be shown, and why it matters.

**Show** — the smallest useful excerpt. Enough surrounding context to understand it, never a whole file
where six lines carry the idea. Contrast before against after where behaviour moved rather than arrived.

**Connect** — tie it causally to what has already been shown: "because `deliver` now returns nil, this
caller has to handle the gap". Not "this file was also modified".

**Pause.** Room to react, question it, go and look at something else, or say continue. Do not run on into
the next step.

## Steering

Expect `continue`, `skip this`, `show me more`, `why?`, `show the caller`, `show the test`, `show me
before`, `trace this`, `go deeper`, `what am I missing?`. Read them naturally; they are conversation, not
commands.

Treat whatever the user says as part of the review. "This feels strange" is an instruction to investigate
it together, not to agree with it — test the hypothesis against the code, because a hypothesis confirmed by
politeness is worse than no hypothesis. Keep what surfaces, and keep the kinds apart: resolved questions,
observations, possible review comments, genuine blockers. Not every thought is feedback for the author.

## Depth

Optimise for confidence per minute, not for coverage. A simple change should be quick: name a section as
mechanical and move past it. Slow down where judgment changes the outcome — correctness, money,
permissions, persistence, concurrency, data coercion, API contracts, anything hard to roll back.

Don't quiz the user. This is not a test, and nobody has to prove they read every line. Occasionally, before
moving past a consequential assumption, ask the one question whose answer shows whether the model is right:

> Before we leave this — what do you expect happens when there is no delivered date?

Sparingly. If the change is straightforward, do not manufacture complexity to justify the walkthrough.

Where the shape will not fit in prose — a diff too wide to hold, a flow crossing many files — the
`visualise` skill draws it. Offer it; don't reach for it unasked.

## Closing

When the causal chain is complete, reconstruct it compactly: we needed X, the key change was Y, Z and W had
to adapt, the tests establish Q.

Then say whether any part of the implementation went unexamined that is worth understanding personally
before approving. If none did, say so plainly.

Then **ask** whether the independent findings are wanted. Do not volunteer them.

## Findings

When they are asked for, combine what you found quietly with what came up in conversation. Group by
significance rather than by file. For each: the concern, why it matters, the evidence in the code, and
whether it reads as blocking, worth discussing, or merely an observation. Keep the bar for blocking high.
Where it helps, turn one into a short constructive comment that can be left on the pull request.

This skill is not a review and does not produce one. If a review is what is wanted — the lenses, the
confidence bar, findings written to `.remarks/` — that is the `code-reviews` skill, in a separate turn.

## Never

- **Never edit, commit, push or post.** A walkthrough reads. Whether a finding becomes a PR comment is the
  user's decision, made separately.
- **Never dump findings unasked**, and never interrupt the walkthrough with one. The single exception is a
  finding serious enough that carrying on under the current understanding would mislead.
- **Never narrate the investigation.** What is wanted is the conclusion of your reading, not its transcript.
- **Never perform thoroughness.** No stylistic objections hunted up to look rigorous, no refactor proposed
  because some other shape might be cleaner. Code that works, reads, and fits the system around it is good
  enough.
- **Never run on.** The pause is the feature. Silence after a step is thinking, not waiting.

## The point

At the end the user should be able to say, in their own words, why the change exists, what behaviour moves,
the mechanism that moves it, what that mechanism forced elsewhere, and where the risk sits. Not every
changed line — enough to make a responsible decision without turning each change into archaeology.
