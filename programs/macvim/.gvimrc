" Disable backup. No swap files.
set nobackup
set nowb
set noswapfile

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

" Window
set hidden          " Allow hiding buffers with unsaved changes
set spelllang=en_au " Australian English
set cursorline      " Show current line
set autoread        " Reload file when edited externally
set autoindent
set mouse=a
set updatetime=100 " Update faster (used for gitgutter)

" Navigation
set scrolloff=3     " Keep 3 context lines above and below cursor

if has('gui_running')
  set shortmess=I
  set guifont=SauceCodePro\ Nerd\ Font\ Mono:h18
  set linespace=1
  set showtabline=0
  " set norelativenumber
  " set nonumber          " Show line numbers
  " set noruler

  " colorscheme default
  colorscheme base16-atelier-dune-lighter
  hi NonText guifg=bg
end
