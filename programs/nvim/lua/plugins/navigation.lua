return {
  {
    -- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists
    "folke/trouble.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    keys = { "<leader>dt", "<cmd>TroubleToggle<cr>", desc = "Toggle trouble" },
  },
  {
    "chentoast/marks.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = {
      mappings = {
        set_next = "m,",
        next = "m]",
        next = "m[",
        preview = "m:",
        -- set_bookmark0 = "m0",
        -- prev = false -- pass false to disable only this default mapping
      }
    },
    init = function()
      vim.api.nvim_create_user_command(
        'DeleteAllMarks',
        ':delm! | delm A-Z0-9',
        {desc = 'Delete all marks'}
      )
    end
  },
  {
    "ThePrimeagen/harpoon",
    enabled = false,
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("harpoon").setup{}
      require("telescope").load_extension("harpoon")
    end
  },
  {
    -- A code outline window for skimming and quick navigation
    "stevearc/aerial.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    keys = {
      { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Toggle aerial" },
    },
    opts = {
      icons = {Array = "󱡠", Boolean = "󰨙", Class = "ﴯ", Collapsed = " ", Color = "", Constant = "", Constructor = "", Enum = "", EnumMember = "", Event = "", Field = "", File = "", Folder = "", Function = "", Interface = "", Keyword = "", Method_Prev = "", Method = "", Module = "", Namespace = "󰦮 ", Null = "󰟢 ", Number = "󰎠 ", Object = " ", Operator = "", Package = "", Property = "ﰠ", Reference = "", Snippet = "", String = "", Struct = "פּ", Text = "", TypeParameter = "", Unit = "塞", Value = "", Variable = ""},
      on_attach = function(bufnr)
        vim.keymap.set('n', '[a', '<cmd>AerialPrev<cr>', {buffer = bufnr})
        vim.keymap.set('n', ']a', '<cmd>AerialNext<cr>', {buffer = bufnr})
      end,
      close_on_select = true,
    },
  },
  {
    -- A file explorer tree for neovim written in lua
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "VimEnter",
    keys = {
      { "<leader>n", "<cmd>NvimTreeFindFile<cr>", desc = "Find within tree" },
      { "<leader>N", "<cmd>NvimTreeFocus<cr>", desc = "Open tree" },
    },
    opts = {
      git = {
        enable = false,
        ignore = false,
      },
      view = {
        width = 40,
        signcolumn = "no",
      },
      filters = { dotfiles = false },
      on_attach = function(bufnr)
        local api = require'nvim-tree.api'
        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        -- NERDTree mappings I prefer
        -- Change root directory
        vim.keymap.set('n', '<S-C>',
          function()
            api.tree.change_root_to_node()
            vim.fn.feedkeys("gg")
          end,
          opts('CD')
        )

        -- Move and copy
        local lib = require("nvim-tree.lib")
        -- Copy
        vim.keymap.set('n', 'mc',
          function()
            local file_src = lib.get_node_at_cursor()['absolute_path']
            vim.ui.input(
              { prompt = 'Copy to: ', default = file_src },
              function(input)
                if (input == nil) then return end
                if (input == file_src) then return print("Same path, ignoring") end

                local dir = vim.fn.fnamemodify(input, ":h") -- Create any parent dirs as required
                vim.fn.system { 'mkdir', '-p', dir }
                vim.fn.system { 'cp', '-R', file_src, input } -- Copy the file
                print("Copied to " .. input)
              end
            )
          end,
          opts('Copy file to')
        )
        -- Move
        vim.keymap.set('n', 'mm',
          function()
            local file_src = lib.get_node_at_cursor()['absolute_path']
            vim.ui.input(
              { prompt = 'Move to: ', default = file_src },
              function(input)
                if (input == nil) then return end
                if (input == file_src) then return print("Same path, ignoring") end

                local dir = vim.fn.fnamemodify(input, ":h") -- Create any parent dirs as required
                vim.fn.system { 'mkdir', '-p', dir }
                vim.fn.system { 'mv', file_src, file_dest } -- Copy the file
                print("Moved to " .. file_dest)
              end
            )
          end,
          opts('Move file to')
        )
      end,
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
      renderer = {
        icons = {
          webdev_colors = true,
          git_placement = "after",
          show = {
            git = false,
          },
          glyphs = {
            folder = {
              arrow_closed = "",
              arrow_open = "",
            },
          }
        }
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)

      vim.cmd[[
        " -- NvimTree
        " NvimTreeNormal = { fg = c.fg_sidebar, bg = c.bg_sidebar },
        " NvimTreeWinSeparator = {
        "   fg = options.styles.sidebars == "transparent" and c.border or c.bg_sidebar,
        "   bg = c.bg_sidebar,
        " },
        " NvimTreeNormalNC = { fg = c.fg_sidebar, bg = c.bg_sidebar },
        hi NvimTreeRootFolder ctermfg=magenta
        "hi NvimTreeFolderIcon ctermfg=magenta
        hi NvimTreeOpenedFolderIcon ctermfg=magenta
        hi NvimTreeFileDirty ctermfg=yellow
        " NvimTreeGitDirty = { fg = c.git.change },
        " NvimTreeGitNew = { fg = c.git.add },
        " NvimTreeGitDeleted = { fg = c.git.delete },
        " NvimTreeOpenedFile = { bg = c.bg_highlight },
        " NvimTreeSpecialFile = { fg = c.purple, underline = true },
        " NvimTreeIndentMarker = { fg = c.fg_gutter },
        " NvimTreeImageFile = { fg = c.fg_sidebar },
        hi NvimTreeSymlink cterm=italic
        hi NvimTreeExecFile cterm=italic ctermfg=yellow
      ]]

      -- Open at startup
      local open_at_start = function() -- data)
        local data = {
          file = vim.api.nvim_buf_get_name(0),
          buf = 0,
        }
        local no_name = data.file == "" and vim.bo[data.buf].buftype == "" -- buffer is a [No Name]
        local directory = vim.fn.isdirectory(data.file) == 1 -- buffer is a directory
        if not no_name and not directory then
          return
        end
        if directory then
          vim.cmd.cd(data.file)
        end
        vim.cmd("NvimTreeOpen")
      end
      open_at_start()
      -- vim.api.nvim_create_autocmd({ "VimEnter" }, {callback = open_at_start})
    end,
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          layout_strategy = 'horizontal',
          layout_config = { width = 0.98, height = 0.98 },
          mappings = {
            i = {
              ["<esc>"] = actions.close
            },
          },
          file_ignore_patterns = {
            "node_modules",
            "*.lock",
            "*.ttf",
          }
        }
      }
    end,
    config = function(_, opts)
      require('telescope').setup(opts)

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fr', builtin.resume, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>fm', builtin.marks, {})
      vim.keymap.set('n', '<leader>fc', builtin.git_bcommits, {})
      vim.keymap.set('n', '<leader>fu', function() builtin.live_grep{default_text=vim.fn.expand('<cword>')} end, {})
      vim.keymap.set( 'n', '<C-p>',
        function()
          local opts = {}
          vim.fn.system('git rev-parse --is-inside-work-tree')
          if vim.v.shell_error == 0 then
            require"telescope.builtin".git_files(opts)
          else
            require"telescope.builtin".find_files(opts)
          end
        end,
        {}
      )

      vim.cmd[[
        hi TelescopeTitle ctermfg=magenta
        hi TelescopeBorder ctermfg=19
        hi TelescopePromptPrefix ctermfg=magenta cterm=bold
        hi TelescopeSelectionCaret ctermfg=green cterm=bold
        hi TelescopeMultiIcon ctermfg=magenta cterm=bold
      ]]
    end,
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
        fg =      { "fg", "Normal" },
        bg =      { "bg", "Normal" },
        hl =      { "fg", "Function" },
        ["hl+"] =     { "fg", "Variable" },
        ["fg+"] =     { "fg", "CursorLine", "CursorColumn", "Normal" },
        ["bg+"] =     { "bg", "CursorLine", "CursorColumn" },
        info =    { "fg", "Keyword" },
        border =  { "fg", "LineNr" },
        prompt =  { "fg", "Function" },
        pointer = { "fg", "Function" },
        marker =  { "fg", "Label" },
        spinner = { "fg", "Label" },
        header =  { "fg", "Comment" }
      }

      vim.cmd[[
        hi fzf1 ctermfg=lightgrey ctermbg=black
        hi fzf2 ctermfg=lightgrey ctermbg=black
        hi fzf3 ctermfg=lightgrey ctermbg=black
      ]]
    end
  },
  {
    -- A well-integrated, low-configuration buffer list that lives in the tabline
    -- 'ap/vim-buftabline'
    dir = "~/Code/kizza/vim-buftabline",
    lazy = false,
    config = function()
      vim.g.buftabline_indicators = 1
      vim.g.buftabline_numbers = 2 -- idx of buffer
      vim.g.buftabline_modified_char = ""

      vim.cmd[[
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
