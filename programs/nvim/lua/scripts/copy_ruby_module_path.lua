local M = {}

function M.get_ruby_module_path()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local path_parts = {}

  for _, line in ipairs(lines) do
    local trimmed = vim.trim(line)

    -- Match module definitions
    local kind, name = trimmed:match("^(module)%s+([%w_:]+)")
    if kind and name then
      table.insert(path_parts, name)
    end

    -- Match class definitions
    kind, name = trimmed:match("^(class)%s+([%w_:]+)")
    if kind and name then
      table.insert(path_parts, name)
      -- Return immediately after first class definition
      return table.concat(path_parts, "::")
    end
  end

  return table.concat(path_parts, "::")
end

function M.copy()
  local path = M.get_ruby_module_path()
  if path ~= "" then
    vim.fn.setreg('"', path)
    vim.notify("Copied: " .. path)
  else
    vim.notify("No module/class found")
  end
end

return M
