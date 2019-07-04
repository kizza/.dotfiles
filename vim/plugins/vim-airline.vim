Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

let g:Powerline_symbols = 'fancy'
let g:airline_powerline_fonts = 1
let g:airline_theme='base16'
let g:airline_skip_empty_sections = 1

" Move 'file' section to section b (and don't show section c)
let g:airline_section_b = '%-0.10{getcwd()}'
" let g:airline_section_c = '%t'
