alias fat="bat"
alias ls="exa"
alias dotfiles="cd ~/.dotfiles"
alias capture_unicode="xxd -psd"

# Run cops/linters on branch files
alias fastcop="since_master | grep \\.rb$ | xargs ls 2>/dev/null | xargs rubocop --force-exclusion"
alias fasterb="since_master | grep \\.erb$ | xargs ls 2>/dev/null | xargs erblint"
alias crystalball="bundle exec crystalball"

function fastspec {
  FILES=$(since_master | grep \._spec.rb$ | xargs ls 2>/dev/null)
  heading "Running rspec with..."
  echo $FILES
  echo $FILES | xargs rspec
}

function set_colour {
  printf '\033Ptmux;\033\033]4;%d;rgb:%s\033\033\\\033\\' $@;
}

function code { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# Fuzzy find directory files with "v" otherwise open "v ."
function v {
  if [[ $# -eq 1 ]]; then
    nvim "$1"
  else
    FILE=$(fzf --multi --height=50% | awk '{$1=$1;print}')
    if [ ! -z "$FILE" ]; then
      nvim "$FILE"
    fi
  fi
}

function fresh {
  nix-shell --run "home-manager switch" ~/.dotfiles/shell.nix
}
