# Set my terminal/tmux/vim theme to "light" or "dark"

function setTheme {
  node ~/.dotfiles/theme/tmux.js
  tmux source-file ~/.tmux.conf
}

alias light="base16_solarized-light && setTheme"
alias dark="base16_gruvbox-dark-medium && setTheme"
alias brown="base16_mocha && setTheme"
alias mario="base16_atelier-dune-light && setTheme"
alias matrix="base16_greenscreen && setTheme"
