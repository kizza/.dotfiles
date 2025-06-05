local M = {}
local ns_id = vim.api.nvim_create_namespace('contextmenu')
local theme = require("colours")

-- State
local state = {
  buffer = nil,
  window = 0,
  items = {},        -- pum menu items
  callback = nil,    -- callback for invocation
  confirmed = false, -- action from pum menu
  restore = {},      -- global values to restore
}

-- Convert menu items to completion items
local function format_completion_item(item, index)
  if type(item) == "string" then
    return { word = item } --, user_data = index }
  end
  return item
end

-- Get current character and highlight under cursor
local function get_current_char_context()
  -- Get highlight info at current position
  local info = vim.inspect_pos()

  -- Get character at position
  local line = vim.api.nvim_buf_get_lines(info.buffer, info.row, info.row + 1, false)[1]
  local char = string.sub(line, info.col + 1, info.col + 1)

  -- Get first syntax highlight group if any
  local syntax_hl = nil
  if #info.syntax > 0 then
    syntax_hl = info.syntax[1].hl_group
    print("syntax " .. syntax_hl)
  end

  -- Get first treesitter highlight group if any
  local ts_hl = nil
  if #info.treesitter > 0 then
    ts_hl = info.treesitter[1].hl_group_link or info.treesitter[1].hl_group
    print("ts " .. ts_hl)
  end

  -- local char_hl_group = vim.api.nvim_get_hl(0, { name = ts_hl or syntax_hl })
  -- print(char_hl_group)

  vim.api.nvim_set_hl(0, "Cmenu", { link = ts_hl or syntax_hl })

  return {
    character = char,
    highlight = ts_hl or syntax_hl,
  }
end

-- Pum completion function
function M.completefunc(findstart, base)
  if findstart == 1 then
    return 0
  end

  -- Create a new indexed table with completion items
  local items = {}
  for i, item in ipairs(state.items) do
    table.insert(items, format_completion_item(item, i - 1))
  end

  local matches = vim.tbl_filter(function(item)
    return string.match(string.lower(item.word), string.lower(base))
  end, items)

  return { words = matches, refresh = 'always' }
end

-- Handle completion selection
local function on_complete_done()
  local item = nil
  if state.confirmed == true then
    item = vim.v.completed_item
    if item.word == "" then -- Could *confirm* a non-choice
      item = nil
    end
  end

  if type(state.callback) == "string" then
    vim.cmd(string.format("call %s('%s')", state.callback, item))
  else
    state.callback(item)
  end

  close()
end

function create_buffer(icon)
  local bufno = vim.api.nvim_create_buf(false, true)
  vim.bo[bufno].filetype = 'contextmenu'

  -- Listen for pum completion event
  vim.api.nvim_create_autocmd("CompleteDone", {
    buffer = bufno,
    callback = function(args)
      vim.schedule(on_complete_done)
    end
  })

  -- If text is changed, a key was pressed that didn't filter the pum list
  vim.api.nvim_create_autocmd("TextChangedI", {
    buffer = bufno,
    callback = function(args)
      if vim.fn.pumvisible() == 1 then -- Will fire complete twice without checking this
        vim.schedule(on_complete_done)
      end
    end
  })

  -- If the list was filtered, but no item is selected automatically select the first item
  vim.api.nvim_create_autocmd("CompleteChanged", {
    buffer = bufno,
    callback = function(args)
      if vim.fn.complete_info({ "selected" }).selected == -1 then
        vim.schedule(function()
          vim.api.nvim_select_popupmenu_item(0, false, false, {})
        end)
      end
    end
  })

  return bufno
end

function create_highlights()
  -- Link context menu styles to Pmenu by default
  vim.api.nvim_set_hl(0, "CmenuNormal", { link = "Pmenu" })
  vim.api.nvim_set_hl(0, "Cmenu", { link = "Pmenu" })
  vim.api.nvim_set_hl(0, "CmenuSel", { link = "PmenuSel" })

  local icon_colour = 3
  local background_colour = 18
  theme.hi("CmenuNormal", { fg = background_colour, bg = icon_colour })

  -- Stylize with background theme
  local theme_colour = 0
  local background_colour = theme.darken(theme_colour, 0.3, { to = "#000000" })
  theme.hi("CmenuNormal", { fg = background_colour, bg = icon_colour })
  theme.hi("CmenuVirtualText", { bold = true })
  theme.hi("Cmenu", { bg = background_colour })
  -- theme.hi("CmenuSel", { bg = theme.darken(theme_colour, 0.2, { towards = "#000000" }) })
end

