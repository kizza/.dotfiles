local M = {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "jose-elias-alvarez/null-ls.nvim",
  }
}

function M.set_diagnostic_signs()
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl }) -- numhl = ""?
  end
end

function M.set_diagnostic_bindings()
  vim.api.nvim_set_keymap('n', '<leader>do', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<leader>d[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<leader>d]', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<leader>da', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<leader>gh', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
end

function M.format_asynchronously(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.lsp.buf_request(
    bufnr,
    "textDocument/formatting",
    vim.lsp.util.make_formatting_params({}),
    function(err, res, ctx)
      if err then
        local err_msg = type(err) == "string" and err or err.message
        -- you can modify the log message / level (or ignore it completely)
        vim.notify("lsp formatting: " .. err_msg, vim.log.levels.WARN)
        return
      end

      -- don't apply results if buffer is unloaded or has been modified
      if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
        return
      end

      if res then
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent noautocmd update")
        end)
      end
    end
  )
end

function M.on_attach(client, bufnr)
  -- print("Attached "..client.name)
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'Format',
      function(input) vim.lsp.buf.format {id = client.id, async = input.bang} end,
      {bang = true, range = true, desc = 'Format using lsp'}
    )

    vim.keymap.set({ 'n', 'x' }, '<leader>df', '<cmd>Format!<cr>', {buffer = bufnr})

    local augroup = vim.api.nvim_create_augroup("LspFormat", {})
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        M.format_asynchronously(bufnr)
      end,
    })
  end
end

function M.start_servers()
  local use_solargraph_diagnostics = false
  require("lspconfig").solargraph.setup {
    cmd = {"bundle", "exec", "solargraph", "stdio"},
    on_attach = M.on_attach,
    settings = {
      solargraph = {
        diagnostics = use_solargraph_diagnostics,
      },
    },
    init_options = {
      formatting = use_solargraph_diagnostics,
    },
  }

  -- Null ls (treat things as if they were LSP)
  local builtins = require("null-ls.builtins")
  local use_bundler = function(provided_args)
    return {
      command = "bundle",
      args = vim.list_extend({ "exec", "rubocop" }, provided_args),
    }
  end
  require'null-ls'.setup {
    on_attach = M.on_attach,
    sources = {
      builtins.diagnostics.rubocop.with(use_bundler(builtins.diagnostics.rubocop._opts.args)),
      builtins.formatting.rubocop.with(use_bundler(builtins.formatting.rubocop._opts.args)),
      -- builtins.completion.spell,
    },
  }
end

function M.config()
  M.start_servers()
  M.set_diagnostic_signs()
  M.set_diagnostic_bindings()

  vim.diagnostic.config({
    virtual_text = false,
    -- virtual_text = {
    --   source = "always",  -- Or "if_many"
    --   prefix = '●', -- Could be '■', '▎', 'x'
    -- },
    severity_sort = true,
    float = {
      source = "always",  -- Or "if_many"
    },
  })

  -- vim.cmd [[ autocmd! CursorHold * lua require'plugins/lsp'.print_diagnostics() ]]
  -- if vim.diagnostic.virtual_text == false then
    -- vim.cmd [[ autocmd! CursorHold * lua vim.diagnostic.open_float() ]]
  -- end
end

return M
