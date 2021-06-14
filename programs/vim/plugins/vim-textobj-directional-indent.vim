"
" This is a vim-text-obj plugin for referencing an indent directionally
" Blatently harvested from the wonderful textobj-indent plugin
"

if exists('g:loaded_textobj_directional_indent')
  finish
endif

let s:EMPTY_LINE = -1

function! s:directional_select(include_empty_lines_p, block_border_type, direction)  "{{{2
  " Check the indentation level of the current or below line.
  let cursor_linenr = line('.')
  let base_linenr = cursor_linenr
  while !0
    let base_indent = s:indent_level_of(base_linenr)
    if base_indent != s:EMPTY_LINE || base_linenr == line('$')
      break
    endif
    let base_linenr += 1
  endwhile

  " Check the end of a block.
  let end_linenr = base_linenr
  if a:direction == "down"
    let end_linenr = base_linenr + 1
    while end_linenr <= line('$')
      let end_indent = s:indent_level_of(end_linenr)
      if s:block_border_p(end_indent, base_indent,
      \                   a:include_empty_lines_p, a:block_border_type)
        break
      endif
      let end_linenr += 1
    endwhile
    let end_linenr -= 1
  endif

  " Check the start of a block.
  let start_linenr = base_linenr
  if a:direction == "up"
    while 1 <= start_linenr
      let start_indent = s:indent_level_of(start_linenr)
      if s:block_border_p(start_indent, base_indent,
      \                   a:include_empty_lines_p, a:block_border_type)
        break
      endif
      let start_linenr -= 1
    endwhile
    let start_linenr += 1
  endif
  if line('$') < start_linenr
    let start_linenr = line('$')
  endif

  " Select the cursor line only
  " if <Plug>(textobj-indent-i) is executed in the last empty lines.
  if ((!a:include_empty_lines_p)
  \   && start_linenr == end_linenr
  \   && start_indent == s:EMPTY_LINE)
    let start_linenr = cursor_linenr
    let end_linenr = cursor_linenr
  endif

  return ['V',
  \       [0, start_linenr, 1, 0],
  \       [0, end_linenr, len(getline(end_linenr)) + 1, 0]]
endfunction

function! s:indent_level_of(linenr)  "{{{2
  let _ = getline(a:linenr)
  if _ == ''
    return s:EMPTY_LINE
  else
    return indent(a:linenr)
  endif
endfunction

function! s:block_border_p(indent,base_indent,include_empty_lines_p,type) "{{{2
  if a:type ==# 'same-or-deep'
    return a:include_empty_lines_p
    \      ? a:indent != s:EMPTY_LINE && a:indent < a:base_indent
    \      : a:indent == s:EMPTY_LINE || a:indent < a:base_indent
  elseif a:type ==# 'same'
    return a:include_empty_lines_p
    \      ? a:indent != s:EMPTY_LINE && a:indent != a:base_indent
    \      : a:indent == s:EMPTY_LINE || a:indent != a:base_indent
  else
    echoerr 'Unexpected type:' string(a:type)
    return 0
  endif
endfunction

"
" Mapping
"

function! InclusiveIndentUp()
  return s:directional_select(!0, 'same-or-deep', 'up')
endfunction

function! ExclusiveIndentUp()
  return s:directional_select(!!0, 'same', 'up')
endfunction

function! InclusiveIndentDown()
  return s:directional_select(!0, 'same-or-deep', 'down')
endfunction

function! ExclusiveIndentDown()
  return s:directional_select(!!0, 'same', 'down')
endfunction

call textobj#user#plugin('directionalselect', {
\   'indent-k': {
\     'select-a-function': 'InclusiveIndentUp',
\     'select-a': 'aK',
\     'select-i-function': 'ExclusiveIndentUp',
\     'select-i': 'iK',
\   },
\   'indent-j': {
\     'select-a-function': 'InclusiveIndentDown',
\     'select-a': 'aJ',
\     'select-i-function': 'ExclusiveIndentDown',
\     'select-i': 'iJ',
\   },
\ })

let g:loaded_textobj_directional_indent = 1
