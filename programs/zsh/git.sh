alias g="git"
alias gd="git diff"
alias gdc="git diff --cached"
alias ga="git add -A" # -A adds deleted files by defailt also
alias gat="git status --untracked-files=no --porcelain | awk '{ print \$2 }' | xargs git add" # git add tracked
alias gas="git diff --cached  --name-only | xargs git add" # git add already staged
alias current="git am --show-current-patch" # During a rebase, shows the current failed patch
alias pollshow="watch --color --no-title --interval 0.5 git show --color" # Show the current commit (to run beside rebases)
alias gl="git l"
alias gll="git log --pretty=format:\"%C(cyan)%h%Creset %an, %C(yellow)%ar: %C(Green)%s\" --stat"
alias gdba="git fetch --prune && git branch | grep -vE '(master|master)$' >/tmp/merged-branches && nvim /tmp/merged-branches && xargs git branch -D </tmp/merged-branches"
alias master="main"

function gs() {
  ~/.dotfiles/programs/git/scripts/git-status-stat
}

function since_master() {
  git diff --name-only $(trunk) # Local only
}

function gdb() {
  git fetch --prune && git branch --merged $(trunk) | grep -vE '(master|main)$' \
    >/tmp/merged-branches && nvim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches
}

# Remove the worktrees sitting on merged branches, then delete those branches.
# The list opens in nvim first, exactly like gdb — delete a line to keep that worktree.
# Pass -f to also remove worktrees holding uncommitted work.
function prune_worktrees() {
  local force
  [[ "$1" == "-f" || "$1" == "--force" ]] && force="--force"

  git fetch --prune || return 1

  local list=/tmp/merged-worktrees
  merged_worktrees >"$list"

  if [[ ! -s "$list" ]]; then
    donetick "No worktrees are sitting on merged branches"
    return
  fi

  nvim "$list" || return 1

  # Never name a local `path` in zsh — it is tied to the PATH array and blows away command lookup
  local worktree_path
  for worktree_path in "${(f)$(<$list)}"; do
    remove_worktree "$worktree_path" "$force"
  done

  git worktree prune
}
alias gdw="prune_worktrees"

# Every worktree path, the main checkout first — git always lists it first
function worktree_paths() {
  git worktree list --porcelain | awk '/^worktree /{ print $2 }'
}

# Every linked worktree, skipping the main one
function worktrees() {
  worktree_paths | tail -n +2
}

# True when a worktree is on a branch already merged into trunk
function worktree_merged() {
  local branch=$(git -C "$1" branch --show-current)
  [[ -n "$branch" ]] && git merge-base --is-ancestor "$branch" $(trunk)
}

function merged_worktrees() {
  local worktree_path
  for worktree_path in "${(f)$(worktrees)}"; do
    worktree_merged "$worktree_path" && echo "$worktree_path"
  done
}

# Remove a worktree and its branch. Only ever called on branches already merged into trunk, which is why
# it takes the branch with it where rm-worktree deliberately does not. Refuses a dirty worktree without
# --force, and a locked one either way (git wants -f -f), so a worktree another agent is live in is never
# yanked.
function remove_worktree() {
  local worktree_path="$1" force="$2"
  local branch=$(git -C "$worktree_path" branch --show-current)

  donetick "Removing worktree $worktree_path ($branch)"
  git worktree remove $force "$worktree_path" || return 1
  git branch -d "$branch"
}

# Each worktree as "path<tab>branch<tab>sha". Porcelain separates entries with a blank line, so flush
# there; a worktree sitting on a detached head has no branch line to read.
function worktree_entries() {
  git worktree list --porcelain | awk '
    /^worktree / { worktree_path = $2; branch = ""; sha = "" }
    /^HEAD /     { sha = substr($2, 1, 10) }
    /^branch /   { branch = $2; sub("refs/heads/", "", branch) }
    /^detached/  { branch = "(detached)" }
    /^$/         { if (worktree_path) printf "%s\t%s\t%s\n", worktree_path, branch, sha; worktree_path = "" }
    END          { if (worktree_path) printf "%s\t%s\t%s\n", worktree_path, branch, sha }
  '
}

