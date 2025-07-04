let g:mapleader = ","

" Experiemtn with space as leader
map <Space> ,

" I keep typing an uppercase W when saving (life is too short)
command W w
command Wq wq

inoremap jj <Esc>
nnoremap <Leader>/ :noh<CR><ESC>|

" Yank from current cursor position till end of line
noremap Y y$
noremap <leader>y "+y


"
" Buffers
" --------------------------------------------------------------------
"
noremap <leader>n :NERDTreeFind<cr>
noremap <leader>N :NERDTree<cr>
nnoremap <C-b> :Buffers<CR>
nnoremap <leader>bb :BufExplorer<cr>
nnoremap gt :bnext<CR>
nnoremap gT :bprev<CR>
nnoremap <leader>x :bdelete<CR>
nnoremap <silent><leader>gT :ShiftBufferLeft<CR>
nnoremap <silent><leader>gt :ShiftBufferRight<CR>

" Close all other buffers
nnoremap <leader>o :w <bar> %bd <bar> e# <bar> bd# <CR><CR>

nmap cp :let @+ = expand("%")<CR>
nmap cP :let @+ = expand("%") . ":" . line(".")<CR>
nmap <leader>it :silent execute("!withvimsplit ". expand("%"))<CR>
nmap <leader>ib :edit %<CR>
nmap <leader>iv :vsplit %<CR>

" Copy buffer paths
nmap cp :let @+ = expand("%")<CR>
nmap cP :let @+ = expand("%") . ":" . line(".")<CR>

" Quick jump to buffer index
func! BufferFromIndex(index)
  let l:lines = split(execute('ls'), "\n")
  if len(l:lines) > a:index - 1
    let l:bufnum = trim(split(split(execute('ls'), "\n")[a:index - 1], " ")[0])
    execute("buffer " . l:bufnum)
  else
    echo "No buffer at position " . a:index
  endif
endfunc
for i in range(0, 9)
  execute "nnoremap <leader>" . i . " :call BufferFromIndex(" . i . ")<CR>"
endfo

" Open current file in new tmux split
nnoremap <silent> <leader>at :execute("silent !withsplit 'v ".expand("%")."'")<CR>

nmap <silent> gd :call jump_from_treesitter#jump()<CR>


"
" Searching
" --------------------------------------------------------------------
"

" FZF (Use :GFiles if git is present)
nnoremap <expr> <C-p> (len(system('git rev-parse')) ? ':Files' : ':GFiles --exclude-standard --others --cached')."\<cr>"

" Escaped ripgrep command
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -- ".shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({ 'options': ['--bind', 'ctrl-a:select-all,ctrl-d:deselect-all'] }), <bang>0)

" Raw ripgrep command
command! -bang -nargs=* Rgr call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -- ".<q-args>, 1,
  \   fzf#vim#with_preview({ 'options': ['--prompt', 'Rgr> ', '--bind', 'ctrl-a:select-all,ctrl-d:deselect-all'] }), <bang>0)

" Self reloading RG
function! SelfReloadingFZF(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, a:query)
  " let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'window': { 'width': 0.9, 'height': 0.7}, 'options': ['--phony', '--query', a:query, '--prompt', 'Search> ', '--bind', 'change:reload:'.reload_command, '--bind', 'ctrl-a:select-all,ctrl-d:deselect-all']}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang RG call SelfReloadingFZF(<q-args>, <bang>0)

nnoremap <silent> <C-f> :call SelfReloadingFZF("", 0)<CR>
nnoremap <silent> <leader>ff :call SelfReloadingFZF("", 0)<CR>
nnoremap <silent> <leader>fu :call SelfReloadingFZF(expand('<cword>'), 0)<CR>
nnoremap <leader>fb :BLines<CR>
nnoremap <leader>fh :History<CR>
nnoremap <leader>f/ :call fzf#vim#search_history({'left': '60'})<CR>
nnoremap <leader>f: :call fzf#vim#command_history({'left': '60'})<CR>


"
" Git
" --------------------------------------------------------------------
"
command! GitContext execute("silent !gitcontext ".expand("%"))
command! GitFile execute("silent !gitfile ".expand("%")." ".line("."))
command! GitSha echom "Copied sha" <bar> execute("silent !linesha ".expand("%")." ".line("."))

