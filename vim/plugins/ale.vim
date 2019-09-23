let g:ale_completion_enabled = 1
let g:ale_fixers = {
  \'typescript': ['prettier'],
  \'elixir': ['mix_format'],
  \'elm': ['format'],
  \}
let g:ale_fix_on_save = 1
let g:ale_sign_error = '!'
let g:ale_linters_explicit = 1

Plug 'w0rp/ale'

" " ALE
" nnoremap gd :ALEGoToDefinition<CR>
" nnoremap gh :ALEHover<CR>
" nnoremap <Leader>ne :ALENextWrap<CR>
" nnoremap <Leader>pe :ALEPreviousWrap<CR>
