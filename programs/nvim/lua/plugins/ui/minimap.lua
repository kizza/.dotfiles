local M = {
  -- Blazing fast minimap for vim, powered by code-minimap written in Rust
  -- "wfxr/minimap.vim",
  "kizza/minimap.vim",
  branch = "live-minimap",
  enabled = false,
  -- dev = true,
  dir = "~/Code/kizza/minimap.vim",
  build = ":!cargo install --locked --version 0.6.4 code-minimap",
  event = { "BufEnter", "BufReadPost", "BufNewFile" },
  dependencies = {
    "dhruvasagar/vim-testify"
  },
  keys = {
    { "<C-w>=", "<C-w>=:call minimap#vim#MinimapResize()<CR>", desc = "Equalise windows" }
  },
}

function M.init()
  vim.g.minimap_auto_start = 1
  vim.g.minimap_git_colors = 1
  vim.g.minimap_highlight_search = 1
  vim.g.minimap_live_updates = 1
  vim.g.minimap_git_strategy = "gitgutter"
  vim.g.minimap_width = 8
  vim.g.minimap_search_color_priority = 130
  vim.g.minimap_block_filetypes = { 'diff', 'fugitive', 'fzf', 'telescope', 'gitrebase', 'gitcommit', 'NvimTree' }
  vim.g.minimap_block_buftypes = { 'nofile', 'nowrite', 'quickfix', 'terminal', 'help', 'prompt', 'NvimTree' }
  vim.g.minimap_close_filetypes = { 'startify', 'netrw', 'NvimTree' }
  vim.g.minimap_background_processing = 0
  -- vim.g.minimap_cursor_color = 'Minimap'

  -- vim.g.minimap_base_highlight = 'minimapBase' -- This seems to leave a right gutter
end

M.opts = {
  stages = 'slide',                       -- for non termgui
  background_colour = 'NotifyBackground', -- for non termgui
  render = 'wrapped-compact',
  level = 2,                              -- DEBUG=1, INFO=2, WARN=3, ERROR=4
  top_down = false,
  minimum_width = 30,
  max_width = 100,
  timeout = 3000,
}

function M.config(_, opts)
  M.highlight()
end

function M.highlight()
  vim.cmd [[
    hi minimapCursor ctermfg=green ctermbg=19
    hi minimapRange ctermfg=blue ctermbg=18

    hi minimapRangeDiffLine guifg=#0000ff ctermbg=18
    hi minimapRangeDiffAdded guifg=#00ff00 ctermbg=18
    hi minimapRangeDiffRemoved ctermfg=red ctermbg=18

    " hi minimap ctermfg=Green guifg=#50FA7B guibg=#32302f
    autocmd CmdlineLeave * if getcmdtype() =~# '[?/]' | call timer_start(0, {-> execute("call minimap#vim#UpdateColorSearch(getcmdline())")})
    autocmd VimResized * call minimap#vim#MinimapResize()
  ]]
  -- " Manually highlight search
  -- " autocmd CmdlineLeave * if getcmdtype() =~# '[?/]' | call timer_start(0, {-> execute("call minimap#vim#UpdateColorSearch(getcmdline())")})
  -- " nnoremap * * :call minimap#vim#UpdateColorSearch(@/)<CR>
  -- " nnoremap # # :call minimap#vim#UpdateColorSearch(@/)<CR>
end

return M
