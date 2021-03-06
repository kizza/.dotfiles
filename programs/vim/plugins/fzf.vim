Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" set rtp+=/usr/local/opt/fzf
" let $FZF_DEFAULT_COMMAND = 'ag -g ""'
let g:fzf_layout = { 'down': '80%' }
let g:fzf_preview_window = ['right:50%', 'ctrl-\']

" Keyword = Purple
" Function = Aqua
" Const = Red
" Type = Green

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Function'],
  \ 'hl+':     ['fg', 'Type'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'info':    ['fg', 'Keyword'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Function'],
  \ 'pointer': ['fg', 'Function'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
