return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- {
      --   "s",
      --   mode = { "n", "x", "o" },
      --   function()
      --     require("flash").jump()
      --   end,
      --   desc = "Flash",
      -- },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Flash Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
  {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    config = function()
      require("hlslens").setup {}

      local kopts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap('n', 'n',
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'N',
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)
    end
  },
  {
    -- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { "<leader>dt", "<cmd>TroubleToggle<cr>", desc = "Toggle trouble" },
  },
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {
      builtin_marks = { ".", "<", ">", "^" },
    },
    init = function()
      vim.api.nvim_create_user_command(
        'MarksDeleteAll',
        ':delm! | delm A-Z0-9',
        { desc = 'Delete all marks' }
      )
    end,
    config = function()
      require("marks").setup {}
      vim.cmd [[hi MarkSignHL ctermfg=17]]
    end
  },
  {
    -- A code outline window for skimming and quick navigation
    "stevearc/aerial.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>at", "<cmd>AerialToggle<cr>",  desc = "Toggle aerial" },
      { "<leader>an", "<cmd>AerialNavOpen<cr>", desc = "Aerial Nav Open" },
    },
    opts = {
      icons = {
        Array = "󱡠",
        Boolean = "󰨙",
        Class = "ﴯ",
        Collapsed = " ",
        Color = "",
        Constant = "",
        Constructor = "",
        Enum = "",
        EnumMember = "",
        Event = "",
        Field = "",
        File = "",
        Folder = "",
        Function = "",
        Interface = "",
        Keyword = "",
        Method_Prev = "",
        Method = "",
        Module = "",
        Namespace = "󰦮 ",
        Null = "󰟢 ",
        Number = "󰎠 ",
        Object = " ",
        Operator = "",
        Package = "",
        Property = "ﰠ",
        Reference = "",
        Snippet = "",
        String = "",
        Struct = "פּ",
        Text = "",
        TypeParameter = "",
        Unit = "塞",
        Value = "",
        Variable = ""
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '[a', '<cmd>AerialPrev<cr>', { buffer = bufnr })
        vim.keymap.set('n', ']a', '<cmd>AerialNext<cr>', { buffer = bufnr })
      end,
      nav = {
        win_opts = {
          cursorline = true,
          winblend = 0,
        },
      },
      close_on_select = true,
    },
  },
  {
    -- The OG fuzzy finder
    "junegunn/fzf",
    enabled = true,
    dependencies = {
      "junegunn/fzf.vim"
    },
    build = ":call fzf#install()",
    event = "VeryLazy",
    init = function()
      vim.g.fzf_layout = { down = "80%" }
      vim.g.fzf_preview_window = { "right:50%", "ctrl-/" }
      vim.g.fzf_action = {
        ["ctrl-t"] = "!withvimsplit",
        ["ctrl-x"] = "split",
        ["ctrl-v"] = "vsplit",
        ["ctrl-o"] = "!open",
      }

      -- Keyword = Purple,  Function = Aqua,  Const = Red,  Type = Green
      vim.g.fzf_colors = {
        fg = { "fg", "Normal" },
        bg = { "bg", "Normal" },
        hl = { "fg", "Function" },
        ["hl+"] = { "fg", "Variable" },
        ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
        ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
        info = { "fg", "Keyword" },
        border = { "fg", "LineNr" },
        prompt = { "fg", "Function" },
        pointer = { "fg", "Function" },
        marker = { "fg", "Label" },
        spinner = { "fg", "Label" },
        header = { "fg", "Comment" }
      }

      vim.cmd [[
        hi fzf1 ctermfg=lightgrey ctermbg=black
        hi fzf2 ctermfg=lightgrey ctermbg=black
        hi fzf3 ctermfg=lightgrey ctermbg=black
      ]]
    end
  },
  {
    -- A well-integrated, low-configuration buffer list that lives in the tabline
    -- 'ap/vim-buftabline'
    'kizza/vim-buftabline',
    -- dir = "~/Code/kizza/vim-buftabline",
    lazy = false,
    config = function()
      vim.g.buftabline_indicators = 1
      vim.g.buftabline_numbers = 2 -- idx of buffer
      vim.g.buftabline_modified_char = ""

      vim.cmd [[
        hi BufTabLineFill ctermbg=19
        hi BufTabLineCurrent ctermbg=0 ctermfg=2 cterm=bold
        hi BufTabLineActive ctermbg=18 ctermfg=2
        hi BufTabLineHidden ctermbg=19 ctermfg=7
        hi BufTabLineModifiedCurrent ctermbg=0 ctermfg=2 cterm=italic,bold
        hi BufTabLineModifiedActive ctermbg=18 ctermfg=2 cterm=italic
        hi BufTabLineModifiedHidden ctermbg=19 ctermfg=7 cterm=italic
      ]]
    end
  },
  {
    "jlanzarotta/bufexplorer",
    event = "VeryLazy",
  },
}
