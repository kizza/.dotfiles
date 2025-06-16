return {
  { "chrisbra/Colorizer",     event = "VeryLazy" },
  { 'mg979/vim-visual-multi', event = "VeryLazy" },
  {
    -- Vim plugin for automatically highlighting other uses of the word under the cursor
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    opts = {
      providers = { "lsp", "treesitter", "regex" },
      under_cursor = false,
      filetypes_denylist = {
        'NvimTree',
        'fugitive',
      }
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      local colours = require("colours")
      colours.hi("IlluminatedWordText", { underline = true })
      -- colours.hi("IlluminatedWordText", { bg = colours.darken(4, 0.7), underline = true })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "IlluminatedWordText" })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "IlluminatedWordText" })
      -- colours.hi("IlluminatedWordRead", { underline = true })
      -- colours.hi("IlluminatedWordWrite", { underline = true })
    end
  },
  {
    -- Highlights and provides motions/textobjects for matching elements (eg. if else end)
    "andymass/vim-matchup",
    lazy = false, -- seems to need to boot up?
    config = function(_, opts)
      -- Not a lua plugin
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.api.nvim_set_hl(0, "MatchWord", { link = "MatchParen" })
    end
  },
  {
    "lmeijvogel/vim-yaml-helper",
    ft = "yaml",
    init = function()
      vim.g["vim_yaml_helper#auto_display_path"] = 0
    end
  },
  -- { "vim-ruby/vim-ruby",     ft = "ruby" }, -- Try with just treesitter
  { "tpope/vim-rails",       ft = "ruby" },
  { "klimeryk/vim-monkey-c", ft = "monkey-c" },
}
