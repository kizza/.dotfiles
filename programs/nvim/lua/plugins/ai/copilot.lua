return {
  "github/copilot.vim",
  event = "VeryLazy",
  init = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_filetypes = {
      codecompanion = false -- disable copilot in codecompanion filetype
    }
  end,
}
