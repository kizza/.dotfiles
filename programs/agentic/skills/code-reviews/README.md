# Code review

What review means here, which lens to reach for, and why the code is never edited by the reviewer.

A review is a set of **lenses**, chosen deliberately and run once each. A lens is read-only. What it finds
becomes a remark against the line it found it on, and the remark is addressed later — by you, or by the
`remarks` skill, in a turn of its own. Nothing in this directory writes code.

The skill is `code-reviews`, plural, because `code-review` singular is the built-in's own name and
shadowing it would cost us the correctness lens below.

That separation is the whole design. It is what makes reviewing a colleague's branch safe by construction,
what stops a reviewer marking its own homework, and what turns findings into something that accumulates
rather than scrolls past.

## Why lenses rather than one reviewer

A single agent told to find everything finds the shallowest thing in each category and stops. Worse, the
categories compete: a reviewer that has just found four naming problems has spent its attention, and the
missing `ORDER BY` goes unmentioned. Splitting by lens buys depth, and buys the ability to *not run* the
lens that does not apply — a rename refactor wants expression and nothing else.

A lens is a way of reading, not a process. The default is to read the change through each chosen lens in
one conversation, one lens at a time — an agent per lens only when the change will not fit a single
context. No loop, no fixer, no re-review: if a lens needs a second round, that says the change is not
ready, not that the review should keep spending.

## The lenses

| Lens | File | What it is for |
|------|------|----------------|
| Correctness | *not here* — `/code-review` | Logic errors, edge cases, races. Anthropic's, with its own verification pass. Do not rebuild it. |
| Expression | `lenses/expression.md` | How it reads. Naming, comments, simplicity, test clarity. The rubric is `~/.claude/CLAUDE.md`. |
| Guarantees | `lenses/guarantees.md` | What the chosen primitive promises, and whether the code leans on a promise it has not got. |
| Spec | `lenses/spec.md` | Whether this builds the thing that was asked for. |
| History | `lenses/history.md` | Whether a branch of several commits holds up at every commit, not just its tip. |
| Security | *not here yet* — `/security-review` | See below. |

Nothing here is invoked to *run* a review. The skill is loaded when review comes up, and what it carries
is the standard: which lens applies, what clears the bar, where findings land. The review itself happens
in the conversation you are already in.

**Guarantees is the one worth having.** Correctness tools look for code that is wrong. This looks for code
that is right today by accident — an order that holds because the rows happen to come back that way, a
uniqueness that holds because nothing has raced yet. Those are the defects that survive review, survive
tests, and surface in production a quarter later.

## Two lenses are deliberately absent

**Correctness** belongs to the built-in `/code-review`. It hunts bugs, verifies candidates against the code
before reporting them, takes an effort level, and runs in its own context window. A hand-rolled version of
it costs more and drifts behind it.

**Security** belongs to the built-in `/security-review` until there is evidence otherwise. A security lens
written from imagination flags the vulnerabilities that appear in articles; one written from three reviews'
worth of misses flags the ones this codebase actually has. Run the built-in first. Write `lenses/security.md`
from what it missed — most likely tenant scoping, authorisation gaps and PII reaching logs.

## Findings become remarks

Every lens writes each finding through the `remarks` CLI, against the file and line it concerns:

```bash
remarks add path/to/file.rb:42 <<'EOF'
Rows arrive unordered; the pagination below assumes stability across requests.
EOF
```

This is not a reporting detail, it is the mechanism:

- **The review is read-only** with no conditional to get wrong. There is no branch of behaviour where a
  reviewer edits a teammate's code, because no reviewer edits anything.
- **`remarks list` is the outstanding review**, whoever wrote it. An agent's finding and one you typed in
  the editor are the same kind of object and are worked through the same way.
- **Applying is a separate turn** with you in it, through the `remarks` skill, which already knows that a
  remark resolved without being addressed is a lie that outlives the branch.
- **Findings compound.** `.remarks/` feeds `remarks-retro`, so what review keeps catching turns into
  standards instead of evaporating with the session.

Remarks are untracked and local, so reviewing someone else's branch in a worktree leaves their work
untouched whatever the review concludes.

## Local branch, or a teammate's pull request

The lenses are the same either way; what changes is what the reviewer can reach. For a pull request, read
`references/pull-request.md` first — it covers getting the branch into a worktree, and the three questions a
diff cannot answer on its own. A diff shows what changed; only a checkout shows who else calls it, whether
the pattern already exists somewhere, and whether the new test fails without the change.

## Repo-local pitfalls

The lenses here are general. A repository's own recurring defects belong in a `REVIEW.md` at its root, which
every lens reads when present: what counts as blocking *here*, which paths to skip, and the checks worth
running on every change. Keep it to instructions that change reviewer behaviour — `CLAUDE.md` already carries
how the code should be written.

## What this replaced

`review-the-code`, retired. It was an adversarial loop: reviewers, then fixers, then fresh reviewers, round
and round until findings degraded to nitpicks. The design was sound and the cost was not — the loop had no
cap by construction, the same diff was read five to eight times, and two of its three perspectives were
re-deriving what `/code-review` already does. Its confidence rubric survives as `references/confidence.md`,
which was the part earning its keep.
