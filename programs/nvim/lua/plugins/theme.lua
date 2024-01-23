return {
  -- {
  --   "RRethy/nvim-base16",
  --   enabled = false,
  --   lazy = false,
  --   priority = 101,
  --   -- init = function()
  --   --   vim.opt.termguicolors = true -- True color support
  --   -- end,
  --   config = function()
  --     vim.cmd[[
  --       " Conditional colours
  --       " Load base 16 theme from terminal
  --       " if filereadable(expand("~/.vimrc_background"))
  --       "   let base16colorspace=256
  --       "   source ~/.vimrc_background
  --       " endif
  --       colorscheme base16-gruvbox-dark-medium

  --       " Load highlights
  --       source ~/.config/nvim/config/highlight.vim
  --     ]]
  --   end
  -- },
  {
    "chriskempson/base16-vim",
    lazy = false,
    priority = 101,
    config = function()
      vim.cmd[[
        " Conditional colours
        " Load base 16 theme from terminal
        if filereadable(expand("~/.vimrc_background"))
          let base16colorspace=256
          source ~/.vimrc_background
        endif

        " Load highlights
        source ~/.config/nvim/config/highlight.vim
      ]]
    end
  },
}
