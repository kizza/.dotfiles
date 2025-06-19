local M = {}
local theme = require("colours")
local hi = theme.hi
local darken = theme.darken
local black, red, green, yellow, blue, magenta, cyan, white = unpack(theme.colour_names)

---@type table<number, fun(): nil>
local highlights = {}

local function defaults()
  -- Transparency
  vim.cmd [[
    hi clear Normal
    hi clear NormalNC
    hi clear NormalFloat
    hi clear TabLineFill " Set by base16-colorscheme (nvim -V1 then `verbose hi TabLineFill`)
    hi clear StatusLine

    hi Normal guibg=NONE
    hi link NormalNC Normal
    hi link TabLineFill Normal
  ]]
  --hi("Normal", { bg = 0 })
  hi("NormalFloat", { bg = 18 })

  hi("CursorLine", { bg = darken(4, 0.86) })
  vim.cmd [[hi clear CursorLineNr | hi link CursorLineNr CursorLine]]
  hi("Visual", { bg = darken(5, 0.8) })
  hi("Identifier", { fg = 21 }) -- Includes (shVariable)
  hi("Comment", { fg = 8, italic = true })
  hi("String", { fg = yellow })
  hi("MatchParen", { bg = 19, underline = true })
  hi("WildMenu", { fg = 18, bg = 20, bold = true })
  hi("Search", { fg = 5, bg = darken(5, 0.9), underline = true })
  hi("IncSearch", { fg = 3, bg = darken(5, 0.7), underline = true })
  hi("CurSearch", { fg = 3, bg = darken(3, 0.7), underline = true })
  hi("YankText", { fg = 3, bg = darken(3, 0.7) })
  hi("LineNr", { fg = 8 })
  hi("NonText", { link = "LineNr" })
  -- hi("ErrorMsg", { fg = cyan, bg = magenta })
  -- hi("MsgArea", { fg = cyan, bg = magenta })
  hi("NvimInternalError", { fg = 1, bg = black })

  -- " Spelling needs black/white text
  hi("SpellBad", { fg = red, undercurl = true })
  hi("SpellCap", { fg = red })
  hi("SpellRare", { fg = cyan })
  hi("SpellLocal", { fg = yellow, undercurl = true })

  hi("VertSplit", { fg = 19 })
  hi("Folded", { fg = 3 })
  -- hi("NormalFloat", { link = "Normal" })
  -- hi("NormalFloat", { bg = 18 })
  hi("FloatTitle", { fg = magenta, bg = 18 })
  hi("FloatBorder", { fg = darken(yellow, 0.2), bg = 18 })
  hi("FloatTransparent", { bg = nil })
  hi("WinSeparator", { link = "VertSplit" }) -- as per neovim .10

  hi("Pmenu", { bg = 18 })
  -- hi("PmenuSel", { bg = 19 })
  hi("PmenuSel", { link = "Visual", bold = true })
  hi("PmenuSbar", { bg = 18 })
  hi("PmenuThumb", { bg = 19 })

  hi("DiagnosticOk", { link = "DiffAdd" })
  hi("DiagnosticError", { link = "DiffDelete" })
  hi("DiagnosticWarn", { fg = yellow, bg = darken(yellow) })
  hi("DiagnosticInfo", { fg = cyan, bg = darken(cyan) })
  hi("DiagnosticHint", { fg = green, bg = darken(green) })

  hi("DiagnosticUnnecessary", { link = "Comment" })

  hi("DiagnosticVirtualTextError", { link = "DiagnosticError", italic = true })
  hi("DiagnosticVirtualTextWarn", { link = "DiagnosticWarn", italic = true })
  hi("DiagnosticVirtualTextInfo", { link = "DiagnosticInfo", italic = true })
  hi("DiagnosticVirtualTextHint", { link = "DiagnosticHint", italic = true })

  hi("DiagnosticUnderlineError", { link = "DiagnosticError", underline = true })
  hi("DiagnosticUnderlineWarn", { link = "DiagnosticWarn", underline = true })
  hi("DiagnosticUnderlineInfo", { link = "DiagnosticInfo", underline = true })
  hi("DiagnosticUnderlineHint", { link = "DiagnosticHint", underline = true })

  hi("DiffAdd", { fg = green, bg = darken(green) })
  hi("DiffChange", { fg = magenta, bg = darken(magenta) })
  hi("DiffDelete", { fg = red, bg = darken(red) })

  hi("htmlStartTag", { link = "Function" })
  hi("htmlEndTag", { link = "Function" })

  -- " Ruler at 80 and 100 (only shows within characters that go over it)
  -- highlight ColorColumn ctermbg=18
  -- call matchadd('ColorColumn', '\(\%80v\|\%100v\)', 100)  " Show +80 as coloured

  hi("@string", { link = "String" })
  hi("@comment", { link = "Comment" })
  -- hi("@comment", { fg = 20 })
  hi("@variable", { fg = 21 })
  hi("@variable.member", { fg = white })
  hi("@variable.member.call", { fg = blue })
  hi("@variable.builtin", { fg = magenta, italic = true })

  hi("@label", { fg = cyan })
  hi("@type", { fg = yellow, italic = true })
  hi("@symbol", { fg = green })
  hi("@string.special.symbol", { link = "@symbol" }) -- Treesitter encodes @symbol as @string.special.symbol
  hi("@operator", { fg = 16 })
  hi("@function", { fg = 15 })
  hi("@function.call", { fg = blue })
  hi("@function.method", { fg = blue })
  hi("@function.method.call", { fg = blue })

  hi("@keyword", { fg = 6, italic = true })
  hi("@keyword.function", { fg = 17 })
  hi("@keyword.return", { fg = 17, italic = true })
  hi("@constant.builtin", { fg = 17, italic = true })
  hi("@punctuation.bracket", { fg = magenta })
  hi("@punctuation.special", { fg = cyan })
  hi("@punctuation.delimiter", { fg = magenta })

  hi("@function.macro", { fg = yellow }) -- Noice match for commands

  -- Typescript
  hi("@tag", { fg = 5 })
end

-- Allow providing styles from plugin specs for ease repainting
---@param fn fun(): nil
local function append(fn)
  table.insert(highlights, fn)
end

-- Execute provided highlights function - and save for re-rnuning
---@param fn fun(): nil
function M.register(fn)
  append(fn)
  fn()
end

function M.setup()
  -- Include our default highlight function
  append(defaults)

  -- Re-run when colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function() M.highlight() end,
  })
end

-- Execute all the highlights functions
function M.highlight()
  for _, func in ipairs(highlights) do
    func()
  end
end

return M
