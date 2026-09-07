# Pull request bodies and GitHub comments

A PR body is markdown rendered by GitHub. It is not a page. **Never link to a file in
`~/.agent/diagrams/`** — nobody else can open it, and it will be dead by the time anyone reviews.

This composes with the `pr` skill and does not replace it. That skill owns pushing, the repo's
`PULL_REQUEST_TEMPLATE.md`, draft-only, and the bullet discipline (terse, one or two sentences,
more than a dozen is a smell). This file only changes **what goes inside those sections** when the
change is hard to follow in prose.

## What GitHub actually renders

Three things do real work in a PR body, and they are the reason a description can be visual at all:

**` ```mermaid ` fences render natively.** A diagram in the body, not a link to one. Use it when
the change moves control or data — a new call path, an inverted dependency, a state machine that
gained a state. Keep it under ~10 nodes; the body is not a canvas.

**` ```diff ` fences colourise.** Lines starting `-` render red, `+` green. Use it for the 5–20
lines that carry the decision — never a whole file, and never the full diff. The Files tab already
has the diff; your job is to point at the part a reviewer would otherwise skim past.

````
```diff
- charge_cents = subtotal_cents * tax_rate
+ # Tax applies after the platform fee is deducted, not before — see #4821
+ charge_cents = (subtotal_cents - platform_fee_cents) * tax_rate
```
````

**`<details><summary>` collapses.** Everything a reviewer does not need on the first read goes
inside one: the migration SQL, the full before/after table, the reasoning behind a rejected
alternative.

## Shape

Keep everything above the first `<details>` to about one screen.

1. **Why**, in bullets — the `pr` skill's rules apply verbatim.
2. **The diagram**, only if something moved. One figure, one claim, with the claim written under it
   as a sentence.
3. **The diff excerpt**, only if a decision is buried in the code where a reviewer would miss it.
4. **Before/after as a table**, when behaviour changed in ways a diff does not show — an input
   column, an old-behaviour column, a new-behaviour column.
5. **Collapsed detail**, everything else.

## Do not

- Reproduce the file tree or the diff stat. GitHub renders both, better.
- Restate what each commit did. The commits are right there, and if they need restating the fix is
  in the commits.
- Use a diagram for a change that only touched one function. The diff is clearer.
- Write more than one Mermaid diagram. If the change needs two, it probably needs splitting.
- Post a wall. The description competes with the diff for the reviewer's attention, and the diff
  should win.
