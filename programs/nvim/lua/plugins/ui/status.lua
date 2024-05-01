local M = {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  lazy = false,
  priority = 100,
  dependencies = {
    "RRethy/nvim-base16",
    "arkav/lualine-lsp-progress",
  }
}

function M.build_theme()
  local theme    = require 'lualine.themes.auto'
  -- local theme    = require 'lualine.themes.base16'
  local c        = require("colours").get

  -- theme.normal   = { a = { fg = 0, bg = 12, gui = "bold" }, b = {}, c = {} }
  theme.normal   = { a = { fg = c(0), bg = c(12), gui = "bold" }, b = {}, c = {} }
  theme.insert   = { a = { fg = c(0), bg = c(10), gui = "bold" }, b = {}, c = {} }
  theme.visual   = { a = { fg = c(0), bg = c(11), gui = "bold" }, b = {}, c = {} }
  theme.command  = { a = { fg = c(2), bg = c(0), gui = "bold" }, b = {}, c = {} }
  theme.replace  = { a = { fg = c(0), bg = c(13), gui = "bold" }, b = {}, c = {} }
  theme.terminal = theme.insert
  theme.inactive = theme.normal

  local modes = { "normal", "insert", "visual", "command", "replace" }
  for _, mode in pairs(modes) do
    theme[mode]["b"] = { fg = c(7), bg = c(19) }                 -- Branch
    theme[mode]["c"] = { fg = c(7), bg = c(18), gui = "italic" } -- File
    theme[mode]["x"] = { fg = c(20), bg = c(18), gui = "" }      -- Meta
  end

  return theme
end

function M.refresh()
  require("lualine.highlight").create_highlight_groups(M.build_theme())
end

function M.config(_, opts)
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
      theme = M.build_theme(),
      disabled_filetypes = {
        statusline = { "fzf", "minimap" },
      },
      extensions = { "nvim-tree" },
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diagnostics'}, -- 'diff',
      lualine_c = {filename_section},
      lualine_x = {{'filetype', colored = true }},
      lualine_y = {
        -- {
        --   'lsp_progress',
        --   display_components = { 'lsp_client_name', { 'percentage' }},
        --   colors = {
        --     percentage  = 20,
        --     title  = "cyan",
        --     message  = "cyan",
        --     spinner = "cyan",
        --     lsp_client_name = 20,
        --     use = true,
        --   },
        --   separators = {
        --     component = ' ',
        --     progress = ' | ',
        --     message = { pre = '(', post = ')'},
        --     percentage = { pre = '', post = '%% ' },
        --     title = { pre = '', post = ': ' },
        --     lsp_client_name = { pre = '', post = '' },
        --     spinner = { pre = '', post = '' },
        --     message = { commenced = 'In Progress', completed = 'Completed' },
        --   },
        --   timer = { progress_enddelay = 500, spinner = 1000, lsp_client_name_enddelay = 1000 },
        --   spinner_symbols = { '🌑 ', '🌒 ', '🌓 ', '🌔 ', '🌕 ', '🌖 ', '🌗 ', '🌘 ' },
        -- },
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
end

return M
