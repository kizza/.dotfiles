return {
  {
    -- Seamless navigation between tmux panes and vim splits
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
  },
  {
    -- easily interact with tmux from vim
    "preservim/vimux",
    keys = {
      { "<leader>rl", "<cmd>VimuxInterruptRunner <bar> VimuxRunLastCommand<cr>" },
      { "<leader>rr", "<cmd>VimuxOpenRunner<cr>" },
      { "<leader>rp", "<cmd>VimuxPromptCommand<cr>" },
      { "<leader>rP", "<cmd>call VimuxPromptCommandThenClose()<cr>" },
      { "<leader>rc", "<cmd>VimuxClearTerminalScreen<cr>" },
      { "<leader>rt", "<cmd>VimuxTogglePane<cr>" },
    },
    init = function()
      vim.g.VimuxPromptString = "Run: "
      -- Only ever adopt a pane vimux titled itself, so paddck's sidebar slot — or any other
      -- neighbour in the window — is never mistaken for the runner.
      vim.g.VimuxRunnerName = "test-runner"
    end
  },
}
