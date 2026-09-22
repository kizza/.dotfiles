---
name: worktree-isolation
description: >
  Give a lookout worktree its own Postgres and Redis via `bin/worktree-setup isolate`, when specs
  interfere with each other, a branch adds a migration, or two runs need to overlap. Use on symptoms
  as much as requests — inexplicable spec failures (missing seed data, foreign key violations, a
  schema that doesn't match the branch), "the test database is shared", "specs are fighting each
  other". Applies to any worktree however it was made: created by the `worktrees` skill, by hand, or
  rooted under ~/.herdr/.
---

# Isolating a lookout worktree

A worktree arrives provisioned but **not** isolated. This skill closes that last gap, and is the one
escalation an agent may decide on for itself.

## The two tiers

| Tier | How you get it | What it buys |
|---|---|---|
| provisioned | `bin/worktree-setup run` — automatic, via `.githooks/post-checkout` | `.envrc.overrides`, `.envrc.secrets`, gems, `node_modules`, own dev-server ports |
| isolated | `bin/worktree-setup isolate` | own **dev + test Postgres databases**, own **Redis logical DBs** |

Per `doc/how_to/use_git_worktrees.md`: `run` sets `WORKTREE_SLOT`, `DEV_HTTP_PORT` and
`DEV_HTTPS_PORT`. Only **`isolate`** sets `DEV_DATABASE_NAME`, `TEST_DATABASE_NAME` and
`REDIS_DB_OFFSET`. Until then the worktree shares the main checkout's databases.

Check which tier you are on with `direnv exec . bin/worktree-setup status` — `DEV DB` / `TEST DB` /
`REDIS` rows appear only once isolated.

**A worktree that skipped the hook has neither tier.** No `.envrc.worktree`, no ports, possibly no
`.envrc.secrets` — so `bin/rails` fails for want of `RAILS_MASTER_KEY`. Git honours exactly one
`core.hooksPath`, so anything repointing it (beads has) silently disables every repo hook. Confirm
with `git config --show-origin core.hooksPath`, restore with `git config core.hooksPath .githooks`,
then `direnv exec . bin/worktree-setup run` to catch the worktree up. `isolate` does not depend on
`run` having happened.

## When to escalate

**The test database is shared.** `config/database.yml:27` defaults `TEST_DATABASE_NAME` to
`lookout_test`, so every non-isolated worktree and the main checkout share one test database. Two
things then break:

- `spec/support/database.rb:9` runs `DatabaseCleaner.clean_with(:truncation)` at `before(:suite)`.
  A second rspec starting **truncates every table out from under** a run already in flight.
- `spec/rails_helper.rb:73` calls `maintain_test_schema!`, so a branch with a new migration reloads
  the schema — and anything else running is now testing against the wrong schema.

Escalate when specs fail in ways that make no sense: missing seed data, foreign key violations,
materialized views that vanished, a schema that doesn't match the branch. **Do not debug the specs.**

Sequential use of a shared test database is fine; concurrency is what breaks it. So the trigger is
not "this is a worktree" but "two runs will overlap" or "this branch changes the schema".

## Doing it

```bash
cd "$WORKTREE_PATH"
direnv exec . bin/worktree-setup isolate   # own databases and Redis, dev seeded
direnv exec . bin/worktree-setup status    # confirm what got assigned
```

Run it under `direnv exec .` — outside the nix shell there is no project Ruby and it fails before it
starts. Add `TLW_SKIP_1PASSWORD=1` in an agent shell, which cannot authorize `op` and otherwise waits
out a 60s authorization timeout.

`isolate` is safe to re-run and skips if already isolated. It copies no files, so it never conflicts
with anything symlinked into the worktree. It calls `prune` at the end, garbage-collecting databases
belonging to worktrees that no longer exist.

It also marks the dev database up to date with `db/data_schema.rb`, so existing data migrations are
recorded as applied rather than left pending for the next `bin/update`. Data migrations the branch
itself adds still show as pending, as they should.

Not every odd spec failure is the database. `Propshaft::MissingAssetError` on `public.css` is a
worktree with no built assets, which isolation does not touch — symlink them from the main checkout
(`ln -sfn "$REPO_ROOT"/app/assets/builds/* app/assets/builds/`) rather than precompiling. The
`worktrees` skill covers it.

## Footgun: never add a symlinked file to `.worktreeinclude`

`bin/worktree/run` copies its file list with `FileUtils.cp_r`, which raises
`ArgumentError: same file` when source and destination are the same file — and `SYNC CONFIG` is a
fatal step, so **`run` exits 1** for every worktree thereafter. Its list is `.envrc.overrides`,
`.envrc.secrets`, `.worktreeinclude`, plus every path named inside `.worktreeinclude`.

So `.worktreeinclude` may name only real files. Anything symlinked into a worktree — a shared
`.claude/settings.local.json`, for instance — must stay out of it.

## Tearing down

Only when Keiran explicitly asks:

```bash
direnv exec . bin/worktree-setup teardown   # drops this worktree's databases, flushes its Redis DBs
```

Skipping teardown is harmless — `prune` collects stale resources on the next `isolate`. Removing the
worktree directory itself is Keiran's call, never an agent's.

## Limits

31 concurrent isolated worktrees (Redis `--databases 64`, two per slot). `bin/worktree-setup prune`
reclaims slots from deleted worktrees. Each full `bin/dev` runs Puma, four Sidekiq workers and two
asset watchers, so isolate freely but do not leave dev servers running.
