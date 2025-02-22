local M              = {}
local base16_colours = require('base16-colorscheme').colors;

-- M.colour_names = { black = 0, red = 1, green = 2, yellow = 3, blue = 4, magenta = 5, cyan = 6, white = 7 }
M.black              = 0
M.red                = 1
M.green              = 2
M.yellow             = 3
M.blue               = 4
M.magenta            = 5
M.cyan               = 6
M.white              = 7
M.colour_names       = { 0, 1, 2, 3, 4, 5, 6, 7 }

local function cterm_to_base16(i)
  local mapping = {
    [0] = "00",
    [1] = "08",
    [2] = "0B",
    [3] = "0A",
    [4] = "0D",
    [5] = "0E",
    [6] = "0C",
    [7] = "05",
    [8] = "03",
    [9] = "08",
    [10] = "0B",
    [11] = "0A",
    [12] = "0D",
    [13] = "0E",
    [14] = "0C",
    [15] = "07",
    [16] = "09",
    [17] = "0F",
    [18] = "01",
    [19] = "02",
    [20] = "04",
    [21] = "06"
  }
  return mapping[i]
end

function M.get(i)
  if vim.opt.termguicolors:get() == false then return i end

  -- Translate cterm index value to base16 code suffix
  local base16_value = cterm_to_base16(i)
  if not base16_value then return nil end

  if base16_colours == nil then
    -- Return from tinted-theme palette
    return "#" .. vim.g["tinted_gui" .. base16_value]
  else
    -- Return from nvim-base16 color palette
    return base16_colours["base" .. base16_value]
  end
  -- return "#" .. os.getenv("BASE16_COLOR_" .. cterm_to_base16(i) .. "_HEX")
end

function M.debug(group_name)
  local hl_group = vim.api.nvim_get_hl_by_name(group_name, true)

  -- Extract the foreground and background colors
  if hl_group.foreground then hl_group.foreground = string.format("#%06x", hl_group.foreground) end
  if hl_group.background then hl_group.background = string.format("#%06x", hl_group.background) end

  print(vim.inspect(hl_group))
end

-- Wrapper for nvim_set_hl, applies cterm colours as provided
-- but applies the gui colour (via base16)
function M.hi(group, opts)
  local palette = opts

  if opts.fg then
    palette.ctermfg = opts.fg
    palette.fg = M.get(opts.fg)
  end

  if opts.bg then
    palette.ctermbg = opts.bg
    palette.bg = M.get(opts.bg)
  end

  vim.api.nvim_set_hl(0, group, palette)
end

return M
