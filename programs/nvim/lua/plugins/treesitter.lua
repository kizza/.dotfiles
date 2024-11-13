return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      highlight = {
        enable = true,
        custom_captures = {
          ["custom.method.name"] = "TSCustomMethodName",
          ["custom.keyword_parameter.name"] = "TSCustomKeywordParameterName",
          ["custom.keyword_parameter.value"] = "TSCustomKeywordParameterValue",
          ["custom.class.method.invocation"] = "TSCustomClassMethodInvocation",
          ["custom.method"] = "TSCustomMethod",
        },
      },
      indent = { enable = true, disable = { "python", "ruby" } },
      context_commentstring = { enable = true, enable_autocmd = false },
      matchup = { -- integrate with vim-matchup
        enable = true,
      },
      ensure_installed = {
        "bash",
        "c",
        -- "embedded_template",
        "html",
        "git_rebase",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "nix",
        "python",
        "query",
        "regex",
        "ruby", -- seems to work again
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      incremental_selection = {
        enable = false,
      },
    },
    config = function(_, opts)
      -- require("nvim-treesitter.install").compilers = { 'clang' }
      require("nvim-treesitter.configs").setup(opts)

      local opt = vim.opt
      opt.foldlevel = 20
      opt.foldmethod = "expr"
      opt.foldexpr = "nvim_treesitter#foldexpr()"

      -- Include eruby as embedded_template
      -- local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      -- parser_config.embedded_template = {
      --   -- install_info = {
      --   --   url = 'https://github.com/tree-sitter/tree-sitter-embedded-template',
      --   --   files =  { 'src/parser.c' },
      --   --   requires_generate_from_grammar  = true,
      --   -- },
      --   used_by = {'eruby'}
      -- }
    end,
  },
}
