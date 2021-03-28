let mapleader=","
let g:mapleader = ","
noremap <leader>n :NERDTree<cr>
noremap <leader>f :NERDTreeFind<cr>

inoremap jj <Esc>

" Buffer navigation
nnoremap <C-b> :Buffers<CR>
nnoremap <leader>bb :BufExplorer<cr>
nnoremap gt :bnext<CR>
nnoremap gT :bprev<CR>
nnoremap <leader>x :bdelete<CR>

" Close all other buffers
nnoremap <leader>o :w <bar> %bd <bar> e# <bar> bd# <CR><CR>

nnoremap <Leader>/ :noh<CR><ESC>|

" FZF
" Use :GFiles if git is present
nnoremap <expr> <C-p> (len(system('git rev-parse')) ? ':Files' : ':GFiles --exclude-standard --others --cached')."\<cr>"

nnoremap <silent> <leader>gc :!gitcontext %<CR>
nnoremap <silent> <leader>gb :execute "!linesha ".expand("%")." ".line(".")<CR>
nnoremap <leader>gs :G<CR>
nnoremap <leader>dp :diffput 1<CR>
nnoremap <leader>dh :diffget 2<CR>
nnoremap <leader>dl :diffget 4<CR>

" piggy backs off hunk preview, and hunk add
nnoremap <leader>hn :GitGutterNextHunk<CR>

nnoremap <leader>tn :TestNearest<CR>
nnoremap <leader>tf :TestFile<CR>
nmap <silent> <leader>rs :let @+ = "HEADLESS=false fd . " . expand("%:h") . " \| entr rspec " . expand("%")<CR>

" nnoremap <C-f> :call fzf#vim#ag('.', '--color-match "20;20"', fzf#vim#with_preview({'left': '90%', 'options': ['--exact', '--query', expand('<cword>')]}))<CR>
nnoremap <leader>ch :call fzf#vim#command_history({'left': '60'})<CR>
" nnoremap <leader>sh :call fzf#vim#search_history({'left': '60'})<CR>

  " \   'rg --column --line-number --no-heading --color=always '.shellescape(<cword>), 1,
  " \   <bang>0 ? fzf#vim#with_preview('up:60%')
  " \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  " \   <bang>0)

" nnoremap <C-f> :call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -- ". shellescape(expand('<cword>')), 1, fzf#vim#with_preview({'left': '90%', 'options': ['--exact', '--query', expand('<cword>')]}))<CR>

nnoremap <silent> <C-f> :
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(expand('<cword>')), 1,
  \   fzf#vim#with_preview({'left':'90%'}))<CR>

" " Just use Rg for ag
" command! -bang -nargs=* Ag
"   \ call fzf#vim#grep(
"   \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
"   \   fzf#vim#with_preview(), <bang>0)

nmap <leader>v :tabedit $MYVIMRC<CR>
nmap cp :let @+ = expand("%")<CR>
nmap cP :let @+ = expand("%") . ":" . line(".")<CR>
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

" Next diagnostic
nmap <silent> <leader>[ <Plug>(coc-diagnostic-prev)

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)
