local function augroup(name)
  return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end

-- Assign syntax files for *some* file types
local syntax_group = augroup("syntax_settings")
for filetype, syntax in pairs({
  eruby = "eruby",
  ruby = "ruby",
  gitcommit = "gitcommit",
  gitrebase = "gitrebase",
}) do
  vim.api.nvim_create_autocmd("FileType", {
    group = syntax_group,
    pattern = filetype,
    -- command = string.format("set syntax=%s", syntax)
    callback = function()
      vim.bo.syntax = syntax
    end,
  })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ higroup = "YankText", timeout = 200 })
  end,
})

-- Dynamic colour columns
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("color_column"),
  callback = function()
    vim.fn.matchadd('ColorColumn', '\\(\\%80v\\|\\%100v\\)', 100)
  end,
})

-- Trim whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("trim_trailing_whitespace"),
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "markdown" then
      vim.cmd([[%s/\s\+$//e]])
    end
  end,
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "aerial-nav",
    "checkhealth",
    "codecompanion",
    "help",
    "man",
    "fugitive",
    "gitsigns-blame",
    "query",         -- InspectTree query
    "DiffviewFiles", -- InspectTree query
    "fugitiveblame",
    "qf",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
