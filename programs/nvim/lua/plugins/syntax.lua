return {
  -- { "sheerun/vim-polyglot", event = "BufRead" }
  { "chrisbra/Colorizer",     event = "VeryLazy" },
  -- { 'jiangmiao/auto-pairs', event = "VeryLazy" },
  { 'mg979/vim-visual-multi', event = "VeryLazy" },
  -- Vim plugin for automatically highlighting other uses of the word under the cursor
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    opts = {
      under_cursor = false,
      filetypes_denylist = {
        'NvimTree',
        'fugitive',
      }
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      local hi = require("colours").hi
      hi("IlluminatedWordText", { bg = 18, underline = true })
    end
  },
  -- match-up is a plugin that lets you highlight, navigate, and operate on sets of matching text
  {
    "andymass/vim-matchup",
    enabled = true,
    lazy = false,
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  {
    "nvim-treesitter/playground",
    cmd = {
      "TSInstall",
      "TSUpdate",
      "TSPlaygroundToggle",
      "TSHighlightCapturesUnderCursor",
    },
    keys = {
      { "<leader>rg", "<cmd>TSHighlightCapturesUnderCursor<cr>", desc = "Highlight under cursor" },
    }
  },
  {
    "lmeijvogel/vim-yaml-helper",
    ft = "yaml",
    init = function()
      vim.g["vim_yaml_helper#auto_display_path"] = 0
    end
  },
  { "vim-ruby/vim-ruby", ft = "ruby" },
  { "tpope/vim-rails",   ft = "ruby" },
}
