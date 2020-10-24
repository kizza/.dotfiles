# alias v="vim iu ~/.vimrc"
alias vim="/usr/local/bin/vim"
alias v="nvim"
alias reload=". ~/.zshrc"
alias dotfiles="cd ~/.dotfiles"
alias cat="bat"
alias whatalias="alias | grep"
alias zshrc="v ~/.zshrc"
alias vimrc="v ~/.vimrc"
alias tmuxrc="v ~/.tmux.conf"
alias bnode="node_modules/.bin/babel-node"
alias filesize="du -hs"
alias generate_uuid="uuid -v5 ns:URL keirans-test-$(date +%s) | pbcopy"
# alias eye="cd $(fd -t d | fzf --preview 'tree {}')"

alias npmi="heading 'Deleting node modules...' && rm -rf node_modules && heading 'Clearing node cache...' && npm cache clear --force && heading 'Installing node modules...' && npm i && finished"

alias frm="heading 'Fetching remote...' && git fetch --prune && heading 'Rebasing on origin/master...' && git rebase origin/master && finished"

alias fastcop='git since-master | grep \\.rb$ | xargs ls 2>/dev/null | xargs rubocop --force-exclusion'
mini () { bin/rake test "$@" }
spec () { bin/rspec "$@" }

alias quiet="exitcode $1"

#
# For ubuntu... phcopy (for my brain)
alias pbcopy="xclip -selection clipboard"

#
# Git related
#

alias g="git"
alias gs="git status --branch"
alias gc="git commit"
alias gd="git diff"
alias gdc="git diff --cached"
alias ga="git add"
alias gl="git l"
alias gdb="git fetch --prune && git branch --merged master | grep -v 'master$' >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches"
alias gdba="git fetch --prune && git branch | grep -v 'master$' >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -D </tmp/merged-branches"
alias master="get checkout master"

# fshow - git commit browser (enter for show, ctrl-d for diff, ` toggles sort)
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

export MYVIMRC=~/.vimrc
