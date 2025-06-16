return {
  {
    "folke/snacks.nvim",
    dev = false, -- playing locally
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    config = function(_, opts)
      require('snacks').setup(opts)

      local colours = require("colours")
      -- colours.hi("SnacksIndent", { fg = 19 })
      -- colours.hi("SnacksIndentScope", { fg = 20 }) -- Current

      -- Find all available highlights with
      -- Snacks.picker.highlights({pattern = "hl_group:^Snacks"})
      vim.defer_fn(function()
        colours.hi("SnacksPickerGitStatusUntracked", { fg = colours.cyan, italic = true })
        colours.hi("SnacksPickerDir", { fg = 20 })
        -- hi("SnacksPickerInputNormal", { bg = colours.black })
        colours.hi("SnacksIndent", { fg = colours.darken(8, 0.4) })
        colours.hi("SnacksPickerTree", { link = "SnacksIndent" })
        colours.hi("SnacksIndentScope", { fg = colours.darken(5, 0.1) }) -- Current
        colours.hi("SnacksDashboardFile", { fg = 7 })                    -- Current
      end, 100)

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd [[cab sp lua Snacks.picker]]

      -- Commands
      vim.api.nvim_create_user_command('Notifications', 'lua require("snacks.picker").notifications()',
        { desc = 'Open notifications (via snacks)' })
      vim.api.nvim_create_user_command('Highlights', 'lua require("snacks.picker").highlights()',
        { desc = 'Open highlights (via snacks)' })
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      styles = {
        float = {
          backdrop = false, -- 95, -- deault 60
        },
        select = {
          width = "30%",
        },
        -- notification = {
        --   -- border = require("config.ui.border").default_border,
        --   wo = {
        --     winblend = vim.opt.winblend:get(),
        --   },
        -- },
      },
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = table.concat({
            "                                                                     ",
            "       ████ ██████           █████      ██                     ",
            "      ███████████             █████                             ",
            "      █████████ ███████████████████ ███   ███████████   ",
            "     █████████  ███    █████████████ █████ ██████████████   ",
            "    █████████ ██████████ █████████ █████ █████ ████ █████   ",
            "  ███████████ ███    ███ █████████ █████ █████ ████ █████  ",
            " ██████  █████████████████████ ████ █████ █████ ████ ██████ ",
          }, "\n"),
        },
        sections = {
          { section = "header" },
          { section = "keys", padding = 2 },
          { icon = " ", title = "Recent Files", section = "recent_files", cmd = true, indent = 2, padding = 1 },
          -- { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
          {
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = "git status --short --branch --renames",
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 2,
          },
          { section = "startup", padding = { 2, 1 } },
        },
      },
      explorer = {
        enabled = true,
        win = {
          list = {
            winhighlight = "Normal:Normal",
            wo = {
              winhighlight = "Normal:Normal",
            }
          }
        }
      },
      indent = {
        enabled = true,
        hl = {
          "SnacksIndent1",
          "SnacksIndent2",
          "SnacksIndent3",
          "SnacksIndent4",
          "SnacksIndent5",
          "SnacksIndent6",
          "SnacksIndent7",
          "SnacksIndent8",
        },
      },
      input = { enabled = true },
      picker = {
        enabled = true,
        formatters = {
          file = {
            truncate = 80,
          }
        },
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            auto_close = false,
            jump = { close = true },
            -- winblend = vim.opt.winblend:get(), -- Adjust transparency level (0-100)
            win = {
              list = {
                wo = {
                  winhighlight = "Normal:Normal",
                }
              }
            }
          },
          files = {
            hidden = true,
            ignored = true,
          },
        }
      },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = {
        enabled = true,
        -- {
        --   animate = {
        --     duration = { step = 15, total = 250 },
        --     easing = "linear",
        --   },
        --   -- faster animation when repeating scroll after delay
        --   animate_repeat = {
        --     delay = 100, -- delay in ms before using the repeat animation
        --     duration = { step = 5, total = 50 },
        --     easing = "linear",
        --   },
        --   -- what buffers to animate
        --   -- filter = function(buf)
        --   --   return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= "terminal"
        --   -- end,
        -- }
      },
      statuscolumn = { enabled = true },
      words = { enabled = false },
      zen = {
        win = {
          width = 0,
          backdrop = { transparent = true, blend = 80 },
        }
      },
    },
    keys = {
      -- Top Pickers & Explorer
      {
        "<C-p>",
        function()
          vim.fn.system('git rev-parse --is-inside-work-tree')
          if vim.v.shell_error == 0 then
            Snacks.picker.git_files()
          else
            Snacks.picker.files()
          end
        end,
        desc = "Find Files"
      },
      { "<leader>gl", function() Snacks.picker.git_log() end,                           desc = "Git Log" },
      { "<leader>gs", function() Snacks.picker.git_status() end,                        desc = "Git Status" },
      { "<leader>n",  function() Snacks.explorer({ auto_close = true }) end,            desc = "File Explorer" },
      -- { "<leader>z",  function() Snacks.zen() end,                           desc = "Toggle Zen Mode" },
      { "<leader>ff", function() Snacks.picker.files() end,                             desc = "Find Files" },
      { "<leader>fo", function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "Find Recent" },
      { "<leader>fb", function() Snacks.picker.buffers() end,                           desc = "Find Buffers" },
      { "<leader>fl", function() Snacks.picker.lines() end,                             desc = "Find Lines" },
      { "<leader>fu", function() Snacks.picker.grep_word() end,                         desc = "Grep Word" },
      { "<leader>fg", function() Snacks.picker.grep() end,                              desc = "Grep" },
      { "<leader>fc", function() Snacks.picker.git_log() end,                           desc = "Find Commit" },
      { "<leader>fm", function() Snacks.picker.marks() end,                             desc = "Find Mark" },
      { "<leader>fr", function() Snacks.picker.resume() end,                            desc = "Resume find" },
      { "<leader>fs", function() Snacks.picker.search_history() end,                    desc = "Find Recent Search" },
    },
  }
}
