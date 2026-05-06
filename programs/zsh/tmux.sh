# if command -v tmux &> /dev/null; then
#   if [[ -n "$TMUX" ]]; then
#     echo "Within tmux"
#     # tmux attach
#   else
#     echo "Creating tmux"
#     # tmux new -s TMUX

#     # Start (or attach to existing) session
#     tmux new-session -A -s TMUX
#   fi
# fi
