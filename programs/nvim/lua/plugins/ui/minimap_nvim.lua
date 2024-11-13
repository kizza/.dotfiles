return {
  {
    -- "kizza/minimap.nvim",
    dir = "~/Code/kizza/minimap.nvim",
    enabled = true,
    -- event = "VeryLazy",
    -- event = { "BufEnter", "BufReadPost", "BufNewFile" },
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      map = {
        width = 10
      }
    },
    config = function(_, opts)
      local minimap = require("minimap")
      -- vim.cmd [[
      --   source ~/.config/nvim/config/highlight.vim
      -- ]]
      minimap.setup(opts)
      minimap.create_default_highlights()
    end,
  }
}
