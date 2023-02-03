" let g:ale_completion_enabled = 1
  " \'typescript': ['prettier'],
let g:ale_fixers = {
  \'elixir': ['mix_format'],
  \'elm': ['format'],
  \'ruby': ['rubocop'],
  \}

let g:ale_linters = {
  \'ruby': ['rubocop', 'solargraph'],
  \}
" let g:ale_ruby_rubocop_executable = "rubocop --server"
let g:ale_ruby_rubocop_options = "--server"

let g:ale_enabled = 1
let g:ale_fix_on_save = 1
" let g:ale_sign_error = ''
" let g:ale_sign_warning = ' '
let g:ale_sign_error = ' '
let g:ale_sign_warning = ' '
let g:ale_sign_info = 'I'
let g:ale_linters_explicit = 1

let g:ale_sign_priority = 11
let g:gitgutter_sign_priority=9

let g:airline#extensions#ale#enabled = 1

" let g:ale_ruby_rubocop_executable = 'bundle'

" Plug 'w0rp/ale'
Plug 'dense-analysis/ale'

" " ALE
" nnoremap gd :ALEGoToDefinition<CR>
" nnoremap gh :ALEHover<CR>
" nnoremap <Leader>ne :ALENextWrap<CR>
" nnoremap <Leader>pe :ALEPreviousWrap<CR>
