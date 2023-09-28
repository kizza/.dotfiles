return {
  {
    "chriskempson/base16-vim",
    lazy = false,
  },
  {,
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        win_options = {
          winblend = 0,
        },
        override = function(conf)
          if vim.api.nvim_win_get_width(0) <= 40 then
            conf.width = 50
          end
          return conf
        end
      },
      select = {
        enabled = true,
        backend = { "telescope" },
      }
    }
  },
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {
        rb = {
          icon = "",
          color = "#701516",
          cterm_color = "124",
          name = "Rb",
        }
      }
    }
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter"
    },
    opts = {
      indent = {
        char = "│",
        highlight = {
          "IndentBlanklineCharSkip",
          "IndentBlanklineChar",
        }
      },
      scope = {
        show_start = false,
        show_end = false,
        highlight = {
          "IndentBlanklineContextChar",
        }
      }
    },
    config = function(_, opts)
      vim.cmd[[
        hi IndentBlanklineChar ctermfg=18
        hi IndentBlanklineCharSkip ctermfg=0
        hi IndentBlanklineContextChar ctermfg=8
      ]]
      require("ibl").setup(opts)
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    priority = 100,
    dependencies = {
      "RRethy/nvim-base16",
      "arkav/lualine-lsp-progress",
    },
    config = function(_, opts)
      local theme = require'lualine.themes.auto'
      theme.normal  = { a = { fg = 0, bg = 12, gui = "bold" }, b = {}, c = {} }
      theme.insert  = { a = { fg = 0, bg = 10, gui = "bold" }, b = {}, c = {} }
      theme.visual  = { a = { fg = 0, bg = 11, gui = "bold" }, b = {}, c = {} }
      theme.command = { a = { fg = 2, bg = 0, gui = "bold" }, b = {}, c = {} }
      theme.replace = { a = { fg = 0, bg = 13, gui = "bold" }, b = {}, c = {} }
      theme.terminal = theme.insert

      local modes = { "normal", "insert", "visual", "command", "replace" }
      for _, mode in pairs(modes) do
        theme[mode]["b"] = { fg = 7, bg = 19 } -- Branch
        theme[mode]["c"] = { fg = 7, bg = 18, gui = "italic" } -- File
        theme[mode]["x"] = { fg = 20, bg = 18, gui = "" } -- Meta
      end

      local filename_section = {
        'filename',
        path = 1,
        shorting_target = 40,
        symbols = {modified = '', readonly = '', unnamed = '[No Name]', newfile = '[New]'}
      }

      local line_location_section = function()
        return vim.fn.line(".").."/"..vim.fn.line("$")
      end

      require("lualine").setup {
        options = {
          theme = theme,
          disabled_filetypes = { statusline = { "fzf" } },
          extensions = { "nvim-tree" },
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diagnostics'}, -- 'diff',
          lualine_c = {filename_section},
          lualine_x = {{'filetype', colored = true }},
          lualine_y = {
            {
              'lsp_progress',
              display_components = { 'lsp_client_name', { 'percentage' }},
              colors = {
                percentage  = 20,
                title  = "cyan",
                message  = "cyan",
                spinner = "cyan",
                lsp_client_name = 20,
                use = true,
              },
              separators = {
                component = ' ',
                progress = ' | ',
                message = { pre = '(', post = ')'},
                percentage = { pre = '', post = '%% ' },
                title = { pre = '', post = ': ' },
                lsp_client_name = { pre = '', post = '' },
                spinner = { pre = '', post = '' },
                message = { commenced = 'In Progress', completed = 'Completed' },
              },
              timer = { progress_enddelay = 500, spinner = 1000, lsp_client_name_enddelay = 1000 },
              spinner_symbols = { '🌑 ', '🌒 ', '🌓 ', '🌔 ', '🌕 ', '🌖 ', '🌗 ', '🌘 ' },
            },
            {'progress'}
          },
          lualine_z = {line_location_section}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {filename_section},
          lualine_x = {line_location_section},
          lualine_y = {},
          lualine_z = {}
        },
      }
    end,
  },
}
