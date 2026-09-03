-- Yanking to `+` from a session running on another machine, so the text lands in the clipboard of
-- the machine you are actually sitting at.
--
-- Neovim finds a clipboard tool by probing, and `$TMUX` is tested before OSC 52 is (see
-- `provider/clipboard.vim`). On a remote host that means `tmux load-buffer`: `"+y` fills the
-- *remote* tmux paste buffer and the Mac clipboard never hears about it. OSC 52 writes the yank
-- into the terminal's own escape stream instead, which tmux passes through and ssh carries home, so
-- `"+y` over ssh reaches the same clipboard as ⌘C.
--
-- Only the copy half goes over the wire. Reading a clipboard back over OSC 52 means asking the
-- terminal and waiting up to ten seconds for an answer most terminals refuse to give, so every copy
-- is kept here and `"+p` replays it instantly. Text copied in a local app still arrives the way it
-- always did, through the terminal's own paste.
--
-- `clipboard` stays unset when a local provider is reachable, as it is on the Mac: yanks are none of
-- the system clipboard's business until `"+y` says otherwise.
local M = {}

-- The last copy, as the `{ lines, register_type }` pair the paste half has to hand back. A register
-- cannot stand in for this — inside a provider callback `+` routes straight back through the
-- provider, so `vim.fn.setreg("+", …)` is swallowed and the register reads back empty.
--
-- One value covers both registers because `+` and `*` are one clipboard on the Mac at the far end of
-- the connection, the way pbcopy has them: OSC 52's second selection is X11's primary, which nothing
-- over there reads.
local copied = nil

-- Resolved on the first copy rather than at startup, so a session that never yanks to the clipboard
-- never loads it.
local send_to_terminal = nil

local function copy(lines, register_type)
  copied = { lines, register_type }

  send_to_terminal = send_to_terminal or require("vim.ui.clipboard.osc52").copy("+")
  send_to_terminal(lines, register_type)
end

-- A two element list rather than two return values: the provider is vimscript, and only the first
-- value survives the crossing — returning the type alongside would lose it and paste every yank back
-- charwise, so a linewise `"+y` would land mid-line.
local function paste()
  return copied or { {}, "v" }
end

local function claim_clipboard()
  vim.g.clipboard = {
    name = "osc52",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

local function tmux_has_ssh_environment()
  if not vim.env.TMUX or vim.fn.executable("tmux") ~= 1 then
    return false
  end

  local ssh_environment = vim.fn.system({ "tmux", "show-environment", "-g" })

  return vim.v.shell_error == 0 and ssh_environment:match("SSH_") ~= nil
end

local function has_local_clipboard_display()
  return vim.env.WAYLAND_DISPLAY or vim.env.DISPLAY or vim.fn.has("macunix") == 1
end

local function should_claim_clipboard()
  if vim.env.SSH_TTY or vim.env.SSH_CONNECTION or tmux_has_ssh_environment() then
    return true
  end

  -- `wl-copy`/`xclip` being installed does not help from a plain SSH shell: without the display
  -- socket, Neovim's Linux providers have nowhere to send the clipboard.
  return not has_local_clipboard_display()
end

function M.setup()
  -- A tmux session on the far end outlives the ssh connection that started it, and tmux only
  -- refreshes `SSH_CONNECTION` on reattach, so ask both Neovim's env and tmux's env before letting
  -- Neovim fall back to a remote clipboard provider.
  if should_claim_clipboard() then
    claim_clipboard()
  end
end

return M
