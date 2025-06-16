local M = {
  "rcarriga/nvim-notify",
  enabled = true,
  event = "VeryLazy",
}

M.opts = {
  -- stages = 'slide', -- for non termgui
  -- background_colour = 'NotifyBackground', -- for non termgui
  render = 'wrapped-compact',
  level = 2, -- DEBUG=1, INFO=2, WARN=3, ERROR=4
  top_down = false,
  minimum_width = 30,
  max_width = 100,
  timeout = 3000,
}

function M.config(_, opts)
  require("notify").setup(opts)
  -- vim.notify = require("notify")
  M.highlight()
end

function M.highlight()
  local colours = require("colours")
  local hi = colours.hi
  hi("NotifyBackground", { bg = colours.black })
  hi("NotifyINFOIcon", { fg = colours.cyan })
  hi("NotifyDEBUGIcon", { fg = colours.magenta })
  hi("NotifyWARNIcon", { fg = colours.yellow })
  hi("NotifyERRORIcon", { fg = colours.red })
  hi("NotifyTRACEIcon", { fg = 17 })

  for _, level in pairs({ "INFO", "DEBUG", "WARN", "ERROR", "TRACE" }) do
    vim.cmd("highlight clear Notify" .. level .. "Border")
    vim.cmd("highlight link Notify" .. level .. "Border Notify" .. level .. "Icon")

    vim.cmd("highlight clear Notify" .. level .. "Title")
    vim.cmd("highlight link Notify" .. level .. "Title Notify" .. level .. "Icon")
  end
end

return M
