hi rubyBlockParameterList ctermfg=cyan
hi rubyString ctermfg=yellow
hi rubyStringDelimiter ctermfg=yellow
hi rubyInstanceVariable ctermfg=cyan
hi rubyControl ctermfg=brown
hi rubyDefine ctermfg=brown
hi rubyClass ctermfg=magenta

hi erubyDelimeter ctermfg=magenta

hi TSKeyword ctermfg=17
hi TSSymbol ctermfg=green
hi TSParameter ctermfg=lightgrey
hi TSFunction ctermfg=blue
hi TSLabel ctermfg=cyan
hi TSOperator ctermfg=magenta
hi TSType ctermfg=yellow
hi TSVariable ctermfg=lightgrey
hi TSString ctermfg=yellow
hi TSPunctBracket ctermfg=lightgrey
hi TSPunctDelimiter ctermfg=magenta

hi TSCustomMethodName ctermfg=lightgrey
hi TSCustomKeywordParameterName ctermfg=green
hi TSCustomKeywordParameterValue ctermfg=lightgrey
hi TSCustomClassMethodInvocation ctermfg=magenta
hi TSCustomMethod ctermfg=none


" vim-rails doesn't fine views with .html.erb without extenging its default
" extensions
setlocal suffixesadd+=.html.erb
setlocal suffixesadd+=.turbo_stream.erb

lua << EOF
  local colours = require("colours")
  local hi = colours.hi
  local cyan = colours.cyan
  local magenta = colours.magenta
  local blue = colours.blue

  hi("@custom.class.called.methods", { italic = true })
  hi("@custom.class.called.conditional", {fg = blue, italic = true})
EOF
  " hi @custom.class.called.conditional.symbol cterm=italic ctermfg=blue
