#!/usr/bin/env bash

# Configure bar
sketchybar --bar height=44 \
  y_offset=7 \
  margin=6 \
  position=right \
  padding_left=0 \
  padding_right=0 \
  blur_radius=30 \
  corner_radius=12 \
  shadow=true \
  color=0xA0000000

# Configure default values
sketchybar --default \
  icon.font="Maple Mono NF:Bold:18.0" \
  label.font="SF Pro:Semibold:18.0" \
  label.width=28 \
  label.align=center \
  width=48

# Create event for items to subscribe to
sketchybar --add event aerospace_workspace_change

  # background.color=0x50F699B6 \
sketchybar --add item logo left \
  --set logo \
  background.drawing=on \
  background.padding_left=4 \
  background.color="0x00$BASE16_COLOR_01_HEX" \
  background.corner_radius=10 \
  background.padding_left=0 \
  background.padding_right=0 \
  background.drawing=on \
  background.height=39 \
  width=40 \
  label.width=38 \
  label.padding_left=4 \
  label.y_offset=2 \
  label="" \
  label.color="0xFF$BASE16_COLOR_0B_HEX" \
  label.font="Maple Mono NF:Bold:22.0" \
  label.padding_right=0

# Define icons
workspace_icons=(
  " "
  ""
  "󰇰"
  ""
  "󰍹"
)

# Populate aerospace workspaces
for sid in $(~/.local/bin/aerospace list-workspaces --all); do
  apps=$(aerospace list-windows --workspace "$sid" | cut -d'|' -f2)
  icon="${workspace_icons[$sid - 1]}" # zero-based index

  padding_left=8
  # for app in ${apps}; do
  #   if [ -z $icon ]; then
  #     icon+="$($CONFIG_DIR/plugins/app_icons.sh ${app})"
  #     space_label="${apps[@]}"
  #   fi
  # done
  # echo "$sid -> $apps"
  # echo $icons
  # echo $space_label

  # Fallback to number if no icon found
  if [ -z $icon ]; then
    icon=$sid
    padding_left=0
  fi

  sketchybar --add item space.$sid left \
    --subscribe space.$sid aerospace_workspace_change \
    --set space.$sid \
    background.corner_radius=8 \
    background.padding_left=0 \
    background.padding_right=0 \
    background.drawing=on \
    background.height=34 \
    width=40 \
    label.width=36 \
    label.font="Maple Mono NF:Bold:18.0" \
    label="$icon" \
    label.y_offset=0 \
    label.padding_left=5 \
    label.padding_right=0 \
    click_script="~/.local/bin/aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done

# Update the bar
sketchybar --update

# Default state
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
