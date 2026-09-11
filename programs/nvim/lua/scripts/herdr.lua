-- A vim-test strategy for herdr, standing in for vimux. Vimux cannot work here whatever the setting:
-- every one of its calls shells out to `tmux`, and herdr is not tmux. It fails loudly rather than
-- quietly because theme.lua sets `vim.env.TMUX` to keep base16 honest, so vimux believes it is inside
-- a session and tmux then reads that value as a socket path — the "error connecting to v:true".
--
-- Same shape as vimux otherwise: one runner pane split off the editor's, reused for every run, found
-- again by its label so it survives an nvim restart, and left unfocused so the editor keeps the cursor.
local M = {}

local RUNNER_LABEL = "test-runner"
local RUNNER_DIRECTION = "right"
-- The runner's share of the split it opens in. herdr's --ratio is the calling pane's share, hence
-- the flip below; an adopted runner keeps whatever width it was last dragged to.
local RUNNER_SHARE = 0.4

local runner_pane_id = nil
local last_command = nil

-- Most commands answer in JSON: a result on stdout, an error on stderr with exit 1. The ones that
-- only act — `pane run`, `send-keys` — answer with nothing at all, so there a clean exit is the whole
-- result. Anything else unparseable, a dead server or a missing binary, comes back as the message.
local function herdr(...)
  local command = { vim.env.HERDR_BIN_PATH or "herdr" }
  vim.list_extend(command, { ... })

  local spawned, completed = pcall(function()
    return vim.system(command, { text = true }):wait()
  end)
  if not spawned then
    return nil, "herdr is not on the path"
  end

  local output = vim.trim(completed.stdout ~= "" and completed.stdout or completed.stderr or "")
  if output == "" then
    if completed.code ~= 0 then
      return nil, "herdr exited " .. completed.code
    end

    return {}
  end

  local decoded, response = pcall(vim.json.decode, output)
  if not decoded or type(response) ~= "table" then
    return nil, output
  end
  if response.error then
    return nil, response.error.message or vim.inspect(response.error)
  end

  return response.result
end

local function editor_pane()
  local result, failure = herdr("pane", "current", "--current")
  if not result then
    return nil, failure
  end

  return result.pane
end

local function still_open(pane_id)
  return pane_id ~= nil and herdr("pane", "get", pane_id) ~= nil
end

-- Only a runner in the editor's own tab counts; the label is free to repeat in other tabs.
local function adopt_runner(tab_id)
  local result = herdr("pane", "list")
  if not result then
    return nil
  end

  for _, pane in ipairs(result.panes) do
    if pane.label == RUNNER_LABEL and pane.tab_id == tab_id then
      return pane.pane_id
    end
  end
end

local function open_runner()
  local result, failure = herdr(
    "pane", "split", "--current",
    "--direction", RUNNER_DIRECTION,
    "--ratio", tostring(1 - RUNNER_SHARE),
    "--cwd", vim.fn.getcwd(),
    "--no-focus"
  )
  if not result then
    return nil, failure
  end

  herdr("pane", "rename", result.pane.pane_id, RUNNER_LABEL)

  return result.pane.pane_id
end

local function ensure_runner()
  if still_open(runner_pane_id) then
    return runner_pane_id
  end

  local pane, failure = editor_pane()
  if not pane then
    return nil, failure
  end

  runner_pane_id = adopt_runner(pane.tab_id)
  if runner_pane_id then
    return runner_pane_id
  end

  runner_pane_id, failure = open_runner()

  return runner_pane_id, failure
end

local function report(failure)
  vim.notify("herdr: " .. failure, vim.log.levels.ERROR)
end

-- vim-test hands the strategy one shell command; `pane run` sends it with the Enter.
function M.run(command)
  local pane_id, failure = ensure_runner()
  if not pane_id then
    return report(failure or "no runner pane")
  end

  last_command = command

  local _, run_failure = herdr("pane", "run", pane_id, command)
  if run_failure then
    report(run_failure)
  end
end

function M.run_last()
  if not last_command then
    return report("nothing has been run yet")
  end

  M.interrupt()
  M.run(last_command)
end

function M.interrupt()
  if still_open(runner_pane_id) then
    herdr("pane", "send-keys", runner_pane_id, "ctrl+c")
  end
end

function M.zoom()
  if still_open(runner_pane_id) then
    herdr("pane", "zoom", runner_pane_id, "--toggle")
  end
end

function M.close()
  if still_open(runner_pane_id) then
    herdr("pane", "close", runner_pane_id)
  end

  runner_pane_id = nil
end

return M
