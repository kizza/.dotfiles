alias g="git"
alias gs="git status --branch"
alias gd="git diff"
alias gdc="git diff --cached"
alias ga="git add -A" # -A adds deleted files by defailt also
alias ir="git rebase -i master"
alias current="git am --show-current-patch" # During a rebase, shows the current failed patch
alias pollshow="watch --color --no-title --interval 0.5 git show --color" # Show the current commit (to run beside rebases)
alias gl="git l"
alias gll="git log --pretty=format:\"%C(cyan)%h%Creset %an, %C(yellow)%ar: %C(Green)%s\" --stat"
alias gdb="git fetch --prune && git branch --merged master | grep -v 'master$' >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches"
alias gdba="git fetch --prune && git branch | grep -v 'master$' >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -D </tmp/merged-branches"
alias master="git checkout master"
alias ir="git rebase -i master"

# Fuzzy find the branch to switch to
function branch() {
  BRANCH=$(git branch --sort=-committerdate | fzf --height=50% --info=hidden --reverse | awk '{$1=$1;print}')
  if [ ! -z "$BRANCH" ]; then
    git checkout "$BRANCH"
  fi
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
  URL="https://buildkite.com/fivegoodfriends/fivegoodfriends/builds?branch=$BRANCH"
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

fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show % | delta --paging never | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
                # xargs -I % sh -c 'git show --color=always % | delta') << 'FZF-EOF'

# Stash (include untracked files, keep current index), interactive rebase, then unstash
wiprebase() {
  heading 'Wipping and rebasing...'
  git add .
  wip "Doing a rebase"
  git rebase -i --autosquash master
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
  git rebase -i --autosquash master
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
  if [[ "$BRANCH" = "master" ]]; then
    out=$(
      git log HEAD~20 --graph --color=always  --format="%C(auto)%h %s%d %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --no-sort --reverse --query="$q" --tiebreak=index \
          --preview "echo 'Currently staged...\n' && git diff --cached --color" --toggle-sort=\`)
  else
    out=$(
      git log master.. --graph --color=always --format="%C(auto)%h %s%d %C(black)%C(bold)%cr" "$@" |
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
  git commit -m "$(printf "$message\n\n[ci skip]\n")"
}

alias unwip='git log -n 1 | grep -q -c "WIP" && git reset HEAD~1'
