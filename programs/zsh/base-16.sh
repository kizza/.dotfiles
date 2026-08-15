# Base16 studio
if [ -z "$BASE16_THEME" ]; then
  ~/base16-studio/bin/relink # Re-link possible theme
fi

# Tinted Shell (-t 1 = Only source if we're running interactively)
if [ -n "$PS1" ] && [[ -t 1 ]]; then
  BASE16_SHELL="$HOME/.config/tinted-theming/tinted-shell/"
  BASE16_SHELL_ENABLE_VARS="true"

  if [ -s "$BASE16_SHELL/profile_helper.sh" ]; then
    source "$BASE16_SHELL/profile_helper.sh"

    # Reset theme
    export BASE16_THEME=$(cat "$BASE16_SHELL_THEME_NAME_PATH")
  fi
fi

# BAT templates
export BAT_THEME="my-base16"
