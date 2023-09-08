return {
  {
    "sindrets/diffview.nvim",
    cmd = {"DiffviewOpen"},
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup({
        keymaps = {
          view = {
            { "n", "[h", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
            { "n", "]h", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
          }
        }
      })
    end
  },
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
    keys = {
      { "<leader>hp", "<cmd>GitGutterPreviewHunk<cr>", desc = "Preview hunk" },
      { "<leader>hs", "<cmd>GitGutterStageHunk<cr>", desc = "Stage hunk" },
      { "<leader>hu", "<cmd>GitGutterUndoHunk<cr>", desc = "Undo hunk" },
      { "[h", "<cmd>GitGutterPrevHunk<cr>", desc = "Previous git hunk" },
      { "]h", "<cmd>GitGutterNextHunk<cr>", desc = "Next git hunk" },
    },
    init = function()
      vim.g.gitgutter_realtime = 1
      vim.g.gitgutter_sign_added = '│'
      vim.g.gitgutter_sign_modified = '│'
      vim.g.gitgutter_sign_removed = '│'
      vim.g.gitgutter_sign_modified_removed = '││'
    end,
  },
}
