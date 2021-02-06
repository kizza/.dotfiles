alias fat="bat"
alias dotfiles="cd ~/.dotfiles"

function fresh {
  # cd ~/.dotfiles
  nix-shell --run "home-manager switch"
  # popd
}
