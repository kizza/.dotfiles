hi rubyBlockParameterList ctermfg=cyan
hi rubyString ctermfg=yellow
hi rubyStringDelimiter ctermfg=yellow
hi rubyInstanceVariable ctermfg=cyan
hi rubyControl ctermfg=brown
hi rubyDefine ctermfg=brown
hi rubyClass ctermfg=magenta

hi TSKeyword ctermfg=brown
hi TSSymbol ctermfg=green
hi TSFunction ctermfg=blue
hi TSLabel ctermfg=cyan
hi TSOperator ctermfg=magenta
hi TSType ctermfg=yellow
hi TSVariable ctermfg=lightgrey
hi TSString ctermfg=yellow

" vim-rails doesn't fine views with .html.erb without extenging its default
" extensions
setlocal suffixesadd+=.html.erb
