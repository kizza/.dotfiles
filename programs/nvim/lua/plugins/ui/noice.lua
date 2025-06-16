return {
  {
    "folke/noice.nvim",
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    -- event = "VeryLazy",
    lazy = false,
    opts = {
      lsp = {
        progress = {
          enabled = false,
        },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      cmdline = {
        format = {
          cmdline = { title = " Command " },
          search_down = { title = " Search " },
          search_up = { title = " Search " },
          ripgrep = { kind = "search", pattern = { "^:%s*Rg%s+" }, icon = "", lang = "regex" },
        },
        opts = {
          win_options = {
            winblend = 0, -- for transparency
            winhighlight = {
              FloatBorder = "FloatBorder",
              FloatTitle = "FloatTitle",
            },
          },
        },
      },

      popupmenu = {
        enabled = false,
      },

      messages = {
        enabled = false,
        view_search = false, -- don't show search count messages
      },

      views = {
        cmdline_popup = {
          position = {
            row = "96%",
            col = "4%",
          },
        }
      },
      routes = {
        {
          -- Don't show buffer write message (requires "written" showing via shortmess config)
          filter = { event = "msg_show", kind = "", find = "written" },
          opts = { skip = true },
        },
        {
          -- Don't show "not found" for search
          filter = { event = "msg_show", find = "E486" },
          opts = { skip = true },
        },
        {
          -- Don't show "yanked" messages
          filter = { event = "msg_show", find = "yanked" },
          opts = { skip = true },
        },
        {
          -- "Serach hit BOTTOM, continuing at TOP (and the reverse)
          filter = { event = "msg_show", kind = "wmsg", find = "BOTTOM" },
          opts = { skip = true },
        },
        {
          -- Show @recording messages
          view = "notify",
          filter = { event = "msg_showmode" },
        },
      },
    },
    config = function(_, opts)
      require('noice').setup(opts)
      -- hi NoiceCmdline ctermbg=red ctermfg=green
      -- hi NoiceCmdlinePopup ctermbg=magenta ctermfg=green # The background popup
      -- hi NoiceCmdlinePrompt ctermbg=red ctermfg=green
      -- hi NoiceCmdlinePopupTitle ctermbg=0 ctermfg=magenta
      -- hi NoiceCmdlinePopupBorder ctermbg=0 ctermfg=magenta

      -- vim.cmd [[
      --   hi link NoiceCmdlinePopupTitle FloatTitle
      --   hi link NoiceCmdlinePopupBorder FloatBorder
      --   hi link NoiceCmdlinePopupTitleSearch FloatTitle
      --   hi link NoiceCmdlinePopupBorderSearch FloatBorder
      --   hi link NoiceConfirmBorder FloatBorder
      --   hi link NoiceCmdlineIconSearch NoiceCmdlineIcon
      --   hi clear NoiceConfirm
      -- ]]

      local colours = require("colours")
      local hi = colours.hi
      hi("NoiceFormatConfirmDefault", { fg = 0, bg = colours.magenta, bold = true })
      hi("NoiceCmdlinePopup", { bg = 18 })
      hi("NoiceCmdlineIcon", { fg = colours.cyan, bg = 18 })

      local _icon, lua_blue = require("nvim-web-devicons").get_icon_color_by_filetype("lua")
      vim.api.nvim_set_hl(0, "NoiceCmdlineIconLua", { ctermfg = 4, fg = lua_blue, default = false })
    end,
  }
}
