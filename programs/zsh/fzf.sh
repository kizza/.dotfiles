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
--inline-info
--color=light
--color=fg:20,fg+:15,hl:5,hl+:2,bg:-1,bg+:18
--color=info:14,prompt:5,pointer:6,marker:6,spinner:3,header:17,border:19
'
