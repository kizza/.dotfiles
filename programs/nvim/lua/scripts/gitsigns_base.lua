-- The revision gitsigns diffs against, for the editor rather than a buffer.
--
-- Two things move the base, and they cooperate:
--
-- `:GitBase <revision>` sets it for the whole editor — every buffer already open and every buffer
-- opened afterwards — because a base that only applied to the buffer under the cursor would have the
-- signs mean something different in each window. Bare `:GitBase` puts it back to the index.
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

-- A root commit has no parent, so diff it against the empty tree to keep it reading as added.
local EMPTY_TREE = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"

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

local function change_base(revision)
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

-- Git writes the `amend` marker only when it stops on an `edit`. It is absent during a conflict
-- stop, where HEAD is the last commit successfully applied and its parent is the wrong base.
local function stopped_on_edit()
  local rebase_directory = git_output("rev-parse", "--git-path", "rebase-merge")
  if not rebase_directory then
    return false
  end

  if not vim.startswith(rebase_directory, "/") then
    rebase_directory = vim.fs.joinpath(vim.fn.getcwd(), rebase_directory)
  end

  return vim.uv.fs_stat(vim.fs.joinpath(rebase_directory, "amend")) ~= nil
end

function M.sync()
  if stopped_on_edit() then
    -- A root commit has no parent, so diff it against the empty tree to keep it reading as added.
    local has_parent = git_output("rev-parse", "--verify", "--quiet", "HEAD~1")
    change_base(has_parent and "HEAD~1" or EMPTY_TREE)

    local head = git_output("log", "-1", "--format=%h %s")
    if head and head ~= (rebase_commit and rebase_commit.head) then
      rebase_commit = { head = head, short = head:match("^%S+") }
      vim.notify(head, vim.log.levels.INFO, { title = "Reviewing commit — signs show its own diff" })
    end
  elseif rebase_commit then
    rebase_commit = nil
    change_base(chosen_base)
    vim.notify("Signs back to " .. (chosen_base or "the index"), vim.log.levels.INFO, { title = "Rebase finished" })
  end
end

local function complete_revision(argument_lead)
  local refs = git_output("for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes")
  if not refs then
    return {}
  end

  return vim.tbl_filter(function(ref)
    return vim.startswith(ref, argument_lead)
  end, vim.split(refs, "\n", { trimempty = true }))
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
end

return M
