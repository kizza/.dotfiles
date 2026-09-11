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

Two things about `create` that are easy to get wrong:

- `--base` applies only to a branch that doesn't exist yet. Given an **existing** branch, `--branch`
  alone checks it out where it stands and `--base` is ignored — so never pass a base you don't mean.
- It fails outright (`fatal: '<branch>' is already used by worktree at …`) if the branch is currently
  checked out in the main worktree. That one has to step aside first; `to-worktree` does this for you.

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

Light by default:

```bash
worktree-provision "$WORKTREE_PATH" "$REPO_ROOT"
```

`~/.dotfiles/bin/worktree-provision` is the one implementation, shared with `to-worktree`. It copies
`.envrc.overrides` and `.envrc.secrets` if the main worktree has them (copied, not symlinked —
`bin/worktree-setup` hard-fails on a symlink), symlinks `.claude/settings.local.json` so new approvals
reach every worktree at once, and runs `direnv allow`. Without that last step `.envrc.secrets` never
loads, so there is no `RAILS_MASTER_KEY` and `bin/rails` / `rspec` fail outright.

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

`agent start` adopts an **existing** pane sitting at its shell prompt — it does not create one, and
it does not carry the brief. Step 4 already left a pane in the new workspace, cwd'd into the
worktree, so find it and adopt it:

```bash
PANE_ID=$(herdr pane list --workspace "$WORKSPACE_ID" | python3 -c '
import json,sys
print(json.load(sys.stdin)["result"]["panes"][0]["pane_id"])')

herdr agent start "$SHORT_NAME" --kind claude --pane "$PANE_ID"
herdr agent prompt "$SHORT_NAME" "Read ./prd.md and begin."
```

`SHORT_NAME` is the branch's last segment, and becomes the agent's address for every command in
*Reviewing* below. `pane list` emits JSON with no `--json` flag, unlike `worktree list`.

Three things the two-call shape implies:

- **No `--cwd`.** The adopted pane is already in the worktree; `agent start` has no say in it, so a
  pane in the wrong directory yields an agent in the wrong directory. Read `cwd` back off the
  response rather than trusting it.
- **No `--no-focus`, and none needed** — adopting a pane doesn't pull Keiran's focus across.
- **`start` only proves the agent is ready for input.** Until `agent prompt` lands it is an idle
  `claude` staring at an empty prompt, which looks identical to a finished one on the board. Add
  `--wait --until working` to the prompt when a fan-out needs to know the brief actually took.

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

## By hand, without an agent

When the point is just to move a branch between the main checkout and a worktree — no card, no agent,
no `prd.md` — the shell functions in `programs/zsh/git.sh` do the whole round trip:

```bash
to-worktree [branch]   # existing branch into a herdr worktree, provisioned lite; fzf when unnamed
cd-worktree            # fzf a worktree and go there
rm-worktree            # fzf a worktree away; the branch survives, ready to check out in the main tree
```

`to-worktree` is steps 0, 4 and 5 in one command, so it does not report a workspace id and cannot feed
step 7. Launching an agent still means walking the steps above.

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
herdr agent prompt <name> "<follow-up>"       # literal text into a running agent
herdr agent wait <name> --until blocked --timeout 600000
```

`blocked` means an agent hit a permission prompt for something outside the allowlist. A prompt sent
to an already-blocked agent is **rejected** rather than queued, so clear the prompt first.

`agent prompt` is the follow-up channel — there is no `agent send`. `agent send-keys` exists but is
for raw key presses (dismissing a dialog), not text.
