return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = {
    'rafamadriz/friendly-snippets',
    { "L3MON4D3/LuaSnip", version = "v2.*" },
  },

  -- use a release tag to download pre-built binaries
  version = '1.*',
  -- AND/OR build from source
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = 'super-tab',
      ['<Tab>'] = {
        function(cmp)
          -- Explicitly selected cmp item wins
          if cmp.is_visible() and cmp.get_selected_item() then
            cmp.accept()
            return true
          end

          -- Intercept copilot and accept its suggestion if present
          if vim.fn['copilot#Enabled']() == 1 and vim.fn['copilot#GetDisplayedSuggestion']().text ~= "" then
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes("<Plug>(copilot-accept-line)", true, true, true),
              "n",
              true
            )
            return true
          end

          if cmp.snippet_active() then
            return cmp.accept()
            -- else
            --   return cmp.select_and_accept()
          end

          return false
        end,
        'snippet_forward',
        'fallback',
      },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    completion = {
      -- (Default) Only show the documentation popup when manually triggered
      documentation = { auto_show = false },
      keyword = { range = 'prefix' },
      menu = {
        winblend = vim.opt.pumblend:get(),
      },
      list = {
        selection = { preselect = false, auto_insert = false },
      },
    },

    -- signature = { enabled = true },
    snippets = { preset = "luasnip" },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'snippets', 'lsp', 'path', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" },

  config = function(_, opts)
    -- Load luasnips
    require('luasnip').setup({ enable_autosnippets = true })
    require("luasnip.loaders.from_lua").lazy_load({ paths = "./snippets" })
    require("luasnip.loaders.from_snipmate").lazy_load({ paths = "./snippets" })
    require('luasnip').filetype_extend("ruby", { "rails" })
    vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
    vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
    vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
    vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})

    require("blink.cmp").setup(opts)

    -- Style
    require("highlights").register(function()
      local colours = require("colours")
      local hi = colours.hi
      hi("BlinkCmpLabelMatch", { fg = colours.magenta })
      hi("BlinkCmpLabelDetail", { fg = 20, italic = true })      -- adjacent to label
      hi("BlinkCmpLabelDescription", { fg = 20, italic = true }) -- right aligned
      hi("BlinkCmpKindClass", { fg = 16 })
      hi("BlinkCmpKindMethod", { fg = colours.blue })
      hi("BlinkCmpKindModule", { fg = colours.magenta })
      hi("BlinkCmpKindSnippet", { fg = colours.yellow })
      hi("BlinkCmpKindVariable", { fg = colours.cyan })
    end)
  end,
}
