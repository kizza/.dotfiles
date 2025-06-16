local M = {}

function M.show()
  require("snacks.picker").git_log({
    title = "Select fixup",
    current_line = true,
    actions = {
      fixup = function(this_picker, item)
        this_picker:close()
        vim.fn.system("git reset")
        vim.schedule(function()
          require("gitsigns.actions").stage_hunk()
          vim.fn.system("git commit --fixup " .. item.commit)
          vim.notify("Fixup for " .. item.commit .. " created", vim.log.levels.INFO, { title = "Git" })
        end)
      end,
    },
    win = {
      input = {
        keys = {
          ["<CR>"] = { "fixup", mode = { "n", "i" }, desc = "Toggle Global Keymaps" },
        },
      },
    },
  })
end

return M
