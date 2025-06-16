return {
  "dense-analysis/ale",
  enabled = false,
  event = "VeryLazy",
  init = function()
    vim.g.ale_fixers = {
      ruby = { 'rubocop' },
    }
    vim.g.ale_linters = {
      ruby = { 'rubocop', 'solargraph' },
    }

    vim.g.ale_ruby_rubocop_executable = 'bundle'
    vim.g.ale_use_neovim_diagnostics_api = 1

    -- vim.g.ale_sign_error = ' '
    -- vim.g.ale_sign_warning = ' '
    -- vim.g.ale_sign_info = 'I'
    -- vim.g.ale_linters_explicit = 1

    -- vim.g.ale_sign_priority = 11
    -- vim.g.gitgutter_sign_priority=9

    -- -- let g:ale_ruby_rubocop_executable = "rubocop --server"
    -- -- let g:ale_ruby_rubocop_options = "--server"
  end
}
