return {
  {
    "tinted-theming/base16-vim",
    dependencies = { "RRethy/nvim-base16" },
    lazy = false,
    enabled = true,
    priority = 1000,
    config = function()
      require("base16-colorscheme").with_config({ telescope = false })
      vim.opt.termguicolors = true
      vim.g.base16_colorspace = 256

      -- Load base16 studio theme from environment
      local base16_studio_path = "~/base16-studio"
      local theme_file = vim.fn.expand(base16_studio_path .. "/themes/vim/" .. os.getenv("BASE16_THEME") .. ".nvim")
      if vim.fn.filereadable(theme_file) then
        vim.fn.execute("source " .. theme_file)
        require("highlights").setup()
      end

      -- Toggle cterm/gui (to allow previewing themes from terminal)
      vim.api.nvim_create_user_command("ToggleGUI", function()
        vim.opt.termguicolors = not vim.opt.termguicolors:get()
        require("plugins.ui.status").refresh()
      end, {})
    end
  },
}
