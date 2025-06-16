return {
  "stevearc/conform.nvim",
  event = "VeryLazy",
  config = function()
    -- This is called as a fallback from my lsp setup (if lsp doens't have formatting)
    require("conform").setup({
      formatters_by_ft = {
        ruby = { "rubocop" },
        eruby = { "erb_format" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end
}
