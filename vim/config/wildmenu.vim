set wildmenu
set wildmode=longest,full
set wildignore+=/node_modules/*,*/tmp/*,*.so,*.swp,*.zip

if has('nvim')
  set wildoptions=pum
endif
