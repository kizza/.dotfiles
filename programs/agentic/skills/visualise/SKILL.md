---
name: visualise
description: >-
  Build the structure of something that will not fit in your head from prose — nested financial
  data, money flows and reconciliations, an unfamiliar subsystem, a large diff, a pull request
  that needs colourised excerpts and a flow chart rather than paragraphs. Produces either a
  self-contained HTML page for comprehension, or GitHub-flavoured markdown when the artefact
  lives in someone else's UI. Fires when asked, or when Keiran says he cannot follow something —
  never to dress up an answer that was fine as text.
---

# Visualise

Prose asks the reader to hold every relationship in working memory at once. Past about four moving
parts that fails, and re-reading does not help — the paragraph is the problem, not the reader.
This skill stops describing the structure and builds it.

The test is never "does it look good". It is: **can he now answer a question he could not answer
before?** Name that question in one sentence before writing anything. Everything on the page either
serves it or comes off.

## When it fires

- He asks: `/visualise`, "draw me", "show me how this fits together", "explain this properly".
- He says he cannot follow something — "I don't get how this works", "this is doing my head in",
  "I've read this three times".
- He asks for a pull request description and the change moves data, money, or control between
  things.

**Never otherwise.** A four-row table belongs in the terminal. Never truncate a terminal answer to
a summary and push the substance into a browser tab — that swaps an answer he can read for a tab he
has to go and open. Never open a browser from a worktree or background agent; he is looking at a
different one. Write the file and print the path.

## Two outputs, and the choice is not stylistic

| Output | Use when | Artefact |
|---|---|---|
| **Page** | He needs to *look* at it — zoom in, follow an edge, come back tomorrow | Self-contained HTML in `~/.agent/diagrams/`, descriptive filename |
| **Prose** | The artefact lives in someone else's UI — PR body, Basecamp, a review comment | GitHub-flavoured markdown, inline or in the PR |

Getting this wrong wastes the work. An HTML page linked from a PR body is a file nobody else can
open. A markdown wall in the terminal is the thing he asked you to stop doing.

Read `references/pull-request.md` before writing any PR body. Read `references/page-scaffold.html`
before writing any page.

## Facts before pictures

A diagram is a claim about how something works, made in a form that is hard to hedge. That is the
whole value, and it is why an invented one is worse than no diagram.

- Read the actual code, the actual data, the actual git history. Every box, edge, and figure traces
  to something you read.
- Cite as you go — `file:line`, a command's output, a ledger id, a column name.
- If you could not establish something, draw it as unknown and say so. A box labelled
  "unverified — no caller found" is useful. A confident wrong arrow costs a day.
- Never invent rationale. "Why" comes from a commit message, a comment, or him — not from what
  would make a tidy story.

## Composition

**One figure, one claim, and the caption states it.** "Payments retry three times before the
ledger is touched" is a caption. "Payment flow" is a label.

**Summary before detail, always.** The first screen carries the answer. Detail sits below it or
behind `<details>`. If he has to scroll to find out what the page is telling him, the page failed.

**Three levels, never more on one screen.** The whole → its parts → the leaf rows. Parts visible,
leaves collapsed. Nesting is exactly what he could not hold in his head; reproducing all of it at
once reproduces the problem in a nicer font.

**Depict the mechanism, not its name.** The path a request takes through the cache says something.
A box labelled "cache" says nothing. Label every arrow — `writes`, `invalidates`, `polls every 30s`.
An unlabelled arrow only claims "related somehow".

**To compare two options, draw the difference** — the edge each one adds or removes. Not two
complete diagrams side by side for the reader to diff by eye.

## Choosing the representation

| Content | Representation |
|---|---|
| Flow, pipeline, state machine, decision tree, sequence, ER/schema | Mermaid — `references/mermaid.md` |
| Money moving between accounts, fee waterfalls, reconciliations, allocations | `references/money.md` — mostly tables and CSS bars, **not** Mermaid |
| Text-heavy structure, module internals, "what each part does" | CSS grid cards |
| Comparison, audit, status matrix | Semantic `<table>` |
| 15+ elements | Hybrid: a 5–8 node Mermaid overview, then detail cards |
| Linear history | CSS timeline |

Mermaid is for connected things. Reaching for it on tabular data produces a worse table.

## Look

The scaffold ships a teal palette as an example. **Re-theme every page** — anchor the direction to
the content's domain: ledgers and reconciliations read as data-dense; architecture as blueprint;
CLI and infra as terminal; a recap as editorial. Plan 4–6 named hex values and one font pair before
writing CSS.

Avoid the defaults that mark a page as unconsidered: Inter or system-ui alone for body text; violet
and fuchsia Tailwind accents (`#8b5cf6`, `#7c3aed`, `#a78bfa`); purple-to-blue gradient heroes;
emoji section markers; everything centred; uniform large border-radius. Bias neutrals toward the
accent hue — pure mid-grey reads as nothing was chosen.

Structure must encode something true: numbered markers only when order matters, eyebrow labels only
when they classify, dividers only at real seams.

## Before delivering

- The page states its question, and answers it in the first screen.
- Every figure and path traces to something you read; nothing was invented to complete a pattern.
- Complete HTML document, no console errors, no horizontal overflow at desktop width.
- Both colour schemes hold up, or single-theme was a deliberate choice.
- Tables keep their rows and columns and wrap long text; wide content scrolls in its own container.
- Every Mermaid diagram sits in a `.diagram-shell` with working zoom, and a `<figcaption>` that
  states the claim.
- Numbers use `tabular-nums` and a stated convention — see `references/money.md`.
- Print the path. Do not open a browser unless this is the session he is watching.

## References

| File | Read when |
|---|---|
| `references/page-scaffold.html` | Writing any HTML page. A working page — strip the demo, keep the shell |
| `references/mermaid.md` | Writing any Mermaid diagram. The gotchas are why diagrams silently break |
| `references/money.md` | Anything with amounts in it |
| `references/pull-request.md` | Writing a PR body or a comment that lands in GitHub |
