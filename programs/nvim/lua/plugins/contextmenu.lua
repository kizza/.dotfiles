return {
  {
    -- "kizza/contextmenu.nvim",
    dir = "~/Code/kizza/nvim/contextmenu.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local contextmenu = require("contextmenu")
      contextmenu.setup(opts)

      -- Stylize with background theme
      local theme = require("colours")
      local icon_colour = 3
      local background_colour = 18
      theme.hi("CmenuNormal", { fg = background_colour, bg = icon_colour })

      local theme_colour = 0
      background_colour = theme.darken(theme_colour, 0.3, { to = "#000000" })
      theme.hi("CmenuNormal", { fg = background_colour, bg = icon_colour })
      theme.hi("CmenuVirtualText", { bold = true })
      theme.hi("Cmenu", { bg = background_colour })
      -- theme.hi("CmenuSel", { bg = theme.darken(theme_colour, 0.2, { towards = "#000000" }) })
    end,
  }
}
