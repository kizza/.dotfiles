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

alias brown="base16_mocha && setTheme"
alias chalk="base16_chalk && setTheme"
alias dark="base16_gruvbox-dark-medium-custom && setTheme"
alias dracula="base16_dracula && setTheme"
alias eighties="base16_eighties && setTheme"
alias forrest="~/.dotfiles/theme/favourites/forrest.theme.sh && setTheme"
alias irblack="base16_irblack && setTheme"
alias joker="base16_joker && setTheme"
alias light="base16_solarized-lighter && setTheme"
alias mario="base16_atelier-dune-lighter && setTheme"
alias materia="base16_materia && setTheme"
alias matrix="base16_greenscreen && setTheme"
alias ocean="base16_ocean && setTheme"
alias tokyonight="base16_tokyonight && setTheme"
alias tomorrow="base16_tomorrow && setTheme"
alias tomorrownight="base16_tomorrow-night && setTheme"
alias wonka="base16_material-palenight && setTheme"
