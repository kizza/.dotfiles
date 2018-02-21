Plug 'itchyny/lightline.vim'
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'relativepath', 'modified' ] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"":""}',
      \   'fileformat': '',
      \   'fileencoding' :''
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag'
      \ },
      \ 'component_type': {
      \   'syntastic': 'error'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }
      " \ 'subseparator': { 'left': '', 'right': '' }

" " Update lightline when syntaxtic is run
" augroup AutoSyntaxticLightLine
"   autocmd!
"   autocmd BufWritePost *.* call s:syntastic_update_lightline()
" augroup END"+

" function! s:syntastic_update_lightline()
"   SyntasticCheck
"   call lightline#update()
" endfunction
