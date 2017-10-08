alias v="nvim iu ~/.vimrc"
alias reload=". ~/.bashrc"

alias dc="docker-compose"
alias v="nvim -u ~/.vimrc"
alias whatalias="alias | grep"
alias zshrc="v ~/.zshrc"
alias vimrc="v ~/.vimrc"
alias tmuxrc="v ~/.tmux.conf"
alias bnode="node_modules/.bin/babel-node"
alias filesize="du -hs"
alias generate_uuid="uuid -v5 ns:URL keirans-test-$(date +%s) | pbcopy"

alias fastcop='git since-master | grep \\.rb$ | xargs ls 2>/dev/null | xargs rubocop --force-exclusion'
mini () { bin/rake test "$@" }
spec () { bin/rspec "$@" }

alias g="git"
alias gs="git status"
alias gc="git commit"
alias gd="git diff"
alias gdc="git diff --cached"
alias ga="git add"
alias gl="git l"

export MYVIMRC=~/.vimrc
