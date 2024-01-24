require("settings")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
 vim.fn.system({
  "git",
  "clone",
  "--filter=blob:none",
  "--single-branch",
  "https://github.com/folke/lazy.nvim.git",
  lazypath,
 })
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = { lazy = true },
  -- install = { colorscheme = { "tokyonight" } },
  dev = {
    path = "~/Code/kizza",
    fallback = false, -- Fallback to git when local plugin doesn't exist
  },
  checker = { enabled = true },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  -- debug = true,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.cmd("source ~/.config/nvim/config/mappings.vim")
    require("autocmds")
    -- vim.cmd [[set runtimepath^=~/.vim runtimepath+=~/.vim/after]]
    -- vim.cmd [[let &packpath=&runtimepath]]
    -- vim.cmd [[source ~/.vimrc]]
  end,
})
