Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

let g:Powerline_symbols = 'fancy'
let g:airline_powerline_fonts = 1
let g:airline_theme='base16'
let g:airline_skip_empty_sections = 1

function! AirlineInit()
  let g:airline_section_b = '%-0.20{getcwd()}'
  let g:airline_section_c = '%t'
  let g:airline_section_x = ''
  let g:airline_section_y = airline#section#create_right(['filetype'])
endfunction
autocmd User AirlineAfterInit call AirlineInit()
