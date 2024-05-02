return {
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-surround", event = "VeryLazy" },
  { "tpope/vim-commentary", event = "VeryLazy" },
  { "vim-scripts/ReplaceWithRegister", event = "VeryLazy" },
  { "wellle/targets.vim", event = "VeryLazy" },
  { "tpope/vim-abolish", event = "VeryLazy" },
  { "tpope/vim-unimpaired", event = "VeryLazy" },
  { "kana/vim-textobj-lastpat", dependencies = { "kana/vim-textobj-user" }, event = "VeryLazy" },
  { "kana/vim-textobj-indent", dependencies = { "kana/vim-textobj-user" }, event = "VeryLazy" },
  { "kizza/vim-textobj-block", dependencies = { "kana/vim-textobj-user" }, event = "VeryLazy" },
  {
    "kizza/joinery.nvim",
    keys = {
      {"<leader>j", "<cmd>Joinery<cr>", desc = "Joinery"}
    },
  },
  {
    "kizza/jump-from-treesitter.nvim",
    keys = {
      { "gd", ":call jump_from_treesitter#jump()<CR>", desc = "Jump from treesitter" },
    },
    init = function()
      vim.g.jump_from_treesitter_fallback = "lua vim.lsp.buf.definition()"
    end
  },
  {
    "kizza/vim-reorder-buffers",
    keys = {
      { "<leader>gT", "<cmd>ShiftBufferLeft<cr>",  desc = "Shift buffers left" },
      { "<leader>gt", "<cmd>ShiftBufferRight<cr>", desc = "Shift buffers right" },
    },
  },
  {
    "FooSoft/vim-argwrap",
    keys = {
      { "<leader>aw", "<cmd>ArgWrap<cr>", desc = "ArgWrap" },
    },
    init = function()
      vim.g.argwrap_tail_comma = 1
    end
  },
}