# Which worktrees hold uncommitted work. One status per worktree, all at once — run in turn they add up
# to a pause before the picker opens. Tracked changes only: a status that walks untracked files costs
# seven times as much, and the preview window shows them anyway.
function worktree_dirty_paths() {
  setopt local_options no_monitor no_notify

  local worktree_path
  for worktree_path in "${(f)$(worktree_paths)}"; do
    ( [[ -n $(git -C "$worktree_path" status --porcelain --untracked-files=no 2>/dev/null) ]] &&
        print -r -- "$worktree_path" ) &
  done
  wait
}

# "2 weeks ago" reads as a sentence; a column wants "2w"
function compact_age() {
  local count=${1%% *} unit=${${${1#* }%% *}%%,*}

  case ${unit%s} in
    second) print -- "${count}s" ;;
    minute) print -- "${count}m" ;;
    hour)   print -- "${count}h" ;;
    day)    print -- "${count}d" ;;
    week)   print -- "${count}w" ;;
    month)  print -- "${count}mo" ;;
    year)   print -- "${count}y" ;;
    *)      print -- "$1" ;;
  esac
}

# "ahead 6, behind 5" as "↑6 ↓5"
function compact_track() {
  local compacted=${${1//ahead /↑}//behind /↓}
  print -- "${compacted//, / }"
}

# Where a worktree sits, dropping the leaf when it only repeats the branch name
function worktree_location() {
  local worktree_path=$1 slug=${2//\//-}

  [[ ${worktree_path:t} == "$slug" ]] && worktree_path=${worktree_path:h}
  print -- "${worktree_path/#$HOME/~}"
}

# One aligned, coloured line per worktree: the branch you are standing in is green, a worktree holding
# uncommitted work carries a dot, and drift from upstream goes yellow when behind, red when the upstream
# is gone. Newest commit first — the worktree you want is nearly always the one you touched last. Pass
# --linked to drop the main checkout. Field one is the path, for the picker to cut back off.
function worktree_rows() {
  local linked_only=$1
  local here=$(git rev-parse --show-toplevel 2>/dev/null)
  local main_worktree=$(worktree_paths | head -1)

  # One for-each-ref carries the age and the drift of every worktree at once — it knows where each branch
  # is checked out, so nothing here has to walk the worktrees to find out. Branches checked out nowhere
  # lead with an empty path, and "|" keeps a branch with no upstream from collapsing its empty column.
  local key age track stamp
  typeset -A branch_age branch_track branch_stamp dirty
  while IFS='|' read -r key age track stamp; do
    branch_age[$key]=$age branch_track[$key]=$track branch_stamp[$key]=$stamp
  done < <(git for-each-ref refs/heads \
    --format='%(worktreepath)|%(committerdate:relative)|%(upstream:track,nobracket)|%(committerdate:unix)' \
    | grep '^/')

  for key in "${(f)$(worktree_dirty_paths)}"; do dirty[$key]=1; done

  local -a sortable
  local entry entry_path branch sha marker branch_colour track_colour
  local branch_width=0 track_width=0 age_width=0
  typeset -A row_branch row_track row_age row_location

  while IFS=$'\t' read -r entry_path branch sha; do
    [[ "$linked_only" == "--linked" && "$entry_path" == "$main_worktree" ]] && continue

    age=$(compact_age "${branch_age[$entry_path]}")
    track=$(compact_track "${branch_track[$entry_path]}")
    stamp=${branch_stamp[$entry_path]:-0}

    # A detached worktree — mid-rebase, or parked on a commit — has no branch to hang its metadata off,
    # so read that off the commit itself
    if [[ "$branch" == "(detached)" ]]; then
      branch="(detached) $sha"
      age=$(compact_age "$(git show -s --format=%cr $sha)")
      stamp=$(git show -s --format=%ct $sha)
    fi

    row_branch[$entry_path]=$branch
    row_track[$entry_path]=$track
    row_age[$entry_path]=$age
    row_location[$entry_path]=$(worktree_location "$entry_path" "$branch")
    sortable+=("$stamp"$'\t'"$entry_path")

    (( ${#branch} > branch_width )) && branch_width=${#branch}
    (( ${#track} > track_width )) && track_width=${#track}
    (( ${#age} > age_width )) && age_width=${#age}
  done < <(worktree_entries)

  (( ${#sortable} )) || return

  for entry in "${(@f)$(print -l -- "${sortable[@]}" | sort -rn)}"; do
    entry_path=${entry#*$'\t'}

    marker=" "
    [[ -n ${dirty[$entry_path]} ]] && marker="${YELLOW}●${RESET}"

    branch_colour=$BLUE
    [[ "$entry_path" == "$here" ]] && branch_colour=$GREEN

    track_colour=$GREEN
    [[ ${row_track[$entry_path]} == *↓* ]] && track_colour=$YELLOW
    [[ ${row_track[$entry_path]} == gone ]] && track_colour=$RED

    print -r -- "$entry_path"$'\t'"$marker ${branch_colour}${(r:$branch_width:)row_branch[$entry_path]}${RESET}" \
      "${track_colour}${(r:$track_width:)row_track[$entry_path]}${RESET}" \
      "${GREY}${(r:$age_width:)row_age[$entry_path]}  ${row_location[$entry_path]}${RESET}"
  done
}

# Fzf the worktrees and print the path of the one picked. Field one is that path and stays hidden — the
# coloured columns after it are what you see and search, and the preview shows what is going on in there.
function worktree_picker() {
  worktree_rows "${@:2}" | fzf --ansi --height 60% --reverse --delimiter=$'\t' --with-nth=2.. \
    --prompt="$1" \
    --preview='git -C {1} -c color.status=always status --short --branch; echo; git -C {1} log --color --oneline -8' \
    --preview-window=down,55%,border-top \
    | cut -f1
}

# Fzf the worktrees and cd into the one picked
function cd-worktree() {
  local worktree_path=$(worktree_picker "Cd to worktree: ")

  [[ -n "$worktree_path" ]] && cd "$worktree_path"
}

# A removed worktree leaves its branch behind on purpose — that is the point of popping one out, the branch
# becomes checkoutable in the main worktree again. Merged work is the one case worth asking about.
function release_branch() {
  local branch="$1"
  [[ -z "$branch" ]] && return

  if git merge-base --is-ancestor "$branch" $(trunk) 2>/dev/null; then
    echo -n "$branch is merged into $(trunk). Delete it? (y/n) " && read response
    [[ "$response" =~ ^[Yy]$ ]] && { git branch -d "$branch"; return }
  fi

  donetick "$branch is free to check out"
}

# Fzf the worktrees and remove the one picked, leaving its branch behind to be checked out in the main
# worktree. Git refuses while a worktree still holds modified or untracked files — rather than force the
# delete, offer to cd there and judge the work by hand.
function rm-worktree() {
  # The main worktree can never be removed, so it is not offered
  local worktree_path=$(worktree_picker "Remove worktree: " --linked)
  [[ -z "$worktree_path" ]] && return

  local branch=$(git -C "$worktree_path" branch --show-current)
  local main_worktree=$(git tree-root)

  # Removing the worktree you are standing in yanks the ground out from under the shell, so step back
  # to the main one first — origin takes you home again if the removal is refused and you walk away
  local origin=$PWD
  [[ "$PWD" == "$worktree_path" || "$PWD" == "$worktree_path"/* ]] && cd "$main_worktree"

  local failure
  if failure=$(git worktree remove "$worktree_path" 2>&1); then
    donetick "Removed worktree $worktree_path"
    release_branch "$branch"
    return
  fi

  echo "${RED}${CROSS}${RESET} $failure"
  [[ "$failure" != *"modified or untracked files"* ]] && return 1

  echo -n "Cd into $worktree_path to clean it up? (y/n) " && read response
  [[ "$response" =~ ^[Yy]$ ]] || { cd "$origin"; return 1; }

  cd "$worktree_path" && git status --short --untracked-files=all
}

function ir() {
  git rebase -i $(rebase_to)
}

function rebase_to() {
  if git current | grep -qE "(main|master)"; then
    echo $(sha_for_fixup_commit)~1
  else
    echo $(trunk)
  fi
}

# When on a branch, rebasing to main is easy, when on main, find the relevant fixup sha
function sha_for_fixup_commit() {
  # Find the oldest fixup commit (within reason)
  FIXUP=$(git log --oneline --reverse -n 20 | grep -E '^[0-9a-f]{7}\sfixup!' | head -n 1)
  FIXUP_SHA=$(echo $FIXUP | awk '{ print $1 }')
  FIXUP_MSG=$(echo $FIXUP | cut -d' ' -f3-)

  # Find related commit
  RELATED=$(git log --oneline --grep "$FIXUP_MSG" | grep -v "fixup" | head -n 1)
  RELATED_SHA=$(echo $RELATED | awk '{ print $1 }')
  echo $RELATED_SHA
}

function rebasewith() {
  local cmd="$1" sha="$2"

  # If no SHA provided, use the commit after the merge base with main (first commit in branch)
  [ -z "$sha" ] && sha=$(git cherry main -v | head -n 1 | awk '{print $2}')

  # Prompt for continuation
  heading "Start rebase with '$1'?"
  git log -1 --oneline "$sha"
  git log "$sha"..HEAD --oneline --reverse
  echo -n "Would you like to continue? (y/n) " && read response

  # Execute rebase with command
  if [[ "$response" =~ ^[Yy]$ ]]; then
    donebox "Executing rebase with command: $cmd"
    git rebase "$sha" --exec "git show --stat --oneline && zsh -ic '$cmd'"
  else
    echo "Sure thing."
  fi
}

function trunk() {
  git rev-parse --abbrev-ref origin/HEAD | sed 's/origin\///'
}

function main() {
  git checkout $(trunk)
}

function build_fzf_preview {
  echo "$1 | bat --color=always --style=plain $2"
}

# Fuzzy find a branch and print its name alone. The list stays exactly as `git branch` renders it so the
# markers survive on screen — `*` for the branch checked out here, `+` for one a worktree already holds —
# and only the pick is stripped back to a name. A detached HEAD lists as `(HEAD detached at …)`, which is
# no branch to hand back.
function select_branch() {
  local picked=$(git branch --sort=-committerdate \
    | fzf --height=50% --info=hidden --reverse --prompt="$1" \
          --preview="$(build_fzf_preview 'git log {-1} --oneline' '--language=gitoneline')" \
    | sed 's/^[*+][[:space:]]*//; s/^[[:space:]]*//')

  [[ -z "$picked" || "$picked" == \(* ]] && return 1
  echo "$picked"
}

# Fuzzy find the branch to switch to
function branch() {
  local picked
  picked=$(select_branch "Checkout: ") || return

  git checkout "$picked"
}

# Check a branch out here even when a worktree already holds it. A branch is a single ref, so only one
# tree may ever commit on it: grab pulls work into the main checkout to run and poke at, and the worktree
# an agent is in stays where it gets committed.
function grab() {
  local picked
  picked=$(select_branch "Grab (ignores other worktrees): ") || return

  local holder=$(git branch --list "$picked" --format='%(worktreepath)')

  git checkout --ignore-other-worktrees "$picked" || return 1

  [[ -n "$holder" && "$holder" != "$(git rev-parse --show-toplevel)" ]] &&
    echo "  ${ITALIC_START}also checked out in $holder — commit there, not here${ITALIC_END}"
}

# Open pr for the current branch
function pr() {
  ROOT=$(git config --get remote.origin.url)
  TAIL=${ROOT/#git@github\.com:/}
  SLUG=${TAIL/%\.git/}
  BRANCH=$(git branch --show-current)
  URL="https://github.com/$SLUG/pull/new/$BRANCH"
  open $URL
}

# Open buildkite for the current branch
function bk() {
  BRANCH=$(git branch --show-current)
  URL="https://buildkite.com/thelookoutway/lookout/builds?branch=$BRANCH"
  open $URL
}

# `gc "Foo"` commits with Foo (otherwise use normally)
function gc() {
  if [[ $# -eq 1 ]]; then
    git commit -m "$1"
  else
    git commit "$@"
  fi
}

function gaf() {
  if [ -z "$1" ]; then
    echo "Pass the fuzzy match to git add with"
  else
    fd "$1" | xargs git add -A
    git status
  fi
}

# Fuzzy find the branch to switch to
function freset() {
  FILES=$(git diff --cached --name-only | fzf --height=50% --info=hidden --multi)
  if [ ! -z "$FILES" ]; then
    if [[ $# -eq 1 ]]; then
      echo $FILES | tr '\n' ' ' | xargs git reset -p
    else
      echo $FILES | xargs git reset
    fi
  fi
}

# # Fuzzy find the branch to switch to
# function fresetp() {
#   git diff --cached --name-only | fzf --height=50% --info=hidden --reverse | git reset
# }

# See https://gist.github.com/junegunn/f4fca918e937e6bf5bad
fshow() {
  git log --graph --color=always --format="%C(magenta)%h%C(yellow)%d %C(white)%s %C(cyan)%C(italic)%cr" | \
  fzf --ansi --no-sort --reverse --tiebreak=index --preview \
   'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}"); [ $# -eq 0 ] || git detail $1 ; }; f {}' \
      --bind "j:down,k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort,ctrl-m:execute:
        (grep -o '[a-f0-9]\{7\}' | head -1 |
        xargs -I % sh -c 'git detail % | delta --paging never | less -r') << 'FZF-EOF'
        {}
        FZF-EOF" --preview-window=right:60%
}
                # xargs -I % sh -c 'git show --color=always % | delta') << 'FZF-EOF'

# Stash (include untracked files, keep current index), interactive rebase, then unstash
wiprebase() {
  heading 'Wipping and rebasing...'
  git add .
  wip "Doing a rebase"
  git rebase -i --autosquash $(rebase_to)
  heading 'Unwipping...'
  git log -n 1 | grep -q -c "WIP" && git reset HEAD~1
  git status
  donebox
}

stash() {
  git stash push -u -m 'Stashed' --quiet
  donetick "Stashed all"
}

unstash() {
  git stash pop
}

# Stash (include untracked files, keep current index), interactive rebase, then unstash
stashrebase() {
  heading 'Stashing and rebasing...'
  git stash push -u -k -m 'Stashed for rebase' --quiet
  git rebase -i --autosquash $(trunk)
  heading 'Unstashing...'
  git stash pop --quiet
  git reset --quiet
  git status
  donebox
}

# Stash (include untracked files, keep current index), interactive rebase, then unstash
stashpull() {
  heading 'Stashing and pulling...'
  git stash push -u -k -m 'Stashed for pull' --quiet
  git pull --rebase
  heading 'Unstashing...'
  git stash pop --quiet
  git reset --quiet
  git status
  donebox
}

# Create a fixup commit from fzf search of your branch's commits
fixup() {
  local out sha
  git diff --cached --quiet --exit-code
  if [ $? -ne 1 ]; then
    echo "No files are staged for a fixup"
    return
  fi
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$BRANCH" = "master" || "$BRANCH" = "main" ]]; then
    out=$(
      git log -n 50 --graph --color=always  --format="%C(auto)%h %s%d %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --no-sort --reverse --query="$q" --tiebreak=index \
          --preview "echo {} | cut -d ' ' -f2 | xargs git show --color" --toggle-sort=\`)
  else
    out=$(
      git log $(trunk).. --graph --color=always --format="%C(auto)%h %s%d %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --no-sort --reverse --query="$q" --tiebreak=index \
          --preview "echo {} | cut -d ' ' -f2 | xargs git show --color" --toggle-sort=\`)
  fi
  sha=$(sed 's/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
  if [ ! -z "$sha" ]; then
    git commit --fixup "$sha"
    donetick "Created fixup up for $sha $(git log --pretty=format:%s -1 $sha)"
  fi
}

# Create a wip commit (with an optional message)
wip() {
  if [[ $# > 0 ]]; then
    message="WIP: $*"
  else
    message="WIP"
  fi
  git commit -m "$(printf "$message\n\n[skip ci]\n")"
}

alias unwip='git log -n 1 | grep -q -c "WIP" && git reset HEAD~1'
