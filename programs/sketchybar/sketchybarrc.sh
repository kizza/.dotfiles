#!/usr/bin/env bash

# Define colors
export COLOR_BLACK="0x40000000"
export COLOR_ACTIVE="0xffffffff"
export COLOR_DEFAULT="0x88ffffff"

# Configure bar
sketchybar --bar height=32 \
  y_offset=5 \
  margin=2 \
  position=right \
  padding_left=10 \
  padding_right=10 \
  blur_radius=30 \
  corner_radius=10 \
  color=$COLOR_BLACK

# Configure default values
sketchybar --default width=32 \
  icon.font="Maple Mono NF:Bold:18.0" \
  icon.color=$COLOR_DEFAULT \
  label.font="Maple Mono NF:Bold:18.0" \
  label.highlight_color="0xff99ccff" \
  label.width=50 \
  label.color=$COLOR_DEFAULT

# Populate aerospace workspaces
sketchybar --add event aerospace_workspace_change
for sid in $(~/.local/bin/aerospace list-workspaces --all); do
  apps=$(aerospace list-windows --workspace "$sid" | cut -d'|' -f2)
  icon=""
  padding_left=8
  for app in ${apps}; do
    if [ -z $icon ]; then
      icon+="$($CONFIG_DIR/plugins/app_icons.sh ${app})"
      space_label="${apps[@]}"
    fi
  done
  echo "$sid -> $apps"
  echo $icons
  echo $space_label

  if [ -z $icon ]; then
    icon=$sid
    padding_left=10
  fi

  sketchybar --add item space.$sid left \
    --subscribe space.$sid aerospace_workspace_change \
    --set space.$sid \
    background.color=0x00D699B6 \
    background.corner_radius=5 \
    background.height=28 \
    background.drawing=on \
    label="$icon" \
    label.padding_left="$padding_left" \
    click_script="~/.local/bin/aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done

# Update the bar
sketchybar --update

# Default state
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