function create_window(icon)
  -- Create window
  local win_opts = {
    relative = 'cursor',
    row = 0,
    col = 0,
    width = 1,
    height = 1,
    focusable = false,
    style = 'minimal',
  }

  local winno = vim.api.nvim_open_win(state.buffer, true, win_opts)

  -- Set window options
  local win_config = {
    foldenable = false,
    wrap = true,
    statusline = '',
    number = false,
    relativenumber = false,
    cursorline = false,
    signcolumn = 'no',
    scrolloff = 0,
    sidescrolloff = 0,
    list = true,                     -- required for listchars (below)
    listchars = 'precedes:' .. icon, -- show icon via *preceding* (overflow) char

    -- NonText is required (to clear the default one)
    winhl = 'Normal:CmenuNormal,Pmenu:Cmenu,PmenuSel:CmenuSel,NormalNC:CmenuNormal,NonText:CmenuNonText',
  }

  for k, v in pairs(win_config) do
    vim.api.nvim_win_set_option(state.window, k, v)
  end

  return winno
end

function M.open(items, callback, opts)
  if #items == 0 then return end

  local defaults = { icon = 'X' }
  opts = vim.tbl_deep_extend('force', defaults, opts or {})
  state.items = items
  state.callback = callback
  state.confirmed = false

  -- Create buffer
  if state.buffer == nil then
    create_highlights()
    state.buffer = create_buffer(opts.icon)
  end

  -- Create icon
  vim.api.nvim_buf_set_extmark(state.buffer, ns_id, 0, 0, {
    virt_text = { { opts.icon, 'CmenuVirtualText' } },
    virt_text_pos = 'inline',
  })

  -- local context = get_current_char_context()

  -- Create window
  state.window = create_window(opts.icon)

  -- Style cursor
  state.restore.guicursor = vim.opt.guicursor:get()
  vim.opt.guicursor = 'i:block-ContextMenuCursor' -- To have the highlighted square (and reversed)

  -- Setup completion
  vim.bo.completefunc = "v:lua.require'funs.contextmenu'.completefunc"
  state.restore.completeopt = vim.opt.completeopt
  vim.opt.completeopt = { "menu", "menuone", "popup", "noinsert", "preview" } -- Changed to vim.opt

  -- Function to confirm choice
  local function confirm_choice()
    state.confirmed = true
    return vim.api.nvim_replace_termcodes('<C-y>', true, true, true)
  end

  -- Function to cancel choice
  local function cancel_choice()
    return vim.api.nvim_replace_termcodes('<C-e>', true, true, true)
  end

  -- Conditional key mappings for <CR> and <Esc>
  vim.keymap.set('i', '<CR>', function()
    return vim.fn.pumvisible() == 1 and confirm_choice() or '<CR>'
  end, { expr = true })

  vim.keymap.set('i', '<Esc>', function()
    return vim.fn.pumvisible() == 1 and cancel_choice() or '<Esc>'
  end, { expr = true })

  -- Open pum completion
  local open_pum_keys = vim.api.nvim_replace_termcodes('<C-x><C-u>', true, true, true)
  vim.api.nvim_feedkeys('A' .. open_pum_keys, 'n', true)
end

function close()
  -- Restore global values
  vim.opt.guicursor = state.restore.guicursor
  vim.opt.completeopt = state.restore.completeopt

  if state.window ~= 0 then
    -- Exit from insert mode (and move right... as we're exiting insert mode, which moves left)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>l', true, false, true), 'n', true)

    -- Close the window
    vim.api.nvim_win_close(state.window, true)
    state.window = 0
  end

  -- Wipe the buffer content clean
  vim.api.nvim_buf_set_lines(state.buffer, 0, -1, false, {})
  vim.api.nvim_buf_clear_namespace(state.buffer, ns_id, 0, -1)
end

function M.example()
  M.open(
    { 'First', 'Second', 'Third' },
    function(item)
      if item == nil then
        vim.notify("Selected nothing")
      else
        vim.notify("Selected " .. item.word)
      end
    end,
    { icon = '' }
  )
end

function M.example1()
  vim.ui.select(
    { "Option 1", "Option 2", "Option 3" }, -- List of items
    { prompt = "Select an option:" },       -- Options table with prompt
    function(choice)                        -- Callback for selected item
      if choice then
        vim.notify("You selected: " .. choice)
      end
    end
  )
end

function M.example2()
  M.open(
    {
      { word = 'First',  abbr = '1st', user_data = 'Custom data 1', menu = 'Meny', kind = 'File', info = 'This other info' },
      { word = 'Second', abbr = '2nd', user_data = 'Custom data 2', info = '' },
      { word = 'Third',  abbr = '3rd', user_data = 'Custom data 3' },
      {
        word = "~/.config/nvim/init.lua",
        abbr = "init.lua",
        kind = "󰈙",
        menu = "~/.config/nvim",
        info = "Configuration file\nLast modified: 2024-01-20"
      }

    },
    function(item)
      if item == nil then
        vim.notify("Selected nothing")
      else
        vim.notify("Selected " .. item.word)
      end
    end,
    { icon = '' }
  )
end

return M
