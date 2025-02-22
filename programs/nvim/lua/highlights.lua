local M = {}
local theme = require("colours")
local hi = theme.hi
local black, red, green, yellow, blue, magenta, cyan, white = unpack(theme.colour_names)

function M.setup()
  hi("Identifier", { fg = 21 }) -- Includes (shVariable)
  hi("Comment", { fg = 8, italic = true })
  hi("String", { fg = yellow })
  hi("MatchParen", { bg = 19, underline = true })
  hi("WildMenu", { fg = 18, bg = 20, bold = true })
  hi("Search", { fg = 5, underline = true })
  hi("IncSearch", { fg = 0, bg = 5, underline = true })
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
  hi("NormalFloat", { bg = 18 })
  hi("FloatTitle", { fg = magenta })
  hi("FloatBorder", { fg = 19 })
  hi("FloatTransparent", { bg = nil })
  hi("WinSeparator", { link = "VertSplit" }) -- as per neovim .10

  hi("Pmenu", { bg = 18 })
  hi("PmenuSel", { bg = 19 })
  -- hi("PmenuSel", { bg = 19, fg = 2, bold = true })
  hi("PmenuSbar", { bg = 18 })
  hi("PmenuThumb", { bg = 18 })

  hi("DiagnosticError", { fg = red, bg = 18 })
  hi("DiagnosticWarn", { fg = yellow, bg = 18 })
  hi("DiagnosticInfo", { fg = cyan, bg = 18 })
  hi("DiagnosticHint", { fg = green, bg = 18 })

  hi("DiagnosticUnnecessary", { link = "Comment" })

  hi("DiagnosticVirtualTextError", { fg = red, bg = 18, italic = true })
  hi("DiagnosticVirtualTextWarn", { fg = yellow, bg = 18, italic = true })
  hi("DiagnosticVirtualTextInfo", { fg = cyan, bg = 18, italic = true })
  hi("DiagnosticVirtualTextHint", { fg = green, bg = 18, italic = true })

  hi("DiagnosticUnderlineError", { fg = red, bg = 18 })
  hi("DiagnosticUnderlineWarn", { fg = yellow, bg = 18 })
  hi("DiagnosticUnderlineInfo", { fg = cyan, bg = 18 })
  hi("DiagnosticUnderlineHint", { fg = green, bg = 18 })

  hi("DiffChange", { fg = magenta })


  hi("htmlStartTag", { link = "Function" })
  hi("htmlEndTag", { link = "Function" })

  -- " Ruler at 80 and 100 (only shows within characters that go over it)
  -- highlight ColorColumn ctermbg=18
  -- call matchadd('ColorColumn', '\(\%80v\|\%100v\)', 100)  " Show +80 as coloured

  hi("@string", { link = "String" })
  hi("@variable", { fg = 21 })
  hi("@comment", { fg = 20 })
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

  hi("@keyword", { fg = 17 })
  hi("@keyword.function", { fg = 17 })
  hi("@keyword.return", { fg = 17, italic = true })
  hi("@constant.builtin", { fg = cyan, italic = true })
  hi("@punctuation.bracket", { fg = magenta })
  hi("@punctuation.special", { fg = 17 })
  hi("@punctuation.delimiter", { fg = magenta })

  -- Typescript
  hi("@tag", { fg = 5 })
end

return M
