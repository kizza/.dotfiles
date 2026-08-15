return {
  {
    "github/copilot.vim",
    event = "VeryLazy",
    init = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_filetypes = {
        codecompanion = false -- disable copilot in codecompanion filetype
      }
    end,
  },
  {
    "folke/sidekick.nvim",
    lazy = false,
    opts = {
      debug = true,
    },
    config = function(_, opts)
      require("sidekick").setup(opts)

      -- Style highlights
      require("highlights").register(function()
        local colours = require("colours")
        colours.hi("SidekickDiffDelete", { fg = 1, bg = colours.darken(1, 0.7), strikethrough = true })
      end)

      -- Normal mode mappings for Copilot Sidekick (NES)
      vim.keymap.set('n', '<C-y>', function()
        if require("sidekick.nes").have() then
          -- Accept the Sidekick suggestion
          require("sidekick.nes").apply()
          return
        end

        -- Fallback to default <C-y> behavior
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-y>', true, true, true), 'n', true)
      end, { desc = "Accept Copilot Sidekick NES suggestion" })

      vim.keymap.set('n', '<C-e>', function()
        if require("sidekick.nes").have() then
          require("sidekick.nes").clear()
          return
        end

        -- Fallback to default <C-e> behavior (usually scroll down in pum)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-e>', true, true, true), 'n', true)
      end, { desc = "Dismiss Copilot Sidekick NES suggestion" })
    end,
  },
}
