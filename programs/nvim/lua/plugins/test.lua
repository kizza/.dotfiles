-- Inside herdr the runner pane is herdr's own; vimux only knows how to talk to tmux.
local function run_in_runner(command)
  if vim.env.HERDR_ENV then
    require("scripts.herdr").run(command)
  else
    vim.fn.VimuxRunCommand(command)
  end
end

local function rspec_at_cursor(prefix)
  return prefix .. " rspec " .. vim.fn.expand("%") .. ":" .. vim.fn.line(".")
end

return {
  {
    "vim-test/vim-test",
    dependencies = { "preservim/vimux" },
    event = "VeryLazy",
    keys = {
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
      {
        "<leader>th",
        function()
          run_in_runner(rspec_at_cursor("HEADLESS=false"))
        end,
        desc = "Test headless",
      },
      {
        "<leader>tr",
        function()
          run_in_runner(rspec_at_cursor("RECORD_SCREEN=true"))
        end,
        desc = "Record test",
      },
      {
        "<leader>tz",
        function()
          require("scripts.herdr").zoom()
        end,
        desc = "Zoom test runner",
      },
      {
        "<leader>tq",
        function()
          require("scripts.herdr").close()
        end,
        desc = "Close test runner",
      },
    },
    config = function()
      vim.g["test#custom_strategies"] = { herdr = require("scripts.herdr").run }
      vim.g["test#strategy"] = vim.env.HERDR_ENV and "herdr" or "vimux"
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
