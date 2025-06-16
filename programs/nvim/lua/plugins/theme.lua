return {
  {
    "tinted-theming/base16-vim",
    dependencies = { "RRethy/nvim-base16" },
    lazy = false,
    enabled = true,
    priority = 1004, -- one more than snacks
    config = function()
      require("base16-colorscheme").with_config({ telescope = false })
      vim.opt.termguicolors = true
      vim.g.base16_colorspace = 256

      local function apply_theme()
        -- Load base16 studio theme from environment
        local theme_name = os.getenv("BASE16_THEME")
        local base16_studio_path = "~/base16-studio"
        local theme_file = vim.fn.expand(base16_studio_path .. "/themes/vim/" .. theme_name .. ".nvim")
        if vim.fn.filereadable(theme_file) == 1 then
          -- vim.schedule(function() print("Setting theme file " .. theme_name) end)
          -- vim.notify("Theming " .. theme_name)
          vim.fn.execute("source " .. theme_file) -- base16studio
        else
          -- vim.schedule(function() print("Setting colorscheme base16-" .. os.getenv("BASE16_THEME")) end)
          vim.notify("Colourscheme " .. os.getenv("BASE16_THEME"))
          vim.cmd("colorscheme base16-" .. os.getenv("BASE16_THEME")) -- fallback
        end

        require("highlights").setup()
      end

      vim.cmd("highlight clear")
      apply_theme()

      -- Reapply colour scheme
      vim.api.nvim_create_user_command("Repaint", function()
        apply_theme()
      end, {})

      -- Toggle cterm/gui (to allow previewing themes from terminal)
      vim.api.nvim_create_user_command("ToggleGUI", function()
        vim.opt.termguicolors = not vim.opt.termguicolors:get()
        require("plugins.ui.status").refresh()
      end, {})
    end
  },
}
