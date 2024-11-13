local function augroup(name)
  return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end

-- -- Syntax highlighting
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("eruby_syntax"),
  pattern = "*.erb",
  command = [[ set syntax=eruby ]],
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("ruby_syntax"),
  pattern = "*.rb",
  command = [[ set syntax=ruby ]],
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
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
  command = [[%s/\s\+$//e]],
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
    "help",
    "man",
    "fugitive",
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
