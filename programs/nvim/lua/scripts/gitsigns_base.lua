-- The revision gitsigns diffs against, for the editor rather than a buffer.
--
-- Two things move the base, and they cooperate:
--
-- `:GitBase <revision>` sets it for the whole editor — every buffer already open and every buffer
-- opened afterwards — because a base that only applied to the buffer under the cursor would have the
-- signs mean something different in each window. Bare `:GitBase` puts it back to the index. Any
-- revision is accepted, but completion offers only the two worth having: the default branch, for
-- everything the branch has changed, and the branch tip, for everything not yet in it.
--
-- The rebase follow takes over while an interactive rebase is parked on an `edit`: HEAD *is* the
-- commit under the knife then, so pointing gitsigns at that commit's parent makes every sign, hunk
-- and preview describe what the commit itself changed rather than what merely happens to be
-- unstaged. When the rebase ends the base goes back to whatever `:GitBase` had chosen, not blindly to
-- the index.
--
-- Either way the base is never silent: `M.status()` feeds the statusline, so signs are never quietly
-- describing a diff other than the one they appear to.
local M = {}

-- What `:GitBase` chose, passed to gitsigns as typed — it understands `main`, `HEAD~1`, `~`, `^` and
-- bare shas alike. Nil means the index, gitsigns' own default.
local chosen_base = nil

-- The commit currently being followed through a rebase, as `{ short, subject }`. Also the record of
-- having announced it, so walking a `git review-commits` pass re-announces on each stop while a plain
-- refocus stays quiet.
local rebase_commit = nil

local function git_output(...)
  local completed = vim.system({ "git", ... }, { text = true, cwd = vim.fn.getcwd() }):wait()
  if completed.code ~= 0 then
    return nil
  end
  return vim.trim(completed.stdout)
end

-- The revision gitsigns was last handed, so a buffer that attaches too late to have read it can be
-- pointed at the same one. Nil means the index, and costs the re-point nothing.
local applied_base = nil

local function change_base(revision)
  applied_base = revision

  local gitsigns_loaded, gitsigns = pcall(require, "gitsigns")
  if gitsigns_loaded then
    gitsigns.change_base(revision, true) -- `true` being every buffer, including ones opened later
  end
end

-- Statusline text, and nil whenever the signs mean what they normally mean so the component can hide
-- itself. The rebase wording is deliberately different: that base moves on its own as the rebase
-- walks, where a `:GitBase` one sits still until it is changed.
function M.status()
  if rebase_commit then
    return "rebase " .. rebase_commit.short
  end
  return chosen_base and ("base " .. chosen_base)
end

function M.set(revision)
  chosen_base = revision
  change_base(revision)
  vim.notify(revision, vim.log.levels.INFO, { title = "Signs now diff against" })
end

function M.reset()
  chosen_base = nil
  change_base(nil)
  vim.notify("Signs back to the index", vim.log.levels.INFO, { title = "Base reset" })
end

local function rebase_directory()
  local directory = git_output("rev-parse", "--git-path", "rebase-merge")
  if not directory then
    return nil
  end

  if not vim.startswith(directory, "/") then
    directory = vim.fs.joinpath(vim.fn.getcwd(), directory)
  end

  return vim.uv.fs_stat(directory) and directory
end

-- Git writes the `amend` marker only when it stops on an `edit`. It is absent during a conflict
-- stop, where HEAD is the last commit successfully applied and its parent is the wrong base.
local function stopped_on_edit()
  local directory = rebase_directory()
  return directory ~= nil and vim.uv.fs_stat(vim.fs.joinpath(directory, "amend")) ~= nil
end

-- The revision the rebase wants signs pointed at, or nil when none is parked on an `edit`.
local function rebase_base()
  if not stopped_on_edit() then
    return nil
  end

  -- A root commit has no parent, so diff it against the empty tree to keep it reading as added.
  local EMPTY_TREE = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
  return git_output("rev-parse", "--verify", "--quiet", "HEAD~1") and "HEAD~1" or EMPTY_TREE
end

local function announce_rebase_commit()
  local head = git_output("log", "-1", "--format=%h %s")
  if head and head ~= (rebase_commit and rebase_commit.head) then
    rebase_commit = { head = head, short = head:match("^%S+") }
    vim.notify(head, vim.log.levels.INFO, { title = "Reviewing commit — signs show its own diff" })
  end
end

