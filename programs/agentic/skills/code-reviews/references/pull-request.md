---
summary: Reviewing a teammate's pull request — getting it local, and the three questions a diff cannot answer.
read_when:
  - The review target is a pull request, or a branch that is not yours
---

# Reviewing a pull request

## Get the context before the diff

```bash
gh pr view <number>                  # title, body, linked issues, and the comment thread
gh pr diff <number>                  # the diff, if all you need is a read
gh pr view <number> --json files     # the file list, for scoping the lenses
```

Read the description and the thread first. The requirement frequently moves in the comments rather than the
body, and the spec lens depends on knowing where it landed.

## Get it into a worktree

A diff is enough for expression and for most of correctness. It is not enough for guarantees or spec, and
it is never enough to be confident. Put the branch somewhere it can be run:

```bash
gh pr checkout <number> --branch <branch>   # fetch the branch without moving your checkout
wt                                          # then pick it, ctrl-t makes the worktree
```

`wt` is the picker; `ctrl-t` creates a worktree for the branch under the cursor and moves you there. The
repository's post-checkout hook provisions it. If specs interfere or the branch adds a migration, the
`worktree-isolation` skill gives the worktree its own database and cache.

Never check a teammate's branch out over your own working directory. A worktree costs seconds and cannot
disturb what you had open.

## The three questions a diff cannot answer

This is the reason the checkout exists. A diff shows what changed; none of these is visible in it, and all
three produce the findings a reviewer is actually valued for.

**1. Who else calls this?** The blast radius is never inside the hunk. Grep the changed method, class and
column names across the repository. A changed signature, a narrowed return, a renamed key — each is fine in
the file it was changed in and breaks somewhere the diff does not show.

**2. Does this pattern already exist?** "We have a helper for that" is the highest-value review comment
there is, and it is invisible from a diff by construction. Search for the shape of what was written, not
its words: an existing scope, concern, serialiser or value object doing the same job. Duplication that
review misses is duplication that lives forever.

**3. Does the test fail without the change?** Revert the source hunk, leave the test, run it. A test that
passes against the old code asserts nothing and will report success for the rest of its life. This takes a
minute and catches what nothing else does.

```bash
git stash push -- <source file>   # or revert the hunk by hand
bundle exec rspec <spec file>     # it should fail, and for the right reason
git stash pop
```

Read the failure, not just its presence. A test that fails for a different reason than the change addresses
is the same defect wearing a disguise.

## Reviewing, not fixing

Everything the lenses find becomes a remark, exactly as on your own branch. Remarks live in `.remarks/`,
untracked and local, so nothing you do reaches the author's branch or the pull request. Reviewing someone
else's work is therefore safe by construction rather than by remembering.

**Do not** commit to their branch, push, or post to the pull request. If findings should reach the author,
that is a separate decision they make with you: `/code-review --comment` posts inline comments, and the
`pr` skill handles the pull request itself. Neither happens as part of a review.

## Handing the findings over

When the review is for a teammate rather than for yourself, the remarks are your notes, not the deliverable.
Summarise for a human: what the change does in a line or two, what you would want changed before merge, and
what you noticed but would not block on. Lead with the shape — "two things worth fixing, four small" — so
they know what they are walking into before the detail.
