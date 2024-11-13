return {
  {
    "MunifTanjim/nui.nvim"
  },
  {
    "kevinhwang91/nvim-ufo",
    enabled = true,
    dependencies = {
      "kevinhwang91/promise-async",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function(_, opts)
      -- vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end

      require('ufo').setup({
        fold_virt_text_handler = handler,
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = false,
    event = "VeryLazy",
    opts = {
      enable = true
    },
    config = function(_, opts)
      require 'treesitter-context'.setup(opts)
      vim.cmd [[
        hi TreesitterContextBottom cterm=underline
      ]]
    end
  },
  {
    "stevearc/dressing.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {
      input = {
        enabled = true,
        win_options = {
          winblend = vim.opt.pumblend:get(),
          winhighlight = "NormalFloat:FloatInput",
        },
        override = function(conf)
          if vim.api.nvim_win_get_width(0) <= 40 then
            conf.width = 50
          end
          return conf
        end
      },
      select = {
        enabled = true,
        backend = { "telescope" },
      },
    },
    init = function()
      vim.cmd("hi FloatInput ctermbg=red")
    end
  },
  {
    "j-hui/fidget.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = {
      text = { spinner = "dots", done = "✔", commenced = "", completed = "" }
    }
  },
  {
    "nvim-tree/nvim-web-devicons",
    opts = function()
      local colours = require("colours")
      return {
        override = {
          ["rb"] = {
            icon = "",
            color = colours.get(colours.red),
            cterm_color = colours.red,
            name = "Rb",
          },
          ["erb"] = {
            icon = "",
            color = colours.get(colours.yellow),
            cterm_color = colours.yellow,
            name = "Erb",
          },
          ["sass"] = {
            icon = "",
            color = colours.get(colours.magenta),
            cterm_color = colours.magenta,
            name = "Sass",
          },
          ["yaml"] = {
            icon = "󰦨",
            color = colours.get(colours.blue),
            cterm_color = colours.blue,
            name = "Yaml",
          },
          ["yml"] = {
            icon = "󰦨",
            color = colours.get(colours.blue),
            cterm_color = colours.blue,
            name = "Yml",
          },
        }
      }
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter"
    },
    opts = {
      indent = {
        char = "│",
        highlight = {
          -- "IndentBlanklineCharSkip",
          "IndentBlanklineChar",
        }
      },
      scope = {
        show_start = false,
        show_end = false,
        highlight = {
          "IndentBlanklineContextChar",
        }
      }
    },
    config = function(_, opts)
      local hi = require("colours").hi
      hi("IndentBlanklineChar", { fg = 18 })
      hi("IndentBlanklineCharSkip", { fg = 0 })
      hi("IndentBlanklineContextChar", { fg = 8 })
      -- vim.cmd [[
      --   hi IndentBlanklineChar ctermfg=18
      --   hi IndentBlanklineCharSkip ctermfg=0
      --   hi IndentBlanklineContextChar ctermfg=8
      -- ]]
      require("ibl").setup(opts)
    end
  },
}
