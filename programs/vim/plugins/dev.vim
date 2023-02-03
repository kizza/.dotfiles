if has('nvim')
  let g:jump_from_treesitter_fallback = "call CocAction('jumpDefinition')"
  Plug '~/Code/kizza/jump-from-treesitter.nvim'
  Plug '~/Code/kizza/joinery.nvim'
  Plug '~/Code/kizza/actionprompt.nvim'
endif

Plug '~/Code/kizza/vim-reorder-buffers'
Plug '~/Code/kizza/vim-textobj-block'
