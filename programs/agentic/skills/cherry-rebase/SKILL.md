---
name: cherry-rebase
description: >
  Rebuild a multi-commit branch by cherry-picking it commit-by-commit onto its base so a
  change threads through every commit and each commit becomes the best, coherent version of
  itself — as if it had always been that way — instead of tacking on a fix-up commit or
  rolling back and rebuilding the branch from scratch (which loses per-changeset fidelity).
  Use when asked to cherry-pick, rebase, rewrite, squash, fix up, or otherwise restructure 
  commit history. Also use when making changes that should be distributed cleanly across 
  multiple commits (such as renames, API changes, namespace moves, or extracted 
  dependencies), ensuring each commit remains coherent, self-contained, and builds/tests 
  correctly for its point in history. Works without requiring an interactive rebase.
---

Apply a change across an existing commit series so that every commit stands on its own and
tells the true story of the change — no "move X" or "rename Y" commit tacked on the end, and
no loss of the individual changesets' fidelity that a full rollback-and-rebuild causes.

# Two intents — decide which before you start

The mechanics below are the same, but the *goal* (and therefore the verification) differs.
Know which one you're doing:

- **Preserve** — thread a cross-cutting change through history without altering behaviour
  (a namespace move, a rename, a signature change). Success = the branch does *exactly* what
  it did before, just shaped better. Verify by proving behaviour is **unchanged** (identical
  pass/fail on backup and HEAD). Here you **replay faithfully and never silently fix**.

- **Coherent** — make each commit the correct, self-consistent version of itself: its specs
  match its behaviour, it builds and passes *at that commit*. This is for a branch whose
  intermediate commits are red or half-baked (a return type changed but its specs weren't
  updated; a bug that a later commit was meant to fix). Success = **each commit is green at
  its own stage**. Here you **do fix** — but each fix belongs in the commit that introduced
  what it corrects (update the spec's expectations *in* the "change the return type" commit;
  fix the bug *in* the commit that added the buggy code), never as a fix-up on the end.

You can run both intents in one pass (this branch was moved to a new namespace in one
cherry-rebase, then made coherent in a second). Do them as *separate* passes — mixing
"changed nothing" and "fixed everything" makes either verification impossible to reason about.

# Why this exists

`git rebase -i` is not usable in this environment: there is no interactive editor and you
cannot sit at successive `edit` stops reacting to the working tree. The human move —
"`rebase -i`, mark commits `edit`, amend at each stop" — is closed to you. This skill is the
non-interactive equivalent: **branch, reset, replay commit-by-commit, verify, clean up.**

Reach for it when the change is *intrinsic to the existing commits' narrative* (a namespace
move, a renamed attribute, a changed method signature, a dependency introduced in an earlier
commit and used in a later one). If the change is genuinely a *new* concern, don't force it
into history — give it its own commit instead.

# The core insight

A change that **reshapes many lines at once** — wrapping code in a module, reindenting,
renaming-with-heavy-edits — defeats line-based 3-way merge. Once an early commit reshapes a
file, every later commit's patch to that file conflicts, because the context lines no longer
match. This bites `cherry-pick`, `rebase`, *and* `range-diff` equally. It is not a tooling
bug; it is inherent to threading a whole-file reshape through history.

The escape is **reconstruction, not merging**: for the reshaped file, don't try to apply the
later commit's patch. Instead regenerate that file's end-state from *that commit's own
snapshot* (`git show <original-sha>:<old-path>`), transformed into its target shape, and stage
that. The file is simply *born* in its target shape in every commit — so there is no "reshape
event" anywhere in history for a later patch to collide with. Let git's merge + rename
detection handle every *other* file automatically; only hand-reconstruct the reshaped one.

# Procedure

1. **Map the series.** `git log --oneline <base>..HEAD` and, for each commit,
   `git show --name-only --format='' <sha>` — know exactly which commits touch the file(s)
   the change will reshape. Those are the ones you'll reconstruct; the rest cherry-pick clean.

2. **Backup.** `git branch backup/<slug>`. This is both your safety net and the *source of the
   per-commit snapshots* you reconstruct from. Everything stays recoverable from it (and the
   reflog) until you delete it at the very end.

3. **Reset the working branch to the base.** `git reset --hard <base>`.

4. **Replay oldest-first.** `git rev-list --reverse <base>..backup/<slug>` gives the order.
   For each original commit:
   - **Doesn't touch the reshaped file** → `git cherry-pick <sha>`. Clean; move on.
   - **Introduces the change** (usually the first commit that creates/edits the file) →
     cherry-pick, then apply the change (e.g. `git mv` + wrap + fix references), stage, and
     `git commit --amend --no-edit`. The change is now *part of that commit's story*, not a
     separate commit.
   - **Later commit that touches the reshaped file** → `git cherry-pick <sha>`; it conflicts
     on that file. Resolve by **reconstruction**: `git show <sha>:<old-path>` → write the
     transformed end-state to the target path → `git rm` the old path if it lingers
     (`DU` = deleted-by-us) → `git add` → `git -c core.editor=true cherry-pick --continue`.
     Git will have auto-merged the *other* files in that commit; only the reshaped one is manual.

