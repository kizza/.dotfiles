Plug 'w0rp/ale'
let g:ale_fixers = {
  \'typescript': ['prettier'],
  \'elixir': ['mix_format'],
  \'elm': ['format'],
  \}
let g:ale_fix_on_save = 1
let g:ale_sign_error = '!'
