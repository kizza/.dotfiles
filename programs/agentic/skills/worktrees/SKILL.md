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

`<repo>` is the main checkout's directory name, `<slug>` the branch with `/` turned to `-` —
so `finance/fix-stranded-po-line` in lookout lands at
`~/Code/worktrees/lookout/finance-fix-stranded-po-line`.

Worktrees live outside `~/Code` proper on purpose: `~/Code/lookout-analytics-dwh` and
`~/Code/lookout-claude-marketplace` are real repositories, and a throwaway worktree named
`~/Code/lookout-something` would be indistinguishable from them. Keep `~/Code` for repos.

Nothing about the location is load-bearing — `bin/worktree-setup` derives slots from
`git worktree list` and database names from a SHA-1 of the canonical path, so any directory works.
The convention is for Keiran's benefit, not the tooling's.

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
worktree at …`), including when the branch sits in the **main** checkout, which has to step aside
first.

## 3. Name the branch

Follow the repo's convention, read off recent branches. In lookout that is
`<area>/<kebab-description>`, area usually a mount — `finance/`, `admin/`, `chsp/`. No card ids in
branch names.

## 4. Create it

Fetch first so a new branch doesn't fork off a stale base:

```bash
git -C "$REPO_ROOT" fetch origin

WORKTREE_PATH=~/Code/worktrees/$REPO_NAME/${BRANCH//\//-}

# Existing branch:
git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" "$BRANCH"

# New branch off origin/main:
git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" -b "$BRANCH" origin/main
```

`git worktree add` creates intermediate directories, so the `<repo>` level needs no `mkdir`.

## 5. Provisioning happens by itself

`git worktree add` fires `.githooks/post-checkout`, which runs `bin/worktree-setup run` against the
new worktree. That copies `.envrc.overrides` and `.envrc.secrets` (so `RAILS_MASTER_KEY` is present
and `bin/rails` / `rspec` work), CoW-clones the gems and confirms them with `bundle install`,
populates `node_modules` via yarn's pnpm linker, and assigns dev-server ports. Expect it to take a
minute or two, most of it bundler.

What it does **not** do is give the worktree its own databases. Postgres and Redis stay shared with
the main checkout — see the **`worktree-isolation`** skill for when that matters and how to escalate.

Confirm it actually ran before working:

```bash
cd "$WORKTREE_PATH" && direnv exec . bin/worktree-setup status
```

`SLOT`, `HTTP` and `HTTPS` mean the hook fired. Nothing, or a missing `.envrc.worktree`, means it
did not — check `git config --show-origin core.hooksPath` resolves to `.githooks`. Git honours
exactly one hooks path, so anything that repoints it (beads has done this) silently disables every
repo hook. `bin/setup` is what sets it; restore with `git config core.hooksPath .githooks`.

For a repo with no worktree tooling of its own, `~/.dotfiles/bin/worktree-provision <path>` copies
machine-local config and runs `direnv allow` — repo-agnostic, and all that is needed.

### Built assets: symlink, never rebuild

`run` does not build assets, so `app/assets/builds` comes up near-empty and any feature or system
spec dies on `Propshaft::MissingAssetError: The asset 'public.css' was not found in the load path`.
That is a missing file, not a broken change — do not debug the spec.

`bin/rails assets:precompile` fixes it and costs minutes and ~86M rebuilding files that already sit
in the main checkout. Symlink them instead, instantly and for nothing:

```bash
ln -sfn "$REPO_ROOT"/app/assets/builds/* app/assets/builds/
```

Link the **contents**, not the directory: `.gitignore` ignores `/app/assets/builds/*` but tracks
`.keep`, so replacing the directory itself shows `.keep` as deleted. Linking into it leaves
`git status` clean, and the links stay ignored.

The worktree then renders the main checkout's CSS and JS. For anything that is not about assets that
is exactly right. A branch that *changes* assets needs its own `bin/rails css:build` /
`javascript:build` — that builds into `app/assets/builds` too, which is all the specs read.

## 6. Work in it

`cd "$WORKTREE_PATH"` and carry on. Run commands under `direnv exec .` so the nix shell and
`.envrc.worktree` are loaded; `TLW_SKIP_1PASSWORD=1` avoids a 60s `op` authorization timeout in an
agent shell.

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

The branch survives removal, ready to check out anywhere. Skipping teardown is harmless; `prune`
collects stale databases on the next `isolate`.

## Hard limits

Never, without Keiran explicitly asking: `git commit`, `git push`, open a PR, or remove a worktree.
Leave the tree dirty for review. Escalating provisioning via `worktree-isolation` is the one thing
to decide unprompted.

## Herdr

Worktrees are no longer created through herdr, and no agent is launched in them — this skill makes a
directory for the current session to work in. The `herdr` skill still drives herdr itself, and
`to-worktree` / `cd-worktree` / `rm-worktree` in `programs/zsh/git.sh` still create herdr-rooted
worktrees under `~/.herdr/worktrees/`. Existing ones there keep working; new ones belong here.
