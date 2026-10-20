#!/usr/bin/env bash
# Resurrect post-save-layout hook. Saves each Claude pane as a resume of the session paddck recorded on it, so a restore
# brings back that conversation rather than a fresh `claude`, or a re-run of the prompt it was started with. Also marks
# paddck's slots and its sidebar, which can only come back as empty shells, for `close-paddck-slots` to close.
resurrect_file="$1"
format='#{@paddck_session_id}|#{?#{||:#{@paddck_slot},#{==:#{pane_id},#{@paddck-pane}}},slot,}'

awk -F'\t' -v OFS='\t' -v format="$format" '
  $1 == "pane" {
    lookup = "tmux display-message -p -t \"" $2 ":" $3 "." $6 "\" \"" format "\""
    answer = ""
    lookup | getline answer
    close(lookup)
    split(answer, paddck, "|")
    if (paddck[1] != "" && $11 ~ /^:claude( |$)/) $11 = ":claude --resume " paddck[1]
    if (paddck[2] == "slot") slot = "paddck_slot" OFS $2 OFS $3 OFS $6 # a line type resurrect does not read
  }
  { print }
  slot != "" { print slot; slot = "" }
' "$resurrect_file" > "$resurrect_file.tmp" && mv "$resurrect_file.tmp" "$resurrect_file"
