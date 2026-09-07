# Money

Financial structures are the reason this skill exists. They are hard to read as prose for a
specific reason: every figure is defined by its relationship to other figures, and prose can only
present one relationship at a time.

## State the frame once, at the top, before any number

A page of amounts with an unstated convention is worse than the paragraph it replaced — it looks
authoritative and cannot be checked. Before the first figure, state:

- **Currency**, and whether mixed currencies appear anywhere on the page.
- **Unit** — dollars or cents. If the source stores cents, say so and say which you are showing.
- **Sign convention** — what a negative means here, and whether it renders as `-1,234.00` or
  `(1,234.00)`. Pick one and never mix them.
- **Period**, as literal dates, not "last month".
- **Gross or net**, and net of what.
- **As at** — the timestamp the figures were drawn, and from where.

## Lead with the invariant

A money explanation exists because something is meant to balance. Put the check in the first
screen, worked, with its result:

```
Opening        12,340.00
Credits       + 4,000.00
Fees          −   137.50
Adjustments   −     0.00
              ──────────
Closing        16,202.50    ✓ matches ledger balance (accounts.balance_cents, drawn 2026-09-07)
```

If it does not tie, that is the most important thing on the page. Show the residual, say so
plainly, and do not bury it below the detail. **Never silently round to make a total balance.**
Rounding residuals get their own line.

## Amounts belong on the edges

In a flow, the boxes are the accounts and the arrows are the movements. The amount, the rate, and
the trigger go on the arrow — `2.5% platform fee`, `settles T+2`, `on invoice paid`. An arrow
labelled only with a direction has explained nothing.

Mermaid handles this badly past a handful of nodes and cannot align decimals. Use it only when the
question is genuinely about *topology* — which account can reach which. When the question is "how
much, and where did it go", a table or a waterfall beats it every time.

## The waterfall is the highest-value money figure

"How did we get from X to Y" is the most common thing that will not fit in a paragraph. It is a
CSS bar chart, not Mermaid: a baseline, one bar per contribution sized to its magnitude, running
total carried along, positive and negative distinguished by position and colour. Order the bars the
way the money actually moved, not largest-first.

## Three levels, and the leaves are collapsed

The total → its components → the leaf rows. Components always visible, leaves behind `<details>`.
For nested entities or allocations, a tree table with the parent total on the parent row and
children indented one level, each child carrying **both** its amount and its share of the parent:

| Account | Amount | Share |
|---|---:|---:|
| **Platform revenue** | **48,200.00** | 100.0% |
| ⤷ Subscription | 31,330.00 | 65.0% |
| ⤷ Transaction fees | 12,050.00 | 25.0% |
| ⤷ Other | 4,820.00 | 10.0% |

Percentages without amounts hide magnitude; amounts without percentages hide proportion. Nested
financial data needs both, or the reader does the arithmetic in their head — which is the thing
they asked you to stop making them do.

## Typesetting numbers

```css
.amount {
  font-variant-numeric: tabular-nums;
  text-align: right;
  font-family: var(--font-mono);
  white-space: nowrap;
}
.amount--negative { color: var(--negative); }
.amount--total    { font-weight: 600; border-top: 1px solid var(--border-bright); }
```

- Right-align every numeric column. Fixed decimal places within a column, always.
- Thousands separators, always. No scientific notation, ever.
- Colour carries **sign**, not emphasis. Keep the in/out pair distinct from the page accent hue, and
  never make the accent green or red.
- Column headers name the unit: `Amount (AUD)`, not `Amount`.

## Cite every figure

Each number gets a source: a `file:line`, a query, a ledger entry id, a column in the source data.
Derived numbers show their arithmetic — `12,050.00 = 482,000.00 × 2.5%` — because a derived number
with no visible derivation is indistinguishable from a guess.

Where a figure could not be established, render it as `—` with a note. Never interpolate a
plausible amount to complete a table. In a financial explanation an invented number is not a
cosmetic flaw; it is the whole failure.
