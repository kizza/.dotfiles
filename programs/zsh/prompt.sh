#
# Prompt
# --------------------------------------------------------------------

local icon=""
local ret_status="%(?:%F{2}$icon:%F{1}$icon)%f"
local background_job_prompt="%(1j:%F{6} …%f:)"
local start_italics=$'%{\x1b[3m%}'
local end_italics=$'%{\x1b[0m%}'

git_prompt()
{
  head=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [ $? -eq 0 ]; then
    if [[ $head != "HEAD" ]]; then
      output=$head
    else
      rebase=$(cat $(git rev-parse --show-toplevel)/.git/rebase-merge/done | awk '{ print $1 " " substr($2,0,10) }')
      if [[ $rebase != "" ]]; then
        output=$(echo $rebase | tail -n1) # Could be several lines
      fi
    fi
    echo '%F{4}  '$start_italics$output'%f'$end_italics
  fi
}

nix_prompt () {
  if [ ! -z $IN_NIX_SHELL ]; then
    echo "%(?:%F{2}NIX:%F{1}NIX)%f"
  fi
}

setopt prompt_subst
PROMPT='$(nix_prompt)${ret_status} %F{6}%c%f$(git_prompt)${background_job_prompt} '

#
# Vim mode
# --------------------------------------------------------------------

bindkey -v

local vim_prompt="%F{3} VIM MODE%f"

set_prompt () {
  if [ $KEYMAP = vicmd ]; then
    RPS1="$vim_prompt $EPS1"
  else
    RPS1="$EPS1"
  fi
}

function zle-line-init zle-keymap-select {
  set_prompt
  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

#
# Most of this is set via home-manager (except this one)
# --------------------------------------------------------------------
setopt HIST_IGNORE_ALL_DUPS

#
# Tab menu completion
# --------------------------------------------------------------------
zstyle ':completion:*' menu select

#
# Extension colours
# --------------------------------------------------------------------

# Use dircolors to populate LS_COLORS, then use with zstyle
eval "$(dircolors -b ~/.dotfiles/programs/zsh/dircolors.sh)"

# Pass in ls-colors, then the "tab menu highlight"
# (38;5;?; is foreground, 48;5;?; is background)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} "ma=38;5;0;48;5;5;1"

# Customise zsh-syntax-highlight options
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=yellow'

# History substring search
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=bg=18,fg=green,bol
