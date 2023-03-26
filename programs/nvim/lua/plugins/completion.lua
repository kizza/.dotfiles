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
  "SirVer/ultisnips",
  "quangnguyen30192/cmp-nvim-ultisnips",
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
  local kind_icons = {Class = "ﴯ", Color = "", Constant = "", Constructor = "", Enum = "", EnumMember = "", Event = "", Field = "", File = "", Folder = "", Function = "", Interface = "", Keyword = "", Method = "", Module = "", Operator = "", Property = "ﰠ", Reference = "", Snippet = "", Struct = "", TabNine = "", Text = "", TypeParameter = "", Unit = "", Value = "", Variable = ""}
  return {
    completion = {
      completeopt = "menu,menuone,noinsert",
    },
    snippet = {
      expand = function(args)
        vim.fn["UltiSnips#Anon"](args.body)
      end,
    },
    sources = cmp.config.sources({
        { name = "ultisnips" },
        { name = "cmp_tabnine" },
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = 'nvim_lsp_signature_help' }
      },
      {{ name = "buffer" }},
      {{ name = "path" }}
    ),
    matching = {
      disallow_partial_fuzzy_matching = false
    },
    mapping = cmp.mapping.preset.insert({
      ['<Tab>'] = cmp.mapping({
        i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        c = function(fallback)
          if cmp.visible() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end
      }),
      ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i', 'c', 's'}),
      -- Up and down are reversed for serach and command (as are sequenced 'near_cursor'
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
      ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
      ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
      ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
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
      format = function(entry, item)
        if kind_icons[item.kind] then
          item.kind = string.format(" %s %s", kind_icons[item.kind], item.kind)
        end

        item.menu = ({
          buffer = "[Buffer]",
          calc = "[Calculator]",
          cmdline = "[Vim Command]",
          cmp_tabnine = "[Tab Nine]",
          nvim_lsp = "[LSP]",
          nvim_lsp_signature_help = "[Signature]",
          nvim_lua = "[Lua]",
          path = "[Path]",
          spell = "[Spellings]",
          treesitter = "[Treesitter]",
          ultisnips = "[Snip]",
          zsh = "[Zsh]",
        })[entry.source.name]
        return item
      end,
    },
    -- experimental = {
    --   ghost_text = {
    --     hl_group = "LspCodeLens",
    --   },
    -- },
  }
end

function M.init()
  vim.g.UltiSnipsJumpForwardTrigger = "<Tab>"
  vim.g.UltiSnipsJumpBackwardTrigger = "<S-Tab>"

  vim.cmd[[
    highlight! CmpItemAbbrMatch ctermfg=magenta
    highlight! CmpItemAbbrMatchFuzzy ctermfg=cyan
    highlight! CmpItemMenu cterm=italic ctermfg=8
    highlight! CmpItemKindTabNineDefault ctermfg=magenta
    highlight! CmpItemKindSnippet ctermfg=yellow
  ]]
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
      {{ name = 'path' }},
      {{ name = 'cmdline' }}
    )
  })
end

return M
