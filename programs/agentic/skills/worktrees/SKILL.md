---
name: worktrees
description: >
  Spin up git worktrees inside herdr and start a Claude agent in each, so parallel branch work is
  reviewable in one place. Use whenever Keiran talks about "worktrees" — spinning one up for a
  Basecamp card, fanning several out across a set of cards or triage items, or resuming work already
  underway in an existing worktree.
---

# Worktrees in herdr

One worktree per unit of work, each in its own herdr workspace, each with a Claude agent already
working on it. Keiran reviews progress by attaching to herdr and moving between workspaces.

Every worktree carries a `prd.md` at its root: the brief the agent is launched against, and the
running log of what happened. It is the durable memory of that worktree.

## 0. Preflight — herdr must be running

The herdr CLI talks over `~/.config/herdr/herdr.sock` and works from **any** terminal. Do **not**
gate on `HERDR_ENV`; that only matters for `--current`-style pane commands, which this skill avoids.

```bash
herdr status 2>/dev/null | grep -q 'status: running' || {
  herdr server >/dev/null 2>&1 &
  until herdr status 2>/dev/null | grep -q 'status: running'; do sleep 0.3; done
}
```

Started headless, there is no attached UI. Tell Keiran to run `herdr` when he wants to review.

## 1. Resolve the repo and the work

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
```

If a Basecamp card is named, fetch it with the **`basecamp` skill** — do not hand-roll API calls.
Extract the numeric card id, the URL, and a succinct one-paragraph purpose.

If no card, derive the purpose from the conversation.

## 2. Reuse before creating

A card may already have a worktree. Check every worktree's `prd.md` for the card id:

```bash
herdr worktree list --cwd "$REPO_ROOT" --json \
  | python3 -c 'import json,sys;[print(w["path"]) for w in json.load(sys.stdin)["result"]["worktrees"]]' \
  | while read -r p; do grep -l "Basecamp: #$CARD_ID" "$p/prd.md" 2>/dev/null; done
```

Match on the **numeric id**, not the URL — URL forms vary. A match means the work is already
underway: reuse that worktree, append to its `prd.md`, and skip to step 6.

This covers hand-made worktrees outside `~/.herdr/` too, because `worktree list` enumerates them all.

## 3. Name the branch

Follow the repo's existing convention, read off recent branches — in lookout that is
`<area>/<kebab-description>` where area is usually a mount (`finance/`, `admin/`, `chsp/`).
Derive from the card title when there is one, otherwise from context. **No card ids in branch
names** — the id lives in `prd.md`.

## 4. Create the worktree

Fetch first, so a fan-out doesn't branch off a stale base:

```bash
git -C "$REPO_ROOT" fetch origin
herdr worktree create --cwd "$REPO_ROOT" --branch "$BRANCH" --base origin/main --no-focus --json
```

Let herdr choose the path (`~/.herdr/worktrees/<repo>/<slug>`) — it owns the directory lifecycle.

Then read back `path` and `open_workspace_id` by re-querying, rather than assuming the shape of the
create response:

```bash
herdr worktree list --cwd "$REPO_ROOT" --json | python3 -c '
import json,sys,os
b=os.environ["BRANCH"]
w=next(w for w in json.load(sys.stdin)["result"]["worktrees"] if w["branch"]==b)
print(w["path"], w.get("open_workspace_id",""))'
```

## 5. Provision — lite

Light by default. Copy only what exists (this skill is repo-agnostic), and **symlink the allowlist**
so it never goes stale:

```bash
cd "$WORKTREE_PATH"

# Copied — bin/worktree-setup owns these and hard-fails on a symlink (FileUtils.cp_r "same file").
for f in .envrc.overrides .envrc.secrets; do
  [ -f "$REPO_ROOT/$f" ] && [ ! -e "$f" ] && cp "$REPO_ROOT/$f" ./
done

# Symlinked — live, so new approvals reach every worktree at once.
if [ -f "$REPO_ROOT/.claude/settings.local.json" ]; then
  mkdir -p .claude
  ln -sfn "$REPO_ROOT/.claude/settings.local.json" .claude/settings.local.json
fi

# Required: without this .envrc.secrets never loads, so there is no RAILS_MASTER_KEY
# and bin/rails / rspec fail outright.
direnv allow . 2>/dev/null || true
```

Lite deliberately skips `bin/worktree-setup run`, so there is **no `node_modules`**. Pure-Ruby specs
are fine; asset-compiling specs and `bin/dev` need escalation — see the `worktree-isolation` skill.

## 6. Write `prd.md`

Write it **before** launching the agent. Arbitrary card text must never go through a command line.

```markdown
# <Short title>

## Purpose
<One succinct paragraph: what outcome ends this work.>

## Source
Basecamp: #<card-id>
<card url>

## Environment
Provisioned **lite**: config copied, allowlist symlinked, direnv allowed.
- No `node_modules` (`yarn install` not run) — asset-compiling specs and `bin/dev` will fail.
- The test database is **shared** with the main checkout and every other lite worktree.
  `spec/support/database.rb` truncates all tables at `before(:suite)`, so a concurrent rspec run
  elsewhere can corrupt yours. If specs fail in ways that make no sense — missing seed data, foreign
  key violations, a schema that doesn't match the branch — suspect this first and escalate using the
  `worktree-isolation` skill rather than debugging the specs.

## Contract
- Investigate, implement, and verify with rspec and linters.
- **Do not commit, push, or open a PR.** Leave the tree dirty for review.
- **Do not touch this file's fate** — never delete it, never `git add` it.
- Append below as you go: what you found, what you changed, what is unresolved.

## Log
<!-- newest last -->
```

When reusing an existing worktree (step 2), append a new `## Log` entry instead of rewriting.

## 7. Launch the agent

```bash
herdr agent start "$SHORT_NAME" \
  --cwd "$WORKTREE_PATH" \
  --workspace "$WORKSPACE_ID" \
  --no-focus \
  -- claude "Read ./prd.md and begin."
```

`SHORT_NAME` is the branch's last segment. `--no-focus` so Keiran isn't yanked between workspaces.

An agent must be started **through herdr** to be reviewable — the `herdr-agent-state.sh`
`SessionStart` hook needs `HERDR_ENV`, `HERDR_SOCKET_PATH` and `HERDR_PANE_ID`, which only exist in
a herdr-created pane. A bare `claude` in a plain terminal is invisible to herdr.

## Fan-out

For "spin up a worktree for each of these cards", run steps 1–7 per card. No concurrency cap and no
staging — spawn them all. Report back a table of card, branch, workspace id, and whether it was
newly created or reused.

Shared-test-database collisions between concurrent agents are an **accepted** tradeoff: light
provisioning is the priority, and a confusing spec failure is re-runnable. `prd.md` already tells
each agent how to recognise and escalate it.

## Hard limits

Never, without Keiran explicitly asking:

- `git commit`, `git push`, or open a PR
- delete, `git add`, or archive a `prd.md`
- `git worktree remove` / `herdr worktree remove` / `bin/worktree-setup teardown`
- close a herdr workspace

Keiran always decides `prd.md`'s fate and when a worktree dies. Escalating provisioning
(`worktree-isolation`) is the one thing an agent may decide for itself.

## Reviewing

```bash
herdr workspace list                          # every workspace and its agent status
herdr agent list                              # agents, their cwd, idle/working/blocked
herdr agent read <name> --source recent --lines 120
herdr agent send <name> "<follow-up>"         # literal text into a running agent
```

`blocked` means an agent hit a permission prompt for something outside the allowlist.
