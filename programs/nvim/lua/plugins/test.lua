return {
  {
    "vim-test/vim-test",
    dependencies = { "preservim/vimux" },
    event = "VeryLazy",
    keys = {
      -- { "<leader>tn", "<cmd>TestNearest<cr>", desc = "Test nearest" },
      {
        "<leader>tn",
        function()
          if vim.bo.filetype == "lua" then
            require("neotest").run.run()
          else
            vim.fn.execute("TestNearest")
          end
        end,
        desc = "Test nearest",
      },
      {
        "<leader>tf",
        function()
          if vim.bo.filetype == "lua" then
            require("neotest").run.run(vim.fn.expand("%"))
          else
            vim.fn.execute("TestFile")
          end
        end,
        desc = "Test file",
      },
      -- { "<leader>tf", "<cmd>TestFile<cr>", desc = "Test file" },
      {
        "<leader>th",
        function()
          vim.cmd [[
            :call VimuxRunCommand("HEADLESS=false rspec ".expand("%").":".line("."))
          ]]
        end,
        desc = "Test file",
      },
    },
    config = function()
      vim.g["test#strategy"] = "vimux"
      vim.g["test#javascript#mocha#options"] = "--require ts-node/register --exit"
    end,
  },
  {
    -- A brilliant in-editor test environment - works amazing for plenary
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-plenary", -- adapter
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter"
    },
    event = "VeryLazy",
    opts = function()
      return {
        adapters = {
          require("neotest-plenary"),
        },
      }
    end,
    config = function(_, opts)
      require("neotest").setup(opts)
      -- vim.cmd [[
      --   hi NeotestDirectory link = Directory
      -- ]]
    end,
    cmd = { "Neotest" },
    keys = {
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Test nearest",
      },
      {
        "<leader>ts",
        function()
          vim.cmd("Neotest summary")
        end,
        desc = "Test nearest",
      },
    }
  }
}
