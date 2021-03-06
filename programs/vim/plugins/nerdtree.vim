Plug 'scrooloose/nerdtree'
" Plug 'jistr/vim-nerdtree-tabs'
let g:NERDTreeChDirMode = 2
let g:NERDTreeShowHidden = 1
let g:NERDTreeDirArrowExpandable = ' '
let g:NERDTreeDirArrowCollapsible = ' '
let g:NERDTreeWinSize=60
let g:NERDTreeHighlightCursorLine = 1
let g:NERDTreeQuitOnOpen = 1
let NERDTreeAutoDeleteBuffer = 1

" autocmd vimenter * NERDTree

Plug 'ryanoasis/vim-devicons'   " (see syntax/nerdtree.vim for icons/styles)

" Plug 'tiagofumo/vim-nerdtree-syntax-highlight' " Colour the icons


" Fix square brackets around dev-icons
" macligatures
" set conceallevel=3
" if exists('g:loaded_webdevicons')
"     call webdevicons#refresh()
" endif
