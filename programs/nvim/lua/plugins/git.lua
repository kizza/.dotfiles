return {
  {
    "tpope/vim-fugitive",
    cmd = { "G" },
  },
  {
    "rhysd/git-messenger.vim",
    keys = {
      { "<leader>gm", "<cmd>GitMessenger<cr>", desc = "Open git messenger" },
    },
  },
  {
    "airblade/vim-gitgutter",
    event = "VeryLazy",
    init = function()
      vim.g.gitgutter_realtime = 1
      vim.g.gitgutter_sign_added = ''
      vim.g.gitgutter_sign_modified = ''
      vim.g.gitgutter_sign_removed = ''
      vim.g.gitgutter_sign_modified_removed = '⇎'
    end,
  },
}
