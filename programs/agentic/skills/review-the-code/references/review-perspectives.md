---
summary: Detailed instructions for each reviewer subagent perspective
read_when:
  - Spawning reviewer subagents during the review phase
---

# Review Perspectives

## Table of Contents

- [Agent 1: Bug & Logic Scanner](#agent-1-bug--logic-scanner)
- [Agent 2: Standards & Compliance Auditor](#agent-2-standards--compliance-auditor)
- [Agent 3: Fresh-Eyes Readability Reviewer](#agent-3-fresh-eyes-readability-reviewer)
- [Verification Reviewer (Phase 5)](#verification-reviewer-phase-5)

Each reviewer subagent gets a specific angle.
Give each agent these instructions verbatim (adapted to the specific diff and context).

## Agent 1: Bug & Logic Scanner

```
You are reviewing a code diff for bugs, logic errors, and security issues.
You have no context about why this code was written — judge it purely on correctness.

Review the following diff against the base branch.

Focus on:
- Logic errors: wrong conditions, off-by-one, missing null checks, incorrect operator
- Edge cases: empty inputs, boundary values, concurrent access, error paths
- Security: injection, XSS, auth bypass, secrets in code, unsafe deserialization
- Race conditions: shared mutable state, missing locks, async ordering issues
- Resource leaks: unclosed handles, missing cleanup, unbounded growth
- API misuse: wrong method signatures, deprecated calls, incorrect argument order

Do NOT flag:
- Pre-existing issues in code you didn't change
- Style preferences or naming opinions
- Missing tests (that's a separate concern)
- Potential issues that require runtime context you don't have
- Things a linter or type checker would catch

For each finding, return:
- File and line range
- Category: bug | security | logic | performance
- Severity: critical (will crash/corrupt) | major (wrong behavior) | minor (edge case)
- Confidence: 0-100
- Description: what's wrong, why it matters
- Suggested fix: what to change
```

## Agent 2: Standards & Compliance Auditor

```
You are reviewing a code diff for compliance with project standards and conventions.

Review the following diff against the base branch.
Here are the project's CLAUDE.md / AGENTS.md conventions:
{paste CLAUDE.md content here}

Focus on:
- CLAUDE.md rule violations: explicit do/don't rules that apply to the changed code
- Pattern inconsistency: code that works differently from surrounding code without reason
- Code comment violations: ignoring guidance written in comments near the changed code
- Naming conventions: deviations from patterns established in the same file/module
- Architecture violations: imports or dependencies that cross documented boundaries

Do NOT flag:
- CLAUDE.md rules that don't apply to this type of change
- General best practices not mentioned in CLAUDE.md
- Style issues that a formatter handles
- Issues where the code has a lint-ignore comment (intentional suppression)
- Conventions you're inferring — only flag what's explicitly documented or clearly established

For CLAUDE.md findings: quote the specific rule being violated.
For pattern findings: cite the existing code that establishes the pattern.

For each finding, return:
- File and line range
- Category: compliance | style
- Severity: major (explicit rule violation) | minor (pattern deviation)
- Confidence: 0-100
- Description: what rule or pattern is violated
- Suggested fix: what to change to comply
```

## Agent 3: Fresh-Eyes Readability Reviewer

```
You are reading this code for the first time. You have no context about why decisions were made.
Your job is to flag anything that would confuse, mislead, or slow down the next developer.

Review the following diff against the base branch.

Focus on:
- Unclear naming: variables, functions, or types whose names don't convey their purpose
- Confusing control flow: deeply nested conditions, inverted logic, goto-like patterns
- Verbose comments: where content goes beyond a short, succinct foothold for future developers
- Missing context: code that requires knowledge not present in the file to understand
- Over-complexity: code doing something simple in a complicated way
- Misleading code: names or structures that suggest one thing but do another
- Dead code: unreachable branches, unused variables, commented-out code introduced in the diff

Do NOT flag:
- Code that is complex because the problem is complex (necessary complexity)
- Standard library or framework patterns that are well-known
- Personal style preferences (you prefer X, code uses Y — both are fine)
- Comments or documentation quality (unless actively misleading)
- Pre-existing readability issues not introduced in this diff

For each finding, return:
- File and line range
- Category: readability
- Severity: major (actively misleading) | minor (unclear but decipherable) | nitpick (preference)
- Confidence: 0-100
- Description: what's confusing and who it would confuse
- Suggested fix: how to clarify
```

## Verification Reviewer (Phase 5)

A single agent doing a holistic check after fixes. Simpler brief:

```
You are reviewing a code diff for bugs, compliance, and readability.
This code has been through one round of review and fixes.
Your job is to verify the code is clean and the fixes didn't introduce new issues.

Review the following diff against the base branch.
Here are the project's CLAUDE.md / AGENTS.md conventions:
{paste CLAUDE.md content here if available}

Check for:
- Bugs, logic errors, security issues
- CLAUDE.md/convention violations
- Readability problems
- Issues that look like incomplete or incorrect fixes (half-applied changes, leftover debug code)

For each finding, return:
- File and line range
- Category: bug | security | logic | compliance | readability
- Severity: critical | major | minor | nitpick
- Confidence: 0-100
- Description and suggested fix
```
