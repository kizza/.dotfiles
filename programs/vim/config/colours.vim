syntax on

" if !exists('*LetThereBeLight')
"   function! LetThereBeLight()
"     " execute "!light"
"     set background=light
"     source ~/.vim/syntax/light.vim
"   endfunction

"   function! DarknessFalls()
"     " execute "!dark"
"     set background=dark
"     source ~/.vim/syntax/dark.vim
"   endfunction

"   command Light call LetThereBeLight()
"   command Dark call DarknessFalls()

"   set background=light
" endif

" set t_Co=256

" base16
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

hi Search cterm=reverse
hi IncSearch cterm=reverse

" Conditional colours
if $BASE16_THEME =~ "light"
  set background="light"
  source ~/.vim/syntax/light.vim
else
  set background="dark"
  source ~/.vim/syntax/dark.vim
endif

hi Visual cterm=reverse

" Includes (shVariable)
hi Identifier ctermfg=blue

hi Comment cterm=italic

" Spelling needs black/white text
hi SpellBad ctermfg=black
hi SpellCap ctermfg=black
hi SpellRare ctermfg=black
hi SpellLocal ctermfg=black

" " colorscheme gruvbox
" " set background=dark
" " let g:gruvbox_italicize_comments = 1
" " let g:grupvbox_contrast_dark = "hard"
" " let g:indent_guides_auto_colors = 1

" let g:solarized_termcolors=256
" colorscheme solarized

" highlight SpellBad ctermfg=17
highlight MatchParen ctermbg=110

" Ruler at 80 and 100 (only shows within characters that go over it)
highlight ColorColumn ctermbg=18
call matchadd('ColorColumn', '\(\%80v\|\%100v\)', 100)  " Show +80 as coloured

" Visual
" hi Visual ctermbg=18 ctermfg=21

" GitGutter
" hi GitGutterAdd ctermfg=black ctermbg=green
" hi GitGutterChange ctermfg=black ctermbg=blue
" hi GitGutterDelete ctermfg=black ctermbg=16
hi GitGutterAdd ctermfg=green
hi GitGutterChange ctermfg=blue
hi GitGutterDelete ctermfg=16

" Tabs
hi TabLine ctermfg=255 ctermbg=8
hi TabLineFill ctermfg=255 ctermbg=8
hi TabLineSel cterm=bold ctermfg=green ctermbg=black

" Comments
hi Comment ctermfg=8

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

" Buftabline
hi BufTabLineFill ctermbg=19
hi BufTabLineCurrent ctermbg=0 ctermfg=2 cterm=bold
hi BufTabLineActive ctermbg=18 ctermfg=2
hi BufTabLineHidden ctermbg=19 ctermfg=7
hi BufTabLineModifiedCurrent ctermbg=0 ctermfg=2 cterm=italic,bold
hi BufTabLineModifiedActive ctermbg=18 ctermfg=2 cterm=italic
hi BufTabLineModifiedHidden ctermbg=19 ctermfg=7 cterm=italic

" ALE
hi ALEError ctermfg=15 ctermbg=red
hi ALEErrorSign ctermfg=15 ctermbg=red
hi ALEWarning ctermfg=15 ctermbg=yellow
hi ALEWarningSign ctermfg=15 ctermbg=yellow

" Coc
hi CocErrorSign ctermfg=15 ctermbg=red
" hi CocErrorHighlight ctermfg=15 ctermbg=red
hi CocErrorHighlight ctermfg=red ctermbg=none cterm=underline
hi CocWarningSign ctermfg=yellow ctermbg=none
hi CocWarningHighlight ctermfg=yellow ctermbg=none cterm=underline
hi CocInfoSign ctermfg=yellow ctermbg=none
hi CocInfoHighlight ctermfg=yellow ctermbg=none cterm=underline
