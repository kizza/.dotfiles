---
summary: Has this presented before — reported, decided, or fixed
read_when:
  - You are the chart review agent on a diagnose case
---

# Chart Review

Read the house rules first: `programs/agentic/skills/diagnose/references/briefs/shared.md`

`results_file: chart-review.md` — id prefix `CH`

You are reviewing the chart: has this presented before, and did anyone record what is supposed to happen?

Use the project's support tracker and its history. Where that is Basecamp, use the `basecamp` skill.

If `{case_dir}/triage-results.md` exists, read it. Triage already ran one search of the tracker and one
of the repo's history; its `TR` results stand and you go past them rather than over them.

**Do not read `{case_dir}/triage.md`.** That file holds triage's provisional read, and it is kept from you
on purpose. Your job is to find what the team actually decided, not to find support for what triage
guessed.

Do this:

- Search for the symptom in the reporter's words, then again in the team's words. Try the feature name,
  the error text, the record type, the state, the amount. One phrasing is never enough — the reporter's
  vocabulary is rarely the team's.
- Check the card's own project and board for neighbours: cards immediately before and after it, cards in
  the same column, cards on the same feature.
- Find duplicates and near-duplicates, including presentations by OTHER patients. Report each URL and what
  it concluded.
- Find the intended behaviour. Messages, documents, and comments where someone DECIDED how this is meant
  to work. This is the evidence that separates a bug from a feature request, and it usually lives in a
  message rather than in the code. Quote it with its URL.
- Find prior attempts: cards or comments describing a fix, a workaround, or an explicit decision not to
  fix. Note whether anything shipped.
- Search the repo's history over the same ground: commits and pull requests mentioning the feature or the
  symptom, reverts, and commit messages describing this behaviour as deliberate.

Report, as results:

- Duplicate and adjacent cards, with URLs and their conclusions
- Any documented statement of intended behaviour, quoted, with its URL
- Prior fixes, workarounds, and decisions not to fix
- Whether this is a first presentation, a recurrence, or a known issue

Do NOT:

- Comment on, move, assign, or otherwise change any card
- Assume an old card's conclusion was correct — report what it concluded, not that it was right
- Stop at one search phrasing
