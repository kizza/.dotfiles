lua << EOF
  local colours = require("colours")
  local hi = colours.hi
  local cyan = colours.cyan
  local magenta = colours.magenta
  local blue = colours.blue

  hi("@module.builtin", { fg = 16 })
EOF
