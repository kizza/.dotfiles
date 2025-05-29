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

M.dark_grey          = 18
M.grey               = 19
M.light_grey         = 20

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

local Colour = {}
Colour.__index = Colour

function Colour.new(cterm)
  local self = setmetatable({}, Colour)
  if type(cterm) ~= "number" then
    error("Cannot build colours from ".. cterm .. " (" .. type(cterm) ..")")
  end
  if cterm < 0 or cterm > 21 or math.floor(cterm) ~= cterm then
    error("Invalid cterm value: must be an integer between 0 and 21")
  end
  self.cterm = cterm
  self.hex = M.get(cterm)
  return self
end

function Colour:darken(percentage, opts)
  opts = opts or {}
  self.hex = M.transition_hex(M.get(self.cterm), opts.to or M.get(0), percentage or 0.9)
  return self
end

function Colour.wrap(obj)
  if Colour.is_colour(obj) then
    return obj
  else
    return Colour.new(obj)
  end
end

function Colour.is_colour(obj)
  return getmetatable(obj) == Colour
end

-- Wrapper for nvim_set_hl, applies cterm colours as provided
-- but applies the gui colour (via base16)
function M.hi(group, opts)
  local palette = opts

  if opts.fg then
    local fg = Colour.wrap(opts.fg)
    palette.ctermfg = fg.cterm
    palette.fg = fg.hex
    -- palette.ctermfg = opts.fg
    -- palette.fg = M.get(opts.fg)
  end

  if opts.bg then
    local bg = Colour.wrap(opts.bg)
    palette.ctermbg = bg.cterm
    palette.bg = bg.hex
  end

  vim.api.nvim_set_hl(0, group, palette)
end

function M.darken(cterm, percentage, opts)
  local colour = Colour.new(cterm)
  colour:darken(percentage, opts)
  return colour
end

-- Transitions a start hex color to an end hex color by a percentage (0..1), blending each RGB channel
function M.transition_hex(start_hex, end_hex, percentage)
  percentage = math.max(0, math.min(percentage or 0, 1))
  local function hex_to_rgb(hex)
    return tonumber(hex:sub(2,3),16),
           tonumber(hex:sub(4,5),16),
           tonumber(hex:sub(6,7),16)
  end

  local function lerp(a, b, t)
    return math.floor(a + (b - a) * t + 0.5)
  end

  local sr, sg, sb = hex_to_rgb(start_hex)
  local er, eg, eb = hex_to_rgb(end_hex)

  local r = lerp(sr, er, percentage)
  local g = lerp(sg, eg, percentage)
  local b = lerp(sb, eb, percentage)

  return string.format("#%02x%02x%02x", r, g, b)
end

function M.create_hi_autocmd()
  -- Define the :Hi command
  vim.api.nvim_create_user_command("Hi", function(opts)
    -- Split the command args into group name and attributes
    local args = vim.split(opts.args, "%s+", { trimempty = true })
    if #args < 1 then
      vim.notify("Usage: Hi <group> [fg=<color>] [bg=<color>] [italic] [bold] ...", vim.log.levels.ERROR)
      return
    end

    local group = args[1] -- First arg is the highlight group
    local attributes = {}

    for i = 2, #args do -- Parse remaining args (e.g., "fg=magenta", "italic")
      local arg = args[i]
      if arg:match("^fg=") then
        local raw = arg:gsub("^fg=", "")
        attributes.fg = tonumber(raw)
      elseif arg:match("^bg=") then
        local raw = arg:gsub("^bg=", "")
        attributes.bg = tonumber(raw)
      elseif arg:match("^link=") then
        local link = arg:gsub("^link=", "")
        attributes.link = link
      elseif arg == "italic" then
        attributes.italic = true
      elseif arg == "underline" then
        attributes.underline = true
      elseif arg == "undercurl" then
        attributes.undercurl = true
      elseif arg == "reverse" then
        attributes.reverse = true
      elseif arg == "bold" then
        attributes.bold = true
        -- Add more attributes as needed (underline, etc.)
      else
        vim.notify("Unknown attribute: " .. arg, vim.log.levels.WARN)
      end
    end

    -- Apply the highlight using your hi function
    M.hi(group, attributes)
  end, {
    nargs = "+", -- Requires at least one argument (group name), allows more
    desc = "Set highlight group using theme colors",
    complete = function(_, cmdline, _)
      if cmdline:match("^Hi%s") then
        local hls = vim.api.nvim_get_hl(0, {})
        local options = {}
        for name, _ in pairs(hls) do
          table.insert(options, name)
        end
        return vim.fn.sort(options)
      else
        return {}
      end
    end
  })
end

return M
