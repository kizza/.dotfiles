---
name: worktrees
description: >
  Create and reuse git worktrees under ~/Code/worktrees/<repo>/<slug>, where parallel branch work
  lives without disturbing the main checkout. Use whenever Keiran talks about "worktrees" — spinning
  one up for a branch, a Basecamp card or a PR, moving a branch out of the main checkout, or resuming
  work already underway in one. Creation is plain `git worktree add`; the repo's own post-checkout
  hook does the provisioning.
---

# Worktrees

One worktree per unit of work, all of them under one root:

```
~/Code/worktrees/<repo>/<slug>
```

`<repo>` is the main checkout's directory name, `<slug>` the branch with `/` turned to `-` — so
`api/fix-stale-cache` lands at `~/Code/worktrees/<repo>/api-fix-stale-cache`.

Worktrees live outside `~/Code` proper on purpose: `~/Code` holds real repositories, and a worktree
sitting at `~/Code/<repo>-something` would be indistinguishable from a repo of that name. Keep
`~/Code` for repos.

Nothing about the location is load-bearing — worktree tooling keys off `git worktree list` and the
canonical path rather than the directory name, so any directory works. The convention is for
Keiran's benefit, not the tooling's.

## 1. Resolve the work

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
```

Named a Basecamp card? Fetch it with the **`basecamp` skill** — never hand-roll the API. Take the
card id, its URL, and a one-paragraph purpose. Named a PR? `gh pr view <n> --json headRefName` gives
the branch to check out. Otherwise derive the branch from the conversation.

## 2. Reuse before creating

```bash
git -C "$REPO_ROOT" worktree list
```

A branch already checked out somewhere is the work already underway — go there rather than creating
a second one. Git refuses a duplicate checkout anyway (`fatal: '<branch>' is already used by
worktree at …`) — except in the **main** checkout, which Keiran grabs branches into on purpose. That
case is his, not yours; see *The main checkout is Keiran's* below.

## 3. Name the branch

Follow the repo's convention, read off recent branches — commonly `<area>/<kebab-description>`, the
area naming the part of the system the change lands in. No card ids in branch names.

## 4. Create it

Fetch first so a new branch doesn't fork off a stale base:

```bash
git -C "$REPO_ROOT" fetch origin

WORKTREE_PATH=~/Code/worktrees/$REPO_NAME/${BRANCH//\//-}

# Existing branch:
git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" "$BRANCH"

# New branch off trunk:
git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" -b "$BRANCH" origin/main
```

`git worktree add` creates intermediate directories, so the `<repo>` level needs no `mkdir`.

## 5. Provisioning happens by itself

`git worktree add` fires `.githooks/post-checkout`, and a repo that has worktree tooling of its own
provisions the new worktree from there. Written here as `bin/worktree-setup <command>` — use
whatever the repo actually provides.

Provisioning typically copies the machine-local env files the repo expects (`.envrc.overrides`,
`.envrc.secrets` and the like, so credentials are present and `bin/rails` / `rspec` work), clones or
links the dependency directories (gems, `node_modules`), and assigns dev-server ports. Expect a
minute or two, most of it the dependency install.

What it does **not** do is give the worktree its own databases. Postgres and Redis stay shared with
the main checkout — see the **`worktree-isolation`** skill for when that matters and how to escalate.

Confirm it actually ran before working:

```bash
cd "$WORKTREE_PATH" && direnv exec . bin/worktree-setup status
```

A slot and its ports mean the hook fired. Nothing, or a missing per-worktree env file, means it did
not — check `git config --show-origin core.hooksPath` resolves to `.githooks`. Git honours exactly
one hooks path, so anything that repoints it (agent tooling has form here) silently disables every
repo hook. The repo's `bin/setup` is usually what sets it; restore with
`git config core.hooksPath .githooks`.

For a repo with no worktree tooling of its own, `~/.dotfiles/bin/worktree-provision <path>` copies
machine-local config and runs `direnv allow` — repo-agnostic, and all that is needed.

### Built assets: symlink, never rebuild

Provisioning installs dependencies but does not build assets, so the build output directory comes up
near-empty and any feature or system spec dies on a missing asset — in a Propshaft app,
`The asset 'public.css' was not found in the load path`. That is a missing file, not a broken
change — do not debug the spec.

Precompiling fixes it and costs minutes and a lot of disk rebuilding files that already sit in the
main checkout. Symlink them instead, instantly and for nothing:

```bash
ln -sfn "$REPO_ROOT"/app/assets/builds/* app/assets/builds/
```

Link the **contents**, not the directory: the ignore rule covers the directory's contents while
tracking a `.keep`, so replacing the directory itself shows `.keep` as deleted. Linking into it
leaves `git status` clean, and the links stay ignored.

The worktree then renders the main checkout's CSS and JS. For anything that is not about assets that
is exactly right. A branch that *changes* assets needs its own `css:build` / `javascript:build` —
that builds into the same directory, which is all the specs read.

## 6. Work in it

`cd "$WORKTREE_PATH"` and carry on. Run commands under `direnv exec .` so the nix shell and the
worktree's own env are loaded. Where that env shells out to a credential manager (1Password's `op`,
say), set its skip flag in an agent shell — an agent cannot authorize the prompt and otherwise waits
out the full timeout for nothing.

## Fan-out

"Spin one up for each of these" is steps 1–5 per branch, no concurrency cap. Report back a table of
branch, path, and whether it was created or reused.

Concurrent specs across worktrees sharing one test database **will** collide — `worktree-isolation`
explains exactly how. Accept it for sequential work; isolate the moment two runs overlap.

## Removing one

Only when Keiran asks:

```bash
cd "$WORKTREE_PATH" && direnv exec . bin/worktree-setup teardown   # only if isolated
git -C "$REPO_ROOT" worktree remove "$WORKTREE_PATH"               # --force if dirty
```

The branch survives removal, ready to check out anywhere. Skipping teardown is harmless; a later
`prune` collects stale databases.

## Hard limits

Never, without Keiran explicitly asking: `git commit`, `git push`, open a PR, or remove a worktree.
Leave the tree dirty for review. Escalating provisioning via `worktree-isolation` is the one thing
to decide unprompted.

## The main checkout is Keiran's

`~/Code/<repo>` is the slot his dev server runs on and where he experiments by hand. **Never work
there.** A session that finds itself in the main checkout makes a worktree and moves to it before
touching anything — no edits, no commits, no rebases, no branch switching, whatever the task and
however small it looks.

He pulls a branch into the slot with `grab` (`git checkout --ignore-other-worktrees`), so the main
checkout is often on **the same branch as a live worktree**. That is deliberate, not damage:

- Do not "fix" it, switch it back, remove the worktree, or run `git worktree prune`.
- A branch is a single ref, so only one tree may commit on it. The worktree is that tree; the slot
  reads and runs. A commit in the slot moves the ref under whoever is working in the worktree, whose
  `git status` then shows the new commit inverted — every addition as a deletion.
- `git worktree list` says what sits where; `git branch --list <branch> --format='%(worktreepath)'`
  names the holder of one branch.

Asked for a worktree on a branch already grabbed into the slot, `git worktree add` refuses
(`fatal: '<branch>' is already used by worktree at …`). `--force` is the supported way to put the
branch back in a worktree while the slot carries on reading it:

```bash
git -C "$REPO_ROOT" worktree add --force "$WORKTREE_PATH" "$BRANCH"
```
