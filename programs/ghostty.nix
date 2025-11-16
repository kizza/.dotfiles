{ pkgs, ... }:

{
  home = {
    file.".config/ghostty/config".text = ''
#
# Fonts
# ghosty +list-fonts
font-family = Maple Mono NF
# font-family-italic = Maple Mono NF Medium Italic
# font-style-italic = italic
font-size = 18
font-thicken = true
font-thicken-strength = 255
adjust-cell-height = 36%
adjust-cursor-height = 36%
bold-is-bright = true
adjust-underline-position = 4


#
# Cursor
#
cursor-invert-fg-bg = true
cursor-color = #99CCFF
cursor-opacity = 1
# cursor-style = bar
term = screen-256color
scrollback-limit = 10000

#
# Window
#
#
title = " "
#window-decoration = none
macos-titlebar-style = hidden
confirm-close-surface = false
background-opacity = 0.92
background-blur = true

#
# Keybindings
#

keybind = global:cmd+grave_accent=toggle_quick_terminal

# Disable keybindings
keybind = ctrl+d=unbind

# Close window (ctrl+x)
keybind = super+w=text:\x02x

# Open a new tab (ctrl+c)
keybind = super+t=text:\x02c

# Cmd+Shift+{} for Ctrl+b np
keybind = super+shift+left_bracket=text:\x02p
keybind = super+shift+right_bracket=text:\x02n

# Pass <C-S-f> to neovim (this is mapped to <leader>md+Shift+{ -> Ctrl+b, p
keybind = ctrl+shift+f=text:,fu
keybind = super+shift+f=text:,pp
'';
  };
}
