local function is_file_buffer(buf)
  return vim.bo[buf].buflisted and vim.bo[buf].buftype == ""
end

local function is_unmodified_file_buffer(buf)
  return is_file_buffer(buf)
      and not vim.bo[buf].modified
      and vim.b[buf].discardable
      and vim.api.nvim_buf_is_valid(buf)
end

local function get_valid_buffers()
  return vim.iter(vim.api.nvim_list_bufs())
      :filter(function(buf) return buf ~= vim.api.nvim_get_current_buf() end)
      :filter(is_unmodified_file_buffer)
      :totable()
end

local M = {}

function M.mark_buffer_as_discardable()
  local buf = vim.api.nvim_get_current_buf()

  if not is_file_buffer(buf) then
    vim.notify("Cannot mark this buffer as discardable", vim.log.levels.WARN)
    return
  end

  vim.b[buf].discardable = true
  vim.notify("Buffer marked as discardable", vim.log.levels.INFO)
end

function M.create_discard_on_buf_enter_autocmd()
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("DiscardableBufferCleanup", { clear = true }),
    callback = function()
      local current = vim.api.nvim_get_current_buf()

      if not is_file_buffer(current) then
        return
      end

      vim.schedule(function()
        for _, buf in ipairs(get_valid_buffers()) do
          vim.api.nvim_buf_delete(buf, {})
        end
      end)
    end,
  })
end

return M

