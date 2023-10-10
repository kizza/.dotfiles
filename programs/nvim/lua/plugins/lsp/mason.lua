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
        'tsserver',
        'eslint',
        'lua_ls',
        'html',
        'cssls'
      }
    })
  end
}

