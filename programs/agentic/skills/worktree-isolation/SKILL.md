---
name: worktree-isolation
description: >
  Escalate a lightly-provisioned lookout worktree to full isolation via bin/worktree-setup, when
  specs interfere with each other, a branch adds a migration, or the worktree needs node_modules or
  its own dev server. Use on symptoms as much as requests — inexplicable spec failures (missing seed
  data, foreign key violations, a schema that doesn't match the branch), "the test database is
  shared", "specs are fighting each other", or a worktree that needs bin/dev or asset compilation.
---

# Escalating a lookout worktree

Worktrees created by the `worktrees` skill are provisioned **lite**: config copied, allowlist
symlinked, `direnv allow` run. That is deliberately not everything. This skill adds the rest, on
demand.

## What each tier actually buys you

| Tier | Command | Gets you |
|---|---|---|
| lite | *(already done)* | `.envrc.overrides`, `.envrc.secrets`, direnv allowed |
| run | `bin/worktree-setup run` | re-syncs config, **`yarn install`** (node_modules), own **ports** |
| isolate | `bin/worktree-setup isolate` | own **dev + test Postgres databases**, own **Redis logical DBs** |

Per `doc/how_to/use_git_worktrees.md`: `run` sets `WORKTREE_SLOT`, `DEV_HTTP_PORT`, `DEV_HTTPS_PORT`.
Only **`isolate`** sets `DEV_DATABASE_NAME`, `TEST_DATABASE_NAME`, `REDIS_DB_OFFSET`. After `run`
alone, the worktree still shares the main checkout's databases.

## When to escalate

**`isolate` — the test database is shared.** `config/database.yml:27` defaults `TEST_DATABASE_NAME`
to `lookout_test`, so every lite worktree and the main checkout share one test database. Two things
then break:

- `spec/support/database.rb:5` runs `DatabaseCleaner.clean_with(:truncation)` at `before(:suite)`.
  A second rspec starting **truncates every table out from under** a run already in flight.
- `spec/rails_helper.rb:69` calls `maintain_test_schema!`, so a branch with a new migration reloads
  the schema — and anything else running is now testing against the wrong schema.

Escalate when specs fail in ways that make no sense: missing seed data, foreign key violations,
materialized views that vanished, a schema that doesn't match the branch. Do not debug the specs.
Sequential use of a shared test database is fine; concurrency is what breaks it.

**`run` — you need `node_modules` or ports.** Asset-compiling specs, system specs, or `bin/dev`.
Fast despite appearances: `.yarnrc.yml` uses the pnpm linker, so it relinks from a shared store.

## Doing it

```bash
cd "$WORKTREE_PATH"
bin/worktree-setup run       # only if you need node_modules or a dev server
bin/worktree-setup isolate   # own databases and Redis
bin/worktree-setup status    # confirm what got assigned
```

`isolate` is safe to re-run and skips if already isolated. It copies no files, so it never conflicts
with the symlinked `.claude/settings.local.json`. It calls `prune` at the end, which garbage-collects
databases belonging to worktrees that no longer exist.

`run` is only needed for node_modules/ports — `isolate` does not depend on it, because lite already
copied `.envrc.secrets` (and therefore `RAILS_MASTER_KEY`) and ran `direnv allow`.

Record in the worktree's `prd.md` that the tier changed, so a later session knows.

## Footgun: never add a symlinked file to `.worktreeinclude`

`bin/worktree/run` copies its file list with `FileUtils.cp_r`, which raises
`ArgumentError: same file` when destination and source are the same file — and `SYNC CONFIG` is a
fatal step, so **`run` exits 1**. Its list is `.envrc.overrides`, `.envrc.secrets`,
`.worktreeinclude`, plus every path named inside `.worktreeinclude`.

`.claude/settings.local.json` is symlinked to the main checkout by the `worktrees` skill, so it must
**not** be listed in `.worktreeinclude`. If someone adds it there, `run` breaks for every worktree.

## Tearing down

Only when Keiran explicitly asks:

```bash
bin/worktree-setup teardown   # drops this worktree's databases, flushes its Redis DBs
```

Skipping teardown is harmless — `prune` collects stale resources on the next `isolate`. Removing the
worktree directory itself is Keiran's call, never an agent's, because `prd.md` dies with it.

## Limits

31 concurrent isolated worktrees (Redis `--databases 64`, two per slot). `bin/worktree-setup prune`
reclaims slots from deleted worktrees.
