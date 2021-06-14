" Visually display indents
Plug 'nathanaelkane/vim-indent-guides'
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_start_level = 2
" let g:indent_guides_color_change_percent = 50

hi IndentGuidesOdd ctermbg=18
" autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=black ctermbg=236

" autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=darkgrey ctermbg=235
" autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=black ctermbg=236

" let g:indent_guides_guide_size = 1 k

" Plug 'Yggdroot/indentLine'
" let g:indentLine_color_term = green
