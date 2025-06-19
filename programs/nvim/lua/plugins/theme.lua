local theme_name_path = vim.fn.expand("~/.config/tinted-theming/theme_name")

-- Resolve the base16 theme name from environment
local function get_theme_name()
  local theme_name = vim.fn.readfile(theme_name_path)[1]
  return theme_name
end

local function apply_theme()
  vim.cmd("highlight clear")
  vim.cmd("doautocmd ColorSchemePre")

  local theme_name = get_theme_name()
  local base16_studio_path = "~/base16-studio"
  local theme_file = vim.fn.expand(base16_studio_path .. "/themes/vim/" .. theme_name .. ".nvim")
  if vim.fn.filereadable(theme_file) == 1 then
    -- vim.notify("Sourcing " .. theme_name)
    vim.fn.execute("source " .. theme_file) -- base16studio
  else
    -- vim.notify("Colourscheme " .. theme_name)    -- os.getenv("BASE16_THEME"))
    vim.cmd("colorscheme base16-" .. theme_name) -- fallback
  end

  vim.cmd("doautocmd ColorScheme")
end

local function throttle(fn, wait)
  local last_call = 0                                        -- Last time the function was called
  return function(...)
    local now = vim.fn.reltimefloat(vim.fn.reltime()) * 1000 -- Get current time in milliseconds
    if now - last_call >= wait then
      fn(...)                                                -- Call the original function
      last_call = now                                        -- Update the last call time
    end
  end
end

local apply_theme_throttled = throttle(apply_theme, 500)

-- https://github.com/rktjmp/fwatch.nvim/blob/main/lua/fwatch.lua
local function watch_for_theme_change()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local uv = vim.loop
      local handle = uv.new_fs_event()

      -- these are just the default values
      local flags = {
        watch_entry = false, -- true = when dir, watch dir inode, not dir content
        stat = false,        -- true = don't use inotify/kqueue but periodic check, not implemented
        recursive = false    -- true = watch dirs inside dirs
      }

      local unwatch = function()
        uv.fs_event_stop(handle)
      end

      local event_cb = function(err, filename, events)
        if err then
          vim.notify("Error watching theme" .. err)
          unwatch()
        else
          vim.schedule(function() apply_theme_throttled() end)
        end
      end

      uv.fs_event_start(handle, theme_name_path, flags, event_cb) -- attach handler

      return handle
    end
  })
end

return {
  {
    "tinted-theming/base16-vim",
    dependencies = { "RRethy/nvim-base16" },
    lazy = false,
    enabled = true,
    priority = 1004, -- one more than snacks
    config = function()
      require("base16-colorscheme").with_config({ telescope = false })
      require("highlights").setup()
      watch_for_theme_change()

      vim.opt.termguicolors = true
      vim.g.base16_colorspace = 256

      -- Reapply colour scheme
      apply_theme()
      vim.api.nvim_create_user_command("Repaint", function()
        apply_theme()
      end, {})

      -- Toggle cterm/gui (to allow previewing themes from terminal)
      vim.api.nvim_create_user_command("ToggleGUI", function()
        vim.opt.termguicolors = not vim.opt.termguicolors:get()
        require("plugins.ui.status").refresh()
      end, {})
    end
  },
}
