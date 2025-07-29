#!/usr/bin/env zsh

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  # background="0xFF${BASE16_COLOR_04_HEX#\#}"
  # sketchybar --set $NAME label.color=0xaa000000 background.color=$background
  sketchybar --set $NAME label.color=0xaa000000 background.color=0xFF7FBBB3
else
  sketchybar --set $NAME label.color=0x77FFFFFF background.color=0x00D699B6
fi
