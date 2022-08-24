require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
    custom_captures = {
      ["custom.method.name"] = "TSCustomMethodName",
      ["custom.keyword_parameter.name"] = "TSCustomKeywordParameterName",
      ["custom.keyword_parameter.value"] = "TSCustomKeywordParameterValue",
      ["custom.class.method.invocation"] = "TSCustomClassMethodInvocation",
      ["custom.method"] = "TSCustomMethod",
    }
  },
  indent = {
    enable = false
  }
}
