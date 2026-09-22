---
name: session-retro
description: End-of-session retrospective that decides what the session learned and where each item belongs — a new skill, an edit to an existing skill, a memory entry, a doc/README change, or nothing. Use at the end of a substantial coding/debugging/ops session, or whenever the user asks "is there anything to turn into a skill / remember / write down from this" ("스킬로 만들 것 있나", "메모리 업데이트할 거 있어?", "what should we keep from this"). Do not use mid-task; it reviews finished work, and it should run BEFORE any narrower "draft a skill" or "save to memory" helper, because it decides which of those (if any) is the right next step.
---

# session-retro

A session usually ends with a handful of things that were hard to figure
out. Most of them should be forgotten. A few should be written down. The
mistake this skill prevents is both directions of getting that wrong:
writing a full skill for a one-off fact, and stuffing a real multi-step
procedure into a memory bullet that can't reproduce it. It also prevents
the more embarrassing failure — spending an hour hand-rolling a workflow
that an existing skill already covered.

Run this as a single pass at the end of work. Output is a short table and,
if the user agrees, the writes.

## 0. Inventory what already exists — before proposing anything

The first question is not "what should I make" but "what is already
here". List the skills currently loaded and skim any whose name overlaps
with what the session did. Grep the memory directory. Concretely:

- Skills: the skill list in the system prompt, plus `ls ~/.claude/skills`
  and `.claude/skills/` in the repo. Read the `description` of anything
  plausibly related.
- Memory: `MEMORY.md` index in the project's memory directory, plus any
  entry whose name matches a topic from the session.
- Repo docs: `docs/`, `AGENTS.md`/`CLAUDE.md`, any `*.md` the session
  touched.

If a skill for this workflow already exists and the session didn't use it,
**say so first** — that's the most valuable finding a retro can produce,
and it's a habit correction, not a new artifact.

## 1. Collect candidates

Walk the session and list every item that meets **all three**:

1. It took real effort to establish — debugging, a wrong guess corrected by
   evidence, a doc that turned out to be wrong, a hidden constraint.
2. It is specific to this project, account, vendor, or team — not
   something a web search answers in five minutes.
3. It will plausibly come up again. Once is an anecdote; the second time
   is a pattern; a third time and you're already late writing it down.

Candidates that fail any of the three go in the table as "nothing" with the
reason — it's useful for the user to see what was considered and dropped.

## 2. Classify each candidate — the decision that matters

Ask two questions of each item.

**Is it a procedure or a fact?**

- A **procedure** has ordered steps, branches, or a non-obvious mechanism
  someone would have to rediscover (a specific API needing an undocumented
  parameter, a permission that must be granted before step 3 or step 3
  silently hangs, a probe loop against a vendor). Procedures need a
  **skill** — memory bullets can't carry ordered steps, and a fact that
  says "there is a procedure" without the procedure is worse than
  nothing because it creates false confidence.
- A **fact** is a single thing that's true: an ID, a trap, a constraint,
  a decision that was made and why. Facts belong in **memory** (or a repo
  doc if the whole team needs it and it's about the code rather than the
  environment).

**Does an existing skill or doc already own this territory?**

- If yes, the answer is an **edit** — a new section in that skill, not a
  new skill that overlaps it. Overlapping skills stop triggering
  reliably; one skill with a §6 is better than two skills that both
  half-match.
- If no, and it's a procedure, it's a **new skill**. Scope it to one
  workflow. If the name needs "and" in it, it's two skills.

Then place it:

| It is… | And… | Goes to |
|---|---|---|
| a procedure | no existing skill covers it | **new skill** |
| a procedure | an existing skill covers the domain | **section added to that skill** |
| a fact about the environment/vendor/account | — | **memory entry** (user's memory dir) |
| a fact about the code, a decision, a settled design | the team needs it | **repo doc** (`docs/`, `MEMORY.md` in repo, ADR) |
| a habit correction ("use X skill next time") | — | **feedback memory** |
| anything else | — | **nothing** — say why |

Two placement questions people get wrong:

- **User scope vs project scope for a skill.** Project scope
  (`.claude/skills/` in the repo, committed) if it mentions the repo's
  files, env vars, service IDs, or vendor accounts. User scope
  (`~/.claude/skills/`) only if it would work unchanged in a different
  repo. Most session-learned skills are project scope. Be honest — a
  skill full of `<your-service>-staging-x9k2` and `+1555…` phone numbers is
  not user scope no matter how general the technique feels.
- **Memory vs doc.** If a future agent needs it but a human teammate
  doesn't, memory. If a teammate would need it to do the same work,
  repo doc. Both is fine when both are true; a pointer from one to the
  other is enough, not a copy.

## 3. Present before writing

Show the table — candidate → classification → destination → one-line
why — and stop. Include the "nothing" rows. The user decides; this skill
does not write anything on its own. Skills in a repo are committed
artifacts other people will read; memory entries shape future sessions.
Neither should appear without the user seeing the list first.

## 4. Write, following the right sub-skill

Once approved, per row:

- **New skill** — write the SKILL.md with frontmatter (`name`,
  `description` that says both *when* to use it and *when not* to, in the
  words a user would actually say — including the user's language if
  they don't work in English). If your setup has a skill-drafting helper
  with its own quality gate — some plugin ecosystems ship one under a name
  like `skillify`, a skill that turns a session's workflow into a skill
  draft and applies a "would a web search answer this in five minutes?"
  filter — run the draft through it; if not, the three criteria in §1
  are the gate.
- **Edit to existing skill** — add a numbered section matching the
  skill's existing structure; cross-link with `[[other-skill]]` where
  it hands off.
- **Memory** — one file per entry with frontmatter and a one-line pointer
  in `MEMORY.md`. Write the *why* and *how to apply*, not just the fact.
  If your setup has a memory-writing helper that enforces that shape —
  e.g. a `remember` skill that classifies each finding (durable fact /
  working note / preference / stale) and writes only to the right
  surface — use it; the shape is what matters, not the helper.
- **Repo doc** — edit in place; if the repo uses ADRs and this is a
  decision, that's the format.

For project-scope skills and repo docs: **branch and PR**, never a direct
commit to the main branch, even for docs-only changes — the repo's
review conventions apply to skills exactly as to code.

## 5. Report

Final message: what was written, where, and — if the retro turned up a
skill that already existed and wasn't used — the plain admission and the
name of the skill to reach for next time.

## When to run this automatically

By default this is manual: the user invokes it at the end of a session.
It can be wired to run on its own via a `Stop` hook in
`~/.claude/settings.json`, but that fires after *every* assistant turn,
which is far too often for a retro — most turns learn nothing. If you
want it automatic, gate it: a hook that runs only when the session's
diff touched more than N files, or only on an explicit "wrapping up"
phrase, or a scheduled run on a long interval. Whatever mechanism your
harness offers for editing hooks/settings, use that; do not turn it on
by default.

## Anti-patterns this skill exists to catch

- Writing a memory bullet that says "there's a way to test vendor X's
  config values without deploying" and no procedure — that's a fact
  pretending to be a skill.
- Writing a skill for a single API quirk ("this endpoint also requires
  an `ownerId` param") — that's a memory entry with delusions of
  grandeur.
- Making a second skill that overlaps an existing one because the
  existing one's name didn't come to mind — check §0 first, every time.
- Committing a project-scope skill straight to `main` because "it's just
  docs".
- Calling a skill user-scope because the *technique* is general when the
  *file* is full of one project's service IDs.
