local ret_status="%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%})"
local background_job_status="%(1j:%{$fg[cyan]%} ...:)"

nix_shell_status () {
  if [ ! -z $IN_NIX_SHELL ]; then
    echo "%(?:%{$fg_bold[green]%}NIX:%{$fg_bold[red]%}NIX)"
  fi
}

PROMPT=' $(nix_shell_status)${ret_status} %{$fg[cyan]%}%c%{$reset_color%}$(git_prompt_info)${background_job_status} '

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[blue]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"
