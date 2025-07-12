return {
  { import = "plugins.ui.status" },
  -- { import = "plugins.ui.minimap" },
  { import = "plugins.ui.minimap_nvim" },
  { import = "plugins.ui.noice" },
  -- { import = "plugins.ui.notify" },  Trying snacks instead

  {
    "MunifTanjim/nui.nvim"
  },
  {
    -- A stylised diagnostics floatign panel to replace the default one
    -- It seems to *always* appear on cursor move... so not quite my tempo presently
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    enabled = false,    -- noisey until can disable cursor autocmd
    priority = 1000,    -- needs to be loaded in first
    opts = {
      transparent_bg = false,
      transparent_cursorline = true,
      use_icons_from_diagnostic = true,
      -- preset = "powerline"
      multilines = {
        -- Enable multiline diagnostic messages
        enabled = true,
        -- Always show messages on all lines for multiline diagnostics
        always_show = true,
      },
    },
    config = function(_, opts)
      require('tiny-inline-diagnostic').setup(opts)
      -- vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = false,
    event = "VeryLazy",
    opts = {
      enable = true
    },
    config = function(_, opts)
      require 'treesitter-context'.setup(opts)
      vim.cmd [[
        hi TreesitterContextBottom cterm=underline
      ]]
    end
  },
  -- {  Using snacks
  --   "stevearc/dressing.nvim",
  --   enabled = true,
  --   event = "VeryLazy",
  --   opts = {
  --     input = {
  --       enabled = true,
  --       win_options = {
  --         winblend = vim.opt.pumblend:get(),
  --         winhighlight = "NormalFloat:FloatInput",
  --       },
  --       override = function(conf)
  --         if vim.api.nvim_win_get_width(0) <= 40 then
  --           conf.width = 50
  --         end
  --         return conf
  --       end
  --     },
  --     select = {
  --       enabled = true,
  --       backend = { "telescope" },
  --     },
  --   },
  --   init = function()
  --     vim.cmd("hi FloatInput ctermbg=red")
  --   end
  -- },
  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        progress = {
          ignore = {
            "ruby_lsp",
          },
        },
        notification = {
          view = {
            icon_separator = " ",                   -- Separator between group name and icon
            group_separator = "---",                -- Separator between notification groups
            group_separator_hl = "FidgetSeparator", -- Highlight group used for group separator
            render_message =                        -- How to render notification messages
                function(msg, cnt)
                  return cnt == 1 and msg or string.format("✨ (%dx) %s", cnt, msg)
                end,
          },
          window = {
            normal_hl = "Fidget",              -- Base highlight group in the notification window
            winblend = vim.opt.winblend:get(), -- Background color opacity in the notification window
            border = "none",                   -- Border around the notification window
            zindex = 45,                       -- Stacking priority of the notification window
            max_width = 0,                     -- Maximum width of the notification window
            max_height = 0,                    -- Maximum height of the notification window
            x_padding = 1,                     -- Padding from right edge of window boundary
            y_padding = 0,                     -- Padding from bottom edge of window boundary
            align = "bottom",                  -- How to align the notification window
            relative = "editor",               -- What the notification window position is relative to
          },
          configs = {
            {
              annote_style = "Question",
              debug_annote = "DEBUG",
              debug_style = "Comment",
              error_annote = "ERROR",
              error_style = "ErrorMsg",
              group_style = "Title",
              icon = "❰❰",
              icon_style = "Special",
              info_annote = " ",
              info_style = "Question",
              name = "Notifications",
              ttl = 5,
              update_hook = function(item)
                print(vim.inspect(item))
              end,
              warn_annote = "WARN",
              warn_style = "WarningMsg"
            }
          }
        }
      }
    end,
    config = function(_, opts)
      require("fidget").setup(opts)
      local theme = require("colours")
      require("highlights").register(function()
        theme.hi("Fidget", { bg = 18, fg = 8 })
        theme.hi("FidgetSeparator", { bg = 0, fg = 6 })
      end)
    end
  },
  {
    "nvim-tree/nvim-web-devicons",
    opts = function()
      local colours = require("colours")
      return {
        override = {
          ["rb"] = {
            icon = "",
            color = colours.get(colours.red),
            cterm_color = colours.red,
            name = "Rb",
          },
          ["erb"] = {
            icon = "",
            color = colours.get(colours.yellow),
            cterm_color = colours.yellow,
            name = "Erb",
          },
          ["prawn"] = {
            icon = "",
            color = colours.get(colours.yellow),
            cterm_color = colours.yellow,
            name = "Prawn",
          },
          ["sass"] = {
            icon = "",
            color = colours.get(colours.magenta),
            cterm_color = colours.magenta,
            name = "Sass",
          },
          ["yaml"] = {
            icon = "󰦨",
            color = colours.get(colours.blue),
            cterm_color = colours.blue,
            name = "Yaml",
          },
          ["yml"] = {
            icon = "󰦨",
            color = colours.get(colours.blue),
            cterm_color = colours.blue,
            name = "Yml",
          },
        }
      }
    end
  },
  {
    -- Highlight undo/redo changes (like yank text does)
    "y3owk1n/undo-glow.nvim",
    event = "VeryLazy",
    enabled = false,
    opts = function()
      local colours = require("colours")
      return {
        animation = {
          enabled = true,
          duration = 300,
          animtion_type = "fade",
          window_scoped = true,
        },
        highlights = {
          undo = { hl_color = { bg = colours.get(3) } },
          redo = { hl_color = { bg = colours.get(2) } },
        }
      }
    end,
    keys = {
      {
        "u",
        function()
          require("undo-glow").undo()
        end,
        mode = "n",
        desc = "Undo with highlight",
        noremap = true,
      },
      {
        "C-r",
        function()
          require("undo-glow").redo()
        end,
        mode = "n",
        desc = "Redo with highlight",
        noremap = true,
      },
      {
        "p",
        function()
          require("undo-glow").paste_below()
        end,
        mode = "n",
        desc = "Paste below with highlight",
        noremap = true,
      },
      {
        "P",
        function()
          require("undo-glow").paste_above()
        end,
        mode = "n",
        desc = "Paste above with highlight",
        noremap = true,
      },
    },
    -- init = function(_, opts)
    -- local hi = require("colours").hi
    -- hi("UgUndo", { fg = 0, bg = 5, underline = true })
    -- hi("UgRedo", { fg = 0, bg = 5, underline = true })

    -- local undo_glow = require("undo-glow")
    -- undo_glow.setup(opts)

    -- vim.keymap.set("n", "u", require("undo-glow").undo, { noremap = true, silent = true })
    -- vim.keymap.set("n", "C-r", require("undo-glow").redo, { noremap = true, silent = true })
    -- -- vim.keymap.set("n", "p", require("undo-glow").paste_below, { noremap = true, silent = true })
    -- -- vim.keymap.set("n", "P", require("undo-glow").paste_above, { noremap = true, silent = true })
    -- -- vim.keymap.set("n", "n", require("undo-glow").search_next, { noremap = true, silent = true })
    -- -- vim.keymap.set("n", "N", require("undo-glow").search_prev, { noremap = true, silent = true })
    -- -- vim.api.nvim_create_autocmd("TextYankPost", {
    -- --   desc = "Highlight when yanking (copying) text",
    -- --   callback = require("undo-glow").yank,
    -- -- })
    -- end,
  },
  -- {
  --   "lukas-reineke/indent-blankline.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter"
  --   },
  --   opts = {
  --     indent = {
  --       char = "│",
  --       highlight = {
  --         -- "IndentBlanklineCharSkip",
  --         "IndentBlanklineChar",
  --       }
  --     },
  --     scope = {
  --       show_start = false,
  --       show_end = false,
  --       highlight = {
  --         "IndentBlanklineContextChar",
  --       }
  --     }
  --   },
  --   config = function(_, opts)
  --     local hi = require("colours").hi
  --     hi("IndentBlanklineChar", { fg = 18 })
  --     hi("IndentBlanklineCharSkip", { fg = 0 })
  --     hi("IndentBlanklineContextChar", { fg = 8 })
  --     -- vim.cmd [[
  --     --   hi IndentBlanklineChar ctermfg=18
  --     --   hi IndentBlanklineCharSkip ctermfg=0
  --     --   hi IndentBlanklineContextChar ctermfg=8
  --     -- ]]
  --     require("ibl").setup(opts)
  --   end
  -- },
}
