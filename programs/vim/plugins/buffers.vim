Plug 'jlanzarotta/bufexplorer'

if !has('gui_running')
  " Plug 'ap/vim-buftabline'
  Plug '~/Code/kizza/vim-buftabline'
  let g:buftabline_indicators = 1
  let g:buftabline_numbers = 2 " idx of buffer
  let g:buftabline_modified_char = ""
end
