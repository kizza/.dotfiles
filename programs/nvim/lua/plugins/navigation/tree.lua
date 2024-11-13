local M = {
  -- A file explorer tree for neovim written in lua
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "VimEnter",
  keys = {
    { "<leader>n", "<cmd>NvimTreeFindFileToggle<cr>", desc = "Find within tree" },
    { "<leader>N", "<cmd>NvimTreeFocus<cr>",          desc = "Open tree" },
  },
}

function M.opts()
  return {
    git = {
      enable = false,
      ignore = false,
    },
    view = {
      width = 40,
      signcolumn = "no",
    },
    filters = { dotfiles = false },
    on_attach = function(bufnr)
      local api = require 'nvim-tree.api'
      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      api.config.mappings.default_on_attach(bufnr)
      -- NERDTree mappings I prefer
      -- Change root directory
      vim.keymap.set('n', '<S-C>',
        function()
          api.tree.change_root_to_node()
          vim.fn.feedkeys("gg")
        end,
        opts('CD')
      )

      -- Move and copy
      local lib = require("nvim-tree.lib")
      -- Copy
      vim.keymap.set('n', 'mc',
        function()
          local file_src = lib.get_node_at_cursor()['absolute_path']
          vim.ui.input(
            { prompt = 'Copy to: ', default = file_src },
            function(input)
              if (input == nil) then return end
              if (input == file_src) then return print("Same path, ignoring") end

              local dir = vim.fn.fnamemodify(input, ":h")   -- Create any parent dirs as required
              vim.fn.system { 'mkdir', '-p', dir }
              vim.fn.system { 'cp', '-R', file_src, input } -- Copy the file
              print("Copied to " .. input)
            end
          )
        end,
        opts('Copy file to')
      )
      -- Move
      vim.keymap.set('n', 'mm',
        function()
          local file_src = lib.get_node_at_cursor()['absolute_path']
          vim.ui.input(
            { prompt = 'Move to: ', default = file_src },
            function(input)
              if (input == nil) then return end
              if (input == file_src) then return print("Same path, ignoring") end

              local dir = vim.fn.fnamemodify(input, ":h") -- Create any parent dirs as required
              vim.fn.system { 'mkdir', '-p', dir }
              vim.fn.system { 'mv', file_src, input }     -- Copy the file
              print("Moved to " .. input)
            end
          )
        end,
        opts('Move file to')
      )
      -- Open in tmux
      vim.keymap.set('n', '<C-t>',
        function()
          local path = lib.get_node_at_cursor()['absolute_path']
          vim.fn.execute("silent !withsplit 'v " .. path .. "'")
        end,
        opts('Open in tmux')
      )
    end,
    actions = {
      open_file = {
        quit_on_open = true,
        window_picker = {
          enable = true,
          picker = "default",
          chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          exclude = {
            filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", "minimap" },
            buftype = { "nofile", "terminal", "help" },
          },
        },
      },
    },
    select_prompts = true,
    renderer = {
      icons = {
        webdev_colors = true,
        git_placement = "after",
        show = {
          git = false,
        },
        glyphs = {
          folder = {
            arrow_closed = "",
            arrow_open = "",
          },
        }
      }
    },
  }
end

function M.init()
end

function M.config(_, opts)
  require("nvim-tree").setup(opts)
  M.open_at_start()
  M.highlight()
end

function M.open_at_start()
  local data = {
    file = vim.api.nvim_buf_get_name(0),
    buf = 0,
  }
  local no_name = data.file == "" and vim.bo[data.buf].buftype == "" -- buffer is a [No Name]
  local directory = vim.fn.isdirectory(data.file) == 1               -- buffer is a directory
  if not no_name and not directory then
    return
  end
  if directory then
    vim.cmd.cd(data.file)
  end
  vim.cmd("NvimTreeOpen")
  vim.cmd("NvimTreeRefresh")
  -- require("nvim-tree.api").tree.open()
end

function M.highlight()
  local colours = require("colours")
  local hi = colours.hi
  local magenta = colours.magenta
  local yellow = colours.yellow
  hi("NvimTreeRootFolder", { fg = magenta })
  hi("NvimTreeOpenedFolderIcon", { fg = magenta })
  hi("NvimTreeFileDirty", { fg = yellow })
  hi("NvimTreeSymlink", { italic = true })
  hi("NvimTreeExecFile", { fg = yellow, italic = true })

  -- vim.cmd[[
  --   " -- NvimTree
  --   " NvimTreeNormal = { fg = c.fg_sidebar, bg = c.bg_sidebar },
  --   " NvimTreeWinSeparator = {
  --   "   fg = options.styles.sidebars == "transparent" and c.border or c.bg_sidebar,
  --   "   bg = c.bg_sidebar,
  --   " },
  --   " NvimTreeNormalNC = { fg = c.fg_sidebar, bg = c.bg_sidebar },
  --   hi NvimTreeRootFolder ctermfg=magenta
  --   "hi NvimTreeFolderIcon ctermfg=magenta
  --   hi NvimTreeOpenedFolderIcon ctermfg=magenta
  --   hi NvimTreeFileDirty ctermfg=yellow
  --   " NvimTreeGitDirty = { fg = c.git.change },
  --   " NvimTreeGitNew = { fg = c.git.add },
  --   " NvimTreeGitDeleted = { fg = c.git.delete },
  --   " NvimTreeOpenedFile = { bg = c.bg_highlight },
  --   " NvimTreeSpecialFile = { fg = c.purple, underline = true },
  --   " NvimTreeIndentMarker = { fg = c.fg_gutter },
  --   " NvimTreeImageFile = { fg = c.fg_sidebar },
  --   hi NvimTreeSymlink cterm=italic
  --   hi NvimTreeExecFile cterm=italic ctermfg=yellow
  -- ]]
end

return M
