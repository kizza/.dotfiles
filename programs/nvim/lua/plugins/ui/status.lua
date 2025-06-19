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
  local theme           = require 'lualine.themes.auto'
  local colours         = require("colours")
  local c               = colours.get

  -- Base theme
  theme.normal          = { a = { fg = c(0), bg = c(12), gui = "bold" }, b = {}, c = {} }
  theme.insert          = { a = { fg = c(0), bg = c(10), gui = "bold" }, b = {}, c = {} }
  theme.visual          = { a = { fg = c(0), bg = c(11), gui = "bold" }, b = {}, c = {} }
  theme.command         = { a = { fg = c(2), bg = c(0), gui = "bold" }, b = {}, c = {} }
  theme.replace         = { a = { fg = c(0), bg = c(13), gui = "bold" }, b = {}, c = {} }
  theme.terminal        = theme.insert
  theme.inactive        = vim.deepcopy(theme.normal)

  -- Standardize selected sections
  local modes           = { "normal", "insert", "visual", "command", "replace" }
  local styled_inactive = colours.darken(5, 0.7, { to = '#666666' }).hex
  for _, mode in pairs(modes) do
    theme[mode]["b"] = { fg = c(7), bg = colours.darken(5, 0.8).hex } -- Branch
    theme[mode]["c"] = { fg = c(7), bg = c(18), gui = "italic" }      -- File
    theme[mode]["x"] = { fg = styled_inactive, bg = c(18), gui = "" } -- Meta
  end

  theme.inactive.c = { fg = styled_inactive, bg = c(18), gui = "italic" } -- File

  return theme
end

function M.refresh()
  require("lualine.highlight").create_highlight_groups(M.build_theme())
end

function M.build_spinner(opts)
  local defaults = {
    -- label = " Asking...",
    symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  }
  opts = vim.tbl_extend("force", defaults, opts or {})
  opts.symbol_size = #opts.symbols

  local C = require("lualine.component"):extend()
  C.processing = false
  C.label = nil
  C.spinner_index = 1

  -- Initializer
  function C:init(options)
    C.super.init(self, options)

    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

    vim.api.nvim_create_autocmd({ "User" }, {
      -- pattern = "CodeCompanionRequest*",
      pattern = "CodeCompanion*",
      group = group,
      callback = function(request)
        if request.match == "CodeCompanionChatSubmitted" or request.match == "CodeCompanionRequestStarted" then
          self.processing = true
          self.label = " Asking"
        elseif request.match == "CodeCompanionChatStopped" or request.match == "CodeCompanionRequestFinished" then
          self.processing = false
          self.label = nil
        end
      end,
    })
  end

  -- Function that runs every time statusline is updated
  function C:update_status()
    if self.label then
      self.spinner_index = (self.spinner_index % opts.symbol_size) + 1
      return opts.symbols[self.spinner_index] .. self.label
    else
      return nil
    end
  end

  return C
end

function M.config(_, opts)
  local filename_section = {
    'filename',
    path = 1,
    shorting_target = 40,
    symbols = { modified = '', readonly = '', unnamed = '[No name]', newfile = '[New]' }
  }

  local line_location_section = function()
    return vim.fn.line(".") .. "/" .. vim.fn.line("$")
  end

  local empty = require('lualine.component'):extend()
  function empty:draw(default_highlight)
    self.status = ''
    self.applied_separator = ''
    self:apply_highlights(default_highlight)
    self:apply_section_separators()
    return self.status
  end

  local colours = require("colours")

  require("lualine").setup {
    options = {
      theme = M.build_theme(),
      section_separators = { left = '', right = '' },
      component_separators = { left = '╲', right = '╱' },
      disabled_filetypes = {
        statusline = { "fzf", "minimap" },
      },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        { 'branch', icon = { '', color = { fg = colours.get(4) } } }
      },
      lualine_c = { filename_section },
      lualine_x = { 'diagnostics', { 'filetype', colored = true } },
      lualine_y = {
        { M.build_spinner() },
        { 'progress' }
      },
      lualine_z = { line_location_section }
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { filename_section },
      lualine_x = { { 'filetype', colored = false }, line_location_section },
      lualine_y = {},
      lualine_z = {}
    },
  }
end

function M.config(_, _opts)
  build()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      vim.schedule(function() build() end)
    end,
  })
end

return M
