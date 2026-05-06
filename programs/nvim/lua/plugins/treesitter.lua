return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    -- event = { "BufReadPost", "BufNewFile" }, -- does not support lazy loading

    config = function()
      local ts = require("nvim-treesitter")

      ts.install({
        "bash",
        "c",
        "html",
        "git_rebase",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "nix",
        "python",
        "query",
        "regex",
        "ruby",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })

      -- Enable Treesitter highlighting + parsing
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)

          -- Recommended by upstream to avoid double-highlighting
          vim.bo[args.buf].syntax = "off"
        end,
      })

      -- Native indentation still immature for some langs
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "ruby" },
        callback = function()
          vim.bo.autoindent = true
          vim.bo.smartindent = true
        end,
      })

      -- Your custom captures
      vim.api.nvim_set_hl(0, "TSCustomMethodName", {})
      vim.api.nvim_set_hl(0, "TSCustomKeywordParameterName", {})
      vim.api.nvim_set_hl(0, "TSCustomKeywordParameterValue", {})
      vim.api.nvim_set_hl(0, "TSCustomClassMethodInvocation", {})
      vim.api.nvim_set_hl(0, "TSCustomMethod", {})

      -- matchup integration currently unstable on 0.12
      -- vim.g.matchup_treesitter_enabled = 0
    end,
  },
}
