set undofile                " Save undo's after file closes
set undodir=$HOME/.vim/undo " Where to save histories
if has('nvim')
  set undodir=$HOME/.config/nvim/undo
end
set undolevels=1000         " How many undos
set undoreload=10000        " Number of lines to save
