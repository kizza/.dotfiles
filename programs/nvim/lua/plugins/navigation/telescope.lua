local M = {
  'nvim-telescope/telescope.nvim',
  -- tag = '0.1.1',
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzf-native.nvim",
  },
}

function M.opts()
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Workaround for https://github.com/nvim-telescope/telescope.nvim/issues/1048
  local multiopen = function(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local num_selections = #picker:get_multi_selection()
    if not num_selections or num_selections <= 1 then
      actions.select_default(prompt_bufnr)
    else
      actions.smart_send_to_qflist(prompt_bufnr)
      actions.open_qflist(prompt_bufnr)
      local open_cmd = "edit"
      vim.cmd("cfdo " .. open_cmd)
    end
  end

  local intmux = function(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    local path = entry.path or entry.filename
    vim.fn.execute("silent !withsplit 'v " .. path .. "'")
    actions.close(prompt_bufnr)
  end

  return {
    defaults = {
      layout_strategy = 'horizontal',
      layout_config = { width = 0.98, height = 0.99 },
      prompt_prefix = ' > ',
      selection_caret = ' > ',
      multi_icon = ' 󰄬 ',
      entry_prefix = '   ',
      mappings = {
        i = {
          ["<esc>"] = actions.close,
          ["<CR>"] = multiopen,
          ["<C-t>"] = intmux,
          -- Reverse tab order (due to sorting)
          ["<Tab>"] = actions.toggle_selection + actions.move_selection_better,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_worse,
          ["<M-a>"] = actions.toggle_all,
        },
      },
      file_ignore_patterns = {
        "node_modules",
        "*.lock",
        "*.ttf",
      }
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {
          -- even more opts
        }
      }
    }
  }
end

function M.init()
end

function M.config(_, opts)
  require('telescope').setup(opts)

  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
  vim.keymap.set('n', '<leader>fr', builtin.resume, {})
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
  vim.keymap.set('n', '<leader>fl', builtin.current_buffer_fuzzy_find, {})
  vim.keymap.set('n', '<C-b>', builtin.buffers, {})
  vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {})
  vim.keymap.set('n', '<leader>ft', builtin.treesitter, {})
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
  vim.keymap.set('n', '<leader>fm', builtin.marks, {})
  vim.keymap.set('n', '<leader>fc', builtin.git_commits, {})
  vim.keymap.set('n', '<leader>fu', builtin.grep_string, {})
  -- vim.keymap.set('n', '<leader>fu', function() builtin.live_grep { default_text = vim.fn.expand('<cword>') } end, {})
  -- vim.keymap.set('n', '<leader>fu', function() vim.cmd("Rg " .. vim.fn.expand('<cword>')) end, {})
  vim.keymap.set('n', '<C-p>',
    function()
      local opts = { show_untracked = true }
      vim.fn.system('git rev-parse --is-inside-work-tree')
      if vim.v.shell_error == 0 then
        require "telescope.builtin".git_files(opts)
      else
        require "telescope.builtin".find_files(opts)
      end
    end,
    {}
  )

  M.highlight()
end

function M.highlight()
  vim.cmd [[
    hi clear TelescopeTitle
    hi clear TelescopeBorder
    hi link TelescopeTitle FloatTitle
    hi link TelescopeBorder FloatBorder
  ]]
  -- hi TelescopePromptPrefix ctermfg=cyan cterm=bold
  -- hi TelescopeSelectionCaret ctermfg=magenta ctermbg=19 cterm=bold
  -- hi TelescopeMultiIcon ctermfg=green cterm=bold
  -- hi TelescopeMultiSelection ctermfg=green
  local colours = require("colours")
  local hi = colours.hi
  hi("TelescopePromptPrefix", { fg = colours.cyan, bold = true })
  hi("TelescopeSelectionCaret", { fg = colours.magenta, bg = 19, bold = true })
  hi("TelescopeMultiIcon", { fg = colours.green, bold = true })
  hi("TelescopeMultiSelection", { fg = colours.green })
end

return M
