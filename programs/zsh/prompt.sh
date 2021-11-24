local icon=""
local ret_status="%(?:%{$fg_bold[green]%}$icon:%{$fg_bold[red]%}$icon)"
local background_job_status="%(1j:%{$fg[cyan]%} ...:)"
local vim_prompt="%{$fg_bold[yellow]%} VIM MODE%{$reset_color%}"

setopt HIST_IGNORE_ALL_DUPS

PROMPT='$(nix_shell_status) ${ret_status} %{$fg[cyan]%}%c%{$reset_color%}$(git_prompt_info)${background_job_status} '

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[blue]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"

strip_color_codes() {
  echo $1 | sed -E "s/"$'\E'"\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]//g"
}

nix_shell_status () {
  if [ ! -z $IN_NIX_SHELL ]; then
    echo "%(?:%{$fg_bold[green]%}NIX:%{$fg_bold[red]%}NIX)"
  fi
}

set_prompt () {
  TEMP=" $(nix_shell_status)${ret_status} %{$fg[cyan]%}%c%{$reset_color%}$(git_prompt_info)${background_job_status} "
  if [ $KEYMAP = vicmd ]; then
    # PS1="%{$fg_bold[yellow]%}$(strip_color_codes $TEMP)%{$reset_color%}"
    # PROMPT="%{$fg_bold[yellow]%}$(strip_color_codes $TEMP)%{$reset_color%}"
    RPS1="$vim_prompt $EPS1"
  else
    # if [ ! $PS1 = $TEMP ]; then
      # PROMPT="$TEMP"
    # fi
    RPS1="$EPS1"
  fi
}

# set_prompt()

# Vim prompt
function zle-line-init zle-keymap-select {
  set_prompt
  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1


# History substring search
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=bg=18,fg=green,bol
