local M = {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    -- { import = "plugins.lsp.nvim-lint" },
    { import = "plugins.lsp.conform" },
    { import = "plugins.lsp.mason" },
    -- { import = "plugins.lsp.null-ls" },
    -- { import = "plugins.lsp.ale" },
  },
  opts = {
    document_highlight = { enabled = false },
  },
}

function M.set_diagnostic_bindings()
  vim.api.nvim_set_keymap('n', '<leader>do', '<cmd>lua vim.diagnostic.open_float()<CR>',
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<leader>di',
    '<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>',
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<leader>da', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
end

function M.set_diagnostic_autocmds()
  local lsp_autocmds = vim.api.nvim_create_augroup("my_lsp", { clear = true })

  vim.api.nvim_create_autocmd("CursorHold", {
    group = lsp_autocmds,
    callback = function()
      vim.diagnostic.open_float()
    end,
  })

  vim.api.nvim_create_autocmd("CursorHoldI", {
    group = lsp_autocmds,
    callback = function()
      vim.lsp.buf.signature_help()
    end,
  })
  -- autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()
  -- autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()
end

function M.disable_syntax_highlighting()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("DisableSemanticHighlighting", { clear = true }),
    callback = function(e)
      local client = vim.lsp.get_client_by_id(e.data.client_id)
      if client then
        client.server_capabilities.semanticTokensProvider = nil -- Not as good as treesitter
      end
    end,
  })
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
        if client.name == "ts_ls" then
          return
        end

        -- print(vim.inspect(client))
        vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent noautocmd update")
        end)
      end
    end
  )
end

function M.on_attach(client, bufnr)
  -- print("Attached " .. client.name)
  -- if client.name ~= "tsserver" and client.server_capabilities.documentFormattingProvider then
  --   -- print("󰄬 Formatting with " .. client.name)
  --   vim.api.nvim_buf_create_user_command(
  --     bufnr,
  --     'Format',
  --     function(input) vim.lsp.buf.format { id = client.id, async = true } end, -- async required in ruby it seems
  --     -- function(input) vim.lsp.buf.format {id = client.id, async = input.bang} end,
  --     { bang = true, range = true, desc = 'Format using lsp' }
  --   )

  --   vim.keymap.set({ 'n', 'x' }, '<leader>df', '<cmd>Format!<cr>', { buffer = bufnr })

  --   local augroup = vim.api.nvim_create_augroup("LspFormat", {})
  --   vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  --   vim.api.nvim_create_autocmd("BufWritePost", {
  --     group = augroup,
  --     buffer = bufnr,
  --     callback = function()
  --       M.format_asynchronously(bufnr)
  --     end,
  --   })
  -- end
end

function M.format_publish_diagnostics(err, result, ctx, config)
  if err then
    print("LSP Error: ", err)
    return
  end

  if result and result.diagnostics then
    -- print(vim.inspect(result))
    for _, diagnostic in ipairs(result.diagnostics) do
      if diagnostic.severity == vim.lsp.protocol.DiagnosticSeverity.Error then
        diagnostic.severity = vim.lsp.protocol.DiagnosticSeverity.Information
      end
    end
  end

  config = config or {}
  config.virtual_text = true
  vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
end

