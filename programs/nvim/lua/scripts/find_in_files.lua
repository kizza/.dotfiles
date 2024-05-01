local Input = require("nui.input")
local NuiText = require("nui.text")
local event = require("nui.utils.autocmd").event

local M = {}

function M.build_input(on_submit)
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
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
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
    vim.cmd("Rg " .. value)
  end

  -- mount/open the component
  local input = M.build_input(on_submit)
  input:mount()
  local colours = require("colours")
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
  end)
end

return M
