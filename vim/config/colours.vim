syntax on

" set background=light
" set t_Co=256

" base16
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" Conditional colours
if $BASE16_THEME =~ "light"
  set background="light"
  source ~/.vim/syntax/light.vim
else
  set background="dark"
  source ~/.vim/syntax/dark.vim
endif

" " colorscheme gruvbox
" " set background=dark
" " let g:gruvbox_italicize_comments = 1
" " let g:grupvbox_contrast_dark = "hard"
" " let g:indent_guides_auto_colors = 1

" let g:solarized_termcolors=256
" colorscheme solarized

highlight SpellBad ctermfg=magenta
" highlight Search guibg=NONE guifg=197 gui=underline ctermfg=197 ctermbg=NONE cterm=underline
highlight Search guibg=NONE guifg=DeepPink2 gui=underline
highlight MatchParen ctermbg=110
highlight ColorColumn ctermbg=217
call matchadd('ColorColumn', '\(\%80v\|\%100v\)', 100)  " Show +80 as coloured

" Visual
hi Visual ctermbg=18 ctermfg=21

" Tabs
hi TabLine ctermfg=15 ctermbg=8
hi TabLineFill ctermfg=15 ctermbg=8
hi TabLineSel cterm=bold ctermfg=green ctermbg=black

" Statusline
hi StatusLine ctermfg=darkgrey ctermbg=black
hi WildMenu cterm=bold ctermfg=18 ctermbg=20

" Marks
hi MarkologyHLo ctermfg=grey ctermbg=18

" FZF
hi fzf1 ctermfg=lightgrey ctermbg=black
hi fzf2 ctermfg=lightgrey ctermbg=black
hi fzf3 ctermfg=lightgrey ctermbg=black

" NERDTree
" hi NERDTreeDir ctermbg=green
hi NERDTreeDirSlash ctermfg=grey
hi NERDTreeFile ctermfg=20
hi NERDTreeFlags ctermfg=8

" ALE
hi ALEError ctermfg=15 ctermbg=Red
" Coc
hi CocHighlightText cterm=underline ctermbg=18    " Current mouseover
hi CocHighlightRead cterm=underline ctermbg=18    " Related mouseover
hi CocErrorSign ctermfg=black ctermbg=16