function M.start_servers()
  local use_solargraph_diagnostics = false
  local lspconfig = require("lspconfig")

  -- Diagnostics range not as good as null-ls
  -- lspconfig.rubocop.setup {
  --   cmd = {"bundle", "exec", "rubocop", "--lsp"},
  --   on_attach = M.on_attach,
  --   flags = {
  --     debounce_text_changes = 3000,
  --   },
  -- }

  lspconfig.solargraph.setup {
    cmd = { "bundle", "exec", "solargraph", "stdio" },
    -- on_attach = M.on_attach,
    on_attach = function(client, bufnr)
      -- print("solargraph is connected!")
      M.on_attach(client, bufnr)
    end,
    flags = {
      debounce_text_changes = 3000,
    },
    settings = {
      solargraph = {
        diagnostics = use_solargraph_diagnostics,
        max_files = 6000
      },
    },
    init_options = {
      formatting = use_solargraph_diagnostics,
    },
  }

  -- Debug active clients (and their properties)
  -- lua print(vim.inspect(vim.lsp.get_active_clients()))
  lspconfig.ruby_lsp.setup {
    -- on_attach = function(client, bufnr)
    --   client.server_capabilities.semanticTokensProvider = nil -- Not as good as treesitter
    --   M.on_attach(client, bufnr)
    -- end,
    settings = {
      rubyLsp = {
        enabledFeatures = { "documentFormatting", "diagnostics", "hover", "completion" }
      }
    }
  }

  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')

  lspconfig.lua_ls.setup {
    -- on_attach = function(client, bufnr)
    --   client.server_capabilities.semanticTokensProvider = nil -- Remove flash of unstyled content
    --   M.on_attach(client, bufnr)
    -- end,
    settings = {
      Lua = {
        -- Disable telemetry
        telemetry = { enable = false },
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          path = runtime_path,
        },
        diagnostics = {
          globals = { "vim" },
          unusedLocalExclude = { "_*" },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            -- Make the server aware of Neovim runtime files
            vim.fn.expand('$VIMRUNTIME/lua'),
            vim.fn.stdpath('config') .. '/lua',
            vim.fn.stdpath('config') .. '/deps',
            vim.fn.stdpath('data') .. '/lazy' -- include installed plugins
          }
        }
      }
    }
  }

  lspconfig.eslint.setup {
    on_attach = function(client, bufnr)
      -- Eslint requires us to tell it to support formatting
      client.server_capabilities.documentFormattingProvider = true
      client.handlers["textDocument/publishDiagnostics"] = M.format_publish_diagnostics
      M.on_attach(client, bufnr)
    end
  }

  -- lspconfig.tailwindcss.setup { on_attach = M.on_attach }

  lspconfig.ts_ls.setup {
    on_attach = function(client, bufnr)
      -- I don't like this one formatting
      client.server_capabilities.documentFormattingProvider = false
      M.on_attach(client, bufnr)
    end,
    commands = {
      OrganiseImports = {
        function()
          vim.lsp.buf.execute_command {
            command = "_typescript.organizeImports",
            arguments = { vim.api.nvim_buf_get_name(0) },
            title = ""
          }
        end,
        description = "Organise imports"
      }
    },
    flags = {
      debounce_text_changes = 3000,
    },
    init_options = {
      preferences = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
        importModuleSpecifierPreference = "non-relative",
      },
    }
  }
end

function M.has_lsp_formatter()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.notify("No lsp clients to format", vim.log.levels.INFO, { title = "LSP" })
    return false
  end

  for _, client in ipairs(clients) do
    if client.server_capabilities.documentFormattingProvider then
      print(client.name .. " supports formatting")
      vim.notify(client.name .. " supports formatting", vim.log.levels.INFO, { title = "LSP" })
      return true
    end
  end
end

function M.format()
  if M.has_lsp_formatter() then
    -- vim.lsp.buf.format { id = client.id, async = true }
    vim.lsp.buf.format { async = true }
    -- vim.notify("Formatted via lsp")
  else
    vim.notify("Formatting via confirm", vim.log.levels.INFO, { title = "LSP" })
    require("conform").format()
    -- vim.notify("Formatted via confirm")
  end
end

function M.config(_, opts)
  M.start_servers()
  M.set_diagnostic_bindings()
  -- M.set_diagnostic_autocmds()
  M.disable_syntax_highlighting()

  vim.api.nvim_create_user_command(
    "Format",
    M.format,
    { bang = true, range = true, desc = 'Format using lsp' }
  )

  vim.keymap.set({ 'n', 'x' }, '<leader>df', '<cmd>Format<cr>')

  vim.diagnostic.config({
    virtual_text = false,
    update_in_insert = false,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.HINT] = ' ',
        [vim.diagnostic.severity.INFO] = ' ',
      },
    },
    -- virtual_text = {
    --   source = "always",  -- Or "if_many"
    --   prefix = '●', -- Could be '■', '▎', 'x'
    -- },
    severity_sort = true,
    -- float = {
    --   source = "always", -- Or "if_many"
    -- },
    float = {
      format = function(diagnostic)
        -- print(vim.inspect(diagnostic))
        local client = diagnostic.source or "LSP?"
        return string.format("[%s] %s", client, diagnostic.message)
      end,
    },
  })

  -- vim.cmd [[ autocmd! CursorHold * lua require'plugins/lsp'.print_diagnostics() ]]
  -- if vim.diagnostic.virtual_text == false then
  -- vim.cmd [[ autocmd! CursorHold * lua vim.diagnostic.open_float() ]]
  -- end
end

return M
