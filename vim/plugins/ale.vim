Plug 'w0rp/ale'
let g:ale_fixers = { 'typescript': ['prettier'] }
let g:ale_fix_on_save = 1

" highlight Search guibg=NONE guifg=197 gui=underline ctermfg=197 ctermbg=NONE cterm=underline
highlight ALEError guibg=NONE guifg=Magenta gui=underline ctermfg=Magenta ctermbg=NONE cterm=underline
