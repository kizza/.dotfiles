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
hi typescriptStorageClass ctermfg=red cterm=bold

" function
hi typescriptFuncKeyword ctermfg=cyan

" export, from, import, get
hi typescriptReserved ctermfg=red

" ; and ,
hi typescriptEndColons ctermfg=grey

" hi typescriptParens ctermfg=Magenta
hi typescriptNumber ctermfg=red
hi typescriptStringS ctermfg=cyan
hi typescriptBoolean ctermfg=cyan

hi typescriptDelimiter ctermfg=Yellow
hi typescriptInterpolationDelimiter ctermfg=Cyan
hi typescriptOpSymbols ctermfg=blue

" then
syn match AndThen "\.then"
hi AndThen ctermfg=cyan

syn match Equality "==="
hi Equality ctermfg=cyan

syn match ConsoleLog "console\.log"
hi ConsoleLog ctermfg=yellow

" object key
syn match InnerProperty "\<\w\+\>?\?:"
hi InnerProperty ctermfg=green

" type
syn match Type "\s[A-Z]\w\+\>"
syn match Type "\.[A-Z]\w\+\>"
hi Type ctermfg=magenta

syn match InnerType "<[A-Z]\w\+>"
hi InnerType ctermfg=magenta

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

