local timer

local function debounce(callback)
  if not timer then timer = vim.uv.new_timer() end
  timer:start(1000, 0, vim.schedule_wrap(callback))
end

return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  -- enabled = false,
  config = function()
    require("lint").linters_by_ft = {
      ruby = { "rubocop" },
      -- eruby = { "erb_lint" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "TextChanged" }, {
      pattern = { "*.rb", "*.html.erb" },
      callback = function()
        -- try_lint without arguments runs the linters defined in `linters_by_ft`
        -- for the current filetype
        debounce(require("lint").try_lint)

        -- You can call `try_lint` with a linter name or a list of names to always
        -- run specific linters, independent of the `linters_by_ft` configuration
        -- require("lint").try_lint("rubocop")
      end,
    })
  end
}
