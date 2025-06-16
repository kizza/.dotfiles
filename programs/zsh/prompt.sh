#
# Prompt
# --------------------------------------------------------------------

local icon=""
local ret_status="%(?:%F{2}$icon:%F{1}$icon)%f"
local background_job_prompt="%(1j:%F{6} …%f:)"
local start_italics=$'%{\x1b[3m%}'
local end_italics=$'%{\x1b[0m%}'

local user="%F{5}%n@%m:%f"
[[ "$HOST" =~ "Mac" ]] && user=""

git_prompt()
{
  git -C ./ rev-parse 2>/dev/null || return # No git

  local label="?"
  local head
  head=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [ $? -eq 0 ]; then
    if [[ $head != "HEAD" ]]; then
      label=$head
    else
      local rebase_dir=$(git rev-parse --git-path rebase-merge 2>/dev/null)
      if [[ -d $rebase_dir ]]; then
        local rebase=$(cat "$rebase_dir/done" | awk '{ print $1 " " substr($2,0,10) }')
        if [[ $rebase != "" ]]; then
          label=$(echo $rebase | tail -n1) # Could be several lines
        fi
      fi
    fi
  fi
  echo -n '%F{4}  '$start_italics$label'%f'$end_italics
}

nix_prompt () {
  if [ ! -z $IN_NIX_SHELL ]; then
    echo "%(?:%F{2}NIX:%F{1}NIX)%f"
  fi
}

setopt prompt_subst
PROMPT='$(nix_prompt)${ret_status} ${user}%F{6}%c%f$(git_prompt)${background_job_prompt} '

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
