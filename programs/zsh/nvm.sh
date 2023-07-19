export NVM_DIR="$HOME/.nvm"

if [[ ! -e $NVM_DIR ]]; then
  git clone https://github.com/nvm-sh/nvm.git $NVM_DIR
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .node-version && -r .node-version  ]]; then
    # echo "Found .node-version"
  elif [[ -f .nvmrc && -r .nvmrc  ]]; then
    echo "Using .nvmrc"
    nvm use
  elif [[ $(nvm version) != $(nvm version default) ]]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
