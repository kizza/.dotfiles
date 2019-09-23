let mapleader=","
let g:mapleader = ","
noremap <leader>n :NERDTree<cr>
noremap <leader>f :NERDTreeFind<cr>

" Buffer navigation
nnoremap <leader>bb :BufExplorer<cr>
nnoremap gt :bnext<CR>
nnoremap gT :bprev<CR>

" Close all other buffers
nnoremap <leader>o :w <bar> %bd <bar> e# <bar> bd# <CR>

nnoremap <Leader>/ :noh<CR><ESC>|

nnoremap <C-p> :FZF<CR>
nnoremap <C-f> :call fzf#vim#ag('.', fzf#vim#with_preview({'options': ['--query', expand('<cword>')]}))<CR>
nmap <leader>v :tabedit $MYVIMRC<CR>
nmap cp :let @+ = expand("%")<CR>
nmap <leader>it :tabedit %<CR>

" vnoremap <C-s> d:execute 'normal i' . join(sort(split(getreg('"'))), ' ')<CR>

nnoremap <silent> <Leader>d :AskVisualStudioCode<CR>
nnoremap <silent> <Leader>s :call ActionMenuCodeActions()<CR>

" Change {} or () brackets on multiple lines
nnoremap <Leader>b( :normal! $%s)s(
nnoremap <Leader>b{ :normal! $%s}s{

" Mapping Y to yank from current cursor position till end of line
noremap Y y$

noremap <Leader>r :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" " Tab navigation
" nmap <Tab> gt
" nmap <S-Tab> gT

" Improve search commands
" nmap * *zz
" nmap n nzz
" nmap N Nzz

" Coc

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)
