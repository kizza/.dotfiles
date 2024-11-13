return {
  "williamboman/mason-lspconfig",
  lazy = false,
  dependencies = {
    {
      "williamboman/mason.nvim",
      lazy = false,
      build = ":MasonUpdate"
    }
  },
  config = function()
    require('mason').setup({})
    require('mason-lspconfig').setup({
      ensure_installed = {
        'ts_ls',
        'eslint',
        'lua_ls',
        'html',
        'cssls'
      }
    })

    -- -- automatically install ensure_installed servers
    -- require("mason-lspconfig").setup_handlers({
    --   -- Will be called for each installed server that doesn't have a dedicated handler.
    --   function(server_name) -- default handler (optional)
    --     -- https://github.com/neovim/nvim-lspconfig/pull/3232
    --     if server_name == "tsserver" then
    --       server_name = "ts_ls"
    --     end
    --     local capabilities = require("cmp_nvim_lsp").default_capabilities()
    --     require("lspconfig")[server_name].setup({
    --       capabilities = capabilities,
    --     })
    --   end,
    -- })
  end
}
