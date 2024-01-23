local M = {
  "rcarriga/nvim-notify",
  enabled = true,
  event = "VeryLazy",
}

M.opts = {
  stages = 'slide', -- for non termgui
  background_colour = 'NotifyBackground', -- for non termgui
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
  vim.cmd[[
    highlight NotifyINFOIcon ctermfg=cyan
    highlight NotifyDEBUGIcon ctermfg=magenta
    highlight NotifyWARNIcon ctermfg=yellow
    highlight NotifyERRORIcon ctermfg=red
    highlight NotifyTRACEIcon ctermfg=17
  ]]

  for _, level in pairs({"INFO", "DEBUG", "WARN", "ERROR", "TRACE"}) do
    vim.cmd("highlight clear Notify"..level.."Border")
    vim.cmd("highlight link Notify"..level.."Border Notify"..level.."Icon")

    vim.cmd("highlight clear Notify"..level.."Title")
    vim.cmd("highlight link Notify"..level.."Title Notify"..level.."Icon")
  end
end

return M
