#!/usr/bin/env bash
# workflow-review <pull request url or number>: open the reading room for a pull request Keiran was asked to
# review — a worktree of its branch, a window in the `Review` tmux session, and a reviewer session in it. The
# window and the session are named for the pull request's title as GitHub shows it; only the worktree keeps
# `pr-<number>`. A window already named for the title means it is open, and nothing happens.
set -euo pipefail

REPOSITORY="$HOME/Code/lookout"
WORKTREES="$HOME/Code/worktrees/lookout"

main() {
  cd "$REPOSITORY"
  IFS=$'\t' read -r number title branch url < <(
    gh pr view "${1:?pull request url or number}" --json number,title,headRefName,url --jq '[.number, .title, .headRefName, .url] | @tsv'
  )

  if tmux list-windows -t Review -F '#W' 2>/dev/null | grep -qxF "$title"; then
    echo "already open: $title"
    return 0
  fi

  worktree="$WORKTREES/pr-$number"
  [ -d "$worktree" ] || add_worktree
  window="$(open_window)"
  tmux send-keys -t "$window" "claude --name $(printf '%q' "$title") $(printf '%q' "/workflow:reviewer $url")" Enter
  echo "opened: $title ($worktree)"
}

add_worktree() {
  git fetch origin "$branch"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add --force "$worktree" "$branch" # --force: the branch may be checked out in another worktree
  else
    git worktree add --track -b "$branch" "$worktree" "origin/$branch"
  fi
}

open_window() {
  # Named windows stay named; tmux only auto-renames the ones opened without -n. Target by id afterwards: a
  # title's `:` and `.` read as tmux target separators.
  if tmux has-session -t Review 2>/dev/null; then
    tmux new-window -P -F '#{window_id}' -t Review -n "$title" -c "$worktree"
  else
    tmux new-session -d -P -F '#{window_id}' -s Review -n "$title" -c "$worktree"
  fi
}

main "$@"
