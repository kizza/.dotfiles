# Terminal theme
# ZSH_THEME="kizza"

function theme {
  script=$(ls "$BASE16_SHELL/scripts" | fzf | awk '{$1=$1;print}')
  source "$BASE16_SHELL/scripts/$script"
}

# Set my terminal/tmux/vim theme to "light" or "dark"
function setTheme {
  node ~/.dotfiles/theme/tmux.js
  tmux source-file ~/.tmux-theme.conf
}

alias light="base16_solarized-light && setTheme"
alias dark="base16_gruvbox-dark-medium && setTheme"
alias brown="base16_mocha && setTheme"
alias mario="base16_atelier-dune-light && setTheme"
alias matrix="base16_greenscreen && setTheme"
alias joker="~/.dotfiles/theme/favourites/joker.theme.sh && setTheme"
alias forrest="~/.dotfiles/theme/favourites/forrest.theme.sh && setTheme"
