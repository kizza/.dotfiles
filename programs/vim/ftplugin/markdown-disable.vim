function! s:get_line_prefix()
  let line = getline(".")
  let prefix = matchstr(line, "^\\A\\+")
  if strlen(prefix) > 5
    let prefix = ''
  endif
  return prefix
endfunction

function! MarkdownInsertPrevBullet()
  setlocal shiftwidth=2
  let prefix = s:get_line_prefix()
  call append(line(".") - 1, prefix)
  call feedkeys("kA")
endfunction

function! MarkdownInsertNextBullet()
  setlocal shiftwidth=2
  let prefix = s:get_line_prefix()
  call append(line("."), prefix)
  call feedkeys("jA")
endfunction

function! MarkdownEnter()
  setlocal shiftwidth=2
  let prefix = s:get_line_prefix()
  " Exit bullet list
  if trim(getline(".")) == "-"
    call setline(line("."), "")
    call feedkeys("o")
  " Make a heading
  elseif getline(".") == "---"
    let heading = substitute(getline(line(".")-1), ".", "-", "g")
    call setline(line("."), heading)
    normal! o
    call feedkeys("i")
  " If prefix starts with -
  elseif stridx(prefix, "-") >= 0
    call append(line("."), prefix)
    call feedkeys("jA")
  " Pass through
  else
    call feedkeys("o")
    " normal! i<CR>
  endif
endfunction

function! MarkdownTab()
  " if col(".") != 1
  "   return
  " endif

  setlocal shiftwidth=2
  call feedkeys(">>A")
endfunction

function! MarkdownShiftTab()
  setlocal shiftwidth=2
  call feedkeys("<<A")
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

nnoremap O :call MarkdownInsertPrevBullet()<CR>
nnoremap o :call MarkdownInsertNextBullet()<CR>

inoremap <Tab> <ESC>:call MarkdownTab()<CR>
inoremap <S-Tab> <ESC>:call MarkdownShiftTab()<CR>

inoremap <CR> <ESC>:call MarkdownEnter()<CR>
