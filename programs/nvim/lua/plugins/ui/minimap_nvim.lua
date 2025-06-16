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
      width = 10
    },
    config = function(_, opts)
      local theme = require("colours")
      theme.hi("MinimapNormal", { fg = 20 })
      theme.hi("MinimapViewport", { fg = 7, bg = theme.darken(19, 0.7) })
      theme.hi("MinimapCursorLine", { fg = 3, bg = theme.darken(3, 0.7) })

      local minimap = require("minimap")
      minimap.setup(opts)
      -- minimap.create_default_highlights()
    end,
  }
}
