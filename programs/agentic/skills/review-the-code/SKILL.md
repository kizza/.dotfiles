---
name: review-the-code
description: Runs an adversarial code review loop that spawns independent reviewer and fixer subagents, iterating until only nitpicks remain. Scores findings by confidence, fixes real issues, and re-reviews with fresh eyes — all internal, no GitHub comments. Use when asked to review code, self-review, adversarial review, or polish code before pushing
---

# Review the code

Adversarial review loop: reviewer finds issues → fixer resolves them → fresh reviewer verifies → repeat until clean.
All findings and fixes happen locally — nothing is posted to GitHub.

## Reference Files

| File | Read When |
|------|-----------|
| `references/review-perspectives.md` | Spawning reviewer subagents — describes each review angle and what to look for |
| `references/confidence-scoring.md` | Scoring findings — rubric, thresholds, and false positive exclusions |

## How It Works

This is a fully autonomous process — the user is not involved until the review is complete or the manager needs help with something it can't resolve on its own.

The **manager** (you) orchestrates the loop between two roles:

- **Reviewer subagents** — spawned with fresh context, no knowledge of how the code was written. They return scored findings.
- **Fixer subagents** — receive the filtered findings and make targeted fixes.

The manager decides everything dynamically: how many reviewers to spawn, how many fixers to spawn, whether to loop again, and when to escalate to the user.
No numbers are hardcoded — scale to the size and complexity of the change.

## Workflow

### Phase 1: Scope the Review

1. **Determine what to review** — default: all changed files vs the base branch
   - `git diff --name-only {base_branch}...HEAD` for the file list
   - `git diff {base_branch}...HEAD` for the full diff
   - If the user specifies a narrower scope (specific files, a directory), use that instead
2. **Read CLAUDE.md and AGENTS.md** if they exist — these inform the compliance review agent
3. **Read the diff** to understand the scope and nature of changes

### Phase 2: Review

Load `references/review-perspectives.md` for the detailed instructions to give each agent.

**Decide how many reviewers to spawn** based on the scope of changes:
- **Small change** (1-3 files, < 100 lines) — 1 subagent covering all perspectives (bug scan, compliance, readability) in a single pass
- **Medium change** (4-10 files, 100-500 lines) — 2 parallel subagents (one for bugs/logic, one for compliance/readability)
- **Large change** (10+ files, 500+ lines) — up to 3 parallel subagents, each with a dedicated perspective:
  - Bug & Logic Scanner
  - Standards & Compliance Auditor
  - Fresh-Eyes Readability Reviewer

These are guidelines, not rules — use judgment.
A 2-file change touching critical auth code may warrant 3 reviewers.
A 20-file rename refactor may only need 1.

Each subagent receives the diff, the list of changed files, and any relevant CLAUDE.md content.
Subagents must not see each other's findings — independent review is the point.

Each agent returns a list of findings, each with:
- **File and line range**
- **Category:** bug, security, logic, style, readability, compliance, performance
- **Severity:** critical, major, minor, nitpick
- **Confidence score:** 0-100 (see `references/confidence-scoring.md`)
- **Description:** what's wrong and why it matters
- **Suggested fix:** concrete description of what to change

### Phase 3: Score and Filter

Load `references/confidence-scoring.md` for the rubric and false positive list.

1. **Collect** all findings from the 3 reviewer subagents
2. **Deduplicate** — if multiple agents flagged the same issue (same file, within 3 lines), keep the highest-confidence version
3. **Filter** — discard findings with confidence below 70
4. **Classify remaining findings:**
   - All nitpicks or empty → **stop, review is clean** → go to Phase 6
   - Any critical/major findings → **must fix** → go to Phase 4
   - Only minor findings → use judgment: fix if straightforward, otherwise stop

### Phase 4: Fix

1. **Group findings** by file proximity and logical relationship into fix batches
2. **Decide how many fixer subagents to spawn:**
   - 1-2 simple findings in the same area → 1 fixer subagent
   - Multiple findings across independent files → parallel fixer subagents, one per file group
   - Complex findings requiring careful thought → fewer fixers working sequentially so each can verify before the next starts
3. Each fixer receives:
   - The specific findings to address (file, line, description, suggested fix)
   - The current file contents
   - Instructions to make minimal, targeted changes — fix exactly what was flagged, nothing more
4. **After fixes are applied**, verify:
   - Run project lint/test commands if available
   - If tests fail, the fixer should address the failure before returning

### Phase 5: Re-Review

Spawn **new reviewer subagent(s)** with fresh context — no knowledge of the previous review or fixes.

Scale the re-review the same way as Phase 2: if the fixes were small and localized, one reviewer is enough.
If the fixes were extensive or touched many files, use more reviewers.

Each agent receives:
- The updated diff (`git diff origin/{base_branch}...HEAD`)
- CLAUDE.md content
- A focused brief: "Review this diff for bugs, logic issues, compliance, and readability. Return scored findings."

**Evaluate the results:**
- No findings above threshold → **done** → go to Phase 6
- New findings exist → return to Phase 4 (fix) then Phase 5 (re-review)
- Same findings keep recurring (agent is going in circles) → **escalate to user**

There is no hard iteration cap.
Stop when findings degrade to nitpicks.
If the loop isn't converging (same issues reappearing, or fixes introducing new issues of similar severity), ask the user for guidance rather than looping forever.

### Phase 6: Report

Present a summary to the user:

```
## Review Complete

**Rounds:** {N} review cycles
**Findings:** {total} found, {fixed} fixed, {filtered} filtered as false positives
**Changes:** {files_changed} files modified

### Fixed Issues
1. [{severity}] {description} — {file}:{line}
2. ...

### Remaining (nitpicks, not fixed)
1. [{severity}] {description} — {file}:{line}
2. ...
```

If the user wants to proceed, they can commit and push.
The skill does not commit or push automatically.

## When the Manager Should Escalate

Ask the user for help when:
- A finding is ambiguous — could be intentional or a bug, and there's no way to tell from the code alone
- The fix for an issue would require architectural changes or touching many files outside the diff scope
- Two reviewer rounds flagged the same issue and the fixer couldn't resolve it
- The reviewer and fixer disagree (fix introduced a new issue of equal or higher severity)
- A finding touches business logic where the "correct" behavior isn't clear from code or docs

## Anti-patterns

- Reviewer subagents must not see each other's findings �� independent review is the whole point
- Fixer must not add features, refactor, or "improve" code beyond the flagged issues
- Do not fix nitpicks — they are informational only
- Do not commit automatically — the user decides when to commit
- Do not post to GitHub — this is an internal review
- Do not involve the user during the loop — only escalate when genuinely stuck (see escalation criteria above)
- Do not hardcode agent counts — scale reviewers and fixers to the size and complexity of the work
- Do not loop more than needed — if the re-reviewer returns only nitpicks, stop
