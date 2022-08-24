Plug 'chriskempson/base16-vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-sensible' " Be sensible
Plug 'sheerun/vim-polyglot' " Language packs
Plug 'vim-scripts/ReplaceWithRegister' " (eg. griw)
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-lastpat' " Search reuslts as text objects (eg. di/)
Plug 'kana/vim-textobj-indent'  " Motions on similar indents of text (eg. <<ii, <<iI)
Plug '~/.vim/plugged/vim-textobj-directional-indent'
" Plug 'jiangmiao/auto-pairs'

" Expand and collapse bracket items/arguments
Plug 'FooSoft/vim-argwrap'
let g:argwrap_tail_comma = 1

" Highlight whitespace in buffers
Plug 'ntpeters/vim-better-whitespace'
autocmd BufWritePre * StripWhitespace

Plug 'wellle/targets.vim'
Plug 'easymotion/vim-easymotion'
" Plug 'dyng/ctrlsf.vim'

Plug 'vim-test/vim-test'
let test#strategy = "vimux"
let test#javascript#mocha#options = "--require ts-node/register --exit"

Plug 'christoomey/vim-tmux-navigator'
Plug 'jeetsukumaran/vim-markology'
let g:markology_enable = 0

Plug 'Yggdroot/indentLine'
let g:indentLine_fileTypeExclude = ['fzf', 'nerdtree']
let g:indentLine_color_term = "19"
let g:indentLine_char_list = [' ', '', ' ', '']

Plug 'rhysd/git-messenger.vim'

Plug 'preservim/vimux'
" Plug 'thosakwe/vim-flutter'

Plug 'chrisbra/Colorizer'
