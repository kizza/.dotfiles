return {
  { "tpope/vim-repeat",   event = "VeryLazy" },
  { "tpope/vim-surround", event = "VeryLazy" },
  -- {
  --   "kylechui/nvim-surround",
  --   version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
  --   event = "VeryLazy",
  --   opts = {},
  -- },
  {
    "tpope/vim-commentary",
    event = "VeryLazy",
    init = function(_, opts)
      vim.cmd("autocmd FileType monkey-c setlocal commentstring=//%s")
    end
  },
  {
    "vim-scripts/ReplaceWithRegister",
    event = "VeryLazy",
    -- keys = {
    --   { "gr", "<Plug>ReplaceWithRegisterOperator", nowait = true, desc = "ReplaceWithRegisterOperator" },
    -- },
  },
  { "wellle/targets.vim",       event = "VeryLazy" },
  { "tpope/vim-abolish",        event = "VeryLazy" },
  { "tpope/vim-unimpaired",     event = "VeryLazy" },

  { "kana/vim-textobj-lastpat", dependencies = { "kana/vim-textobj-user" }, event = "VeryLazy" },  -- Support custom textobjectx
  { "kana/vim-textobj-indent",  dependencies = { "kana/vim-textobj-user" }, event = "VeryLazy" },  -- A nice indent one
  { "kizza/vim-textobj-block",  dependencies = { "kana/vim-textobj-user" }, event = "VeryLazy", }, -- Custom dirctional indent and block
  -- { "numToStr/Comment.nvim",           lazy = false },
  {
    -- Magical "auto" increments of selection based on treesitter scopes
    "RRethy/nvim-treesitter-textsubjects",
    enabled = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,           -- Doesn't seem to work when lazy
    opts = {
      prev_selection = 'o', -- Go backwards in selection scope
      keymaps = {
        ['.'] = 'textsubjects-smart',
        [';'] = 'textsubjects-container-outer',
        ['i;'] = 'textsubjects-container-inner',
      },
    },
    config = function(_, opts)
      require('nvim-treesitter-textsubjects').configure(opts)
    end
  },
  {
    -- Update comment string within contexts
    "JoosepAlviste/nvim-ts-context-commentstring",
    enabled = false,
    event = "VeryLazy",
    init = function()
      vim.g.skip_ts_context_commentstring_module = true
    end,
    config = function(_, opts)
      require("ts_context_commentstring").setup(opts)
    end
  },
  {
    "kizza/joinery.nvim",
    keys = {
      { "<leader>j", "<cmd>Joinery<cr>", desc = "Joinery" }
    },
  },
  {
    "kizza/vim-reorder-buffers",
    cmd = { "ShiftBufferLeft", "ShiftBufferRight", "MoveBufferTo", "CloseBuffersUntil", "CloseBuffersAfter" },
    keys = {
      { "<leader>gT",  "<cmd>ShiftBufferLeft<cr>",   desc = "Shift buffers left" },
      { "<leader>gt",  "<cmd>ShiftBufferRight<cr>",  desc = "Shift buffers right" },
      { "<leader>tm1", "<cmd>MoveBufferTo 1<cr>",    desc = "Move buffer to first" },
      { "<leader>tm2", "<cmd>MoveBufferTo 2<cr>",    desc = "Move buffer to second" },
      { "<leader>tm3", "<cmd>MoveBufferTo 3<cr>",    desc = "Move buffer to third" },
      { "<leader>tm4", "<cmd>MoveBufferTo 4<cr>",    desc = "Move buffer to fourth" },
      { "<leader>tm5", "<cmd>MoveBufferTo 5<cr>",    desc = "Move buffer to fifth" },
      { "<leader>tm6", "<cmd>MoveBufferTo 6<cr>",    desc = "Move buffer to sixth" },
      { "<leader>tm7", "<cmd>MoveBufferTo 7<cr>",    desc = "Move buffer to seventh" },
      { "<leader>tm8", "<cmd>MoveBufferTo 8<cr>",    desc = "Move buffer to eighth" },
      { "<leader>tm9", "<cmd>MoveBufferTo 9<cr>",    desc = "Move buffer to nineth" },
      { "<leader>txh", "<cmd>CloseBuffersUntil<cr>", desc = "Close buffers before" },
      { "<leader>txl", "<cmd>CloseBuffersAfter<cr>", desc = "Close buffers after" },
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