" nnoremap <silent> <leader>gs :GFiles?<CR>  Using snacks
nnoremap <silent> <leader>gc :GitContext<CR>
nnoremap <silent> <leader>gf :GitFile<CR>
vnoremap <silent> <leader>gf :<C-U> execute("silent !gitfile ".expand("%")." ".line("'<")." ".line("'>"))<CR>
nnoremap <silent> <leader>gb :GitSha<CR>

" Mergetool
nnoremap <leader>dp :diffput 1<CR>
nnoremap <leader>dh :diffget 2<CR>
nnoremap <leader>dl :diffget 4<CR>

" piggy backs off hunk preview, and hunk add
nnoremap [h :GitGutterPrevHunk<CR>
nnoremap ]h :GitGutterNextHunk<CR>
nnoremap <silent> <leader>fs :execute("silent !git add %")<CR>

func! CustomAction()
  let l:items = [
    \ { 'word': 'Git Context', 'abbr': '1st', 'user_data': 'context' },
    \ { 'word': 'Git File', 'abbr': '2nd', 'user_data': 'file' },
    \ { 'word': 'Git Sha', 'abbr': '2nd', 'user_data': 'sha' },
    \ ]

  call actionmenu#open(
    \ l:items,
    \ { index, item -> CustomActionCallback(index, item) },
    \ { 'icon': { 'character': '', 'foreground': 'yellow' } }
    \ )
endfunc

func! CustomActionCallback(index, item)
  if a:item['user_data'] == "context"
    " execute("silent !gitcontext ".expand("%"))
    GitContext
  elseif a:item['user_data'] == "file"
    GitFile
    " execute("silent !gitfile ".expand("%"))
  elseif a:item['user_data'] == "sha"
    GitSha
    " execute("silent !linesha ".expand("%")." ".line("."))
    " echom "Copied sha"
  endif
endfunc

nnoremap <silent> <leader>G :call CustomAction()<CR>


"
" Testing
" --------------------------------------------------------------------
"
nnoremap <leader>tn :TestNearest<CR>
nnoremap <leader>tf :TestFile<CR>
nnoremap <leader>th :call VimuxRunCommand("HEADLESS=false rspec ".expand("%").":".line("."))<CR>

" Vimux
nnoremap <leader>rl :VimuxInterruptRunner <bar> VimuxRunLastCommand<CR>
nnoremap <leader>rr :VimuxOpenRunner<CR>
nnoremap <leader>rp :VimuxPromptCommand<CR>
nnoremap <leader>rP :call VimuxPromptCommandThenClose()<CR>
nnoremap <leader>rc :VimuxClearTerminalScreen<CR>
nnoremap <leader>rt :VimuxTogglePane<CR>

function! VimuxPromptCommandThenClose() abort
  if VimuxOption('VimuxCommandShell')
    let l:command = input("Once?: ", "", 'shellcmd')
  else
    let l:command = input("Once?: ", "")
  endif
  VimuxRunCommand(l:command . " && exit")
endfunction


"
" Manipulation
" --------------------------------------------------------------------
"
nnoremap <leader>j :Joinery<CR>
nnoremap <leader>aw :ArgWrap<CR>

" Join lines without any space
nnoremap gJ Jx
vnoremap gJ :call joinery#join_lines_without_spaces()<CR>

" Simple erb openers (I hate these)
imap <leader>{ <%
imap <leader>} %>

nnoremap [a :ALEPreviousWrap<CR>
nnoremap ]a :ALENextWrap<CR>

" vnoremap <C-s> d:execute 'normal i' . join(sort(split(getreg('"'))), ' ')<CR>

" nnoremap <silent> <Leader>d :AskVisualStudioCode<CR>
nnoremap <silent> <Leader>s :call ActionMenuCodeActions()<CR>

" Change {} or () brackets on multiple lines
" Commenting this out to use <leader>b for :Buffers
" nnoremap <Leader>b( :normal! $%s)s(
" nnoremap <Leader>b{ :normal! $%s}s{

" Show syntax under cursor
" noremap <Leader>R :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
"       \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
"       \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

noremap <Leader>r :TSHighlightCapturesUnderCursor<CR>




nnoremap <leader>ig :IndentGuidesToggle<CR>
" " Tab navigation
" nmap <Tab> gt
" nmap <S-Tab> gT

" Improve search commands
" nmap * *zz
" nmap n nzz
" nmap N Nzz

"
" COC
" --------------------------------------------------------------------
"

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
