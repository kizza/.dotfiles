set nocompatible              " be iMproved, required
filetype off                  " required
set statusline=[%n]\ %<%.99f\ %h%w%m%r%{exists('*CapsLockStatusline')?CapsLockStatusline():''}%y%=%-16(\ %l,%c-%v\ %)%P
call plug#begin('~/.vim/plugged')

" Plug 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'terryma/vim-multiple-cursors'
" Plug 'ervandew/supertab'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'rking/ag.vim'
Plug 'tpope/vim-sensible' " Be sensible
" Plug 'sheerun/vim-polyglot' " Language packs
Plug 'vim-scripts/ReplaceWithRegister' " (eg. griw)
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-lastpat' " Search reuslts as text objects (eg. di/)
Plug 'kana/vim-textobj-indent'  " Motions on similar indents of text (eg. <<ii, <<iI)
" Plug 'jiangmiao/auto-pairs'

" CtrlP
" Plug 'ctrlpvim/ctrlp.vim'
" let g:ctrlp_working_path_mode = 'rw'

" " Ctags
" Plug 'ludovicchabant/vim-gutentags'
" let g:gutentags_cache_dir = '/tmp'

" " Airline
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
" let g:Powerline_symbols = 'fancy'
" let g:airline_powerline_fonts = 1
" " let g:airline_theme='powerlineish'
" let g:airline#extensions#default#section_truncate_width = {
"       \  'b': 90,
"       \  'w': 150,
"       \  'x': 90,
"       \  'y': 130,
"       \  'z': 110,
"       \  'warning': 80,
"       \  'error': 80,
"       \ }

" Better searching
Plug 'mileszs/ack.vim'
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Js syntax

" vimrc.js attemp
" Plug 'othree/yajs.vim'
" Plug 'othree/es.next.syntax.vim'
" Plug 'mxw/vim-jsx'
" let g:jsx_ext_required = 0
" Plug 'othree/javascript-libraries-syntax.vim'

Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'

" Plugin 'isRuslan/vim-es6'
" Plugin 'jelera/vim-javascript'
" autocmd FileType javascript setlocal makeprg=standard

" Auto wordwrap with some file types
au BufRead,BufNewFile *.md setlocal wrap

if exists('plugins')
endif
" Themes
Plug 'morhetz/gruvbox'
Plug 'altercation/vim-colors-solarized'
Plug 'NLKNguyen/papercolor-theme'
Plug 'rakr/vim-one'

call plug#end()

" using Source Code Pro
" set anti enc=utf-8
set guifont=Source\ Code\ Pro\ 11

" Wildmenu
set wildmenu
set wildmode=longest,full

" Whitespace
set listchars=tab:▸\ ,trail:· " Show tabs, trailing whitespace and end of lines
set list
set nowrap                    " Do not wrap lines
set expandtab                 " Use spaces instead of tabs
set smarttab                  " Be smart when using tabs ;-)
set softtabstop=2             " 1 tab is 2 spaces
set shiftwidth=2
set foldlevelstart=99         " Expand all folds by default.
set backspace=2
set smartcase                 " Infer uppercase search when uppercase used
set noeol
" set encoding=utf-8

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" Don't find these patterns
set wildignore+=/node_modules/*,*/tmp/*,*.so,*.swp,*.zip

" Easy window navigation
" nnoremap <C-h> <C-W>h
" nnoremap <C-j> <C-W>j
" nnoremap <C-k> <C-W>k
" nnoremap <C-l> <C-W>l
" if has('nvim')  " Required for neovim to handle c-h
"   nmap <BS> <C-W>h
" endif

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()
autocmd BufWrite *.* :call DeleteTrailingWS()

" Disable backup. No swap files.
set nobackup
set nowb
set noswapfile

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" Don't hide json quotes
let g:vim_json_syntax_conceal = 0

" " Set theme
" colorscheme gruvbox
" set background=dark
" let g:gruvbox_italicize_comments = 1
" let g:grupvbox_contrast_dark = "hard"
" let g:indent_guides_auto_colors = 1

colorscheme solarized

" set t_Co=256
" colorscheme PaperColor
" set background=dark

" colorscheme solarized
" set background=light

" Mappings (shortcuts)
let mapleader=","
let g:mapleader = ","
noremap <leader>n :NERDTree<cr>
noremap <leader>f :NERDTreeFind<cr>
" nnoremap <Leader-p> :CtrlP<CR>:
nnoremap <C-p> :FZF<CR>
nnoremap <Leader>/ :noh<CR><ESC>|
map <Leader>sw :w<Cr>
nmap <leader>v :tabedit $MYVIMRC<CR>
nmap cp :let @+ = expand("%")<CR>
nmap <leader>it :tabedit %<CR>
nnoremap <Leader>b( :normal! $%s)s(
nnoremap <Leader>b{ :normal! $%s}s{

" Window
syntax enable       " Syntax highlighting
set hidden          " Allow hiding buffers with unsaved changes
set number          " Show line numbers
set relativenumber
set ruler           " Show cursor position
set spelllang=en_au " Australian English
set cursorline      " Show current line
set autoread        " Reload file when edited externally
set autoindent
" set smartindent

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" " Set tab colours
" hi TabLineFill ctermfg=Red ctermbg=240
" hi TabLine cterm=none ctermfg=234 ctermbg=240
" hi TabLineSel cterm=none ctermfg=white ctermbg=235

" hi TabLineSel cterm=none

" Search
set ignorecase " Case insensitive search
set incsearch  " Makes search act like search in modern browsers
set hlsearch   " Highlight search results
highlight Search guibg=NONE guifg=197 gui=underline ctermfg=197 ctermbg=NONE cterm=underline
"
" Persistent undo
set undofile                " Save undo's after file closes
set undodir=$HOME/.vim/undo " Where to save histories
set undolevels=1000         " How many undos
set undoreload=10000        " Number of lines to save

" colorscheme solarized
" set background=light
" Switch on highlighting the last used search pattern.
" if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
"   colorscheme solarized
"   set hlsearch
" endif

" hi Normal ctermbg=none
" hi NonText ctermbg=none

" Show spelling mistakes
hi SpellBad ctermfg=magenta

" " Tweak theme
if exists('no')
hi javaScriptBraces cterm=none ctermbg=none ctermfg=darkcyan
hi javaScriptParens cterm=none ctermbg=none ctermfg=darkcyan
" syn match parens /[(){}]/
" hi parens ctermfg=magenta
" autocmd BufRead,BufNewFile * syn match commas /[(){}]/ | hi parens ctermfg=darkmagenta
" autocmd BufRead,BufNewFile * syn match parens /:,/ | hi parens ctermfg=darkmagenta
" " hi jsOperator ctermfg=blue
hi Operator cterm=none ctermbg=none ctermfg=blue
hi MatchParen cterm=none ctermbg=none ctermfg=darkmagenta
hi jsParen ctermfg=175
hi jsNoise ctermfg=cyan
hi jsVariableDef ctermfg=white
hi jsObject ctermfg=173
syn keyword temp ","
hi temp ctermfg=red
hi IndentGuidesOdd  guibg=darkgrey ctermbg=236
hi IndentGuidesEven guibg=black ctermbg=235
endif

" Color column
" let &colorcolumn=join(range(81,999),",")
" highlight ColorColumn ctermbg=235 guibg=#2c2d27
" let &colorcolumn="80,".join(range(120,999),",")
hi MatchParen ctermbg=110
hi ColorColumn ctermbg=217
call matchadd('ColorColumn', '\(\%80v\|\%100v\)', 100)  " Show +80 as coloured

runtime macros/matchit.vim
