Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

let g:Powerline_symbols = 'fancy'
let g:airline_powerline_fonts = 1
let g:airline_theme='base16'
let g:airline_skip_empty_sections = 1

function AirlineModifiedChar()
  return &modified ? " " : ""
endfunction

function! AirlineInit()
  let g:airline_section_b = '%-0.16{getcwd()}'
  let g:airline_section_x = ''
  let g:airline_section_y = airline#section#create_right(['filetype'])

  " Custom mofified char
  call airline#parts#define_raw('fileonly', airline#formatter#short_path#format('%f'))
  call airline#parts#define_function('modified', 'AirlineModifiedChar')
  let g:airline_section_c = airline#section#create(['%<', 'fileonly', 'modified', g:airline_symbols.space, 'readonly', 'coc_status', 'lsp_progress'])

  " Style modified part
  let g:airline#themes#base16#palette.normal['airline_c'] = ['#d5c4a1', '#3c3836', '7', '18', 'none']
  let g:airline#themes#base16#palette.normal_modified = {'airline_c': ['#d5c4a1', '#3c3836', '7', '18', 'italic']}
  let g:airline#themes#base16#palette.insert_modified = copy(g:airline#themes#base16#palette.normal_modified)
  let g:airline#themes#base16#palette.visual_modified = copy(g:airline#themes#base16#palette.insert_modified)
  let g:airline#themes#base16#palette.replace_modified = copy(g:airline#themes#base16#palette.insert_modified)
  let g:airline#themes#base16#palette.inactive_modified = {'airline_c' : [ "", "", "19", "" ]}
endfunction
autocmd User AirlineAfterInit call AirlineInit()
