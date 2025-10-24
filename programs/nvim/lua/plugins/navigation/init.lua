return {
  -- { import = "plugins.navigation.tree" }, -- Using snacks isntead
  -- { import = "plugins.navigation.telescope" },
  {
    "kizza/actionmenu.nvim",
    branch = "v2",
    dev = true,
    enabled = true,
    event = "VeryLazy",
    opts = {
    },
    config = function(_, opts)
    end,
  },
  {
    "olimorris/persisted.nvim",
    event = "BufReadPre", -- Ensure the plugin loads only when a buffer has been loaded
    opts = {
      -- Your config goes here ...
    },
  },
  {
    "folke/flash.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = true,
        },
        char = {
          highlight = { backdrop = false },
        }
      },
    },
    config = function(_, opts)
      require("flash").setup(opts)

      local colours = require("colours")
      colours.hi("FlashLabel", { fg = 7, bg = colours.darken(3, 0.5) })
      vim.cmd [[hi FlashLabel guifg=#FFFFFF]]
      -- vim.cmd("hi FlashLabel guifg=#FF2FCF guibg=black")
      colours.hi("FlashCursor", { link = "FlashLabel" })
    end,
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
    "kizza/jump-from-treesitter.nvim",
    keys = {
      { "gd", ":call jump_from_treesitter#jump()<CR>", desc = "Jump from treesitter" },
    },
    init = function()
      vim.g.jump_from_treesitter_fallback = "lua vim.lsp.buf.definition()"
    end
  },
  {
    "kevinhwang91/nvim-hlslens",
    enabled = false,
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
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
    opts = {},
    cmd = { "Trouble", "TroubleToggle" },
    keys = { { "<leader>dt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle trouble diagnostics" } },
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

      local hi = require("colours").hi
      hi("MarkSignHL", { fg = 3 })
    end
  },
  {
    -- A code outline window for skimming and quick navigation
    "stevearc/aerial.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
    keys = {
      { "<leader>at", "<cmd>AerialToggle<cr>",  desc = "Toggle aerial" },
      { "<leader>an", "<cmd>AerialNavOpen<cr>", desc = "Aerial Nav Open" },
    },
    opts = {
      icons = {
        Array = "󱡠",
        Boolean = "󰨙",
        Class = "󰠱",
        Collapsed = " ",
        Color = "󰏘",
        Constant = "󰏿",
        Constructor = "",
        Enum = "",
        EnumMember = "",
        Event = "",
        Field = "",
        File = "󰈙",
        Folder = "󰉋",
        Function = "󰊕",
        Interface = "",
        Keyword = "",
        Method = "󰆧",
        Module = "",
        Namespace = "󰦮 ",
        Null = "󰟢 ",
        Number = "󰎠 ",
        Object = " ",
        Operator = "󰆕",
        Package = "",
        Property = "󰜢",
        Reference = "",
        Snippet = "",
        String = "",
        Struct = "פּ",
        Text = "",
        TypeParameter = "",
        Unit = "",
        Value = "󰎠",
        Variable = "󰀫"
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '[a', '<cmd>AerialPrev<cr>', { buffer = bufnr })
        vim.keymap.set('n', ']a', '<cmd>AerialNext<cr>', { buffer = bufnr })
      end,
      layout = {
        max_width = { 80, 0.3 },
        -- width = 80
        min_width = { 40, 0.2 }
      },
      nav = {
        win_opts = {
          cursorline = true,
          winblend = vim.opt.pumblend:get(),
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
      "junegunn/fzf.vim",
      'nvim-telescope/telescope.nvim', -- for highlight groups (TelescopeSelection)
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
      -- vim.cmd [[
      --   hi FzfPrompt ctermfg=magenta
      --   hi FzfPointer ctermfg=green
      -- ]]
      -- vim.g.fzf_colors = {
      --   fg = { "fg", "Normal" },
      --   bg = { "bg", "Normal" },
      --   hl = { "fg", "Function" },
      --   ["hl+"] = { "fg", "Variable" },
      --   ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
      --   ["bg+"] = { "bg", "TelescopeSelection", "CursorLine", "CursorColumn" },
      --   info = { "fg", "Keyword" },
      --   border = { "fg", "TelescopeBorder", "LineNr" },
      --   prompt = { "fg", "FzfPrompt" },
      --   pointer = { "fg", "FzfPointer" }, -- Then chevron > for selection
      --   marker = { "fg", "FzfMarker" }, -- Then chevron > when ticked
      --   spinner = { "fg", "Label" },
      --   header = { "fg", "Comment" }
      -- }
    end,
    config = function()
      -- The lower line segments (reset when colorscheme is set)
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
    enabled = false,
    -- dir = "~/Code/kizza/vim-buftabline",
    lazy = false,
    config = function()
      print("Doing this")
      vim.g.buftabline_indicators = 1
      vim.g.buftabline_numbers = 2 -- idx of buffer
      vim.g.buftabline_modified_char = ""

      local hi = require("colours").hi
      hi("BufTabLineFill", { bg = 18 }) -- 19 })
      hi("BufTabLineCurrent", { fg = 2, bg = 0, bold = true })
      hi("BufTabLineActive", { fg = 2, bg = 18 })
      hi("BufTabLineHidden", { fg = 7, bg = 19 })
      hi("BufTabLineModifiedCurrent", { fg = 2, bg = 0, italic = true, bold = true })
      hi("BufTabLineModifiedActive", { fg = 2, bg = 18, italic = true })
      hi("BufTabLineModifiedHidden", { fg = 7, bg = 19, italic = true })
      -- vim.cmd [[
      --   hi BufTabLineFill ctermbg=19
      --   hi BufTabLineCurrent ctermbg=0 ctermfg=2 cterm=bold
      --   hi BufTabLineActive ctermbg=18 ctermfg=2
      --   hi BufTabLineHidden ctermbg=19 ctermfg=7
      --   hi BufTabLineModifiedCurrent ctermbg=0 ctermfg=2 cterm=italic,bold
      --   hi BufTabLineModifiedActive ctermbg=18 ctermfg=2 cterm=italic
      --   hi BufTabLineModifiedHidden ctermbg=19 ctermfg=7 cterm=italic
      -- ]]
    end
  }
}
