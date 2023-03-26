return {
  -- { "sheerun/vim-polyglot", event = "BufRead" }
  { "chrisbra/Colorizer", event = "VeryLazy" },
  { 'folke/tokyonight.nvim', event = "VeryLazy" },
  -- Vim plugin for automatically highlighting other uses of the word under the cursor
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    init = function()
      vim.cmd[[
        hi IlluminatedWordText ctermbg=18
      ]]
    end
  },
  -- match-up is a plugin that lets you highlight, navigate, and operate on sets of matching text
  {
    "andymass/vim-matchup",
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
  { "tpope/vim-rails", ft = "ruby" },
}
