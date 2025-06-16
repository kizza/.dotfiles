vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Unbind defaulted lsp keymaps
-- https://github.com/gpanders/neovim/blob/2e6d0ddb586b3ac243c62cc165172db799043752/runtime/doc/lsp.txt#L65
vim.keymap.del({ 'n', 'x' }, 'gra')
vim.keymap.del('n', 'grn')
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'gri')

local opt = vim.opt

opt.autoread = true -- Reload file when edited externally
-- opt.clipboard = "unnamedplus" -- Sync with system clipboard
-- opt.cmdheight = 0   -- Don't show bar below statusline
opt.completeopt = "menu,menuone,noselect"
-- opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.confirm = true             -- Confirm to save changes before exiting modified buffer
opt.cursorline = true          -- Enable highlighting of the current line
opt.expandtab = true           -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 0
opt.list = true -- Show some invisible characters (tabs...
opt.listchars = { trail = '·', tab = '▸ ' } -- Show tabs, trailing whitespace and end of lines
opt.mouse = "a" -- Enable mouse mode
-- opt.mousemoveevent = true -- Enable mouse move (for tab hovers)
opt.number = true -- Print line number
opt.pumblend = 15 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 3 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append { I = true, c = true, F = true }
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of curaent
-- opt.syntax = true -- Hoping this only works for my custom files
opt.tabstop = 2 -- Number of spaces tabs count for
-- opt.timeoutlen = 300
-- opt.termguicolors = true -- True color support
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 100               -- Save swap file and trigger CursorHold
opt.redrawtime = 1500              -- default is 2000
-- opt.wildmenu = true
opt.wildmode = "longest:full,full" -- Command-line completion mode
-- opt.wildoptions = pum
opt.winblend = 15                  -- 10
opt.winminwidth = 5                -- Minimum window width
opt.wrap = false                   -- Disable line wrap

if vim.fn.has("nvim-0.9.0") == 1 then
  opt.splitkeep = "screen"
  opt.shortmess:append { C = true }
end

-- Better diff (see codecompanion)
vim.opt.diffopt = {
  "internal",
  "filler",
  -- "vertical",
  "closeoff",
  "algorithm:histogram", -- https://adamj.eu/tech/2024/01/18/git-improve-diff-histogram/
  "indent-heuristic",    -- https://blog.k-nut.eu/better-git-diffs
  -- "followwrap",
  -- "linematch:120",
}

-- Disable backup. No swap files.
opt.backup = false
opt.wb = false
opt.swapfile = false

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Undercurl support??
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])
