#!/usr/bin/env zsh

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  FG="0xFFFFFFFF"
  BG="0x90$BASE16_COLOR_0E_HEX"
  sketchybar --set $NAME label.color=$FG background.color=$BG
else
  FG="0xF0$BASE16_COLOR_07_HEX"
  BG="0x60$BASE16_COLOR_02_HEX"
  sketchybar --set $NAME label.color=$FG background.color=$BG
fi
