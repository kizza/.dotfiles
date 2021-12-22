Plug 'jlanzarotta/bufexplorer'


if !has('gui_running')
  Plug 'ap/vim-buftabline'
  let g:buftabline_indicators = 1
  let g:buftabline_numbers = 2 " idx of buffer
end
