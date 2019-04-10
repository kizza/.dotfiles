# Set my terminal/tmux/vim theme to "light" or "dark"

function setTheme {
  node ~/.dotfiles/tmux/tmux-theme.js
  tmux source-file ~/.tmux.conf
}

alias light="base16_solarized-light && setTheme"
alias dark="base16_gruvbox-dark-medium && setTheme"
