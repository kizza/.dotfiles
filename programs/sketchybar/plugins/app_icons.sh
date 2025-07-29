#!/bin/bash

app="$1"

case "$app" in
  "Arc") echo "󰊯 ";;
  "Ghostty") echo " ";;
  "Microsoft Outlook") echo "󰴢 ";;
  "Apple") echo "󰀵";;
  *) echo "";;
esac
