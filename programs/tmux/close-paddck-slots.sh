#!/usr/bin/env bash
# Resurrect post-restore-all hook: closes the panes `record-paddck-panes` marked as paddck's, leaving each window as its
# work alone for paddck to give a fresh slot when the sidebar comes back. Ids first, since closing a pane renumbers the rest.
resurrect_file="$1"

slots=$(awk -F'\t' '$1 == "paddck_slot" { print $2 ":" $3 "." $4 }' "$resurrect_file" |
  while read -r target; do tmux display-message -p -t "$target" '#{pane_id}' 2>/dev/null; done)

for pane in $slots; do
  tmux kill-pane -t "$pane"
done
