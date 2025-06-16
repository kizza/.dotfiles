" hi rubyBlockParameterList ctermfg=cyan
" hi rubyString ctermfg=yellow
" hi rubyStringDelimiter ctermfg=yellow
" hi rubyInstanceVariable ctermfg=cyan
" hi rubyControl ctermfg=brown
" hi rubyDefine ctermfg=brown
" hi rubyClass ctermfg=magenta

" hi rubyTestMacro ctermfg=magenta " describe, context
" hi rubyAssertion cterm=italic ctermfg=cyan " expect

" hi erubyDelimeter ctermfg=magenta

" hi TSKeyword ctermfg=17
" hi TSSymbol ctermfg=green
" hi TSParameter ctermfg=lightgrey
" " hi TSFunction ctermfg=blue
" hi TSLabel ctermfg=cyan
" hi TSOperator ctermfg=magenta
" hi TSType ctermfg=yellow
" hi TSVariable ctermfg=lightgrey
" hi TSString ctermfg=yellow
" hi TSPunctBracket ctermfg=lightgrey
" hi TSPunctDelimiter ctermfg=magenta

" hi TSCustomMethodName ctermfg=lightgrey
" hi TSCustomKeywordParameterName ctermfg=green
" hi TSCustomKeywordParameterValue ctermfg=lightgrey
" hi TSCustomClassMethodInvocation ctermfg=magenta
" hi TSCustomMethod ctermfg=none

" hi @function ctermfg=white
" hi @function.call ctermfg=blue

" hi @custom.class.called.methods cterm=italic
" hi @custom.class.called.conditional cterm=italic ctermfg=blue
" hi @custom.class.called.conditional.symbol cterm=italic ctermfg=blue

" hi @variable.builtin ctermfg=magenta " self

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

  hi("@variable.member.ruby", {fg = cyan, italic = true})
  hi("@lsp.type.namespace.ruby", {fg = 16, italic = true})
  hi("@custom.class.called.methods", { italic = true })
  hi("@custom.class.called.conditional", {fg = blue, italic = true})
  hi("@custom.setter.method", {fg = 7})

  -- For named arguments in methods foo(name: :value)
  hi("@custom.keyword_parameter.name", {fg = 2})
  hi("@custom.keyword_parameter.value", {fg = 7})

  vim.cmd([[
    highlight link lsp.type.method.ruby NONE " Clear this lsp semantic token
  ]])
EOF
  " hi @custom.class.called.conditional.symbol cterm=italic ctermfg=blue
