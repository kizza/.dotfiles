# History completion
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi

# FZF Theme
#
# fg: The majority of the text (unselected items)
# bg: The majority of the back (essentially the page)
# hl: The matching text

# fg+: Same, but as the highlighted item
# bg+: Same, but as the highlighted item
# hl+: Same, but as the highlighted item

# info: The details of the query (how many etc)
# prompt: FZF> bit
# pointer: The left cursor
export FZF_DEFAULT_OPTS='
--color=light
--color=fg:8,bg:-1,hl:2,fg+:15,bg+:18,hl+:2
--color=info:14,prompt:6,pointer:2,marker:6,spinner:#61afef,header:17
'
