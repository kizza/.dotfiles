local M = {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  keys = { ":", "/", "?" },
}

M.dependencies = {
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/cmp-nvim-lsp-signature-help",
  "ray-x/cmp-treesitter",
  {
    "L3MON4D3/LuaSnip",
    init = function()
      vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
      vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
      vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
      vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})
    end,
    config = function()
      require("luasnip.loaders.from_lua").lazy_load({ paths = "./snippets" })
      require("luasnip.loaders.from_snipmate").lazy_load({ paths = "./snippets" })
    end
  },
  "saadparwaiz1/cmp_luasnip",
  -- "SirVer/ultisnips",
  -- "quangnguyen30192/cmp-nvim-ultisnips",
  {
    -- "kizza/cmp-rg-lsp",
    dir = "~/Code/kizza/cmp-rg-lsp",
  },
  {
    'tzachar/cmp-tabnine',
    build = './install.sh',
    config = function()
      local tabnine = require('cmp_tabnine.config')
      tabnine:setup({
        max_lines = 1000,
        max_num_results = 20,
        sort = true,
        run_on_every_keystroke = true,
        show_prediction_strength = true,
        snippet_placeholder = '..',
        ignored_file_types = {
          lua = true
        },
      })
    end
  },
}

function M.opts()
  local cmp = require("cmp")

  local luasnip = require("luasnip")
  local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  return {
    completion = {
      completeopt = "menu,menuone,noinsert",
    },
    snippet = {
      expand = function(args)
        -- vim.fn["UltiSnips#Anon"](args.body)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    performance = {
      -- debounce = 60,
      -- throttle = 30,
      -- fetching_timeout = 500,
      debounce = 100,
      throttle = 60,
      fetching_timeout = 500,
    },
    sources = M.sources(cmp),
    -- sources = cmp.config.sources(
    --   {
    --     { name = "luasnip" },
    --     -- { name = "ultisnips" },
    --     {
    --       name = "rg_lsp",
    --       option = {},
    --       patterns = {
    --         -- require("cmp-rg-lsp.builtins").ruby,
    --         {
    --           kind = cmp.lsp.CompletionItemKind.Keyword,
    --           pattern = '^\\s*(def|scope|class|module|attribute)\\s+(self\\.|:)?(\\w*%s\\w+(\\?|!)?)',
    --           match = 3,
    --           filetype = { "ruby" },
    --         },
    --         -- {
    --         --   kind = cmp.lsp.CompletionItemKind.Property,
    --         --   pattern = '^#\\s*(\\w*%s\\w+)+\\s+:',
    --         --   match = 1,
    --         --   filetype = { "ruby" },
    --         -- }
    --       }
    --     },
    --     { name = "cmp_tabnine" },
    --     { name = "nvim_lsp" },
    --     { name = "buffer" },
    --     { name = 'nvim_lsp_signature_help' }
    --   },
    --   {{ name = "buffer" }},
    --   {{ name = "path" }}
    -- ),
    matching = {
      disallow_partial_fuzzy_matching = false
    },
    -- (`i` = insert mode, `c` = command mode, `s` = select mode):
    mapping = cmp.mapping.preset.insert({
      -- ['<Tab>'] = cmp.mapping({
      --   i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
      --   c = function(fallback)
      --     if cmp.visible() then
      --       cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
      --     else
      --       fallback()
      --     end
      --   end
      -- }),
      -- ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i', 'c', 's'}),

      -- LuaSnip mapping (C-e to close if needed)
      ["<Tab>"] = cmp.mapping({
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        i = function(fallback)
          if cmp.visible() then
            -- cmp.select_next_item()
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- they way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end
      }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        -- if cmp.visible() then
        --   cmp.select_prev_item()
        -- else
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),


      -- Up and down are reversed for serach and command (as are sequenced 'near_cursor'
      -- (though this itself is reversed when using noice!)
      ['<C-n>'] = cmp.mapping({
        c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        s = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
      }),
      ['<C-p>'] = cmp.mapping({
        c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        s = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
      }),
      --
      ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { 'i' }),
      ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { 'i' }),
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-e>'] = cmp.mapping({ i = cmp.mapping.close(), c = cmp.mapping.close() }),
      ["<CR>"] = cmp.mapping({
        i = function(fallback)
          if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end,
      }),
    }),
    formatting = {
      format = M.formatting
    },
    -- experimental = {
    --   ghost_text = {
    --     hl_group = "LspCodeLens",
    --   },
    -- },
  }
end

function M.sources(cmp)
  return cmp.config.sources(
    {
      { name = "luasnip" },
      -- { name = "ultisnips" },
      {
        name = "rg_lsp",
        option = {},
        patterns = {
          -- require("cmp-rg-lsp.builtins").ruby,
          {
            kind = cmp.lsp.CompletionItemKind.Keyword,
            pattern = '^\\s*(def|scope|class|module|attribute)\\s+(self\\.|:)?(\\w*%s\\w+(\\?|!)?)',
            match = 3,
            filetype = { "ruby" },
          },
          -- {
          --   kind = cmp.lsp.CompletionItemKind.Property,
          --   pattern = '^#\\s*(\\w*%s\\w+)+\\s+:',
          --   match = 1,
          --   filetype = { "ruby" },
          -- }
        }
      },
      { name = "cmp_tabnine" },
      { name = "nvim_lsp" },
      { name = "buffer" },
      { name = 'nvim_lsp_signature_help' }
    },
    { { name = "buffer" } },
    { { name = "path" } }
  )
