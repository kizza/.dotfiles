call plug#end()

" base16
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" using Source Code Pro
" set anti enc=utf-8

" " Useful mappings for managing tabs
" map <leader>tn :tabnew<cr>
" map <leader>to :tabonly<cr>
" map <leader>tc :tabclose<cr>
" map <leader>tm :tabmove

" Easy window navigation
" nnoremap <C-h> <C-W>h
" nnoremap <C-j> <C-W>j
" nnoremap <C-k> <C-W>k
" nnoremap <C-l> <C-W>l
" if has('nvim')  " Required for neovim to handle c-h
"   nmap <BS> <C-W>h
" endif

" Don't hide json quotes
let g:vim_json_syntax_conceal = 0

" " Set tab colours
" hi TabLineFill ctermfg=Red ctermbg=240
" hi TabLine cterm=none ctermfg=234 ctermbg=240
" hi TabLineSel cterm=none ctermfg=white ctermbg=235

" hi TabLineSel cterm=none

" colorscheme solarized
" set background=light
" Switch on highlighting the last used search pattern.
" if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
"   colorscheme solarized
"   set hlsearch
" endif

" hi Normal ctermbg=none
" hi NonText ctermbg=none

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

