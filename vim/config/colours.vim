syntax on

" set background=light
" set t_Co=256

" " colorscheme gruvbox
" " set background=dark
" " let g:gruvbox_italicize_comments = 1
" " let g:grupvbox_contrast_dark = "hard"
" " let g:indent_guides_auto_colors = 1

" let g:solarized_termcolors=256
" colorscheme solarized

highlight SpellBad ctermfg=magenta
highlight Search guibg=NONE guifg=197 gui=underline ctermfg=197 ctermbg=NONE cterm=underline
highlight MatchParen ctermbg=110
highlight ColorColumn ctermbg=217
call matchadd('ColorColumn', '\(\%80v\|\%100v\)', 100)  " Show +80 as coloured

