# History completion
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi

export FZF_DEFAULT_OPTS=''
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--color=light
--color=fg:8,bg:-1,hl:2,fg+:15,bg+:18,hl+:2
--color=info:14,prompt:1,pointer:2,marker:8,spinner:#61afef,header:17
'
