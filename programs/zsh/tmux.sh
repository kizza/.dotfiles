if command -v tmux &> /dev/null; then
  if [[ -n "$TMUX" ]]; then
    echo "Within tmux"
    # tmux attach
  else
    echo "Creating tmux"
    tmux new -s TMUX
  fi
fi
