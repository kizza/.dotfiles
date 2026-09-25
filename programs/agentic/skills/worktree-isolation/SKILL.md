---
name: worktree-isolation
description: >
  Give a worktree its own database and cache — its own Postgres databases and Redis logical DBs —
  through the repo's worktree tooling, when specs interfere with each other, a branch adds a
  migration, or two runs need to overlap. Use on symptoms as much as requests — inexplicable spec
  failures (missing seed data, foreign key violations, a schema that doesn't match the branch), "the
  test database is shared", "specs are fighting each other". Applies to any worktree however it was
  made: created by the `worktrees` skill, by `git worktree add`, or by hand.
---

# Isolating a worktree

A worktree arrives provisioned but **not** isolated. This skill closes that last gap, and is the one
escalation an agent may decide on for itself.

Commands are written here as `bin/worktree-setup <command>` — use whatever the repo actually
provides, and read its own worktree docs where it has them.

## The two tiers

| Tier | How you get it | What it buys |
|---|---|---|
| provisioned | `bin/worktree-setup run` — automatic, via `.githooks/post-checkout` | machine-local env files, dependencies, own dev-server ports |
| isolated | `bin/worktree-setup isolate` | own **dev + test databases**, own **Redis logical DBs** |

`run` assigns the worktree its slot and its dev-server ports. Only **`isolate`** sets the dev and
test database names and the cache's DB offset. Until then the worktree shares the main checkout's
databases.

Check which tier you are on with `direnv exec . bin/worktree-setup status` — the database and cache
rows appear only once isolated.

**A worktree that skipped the hook has neither tier.** No per-worktree env file, no ports, possibly
no secrets — so `bin/rails` fails for want of credentials before it starts. Git honours exactly one
`core.hooksPath`, so anything repointing it silently disables every repo hook. Confirm with
`git config --show-origin core.hooksPath`, restore with `git config core.hooksPath .githooks`, then
`direnv exec . bin/worktree-setup run` to catch the worktree up. `isolate` does not depend on `run`
having happened.

## When to escalate

**The test database is shared.** The test database name defaults to one value for the whole repo, so
every non-isolated worktree and the main checkout point at a single test database. Two things then
break:

- A suite that truncates at `before(:suite)` — `DatabaseCleaner.clean_with(:truncation)`, typically
  — means a second rspec starting **truncates every table out from under** a run already in flight.
- `maintain_test_schema!` reloads the schema when a branch carries a new migration, and anything
  else running is now testing against the wrong schema.

Escalate when specs fail in ways that make no sense: missing seed data, foreign key violations,
materialized views that vanished, a schema that doesn't match the branch. **Do not debug the specs.**

Sequential use of a shared test database is fine; concurrency is what breaks it. So the trigger is
not "this is a worktree" but "two runs will overlap" or "this branch changes the schema".

**The main checkout counts as a sharer.** It has no per-worktree env, so it sits on the default
development and test databases exactly like an unisolated worktree — and it is where Keiran runs his
dev server, pulling branches in with `grab` to drive them by hand. A branch that adds a migration is
therefore one he cannot safely grab: running it in the slot migrates the database every unisolated
worktree reads, and trunk is then behind its own schema. Isolate that branch's worktree and say the
branch carries a migration, rather than leaving it to be found in the slot.

## Doing it

```bash
cd "$WORKTREE_PATH"
direnv exec . bin/worktree-setup isolate   # own databases and cache, dev seeded
direnv exec . bin/worktree-setup status    # confirm what got assigned
```

Run it under `direnv exec .` — outside the nix shell there is no project Ruby and it fails before it
starts. Where the env shells out to a credential manager, set its skip flag in an agent shell, which
cannot authorize the prompt and otherwise waits out the full timeout for nothing.

`isolate` is safe to re-run and skips if already isolated. It copies no files, so it never conflicts
with anything symlinked into the worktree. It prunes at the end, garbage-collecting databases
belonging to worktrees that no longer exist.

Where the repo tracks data migrations separately, isolate also marks the new dev database current
with them, so existing ones are recorded as applied rather than left pending for the next update.
Data migrations the branch itself adds still show as pending, as they should.

Not every odd spec failure is the database. A missing-asset error is a worktree with no built
assets, which isolation does not touch — symlink them from the main checkout
(`ln -sfn "$REPO_ROOT"/app/assets/builds/* app/assets/builds/`) rather than precompiling. The
`worktrees` skill covers it.

## Footgun: never list a symlinked file for copying

Setup scripts provision a worktree by copying a list of machine-local files into it. Copying with
`FileUtils.cp_r` raises `ArgumentError: same file` when source and destination are the same file, and
where that copy is a fatal step the whole setup **exits non-zero** for every worktree thereafter.

So the copy list may name only real files. Anything symlinked into a worktree — a shared
`.claude/settings.local.json`, for instance — must stay out of it.

## Tearing down

Only when Keiran explicitly asks:

```bash
direnv exec . bin/worktree-setup teardown   # drops this worktree's databases, flushes its cache DBs
```

Skipping teardown is harmless — a later `prune` collects stale resources. Removing the worktree
directory itself is Keiran's call, never an agent's.

## Limits

The ceiling is the cache's logical database count: Redis ships 64, and two per slot leaves 31
concurrent isolated worktrees. `prune` reclaims slots from deleted worktrees. A full dev stack per
worktree is several processes — app server, background workers, asset watchers — so isolate freely
but do not leave dev servers running.
