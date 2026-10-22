#!/usr/bin/env bash
#
# Announces the end of a turn — spoken, and on screen. Named after the session when Keiran has
# named it (`/rename`), else after the branch rather than the agent, because with several worktree
# agents running at once "claude done" says nothing about which one finished: `Auto attachments`
# speaks as "Auto attachments done", and an unnamed session on `billing/duplicate-invoice-lines` as
# "duplicate-invoice-lines done". Falls back to the directory name when detached or outside a
# repository.
#
# A turn ending is not the work ending. An agent that spawned subagents in the background sends
# Stop the moment its own last word is out, with the subagents still grinding — so the payload is
# read first and nothing is said while any of them is still running.
#
# Which means a batch that finishes long after the turn did is never announced. That is the trade:
# SubagentStop fires identically for a subagent the turn *waited* for, so announcing there would
# say "done" in the middle of every turn that spawned one. The sidebar is the surface for work
# finishing while you are away — it can tell the two apart, and this cannot.

set -uo pipefail

payload="$(cat)"

# Still working, whatever the turn said. A string match rather than jq: this runs on every turn of
# every agent, and an announcement that goes quiet because a binary is missing is worse than
# matching against JSON that Claude emits without spaces.
case "$payload" in
  *'"status":"running"'*) exit 0 ;;
esac

# Claude Code registers every live session in ~/.claude/sessions, one JSON file per process, with
# the name it goes by and whether that came from him ("user") or was derived from the directory.
# A derived name is the directory's, which the branch already says better, so only his counts.
session_name() {
  local file
  file="$(grep -l "\"sessionId\":\"$1\"" "$HOME/.claude/sessions"/*.json 2>/dev/null | head -1)"
  [ -n "$file" ] || return 0
  grep -q '"nameSource":"user"' "$file" || return 0
  sed -n 's/.*"name":"\([^"]*\)".*/\1/p' "$file"
}

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || true

session_id="${payload##*\"session_id\":\"}"
session_id="${session_id%%\"*}"

name="$(session_name "$session_id")"
[ -n "$name" ] || name="$(git branch --show-current 2>/dev/null | sed 's|.*/||')"
[ -n "$name" ] || name="$(basename "$PWD")"

osascript -e 'display notification "Claude is done" with title "Claude Code"' >/dev/null 2>&1
"$HOME/.dotfiles/bin/piper_say" "$name done" >/dev/null 2>&1

exit 0
