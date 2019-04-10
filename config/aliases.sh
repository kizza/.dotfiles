# alias v="vim iu ~/.vimrc"
alias vim="/usr/local/bin/vim"
alias v="vim"
alias reload=". ~/.zshrc"
alias dotfiles="cd ~/.dotfiles"

alias cat="bat"
alias dc="docker-compose"
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

alias g="git"
alias gs="git status --branch"
alias gc="git commit"
alias gd="git diff"
alias gdc="git diff --cached"
alias ga="git add"
alias gl="git l"
alias gdb="git fetch --prune && git branch --merged master | grep -v 'master$' >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches"

export MYVIMRC=~/.vimrc
