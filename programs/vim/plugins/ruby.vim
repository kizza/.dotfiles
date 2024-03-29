filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins

Plug 'vim-ruby/vim-ruby'

Plug 'tpope/vim-rails'

Plug 'nvim-treesitter/nvim-treesitter'
Plug 'tree-sitter/tree-sitter-ruby'
Plug 'nvim-treesitter/playground'

" Yaml navigation
let g:vim_yaml_helper#auto_display_path = 0
Plug 'lmeijvogel/vim-yaml-helper'
