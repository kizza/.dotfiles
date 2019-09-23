function! InsertPrevBullet()
  let line = getline(".")
  let prefix = matchstr(line, "^\\A\\+")

  call append(line(".") - 1, prefix)
  call feedkeys("kA")
endfunction

function! InsertNextBullet()
  let line = getline(".")
  let prefix = matchstr(line, "^\\A\\+")

  " if prefix=~"---"
  "   call feedkeys("o")
  " else
    call append(line("."), prefix)
    call feedkeys("jA")
  " endif

endfunction

nnoremap O :call InsertPrevBullet()<CR>
nnoremap o :call InsertNextBullet()<CR>
