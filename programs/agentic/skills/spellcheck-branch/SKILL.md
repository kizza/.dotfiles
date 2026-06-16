---
name: spellcheck-branch
description: >
  Fix spelling errors, typos, and grammatical mistakes in code comments AND
  commit messages within the current branch. Use this skill whenever the user
  asks to spellcheck, proofread, or fix typos in comments or commit messages —
  or uses a phrase like "/spellcheck", "check my comments", "fix comment typos",
  "clean up my commits", or "fix my commit messages". Applies to any language.
  Creates proper fixup commits for comment errors; rewrites commit messages
  directly via interactive rebase for message errors.
---

# Spellcheck Comments & Commit Messages

Find and fix spelling/grammar errors in code comments and commit messages
introduced on this branch, with appropriate git commits.

---

## Phase A — Code Comments

### Step A1 — Discover changed files

Run a diff against main (or the configured base branch) for all source files:

```bash
git diff main..HEAD -- '*.rb' '*.py' '*.js' '*.ts' '*.go' '*.java' \
  '*.c' '*.cpp' '*.h' '*.cs' '*.swift' '*.kt' '*.rs' '*.php'
```

If the user mentioned a specific language or extension, narrow accordingly.
If the repo uses a base branch other than `main` (e.g. `master`, `develop`),
substitute it.

### Step A2 — Identify comment lines

From the diff output, collect only **added or modified lines** (lines starting
with `+`, excluding the `+++` header). From those, extract only lines that
contain comments — i.e. lines where the code portion is a comment syntax for
that file's language (`//`, `#`, `/*`, `*`, `--`, `<!--`, etc.).

Ignore lines that are purely code with no comment text.

### Step A3 — Check spelling and grammar

Scan the collected comment text for:
- Spelling mistakes and typos
- Grammatical errors (wrong tense, missing words, subject-verb disagreement)
- Doubled words ("the the")
- Wrong homophones ("there/their/they're", "its/it's") in context

Do **not** flag:
- Technical identifiers, variable names, or jargon used intentionally
- Abbreviations that are idiomatic in code comments (e.g. `impl`, `func`, `idx`)
- Non-English words or domain terms that appear intentional

### Step A4 — Blame each error

For each error found, run `git blame` on that file and line to determine
whether the line was introduced on this branch or existed before:

```bash
git blame -L <line>,<line> <file>
```

Classify each error as:
- **Branch error**: introduced by a commit on this branch
- **Pre-existing error**: introduced before this branch

### Step A5 — Create commits

#### Branch errors — one fixup commit per original commit

Group branch errors by the commit that introduced them. For each such commit,
fix the relevant lines and create a fixup commit:

```bash
git add <files>
git commit --fixup=<original-sha>
```

This lets the author run `git rebase -i --autosquash` later if desired.
Do **not** rebase yourself.

#### Pre-existing errors — one combined commit

Fix all pre-existing errors in one pass, then commit:

```bash
git add <files>
git commit -m "Fix past spelling mistakes in comments" \
  -m "These were probably me in the past anyway."
```

---

## Phase B — Commit Messages

### Step B1 — Collect commit messages on this branch

```bash
git log main..HEAD --format="%H %s"
```

This gives the SHA and subject line for every commit on the branch.
For commits with a body, also fetch the full message:

```bash
git log main..HEAD --format="%H%n%B%n---END---"
```

### Step B2 — Check spelling and grammar in messages

Apply the same rules as Phase A (Step A3) to each commit's subject line and
body. Additionally check:
- Capitalisation of the first word of the subject
- Obvious punctuation errors (e.g. double spaces, trailing spaces)

Do **not** "fix":
- Intentional stylistic choices (no trailing period, imperative mood, etc.)
- Technical terms, branch names, ticket numbers, URLs, or code snippets

### Step B3 — Show proposed corrections for confirmation

**Before making any changes**, display a table of every proposed correction so
the user can review and approve:

```
Proposed commit message corrections
────────────────────────────────────────────────────────────────────────
SHA      Current message                  Proposed message
-------- -------------------------------- --------------------------------
a1b2c3d  Fix teh widget laoding bug       Fix the widget loading bug
e4f5a6b  Refactor authetication flow      Refactor authentication flow
────────────────────────────────────────────────────────────────────────
Proceed? (yes / no / select)
```

If the user wants to selectively apply corrections, let them list the SHAs to
include before continuing.

If there are **no** corrections to make, say so and skip to the report.

### Step B4 — Apply corrections via rebase

Once the user confirms, rewrite each affected commit's message using
`git commit --amend` inside a non-interactive rebase driven by an `exec` script.
The safest approach:

```bash
# Build a rebase script that amends exactly the commits that need fixing.
# For each SHA that needs a new message, run:
GIT_SEQUENCE_EDITOR='<path-to-script>' git rebase -i main
```

Where the sequence editor script rewrites the `pick` line for each target SHA
to `reword`, and leaves all others as `pick`. Git will then pause at each
`reword` commit and open the editor — but to keep this non-interactive, set
`GIT_EDITOR` to a script that writes the corrected message directly:

```bash
GIT_EDITOR='<per-commit-message-writer>' \
GIT_SEQUENCE_EDITOR='<reword-picker>' \
  git rebase -i main
```

Practical implementation:

1. Write the corrected messages to temp files: `/tmp/msg-<sha>.txt`
2. Write a sequence editor script that changes `pick <sha>` → `reword <sha>`
   for each target SHA.
3. Write a per-commit editor script that, given the commit message file path
   as `$1`, copies the appropriate `/tmp/msg-<sha>.txt` into it using the
   current `HEAD` SHA to identify which message to use.
4. Run the rebase.
5. Clean up temp files.

> **Note**: this rewrites history. Warn the user if the branch has already
> been pushed to a shared remote, as a force-push will be required afterwards.

### Step B5 — Verify

After the rebase completes, run:

```bash
git log main..HEAD --oneline
```

Display the resulting commit list so the user can confirm the messages look
correct.

---

## Phase C — Report

After both phases complete, summarise:

- **Comments**: number of errors fixed, broken down by branch vs pre-existing;
  list of fixup commits created (SHA + which original commit each targets);
  any errors skipped and why.
- **Commit messages**: list of commits whose messages were rewritten
  (old → new); note if a force-push will be needed.
- If nothing needed fixing in either phase, say so clearly.

---

## Notes

- **Phase A never rebases** — only creates new fixup commits.
- **Phase B always rebases** — this is unavoidable for message correction.
  Always confirm with the user (Step B3) before touching history.
- If the base branch is ambiguous, ask the user before proceeding.
- If there are no errors in a phase, skip it silently and mention it in the
  report.
