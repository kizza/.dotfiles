lua << EOF
  local colours = require("colours")
  local hi = colours.hi

  hi("@constant.git_rebase", {fg = colours.magenta})
  hi("@custom.gitrebase.pick", {fg = colours.yellow, italic = true})
  hi("@custom.gitrebase.edit", {fg = colours.green, italic = true})
  hi("@custom.gitrebase.reword", {fg = colours.blue, italic = true})
  hi("@custom.gitrebase.squash", {fg = 20, italic = true})
  hi("@custom.gitrebase.fixup", {fg = colours.cyan, italic = true})
  hi("@custom.gitrebase.drop", {fg = colours.red, italic = true})
EOF
