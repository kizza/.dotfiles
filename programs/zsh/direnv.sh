if [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook $SHELL)"
fi
