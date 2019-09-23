" Black
" DarkBlue
" DarkGreen
" DarkCyan
" DarkRed
" DarkMagenta
" Brown, DarkYellow
" LightGray, LightGrey, Gray, Grey
" DarkGray, DarkGrey
" Blue, LightBlue
" Green, LightGreen
" Cyan, LightCyan
" Red, LightRed
" Magenta, LightMagenta
" Yellow, LightYellow
" White

" const, etc:w
hi typescriptStorageClass ctermfg=yellow cterm=none

" function
hi typescriptFuncKeyword ctermfg=cyan

" export, from, import, get
hi typescriptReserved ctermfg=yellow cterm=none

" return
hi typescriptStatement ctermfg=blue cterm=none

" switch, case, default
hi typescriptLabel ctermfg=yellow cterm=none

" ; and ,
hi typescriptEndColons ctermfg=8

syn match typescriptComa ","
hi typescriptComa ctermfg=grey

" hi typescriptParens ctermfg=Magenta
hi typescriptNumber ctermfg=yellow
hi typescriptStringS ctermfg=cyan
hi typescriptBoolean ctermfg=cyan cterm=bold

hi typescriptDelimiter ctermfg=Yellow
hi typescriptInterpolationDelimiter ctermfg=Cyan
hi typescriptOpSymbols ctermfg=blue

" Not sure what this is, don't want it atm
hi typescriptMessage ctermfg=none

" then
syn match AndThen "\.then"
hi AndThen ctermfg=cyan

syn match Equality "==="
hi Equality ctermfg=cyan

" console.log
syn match ConsoleLog "console\.log"
hi ConsoleLog ctermfg=yellow

" type
" syn match CustomType " [A-Z]\w\+\>"
syn match CustomType "\s\u\w\+\>"
syn match CustomType "\s\(string\|boolean\|number\|object\)\>"
syn match CustomType "\.\u\w\+\>"
hi CustomType ctermfg=magenta

" <type>
syn match InnerType "<[A-Z]\w\+>"
hi InnerType ctermfg=magenta

" object key
" syn match InnerProperty "\<\w\+\>?\?:"
syn region InnerPropertyWrapper start="\<\w\+:" end="." transparent contains=InnerProperty
syn match InnerProperty "\l\w\+" contained
hi InnerProperty ctermfg=green

" Func calls
" syn region FuncCallWrapper start="\.\l" end="\>" contains=FuncCall
syn region FuncCallWrapper start="\<\l\a\+(" end="." transparent contains=FuncCall
syn match FuncCall "\l\a\+" contains=FuncCallParens contained
hi FuncCall ctermfg=blue

" Comment
hi typescriptComment ctermfg=8
hi typescriptLineComment ctermfg=8

" SCRATCH
"
" syn match shebang ".*touch.*"

" hi link shebang Comment
" hi shebang ctermbg=red

" syn match foo "\s+(.*)\:"
" syn match foo /\s+(.*)\:/
" hi foo ctermbg=red


" syn match foo /\<Host/
" syn match foo "/\(Host"
" hi foo ctermbg=red

" syn region innerBrace start=+{+ end=+}+ transparent contains=redTeX
" syn region innerBrace start=+\<<+ end=+>\>+
" syn region redTeX start=+{}+ end=+}+ contains=innerBrace
" syn region redTeX start=+{}+ end=+}+ contains=innerBrace
" hi innerBrace ctermbg=red

