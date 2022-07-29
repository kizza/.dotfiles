Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

let g:fzf_layout = { 'down': '80%' }
let g:fzf_preview_window = ['right:50%', 'ctrl-\']

let g:fzf_action = {
  \ 'ctrl-t': '!withvimsplit',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit',
  \ 'ctrl-o': '!open',
  \ }

" Keyword = Purple
" Function = Aqua
" Const = Red
" Type = Green
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Function'],
  \ 'hl+':     ['fg', 'Variable'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'info':    ['fg', 'Keyword'],
  \ 'border':  ['fg', 'LineNr'],
  \ 'prompt':  ['fg', 'Function'],
  \ 'pointer': ['fg', 'Function'],
  \ 'marker':  ['fg', 'Label'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
