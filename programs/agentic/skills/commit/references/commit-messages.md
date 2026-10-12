# Commit messages

A message is read by someone reconstructing a decision months later, with the diff beside them. The
subject tells them what operation was performed; the body tells them why it was worth performing.

## Subject

- **A label, at 50 columns hard.** Imperative, sentence case, no full stop.
- **Name the operation, not the reasoning behind it** — `Extract`, `Introduce`, `Rename`, `Move`,
  `Use`. The why belongs in the body, if anywhere.
- **Name the artefact, spelled as the code spells it.** `Extract classification from
  FundingSourceAdapter`, never "extract funding source adapter classification". The artefact goes
  bare in the subject — no backticks there.

## Body

- **A body only when it earns one.** What changed is the subject's job; the body carries why, and
  what a reviewer would otherwise have to reconstruct.
- **Wraps at 72 columns.** The 120-column rule for code comments does not reach here. `textwidth=72`
  enforces it in the editor, but a message written with `-m` or a heredoc bypasses that — wrap it
  yourself.
- **Bullets beat paragraphs.** One line per decision or trade-off. Reach for prose only when the why
  needs a sentence to hold together.
- **Every code mention is backticked.** A domain word used as prose stays lowercase (`sah`); inside
  an identifier it keeps its casing (`Finance::SAH::ClaimCSVTotalsRow`).