5. **Verify (do not skip — this is what earns trust).** See below.

6. **Clean up.** Delete `backup/<slug>` only *after* verification passes.

# Verification

Three checks, strongest last:

- **`git range-diff backup/<slug>...HEAD`** — pairs old vs new commits and shows how each
  commit's diff changed. Expect to see *only* the intended delta (path, wrapper, references).
  **Caveat:** range-diff pairs commits by textual similarity, so a heavy reshape drops the
  similarity below its threshold and it will show reshaped commits as *dropped-then-re-added*
  (`<` / `>`) rather than matched (`!`). That is a limitation of the tool, not a sign of error
  — fall back to the net-tree check for those.

- **Net tree diff: `git diff --stat backup/<slug> HEAD`** plus a whitespace-insensitive diff
  of the reshaped file
  (`diff <(git show backup:<old> | sed 's/^[[:space:]]*//') <(git show HEAD:<new> | sed 's/^[[:space:]]*//')`).
  The net difference across the *whole series* must be only the intended change. This proves
  the aggregate even when range-diff couldn't pair intermediate commits.

- **Behavioural check — depends on the intent (see "Two intents"):**
  - *Preserve:* run the affected tests on **both** `backup` and `HEAD` and confirm
    **identical pass/fail counts**. The goal is that the replay changed *nothing*
    behaviourally — pre-existing failures must stay exactly as pre-existing. Do not "fix" a
    red suite as part of the thread; that would make the range-diff meaningless.
  - *Coherent:* checking HEAD alone is not enough — a commit can be red mid-history yet green
    by the tip. **Check out each commit and run its specs** (`git checkout <sha>` → rspec →
    return to the branch with `git checkout <branch>`), and confirm **each stage is green on
    its own**. Then confirm HEAD is green too. This per-commit sweep is the whole point of the
    coherent intent; skipping it defeats it.

# Guidelines & gotchas (learned the hard way)

* **Faithful vs. fixing is set by the intent, not by whim.** In a *preserve* pass, if a
  commit's snapshot contains a bug or a failing test, reproduce it exactly and flag it — don't
  fix it, or the "changed nothing" proof collapses. In a *coherent* pass, fixing is the job —
  but put each fix in the commit that introduced the thing it corrects (the Money-type spec
  update lands in the "return currency" commit; the argument-order bug fix lands in the commit
  that wrote the bug), so every commit is internally consistent and nothing leaks forward.
* **Surface real decisions; don't code around them.** Some fixes are genuine forks, not
  mechanics — stop and ask, then thread the answer. This session hit two: the target namespace
  already existed as a *class* not a module (reopen it vs. rename), and a lookup read the wrong
  blob key (`"Invoice Item Identifier"` vs the real `"Item Identifier"`, and column-vs-blob as
  the data source). A conflict pause is a natural place to raise these.
* **A coherence fix can cascade to fixtures.** Correcting the code often means the test data
  that fed the old (broken) behaviour is now wrong too — e.g. fixing which blob key is read
  meant every fixture had to actually populate that key, and a payment-statement fixture needed
  a `delivery_date` inside the pre-commencement window for the scope to match. Fix the fixtures
  in the same commit, and let the per-commit green sweep catch the ones you miss.
* **Let git do what it can.** Rename detection carries lightly-touched files (like specs whose
  only change is a `describe` constant) through automatically. Only reshaped files need hands.
* **`-c core.editor=true`** on `cherry-pick --continue` (and `--no-edit` on amend) prevents the
  commit-message step from hanging on an editor you can't drive.
* **`DU` / deleted-by-us** conflicts on the old path mean "you moved it, they edited it" —
  resolve by `git rm`-ing the old path; the content lives at the new path.
* **Verify the introduced change loads before replaying the rest.** If the change has a
  structural error (bad nesting, wrong path, autoload mismatch), catch it right after the first
  commit — otherwise every subsequent reconstruction inherits it and you redo them all.
* **You *can* participate in the merge, one file at a time.** Even without interactive rebase,
  cherry-pick pausing on a conflict is functionally the same as an `edit` stop: inspect,
  resolve that single file, `--continue`. Narrate each pause so the user follows along.

# Output

A rewritten branch where the change is woven invisibly through every commit — each commit is
the best version of itself and no discrete "move/rename/fix-up" commit exists. For a *preserve*
pass, behaviour is provably unchanged from the original series; for a *coherent* pass, every
commit is green at its own stage and HEAD is green. The backup branch is deleted once
verification passes.
