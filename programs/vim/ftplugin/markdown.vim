function! s:get_line_prefix()
  let line = getline(".")
  let prefix = matchstr(line, "^\\A\\+")
  if strlen(prefix) > 5
    let prefix = ''
  endif
  return prefix
endfunction

function! s:insert_prev_bbullet()
  let prefix = s:get_line_prefix()
  call append(line(".") - 1, prefix)
  call feedkeys("kA")
endfunction

function! s:insert_next_bullet()
  let prefix = s:get_line_prefix()

  call append(line("."), prefix)
  call feedkeys("jA")
endfunction

function! GetVisualSelection()
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  " if len(lines) == 0
  "     return ''
  " endif
  if len(lines) > 0
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
  endif

  return lines
  " return join(lines, "\n")
endfunction

function! IndentMarkdown()
  let lines = GetVisualSelection()
  let indented = map(lines, { index, item } -> "Foo " . item)

  let @i=join(lines, "\n")
  feedkeys
  " execute("normal! gv")
  call append(line("."), prefix)
  call feedkeys("jA")
endfunction

" setlocal indentexpr=SwiftIndent()
" function! SwiftIndent()
"   let line = getline(v:lnum)
"   let previousNum = prevnonblank(v:lnum - 1)
"   let previous = getline(previousNum)
"   " if previous =~ "{" && previous !~ "}" && line !~ "}" && line !~ ":$"
"   "   return indent(previousNum) + &tabstop
"   " endif
"   return
" endfunction

" nnoremap O :call s:insert_prev_bullet()<CR>
" nnoremap o :call s:insert_next_bullet()<CR>