function M.sync()
  local base = rebase_base()

  if base then
    change_base(base)
    announce_rebase_commit()
  elseif rebase_commit then
    rebase_commit = nil
    change_base(chosen_base)
    vim.notify("Signs back to " .. (chosen_base or "the index"), vim.log.levels.INFO, { title = "Rebase finished" })
  end
end

-- The base gitsigns should start life with, for `gitsigns.setup { base = ... }`, so buffers opened
-- from then on attach already pointed at it. Announcing is left to `M.sync()`, which runs a tick
-- later with the notify plugin up.
function M.initial()
  applied_base = rebase_base() or chosen_base
  return applied_base
end

-- Buffers re-pointed since gitsigns loaded, so each one costs at most one pass and a re-point can
-- never answer the update it provoked.
local repointed = {}

-- Every buffer open before gitsigns loads attaches against the index however the base is set,
-- because gitsigns' own `plugin/gitsigns.lua` calls `setup()` first: ours runs second, and by then
-- attach has already read the base off a config we had not written to yet. Re-pointing those buffers
-- is what saves reloading the one you land in — the first file of `nvim $(git committed)`.
--
-- It waits for gitsigns to announce the buffer, because until then there is nothing to re-point:
-- `change_base` walks the cache, and an attach still in flight has left an entry there with no git
-- object on it yet. A re-point that arrives in that window sets the revision and loses the diff,
-- which is the worst of both — signs that claim the right base while showing the wrong one.
local function repoint_late_attach(bufnr)
  if not applied_base or not bufnr or repointed[bufnr] then
    return
  end

  local cache_loaded, cache = pcall(require, "gitsigns.cache")
  local entry = cache_loaded and cache.cache[bufnr]
  if not entry or not entry.git_obj then
    return
  end

  repointed[bufnr] = true
  if entry.git_obj.revision ~= applied_base then
    change_base(applied_base)
  end
end

-- The branch being replayed, since `--show-current` is empty while a rebase has HEAD detached — and
-- detached is exactly where `git review-commits` leaves you.
local function current_branch()
  local directory = rebase_directory()
  local head_name = directory and vim.fs.joinpath(directory, "head-name")
  if head_name and vim.uv.fs_stat(head_name) then
    local branch = vim.trim(vim.fn.readfile(head_name)[1] or "")
    if branch ~= "" then
      return (branch:gsub("^refs/heads/", ""))
    end
  end

  local branch = git_output("branch", "--show-current")
  return branch ~= "" and branch or nil
end

-- Whatever `origin/HEAD` points at, falling back the way `git review-commits` does.
local function default_branch()
  local origin_head = git_output("symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD")
  if origin_head then
    return (origin_head:gsub("^origin/", ""))
  end

  return git_output("rev-parse", "--verify", "--quiet", "main") and "main" or "master"
end

-- The two bases worth offering, in the order you reach for them. Anything else can still be typed.
local function complete_revision(argument_lead)
  local candidates = {}
  for _, revision in ipairs({ default_branch(), current_branch() }) do
    if revision and not vim.tbl_contains(candidates, revision) and vim.startswith(revision, argument_lead) then
      table.insert(candidates, revision)
    end
  end

  return candidates
end

function M.setup()
  vim.api.nvim_create_user_command("GitBase", function(command)
    if command.args == "" then
      M.reset()
    else
      M.set(command.args)
    end
  end, {
    nargs = "?",
    complete = complete_revision,
    desc = "Diff signs against a revision in every buffer — bare resets to the index",
  })

  vim.api.nvim_create_user_command("RebaseBaseSync", M.sync, {
    desc = "Re-point gitsigns at the commit an interactive rebase is stopped on",
  })

  -- `VeryLazy` matters as much as `VimEnter` here: gitsigns is loaded on that event, so at `VimEnter`
  -- the require above still fails and the base is silently left alone until something later refocuses
  -- the window. Both are registered because either may be the one that first finds gitsigns loaded,
  -- and re-pointing at a base already set is a no-op.
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "DirChanged" }, {
    group = vim.api.nvim_create_augroup("my_gitsigns_base", { clear = true }),
    callback = vim.schedule_wrap(M.sync),
  })

  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("my_gitsigns_base_very_lazy", { clear = true }),
    pattern = "VeryLazy",
    callback = vim.schedule_wrap(M.sync),
  })

  -- gitsigns fires this per buffer once its cache entry is whole, which is the earliest moment a
  -- buffer that attached before our base existed can be pointed at it.
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("my_gitsigns_base_late_attach", { clear = true }),
    pattern = "GitSignsUpdate",
    callback = function(event)
      repoint_late_attach(event.data and event.data.buffer)
    end,
  })
end

return M