end

function M.formatting(entry, item)
  local kind_icons = {
    Class = "󰠱",
    Color = "󰏘",
    Constant = "󰏿",
    Constructor = "",
    Enum = "",
    EnumMember = "",
    Event = "",
    Field = "󰜢",
    File = "󰈙",
    Folder = "󰉋",
    Function = "󰊕",
    Interface = "",
    Keyword = "",
    Method = "󰆧",
    Module = "",
    Operator = "󰆕",
    Property = "󰜢",
    Reference = "",
    Snippet = "",
    Struct = "",
    TabNine = "",
    Text = "",
    TypeParameter = "",
    Unit = "",
    Value = "󰎠",
    Variable = "󰀫"
  }
  if kind_icons[item.kind] then
    item.kind = string.format(" %s %s", kind_icons[item.kind], item.kind)
  end

  -- `abbr_hl_group`, `kind_hl_group` and `menu_hl_group`.
  item.menu_hl_group = entry.source.name
  -- highlight groups for item.menu
  item.menu_hl_group = ({
    nvim_lsp = "CmpItemMenuLSP",
    cmp_tabnine = "CmpItemMenuTabnine",
    rg_lsp = "CmpItemMenuRgLSP",
    ultisnips = "CmpItemMenuSnippet",
  })[entry.source.name] -- default is CmpItemMenu

  item.menu = ({
    buffer = "[Buffer]",
    calc = "[Calculator]",
    cmdline = "[Vim Command]",
    cmp_tabnine = "[Tab Nine]",
    nvim_lsp = "[LSP]",
    nvim_lsp_signature_help = "[Signature]",
    nvim_lua = "[Lua]",
    path = "[Path]",
    rg_lsp = "[Rg]",
    spell = "[Spellings]",
    treesitter = "[Treesitter]",
    ultisnips = "[Snip]",
    zsh = "[Zsh]",
  })[entry.source.name] or string.format("%s", entry.source.name)
  return item
end

function M.init()
  -- vim.g.UltiSnipsJumpForwardTrigger = "<Tab>"
  -- vim.g.UltiSnipsJumpBackwardTrigger = "<S-Tab>"
end

function M.config(_, opts)
  local cmp = require("cmp")
  cmp.setup(opts)

  cmp.setup.cmdline({ '/', '?' }, {
    view = {
      entries = { selection_order = 'near_cursor' },
    },
    sources = {
      { name = 'buffer' },
    }
  })

  cmp.setup.cmdline(':', {
    view = {
      entries = { selection_order = 'near_cursor' },
    },
    sources = cmp.config.sources(
      { { name = 'path' } },
      { { name = 'cmdline' } }
    )
  })

  M.highlight()
end

function M.highlight()
  -- vim.cmd [[
  --   highlight CmpItemAbbrMatch ctermfg=magenta
  --   highlight CmpItemAbbrMatchFuzzy ctermfg=cyan
  --   highlight CmpItemMenu cterm=italic ctermfg=8

  --   highlight CmpItemKindClass ctermfg=16
  --   highlight CmpItemKindMethod ctermfg=blue
  --   highlight CmpItemKindModule ctermfg=magenta
  --   highlight CmpItemKindSnippet ctermfg=yellow

  --   highlight CmpItemMenuLSP ctermfg=cyan
  --   highlight CmpItemMenuRgLSP ctermfg=yellow
  --   highlight CmpItemMenuSnippet ctermfg=magenta
  --   highlight CmpItemMenuTabnine ctermfg=magenta
  -- ]]
  local colours = require("colours")
  local hi = colours.hi
  local magenta = colours.magenta
  local cyan = colours.cyan
  local blue = colours.blue
  local yellow = colours.yellow

  hi("CmpItemAbbr", { bg = nil })
  hi("CmpItemAbbrMatch", { fg = magenta })
  hi("CmpItemAbbrMatchFuzzy", { fg = cyan })
  hi("CmpItemMenu", { fg = 8, italic = true })

  hi("CmpItemKindClass", { fg = 16 })
  hi("CmpItemKindMethod", { fg = blue })
  hi("CmpItemKindModule", { fg = magenta })
  hi("CmpItemKindSnippet", { fg = yellow })
  hi("CmpItemKindVariable", { fg = cyan })

  hi("CmpItemMenuLSP", { fg = cyan })
  hi("CmpItemMenuRgLSP", { fg = yellow })
  hi("CmpItemMenuSnippet", { fg = magenta })
  hi("CmpItemMenuTabnine", { fg = magenta })
end

return M
