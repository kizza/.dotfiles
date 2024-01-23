local M = {}

M.highlight = setmetatable({}, {
  __newindex = function(_, hlgroup, args)
  if ('string' == type(args)) then
    vim.cmd(('hi! link %s %s'):format(hlgroup, args))
    return
  end
})

return {
  base00 = '#282828',
  base08 = '#fb4934',
  base0B = '#b8bb26',
  base0A = '#fabd2f',
  base0D = '#83a598',
  base0E = '#d3869b',
  base0C = '#8ec07c',
  base05 = '#d5c4a1', -- white
  base03 = '#665c54', -- bright black
  base07 = '#fbf1c7', -- bright white
  base09 = '#fe8019', -- extra shades
  base0F = '#d65d0e',
  base01 = '#3c3836', -- dark shades
  base02 = '#504945',
  base04 = '#bdae93', -- light shades
  base06 = '#ebdbb2',
}

local black = vim.g.terminal_color_0
local red = vim.g.terminal_color_1
local green = vim.g.terminal_color_2
local yellow = vim.g.terminal_color_3
local blue= vim.g.terminal_color_4
local magenta = vim.g.terminal_color_5
local cyan = vim.g.terminal_color_6
local white = vim.g.terminal_color_7
local brightblack = vim.g.terminal_color_8

vim.g.terminal_color_8  = M.colors.base03
vim.g.terminal_color_9  = M.colors.base08
vim.g.terminal_color_10 = M.colors.base0B
vim.g.terminal_color_11 = M.colors.base0A
vim.g.terminal_color_12 = M.colors.base0D
vim.g.terminal_color_13 = M.colors.base0E
vim.g.terminal_color_14 = M.colors.base0C
vim.g.terminal_color_15 = M.colors.base07
