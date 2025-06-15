# Tinted Shell
BASE16_SHELL="$HOME/.config/tinted-theming/tinted-shell/"
BASE16_SHELL_ENABLE_VARS="true"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        source "$BASE16_SHELL/profile_helper.sh"

# BAT templates
export BAT_THEME="my-base16"
