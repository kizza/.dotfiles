return {
  -- Null ls (treat things as if they were LSP)
  "nvimtools/none-ls.nvim",
  enabled = false,
  event = "VeryLazy",
  config = function(_, opts)
    local builtins = require("null-ls.builtins")

    local use_bundler = function(options, custom_diagnostic_config)
      local diagnostic_config = custom_diagnostic_config or vim.diagnostic.config()
      return {
        command = "bundle",
        args = vim.list_extend({ "exec", options.command }, options.args), -- prefix args with "exec {command}"
        diagnostic_config = diagnostic_config,
      }
    end

    local rubocop = require("lsp.null-ls.rubocop")

    -- lua print(vim.inspect(require("null-ls.builtins").formatting.rubycop))
    require 'null-ls'.setup {
      debounce = 1000,
      debug = true,
      notify_format = "[HERE null-ls] %s",
      -- diagnostics_format = "#{m} #{s}", -- already includes source it seems
      fallback_severity = vim.diagnostic.severity.INFO,
      update_in_insert = false,
      on_attach = require 'plugins.lsp'.on_attach,
      sources = {
        -- rubocop.with(use_bundler(rubocop._opts)),
        builtins.diagnostics.rubocop,
        -- builtins.diagnostics.rubocop.with(use_bundler(builtins.diagnostics.rubocop._opts)),
        builtins.formatting.rubocop.with(use_bundler(builtins.formatting.rubocop._opts)),
        builtins.diagnostics.erb_lint.with(use_bundler(builtins.diagnostics.erb_lint._opts, { virtual_text = true })),
        -- builtins.formatting.erb_lint.with(use_bundler(builtins.formatting.erb_lint._opts)),

        -- builtins.diagnostics.erb_format.with(use_bundler(builtins.diagnostics.erb_format._opts)),
        -- builtins.formatting.erb_format.with(use_bundler(builtins.formatting.erb_format._opts)),
        -- builtins.completion.spell,
      },
    }
  end
}
