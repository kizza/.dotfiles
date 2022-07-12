if has('nvim')
  let g:jump_from_treesitter_fallback = "call CocAction('jumpDefinition')"
  Plug '~/Code/kizza/jump-from-treesitter.nvim'
  Plug '~/Code/kizza/joinery.nvim'
endif

Plug '~/Code/kizza/vim-textobj-directional-indent'
