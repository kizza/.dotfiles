local M = {}

function M._get_open_buffers(zindex)
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_loaded(buf) and vim.fn.bufname(buf) ~= "" and vim.bo[buf].buftype ~= "nofile"
  end, vim.api.nvim_list_bufs())
end

function M._buffer_names(buffers)
  return vim.tbl_map(function(buf)
    return vim.fn.bufname(buf)
  end, buffers)
end

function M._write_to_file(file_path, lines)
  local file = io.open(file_path, "w")
  if not file then
    error("Failed to open file: " .. file_path)
  end
  for _, line in ipairs(lines) do
    file:write(line .. "\n")
  end
  file:close()
end

function M.take_a_snapshot()
  local name = vim.fn.input("Snapshot name", "open_buffers.txt")
  if name == "" then return end

  local snapshot_file = vim.fn.getcwd() .. "/" .. name
  local open_buffers = M._get_open_buffers()
  local buffer_paths = M._buffer_names(open_buffers)
  M._write_to_file(snapshot_file, buffer_paths)
  print("Snapshot saved to " .. snapshot_file)
end

function M.read_a_snapshot()
  M.select_snapshot_file(function(file_path)
    local file = io.open(file_path, "r")
    if not file then return print("Failed to open file: " .. file_path) end
    for line in file:lines() do
      vim.cmd("edit " .. vim.fn.fnameescape(line))
    end
    file:close()
    print("Snapshot loaded from " .. file_path)
  end)
  -- local file_path = M.build_snapshot_path()
end

function M.select_snapshot_file(callback)
  -- Get the list of snapshot files in root directory
  local txt_files = vim.fn.glob("*.txt", false, true)
  if #txt_files == 0 then return print("No snapshots found") end

  -- Use vim.ui.select to present the files
  vim.ui.select(txt_files, {
    prompt = "Select a snapshot:",
    format_item = function(item)
      return vim.fn.fnamemodify(item, ":t") -- Show only the filename, not the full path
    end,
  }, function(choice)
    if not choice then return print("No file selected.") end
    callback(choice)
  end)
end

return M
