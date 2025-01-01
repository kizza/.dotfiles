local Input = require("nui.input")
local NuiText = require("nui.text")
local event = require("nui.utils.autocmd").event
local colours = require("colours")

local M = {}

function M.open_backdrop(zindex)
  local backdrop_buf = vim.api.nvim_create_buf(false, true)
  local backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines,
    row = 0,
    col = 0,
    style = "minimal",
    focusable = false,
    zindex = zindex
  })
  vim.api.nvim_set_hl(0, "KizzaBackdrop", { bg = "#000000", default = true })
  vim.api.nvim_set_option_value("winblend", 80, { scope = "local", win = backdrop_win })
  vim.api.nvim_set_option_value("winhighlight", "Normal:KizzaBackdrop", { scope = "local", win = backdrop_win })
  vim.bo[backdrop_buf].buftype = "nofile"
  vim.bo[backdrop_buf].filetype = "kizza_backdrop"
  return backdrop_win
end

function M.build_input(on_submit)
  local exists = pcall(vim.api.nvim_get_hl, 0, { name = "FindFilesBorder", link = true })
  if not exists then
    colours.hi("FindFilesBorder", { fg = 3 })
  end
  return Input({
    position = "50%",
    size = { width = 60 },
    border = {
      style = "rounded",
      text = {
        top = " Find in files ",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FindFilesBorder",
    },
  }, {
    prompt = "  ",
    default_value = "",
    on_submit = on_submit
  })
end

function M.assign_keymap(input, key, fun)
  input:map("n", key, function() fun() end, { noremap = true })
  input:map("i", key, function() fun() end, { noremap = true })
end

function M.find_in_files()
  local mode = "normal"

  local function on_submit(value)
    -- value = vim.fn.shellescape(value)
    if mode == "normal" then
      local regex_escape_chars = ("[]()"):gsub(".", "%%" .. "%0") -- Escapes each char, for substitution below eg. %[%]%(%)
      value = value:gsub("([" .. regex_escape_chars .. "])", "\\%1")
    end
    local command = "Rg " .. value
    vim.fn.histadd("cmd", command) -- Add to command history
    vim.cmd(command)               -- Execute the command
  end

  -- mount/open the component
  local input = M.build_input(on_submit)
  local backdrop_win = M.open_backdrop(input._.win_config.zindex - 5)
  input:mount()
  colours.hi("MySpecialChar", { fg = colours.cyan })
  vim.cmd [[syn match MySpecialChar ""]]

  -- Toggle mode with <Tab>
  local function toggle_mode()
    mode = mode == "normal" and "regex" or "normal"
    local display_mode = mode == "regex" and "Regex" or ""
    input.border:set_text("bottom", NuiText(display_mode, "Comment"), "right")
  end
  M.assign_keymap(input, "<Tab>", toggle_mode)

  -- Close with <Esc>
  local function close_manually()
    input:unmount()
  end
  M.assign_keymap(input, "<Esc>", close_manually)

  -- unmount component when cursor leaves buffer
  input:on(event.BufLeave, function()
    input:unmount()
    vim.api.nvim_win_close(backdrop_win, true)
  end)
end

return M
