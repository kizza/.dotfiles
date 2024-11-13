return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen" },
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup({
        view = {
          merge_tool = {
            layout = "diff1_plain"
          }
        },
        keymaps = {
          view = {
            { "n", "[h", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
            { "n", "]h", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
          }
        }
      })
    end
  },
  {
    "tpope/vim-fugitive",
    cmd = { "G" },
  },
  {
    "rhysd/git-messenger.vim",
    keys = {
      { "<leader>gm", "<cmd>GitMessenger<cr>", desc = "Open git messenger" },
    },
    init = function()
      vim.g.git_messenger_always_into_popup = 1
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require('gitsigns').setup {
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']h', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          map('n', '[h', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hr', gs.reset_hunk)
          map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function() gs.blame_line { full = true } end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function() gs.diffthis('~') end)
          map('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

          -- Highlights
          local colours = require("colours")
          local hi = colours.hi
          hi("GitSignsChange", { link = "DiffChange" })
          hi("GitSignsAddInline", { fg = colours.green, reverse = true })
          hi("GitSignsDeleteInline", { fg = colours.red, reverse = true })
          hi("GitSignsChangeInline", { fg = colours.magenta, reverse = true })
        end
      }
    end
  },
}
