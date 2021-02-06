alias g="git"
alias gs="git status --branch"
alias gd="git diff"
alias gdc="git diff --cached"
alias ga="git add"
alias gl="git l"
alias gll="git log --pretty=format:\"%C(cyan)%h%Creset %an, %C(yellow)%ar: %C(Green)%s\" --stat"
alias gdb="git fetch --prune && git branch --merged master | grep -v 'master$' >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches"
alias gdba="git fetch --prune && git branch | grep -v 'master$' >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -D </tmp/merged-branches"
alias master="get checkout master"
alias ir="git rebase -i master"

# `gc "Foo"` commits with Foo (otherwise use normally)
function gc() {
  if [[ $# -eq 1 ]]; then
    git commit -m "$1"
  else
    git commit "$@"
  fi
}

fshow() {
  local out shas sha q k
  while out=$(
      git log --graph --color=always \
          --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --multi --no-sort --reverse --query="$q" --tiebreak=index \
          --print-query --expect=ctrl-d --toggle-sort=\`); do
    q=$(head -1 <<< "$out")
    k=$(head -2 <<< "$out" | tail -1)
    shas=$(sed '1,2d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
    [ -z "$shas" ] && continue
    if [ "$k" = 'ctrl-d' ]; then
      git diff --color=always $shas | less -R
    else
      for sha in $shas; do
        git show --color=always $sha | less -R
      done
    fi
  done
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
      git log HEAD~20 --graph --color=always \
          --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --no-sort --reverse --query="$q" --tiebreak=index \
          --preview "echo 'Currently staged...\n' && git diff --cached --color" --toggle-sort=\`)
  else
    out=$(
      git log master.. --graph --color=always \
          --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --no-sort --reverse --query="$q" --tiebreak=index \
          --preview "echo 'Currently staged...\n' && git diff --cached --color" --toggle-sort=\`)
  fi
  sha=$(sed 's/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
  if [ ! -z "$sha" ]; then
    git commit --fixup "$sha"
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
