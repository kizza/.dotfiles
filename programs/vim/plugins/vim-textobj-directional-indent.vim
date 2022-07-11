"
" This is a vim-text-obj plugin for referencing an indent directionally
" Blatently harvested from the wonderful textobj-indent plugin
"

if exists('g:loaded_textobj_directional_indent')
  finish
endif

"
" Mapping
"

function! InclusiveIndentUp()
  let current_line = line(".")
  let current_indent = indent(current_line)
  let prev_less_indented = search('^\s\{'.(current_indent - &tabstop).'}\S', 'nbzW')

  let start_linenr = prev_less_indented + 1
  let end_linenr = current_line

  return ['V',
  \       [0, start_linenr, 1, 0],
  \       [0, end_linenr, len(getline(end_linenr)) + 1, 0]]
endfunction

function! ExclusiveIndentUp()
  let current_line = line(".")
  let current_indent = indent(current_line)
  let prev_indent = search('^\s\{'.current_indent.'}\S', 'nbzW')
  let prev_blank_line = search('^\s\?$', 'nbzW')

  let start_linenr = max([prev_indent, prev_blank_line + 1])
  let end_linenr = current_line

  return ['V',
  \       [0, start_linenr, 1, 0],
  \       [0, end_linenr, len(getline(end_linenr)) + 1, 0]]
endfunction

function! InclusiveIndentDown()
  let current_line = line(".")
  let current_indent = indent(current_line)
  let next_less_indented = search('^\s\{'.(current_indent - &tabstop).'}\S', 'nW')

  let start_linenr = current_line
  let end_linenr = next_less_indented - 1

  return ['V',
  \       [0, start_linenr, 1, 0],
  \       [0, end_linenr, len(getline(end_linenr)) + 1, 0]]
endfunction

function! ExclusiveIndentDown()
  let current_line = line(".")
  let current_indent = indent(current_line)
  let next_indent = search('^\s\{'.current_indent.'}\S', 'nW')
  let next_blank_line = search('^\s\?$', 'n')

  let start_linenr = current_line
  let end_linenr = min([next_indent, next_blank_line - 1])

  return ['V',
  \       [0, start_linenr, 1, 0],
  \       [0, end_linenr, len(getline(end_linenr)) + 1, 0]]
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
