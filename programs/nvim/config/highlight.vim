hi Identifier ctermfg=21 " Includes (shVariable)
hi Comment cterm=italic
hi String ctermfg=yellow
hi MatchParen ctermbg=19 cterm=underline
hi WildMenu cterm=bold ctermfg=18 ctermbg=20
hi Search ctermbg=none ctermfg=5 cterm=underline
hi IncSearch ctermbg=5 ctermfg=0 cterm=underline

" Spelling needs black/white text
hi SpellBad ctermfg=black
hi SpellCap ctermfg=black
hi SpellRare ctermfg=black
hi SpellLocal ctermfg=black

hi NormalFloat ctermbg=18
hi FloatTitle ctermfg=magenta
hi FloatBorder ctermfg=19
hi FloatTransparent ctermbg=none

" Light
" hi Pmenu ctermbg=19
" hi PmenuSbar ctermbg=18
" hi PmenuThumb ctermbg=18
" hi FloatBorder ctermfg=19

hi Pmenu ctermbg=18
hi PmenuSel ctermfg=none ctermbg=19
hi PmenuSbar ctermbg=18
hi PmenuThumb ctermbg=18
hi FloatBorder ctermfg=19

hi DiagnosticError ctermfg=red ctermbg=18
hi DiagnosticWarn ctermfg=yellow ctermbg=18
hi DiagnosticInfo ctermfg=cyan ctermbg=18
hi DiagnosticHint ctermfg=green ctermbg=18

hi DiagnosticVirtualTextError cterm=italic ctermfg=red ctermbg=18
hi DiagnosticVirtualTextWarn cterm=italic ctermfg=yellow ctermbg=18
hi DiagnosticVirtualTextInfo cterm=italic ctermfg=cyan ctermbg=18
hi DiagnosticVirtualTextHint cterm=italic ctermfg=green ctermbg=18

hi DiagnosticUnderlineError ctermfg=red ctermbg=18
hi DiagnosticUnderlineWarn ctermfg=yellow ctermbg=18
hi DiagnosticUnderlineInfo ctermfg=cyan ctermbg=18
hi DiagnosticUnderlineHint ctermfg=green ctermbg=18

" Ruler at 80 and 100 (only shows within characters that go over it)
highlight ColorColumn ctermbg=18
call matchadd('ColorColumn', '\(\%80v\|\%100v\)', 100)  " Show +80 as coloured

hi @label ctermfg=cyan
hi @type cterm=italic ctermfg=yellow
hi @symbol ctermfg=green
hi link @string.special.symbol @symbol " Treesitter encodes @symbol as @string.special.symbol
hi @operator ctermfg=16
" hi @function ctermfg=15
" hi @function.call ctermfg=magenta
hi @keyword.function ctermfg=17
hi @keyword.return ctermfg=17 cterm=italic
hi @constant.builtin cterm=italic ctermfg=cyan
hi @variable.builtin cterm=italic
hi @punctuation.bracket ctermfg=magenta
hi @punctuation.special ctermfg=17
" hi @punctuation.delimiter ctermfg=magenta
