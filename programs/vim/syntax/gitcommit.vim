setlocal textwidth=72
setlocal spell

lua << EOF
  local colours = require("colours")
  local hi = colours.hi

  vim.bo.textwidth = 72
  vim.wo.spell = true
  hi("ColorColumn", { bg=19 })
EOF

