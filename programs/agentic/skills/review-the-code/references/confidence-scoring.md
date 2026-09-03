---
summary: Confidence scoring rubric, thresholds, and false positive exclusion rules
read_when:
  - Scoring review findings or filtering false positives
---

# Confidence Scoring

Every finding gets a confidence score from 0-100.
The score reflects how certain the reviewer is that the issue is real and worth fixing.

## Rubric

Give this rubric to reviewer subagents verbatim:

| Score | Meaning | Action |
|-------|---------|--------|
| **0** | Not confident. False positive that doesn't hold up to scrutiny, or a pre-existing issue not introduced in this diff. | Discard |
| **25** | Somewhat confident. Might be real, might be a false positive. Couldn't verify. Stylistic issues not explicitly called out in CLAUDE.md. | Discard |
| **50** | Moderately confident. Verified as a real issue, but a nitpick or unlikely to matter in practice. Not important relative to the rest of the changes. | Discard (below threshold) |
| **70** | Confident. Real issue that was verified. Could cause problems but has workarounds or is edge-case. | Include (at threshold) |
| **75** | Highly confident. Double-checked and verified. Very likely to be hit in practice. Existing approach is insufficient. Directly impacts functionality, or explicitly mentioned in CLAUDE.md. | Include |
| **100** | Absolutely certain. Confirmed real issue. Will happen frequently. Evidence directly proves it. | Include |

## Threshold

**Discard all findings with confidence below 70.**

This is more aggressive than many review tools (which use 50).
The goal is zero false positives — it's better to miss a minor issue than to waste a fix cycle on something that isn't real.

If the threshold feels too aggressive for a specific codebase, the manager can lower it to 50 for a run.

## False Positive Exclusions

These are NOT real findings — score them 0 regardless of how they look:

**Pre-existing issues:**
The flagged code was not added or modified in this diff.
Check the diff hunks — if the line doesn't appear in a `+` section, it's pre-existing.

**Linter/compiler catches:**
Missing imports, type errors, formatting, unused variables, incorrect indentation.
These will be caught by CI. Flagging them wastes a review cycle.

**Pedantic nitpicks a senior engineer wouldn't mention:**
Subjective naming preferences, extra blank lines, comment style, import ordering.
Unless CLAUDE.md explicitly calls it out, it's a nitpick.

**Intentional suppressions:**
Code with lint-ignore comments, `// eslint-disable`, `# noqa`, `@SuppressWarnings`, etc.
The developer intentionally suppressed this — don't re-flag it.

**Intentional behavior changes:**
New functionality that changes how something works is not a bug.
If the diff adds a new parameter, changes a default, or modifies a return value, that's likely the point of the change.

**General quality concerns:**
"Should have more tests", "could use better error handling", "consider logging here."
Unless CLAUDE.md requires it, these are opinions, not findings.

**Issues on unmodified lines:**
Even if code near the changed lines has issues, if those lines weren't touched, they're out of scope.

## Deduplication

When multiple agents flag the same issue:
1. Same file, within 3 lines → likely the same finding
2. Keep the version with the highest confidence score
3. If scores are equal, keep the one with the most specific suggested fix
4. Note in the finding that multiple agents independently flagged it (increases confidence)

When two agents flag different aspects of the same code:
- These are separate findings — keep both
- Example: Agent 1 flags a null check bug, Agent 3 flags the same function as confusingly named — both valid

## Severity vs Confidence

These are independent dimensions:

- **Severity** = how bad is it if this is real? (critical → will crash, nitpick → preference)
- **Confidence** = how sure are we it's real? (0 → false positive, 100 → certain)

A critical-severity, low-confidence finding gets discarded (probably not real).
A minor-severity, high-confidence finding gets included (definitely real, just small).

The filter operates on confidence only. Severity determines fix priority.
