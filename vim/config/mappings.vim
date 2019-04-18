let mapleader=","
let g:mapleader = ","
noremap <leader>n :NERDTree<cr>
noremap <leader>f :NERDTreeFind<cr>

" Buffer navigation
nnoremap <leader>bb :BufExplorer<cr>
nnoremap gt :bnext<CR>
nnoremap gT :bprev<CR>

nnoremap <Leader>/ :noh<CR><ESC>|
nnoremap gd :ALEGoToDefinition<CR>
nnoremap gh :ALEHover<CR>
nnoremap <Leader>ne :ALENextWrap<CR>
nnoremap <Leader>pe :ALEPreviousWrap<CR>

nnoremap <C-p> :FZF<CR>
nmap <leader>v :tabedit $MYVIMRC<CR>
nmap cp :let @+ = expand("%")<CR>
nmap <leader>it :tabedit %<CR>

" Change {} or () brackets on multiple lines
nnoremap <Leader>b( :normal! $%s)s(
nnoremap <Leader>b{ :normal! $%s}s{

" Mapping Y to yank from current cursor position till end of line
noremap Y y$

" " Tab navigation
" nmap <Tab> gt
" nmap <S-Tab> gT

" Improve search commands
nmap * *zz
nmap n nzz
nmap N Nzz
