---
name: code-reviews
description: >
  How code is reviewed here — the lenses to read it through, the bar a finding has to clear, and where
  findings go. Load whenever review is in the air: "review this", "review my branch", "review this PR",
  "look over these changes", a pull request handed over to read, or before calling a change finished.
  Read-only: findings become remarks, and nothing is edited, committed or posted.
---

# Code reviews

**This is context, not a pipeline.** It does not run a review — it tells you how to do one, and hands you
the lens to read the change through. Load it, take what the change warrants, and then review in this
conversation. Reach for agents only where a change is genuinely too big for one context.

Read `README.md` first for the intent: why review is split into lenses, why the reviewer never edits, and
how findings reach `.remarks/`.

## Reference files

| File | Read when |
|------|-----------|
| `README.md` | Always, first — the design and the protocol |
| `lenses/expression.md` | Reading for how it reads: naming, comments, simplicity, tests |
| `lenses/guarantees.md` | Reading for what a primitive promises and where the code over-trusts it |
| `lenses/spec.md` | Reading for whether it builds what was asked |
| `lenses/history.md` | Reading a multi-commit branch as a series, commit by commit |
| `references/pull-request.md` | The target is a pull request, or a branch that is not yours |
| `references/confidence.md` | Deciding whether a finding is worth a remark |

## Reviewing

**1. Establish the target.** Default to the branch's commits ahead of its upstream plus the working tree.
A pull request, a ref range, a path or a directory if one is named. Do not guess — if it is ambiguous, ask.
If it is a pull request or someone else's branch, read `references/pull-request.md` now.

**2. Read `REVIEW.md`** at the repository root if it exists, and the `CLAUDE.md` files covering the changed
paths. `REVIEW.md` outranks everything here on severity, skips and repo-specific checks.

**3. Choose the lenses, and say which and why** in one line before starting. Choose by what the change is,
not by habit — an unwanted lens costs attention and returns noise:

- **Correctness** — anything with behaviour in it. Run `/code-review`, which hunts bugs and verifies them
  against the code before reporting. Do not hand-roll it.
- **Expression** — almost always. Cheap, and it is the house standard.
- **Guarantees** — new or changed models, migrations, queries, collections, times, money, background jobs,
  serialisation, anything concurrent. Skip it for a pure rename or a copy change.
- **Spec** — whenever the intent is written down: a Basecamp card, an issue, a commit body, a wireframe.
  Skip it and say so when there is nothing to check against.
- **History** — a branch of more than one commit that will be read commit by commit. Skip it for a single
  commit or a branch that will be squashed.
- **Security** — run `/security-review` when the change touches authentication, authorisation, user input,
  file handling, or anything reaching a log or an external service.

**4. Read the chosen lens files and review here, inline.** One lens at a time, finishing each before the
next, so the categories do not compete for attention. Say which lens you are on as you go.

Spawn agents only when the change will not fit one context — many files, or a diff long enough that holding
it alongside the lenses would crowd out the reading. Then it is **one agent per lens, one pass, no loop and
no fixer**, each handed the diff, the changed-file list, the relevant `CLAUDE.md` and `REVIEW.md`, and its
own lens file. Give each brief this line verbatim:

> Perform this review directly. Do not invoke `/code-review`, `/security-review`, the `code-reviews` skill
> or any other review skill, and do not spawn agents.

**5. Hold each finding to the bar.** Apply `references/confidence.md`: verified against the code, not
inferred from naming, and discarded below 70. Two lenses flagging one line from different angles are two
findings; two flagging the same thing are one.

**6. Write each surviving finding as a remark** against the file and line it concerns:

```bash
remarks add path/to/file.rb:42 <<'EOF'
One or two sentences: what is wrong, and what it costs. Concrete, not a category.
EOF
```

On a branch of more than one commit, end the remark with the commit that introduced the line — `Fold into
<sha>.` — so the fix lands in that commit rather than on the end.

**7. Report** — the tally first, then findings grouped by lens, each as `file:line` and one line. Name the
lenses you ran and the ones you skipped. Close with the count of remarks written and that `remarks list`
now holds them.

## Never

- **Never edit, commit, push or post.** Not on your own branch, not on anyone's. Findings go to remarks;
  applying them is a separate turn through the `remarks` skill.
- **Never loop.** One pass per lens. Re-reviewing after fixes is a new review, asked for by a human.
- **Never fan out by default.** The expense of a review is agents re-reading the same diff. One context
  reading carefully beats four contexts reading the same thing shallowly, and it is the common case.
- **Never let a brief spawn a reviewer.** Review skills trigger on the words a review brief is made of, so
  a lens that re-invokes one cascades. That is what the verbatim line in step 4 is for.
- **Never flag what CI already catches.** Formatting, imports, type errors, lint. A round trip for nothing.
- **Never review unchanged lines.** Pre-existing problems are out of scope unless the change is what made
  them load-bearing — and then the finding is about the change.
