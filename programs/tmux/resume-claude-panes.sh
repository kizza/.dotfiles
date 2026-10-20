#!/usr/bin/env bash
# Resurrect post-save-layout hook: saves each Claude pane as a resume of the session paddck recorded on it, so a
# restore brings back that conversation rather than a fresh `claude` — or a re-run of the prompt it was started with.
resurrect_file="$1"

awk -F'\t' -v OFS='\t' '
  $1 == "pane" && $11 ~ /^:claude( |$)/ {
    lookup = "tmux show-options -pqv -t \"" $2 ":" $3 "." $6 "\" @paddck_session_id"
    session_id = ""
    lookup | getline session_id
    close(lookup)
    if (session_id != "") $11 = ":claude --resume " session_id
  }
  { print }
' "$resurrect_file" > "$resurrect_file.tmp" && mv "$resurrect_file.tmp" "$resurrect_file"
