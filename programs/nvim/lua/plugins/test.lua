return {
  {
    "vim-test/vim-test",
    dependencies = {
      "preservim/vimux"
    },
    keys = {
      { "<leader>tn", "<cmd>TestNearest<cr>", desc = "Test nearest" },
      { "<leader>tf", "<cmd>TestFile<cr>", desc = "Test file" },
      {
        "<leader>th",
        function()
          vim.cmd[[
            :call VimuxRunCommand("HEADLESS=false rspec ".expand("%").":".line("."))
          ]]
        end,
        desc = "Test file",
      },
    },
    init = function()
      vim.g["test#strategy"] = "vimux"
      vim.g["test#javascript#mocha#options"] = "--require ts-node/register --exit"
    end,
  },
}
