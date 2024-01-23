if command -v tmux &> /dev/null && [[ -z "$TMUX" ]]; then
  tmux attach -t TMUX || tmux new -s TMUX
fi
