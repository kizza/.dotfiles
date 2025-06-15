-- Walk thr provided string through treesitter syntax portions
-- to build a table of { text, highlight } pairs
---@param result table
---@param s string
---@param lnum number
---@param coloff? number
local function fold_virt_text(result, s, lnum, coloff)
  if not coloff then coloff = 0 end

  local text = ""
  local hl
  for i = 1, #s do
    local char = s:sub(i, i)
    local hls = vim.treesitter.get_captures_at_pos(0, lnum, coloff + i - 1)
    local _hl = hls[#hls]
    if _hl then
      local new_hl = "@" .. _hl.capture
      if new_hl ~= hl then
        table.insert(result, { text, hl })
        text = ""
        hl = nil
      end
      text = text .. char
      hl = new_hl
    else
      text = text .. char
    end
  end
  table.insert(result, { text, hl })
end

---@return table
function _G.custom_foldtext()
  local start = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
  local end_str = vim.fn.getline(vim.v.foldend)
  local end_ = vim.trim(end_str)
  local result = {}

  -- Insert virtual text
  fold_virt_text(result, start, vim.v.foldstart - 1)
  table.insert(result, { " ", "FoldPillInverse" })
  table.insert(result, { "...", "FoldPill" })
  table.insert(result, { " ", "FoldPillInverse" })
  fold_virt_text(result, end_, vim.v.foldend - 1, #(end_str:match("^(%s+)") or ""))

  -- Insert label
  local fold_line_count = vim.v.foldend - vim.v.foldstart + 1
  table.insert(result, { "    ", "" })
  table.insert(result, { string.format("%d lines ", fold_line_count), 'FoldInfo' })
  return result
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- Highlights
    local theme = require("colours")
    theme.hi("FoldPill", { bg = 19 })
    theme.hi("FoldPillInverse", { fg = 19 })
    theme.hi("FoldInfo", { italic = true })

    -- Beahviour
    local opt = vim.opt
    opt.foldmethod = "expr" -- Use expression-based folding
    opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    opt.foldtext = "v:lua.custom_foldtext()"
    opt.foldenable = false -- Disable folding by default (folds open)
    opt.foldlevel = 20

    -- Keybindings
    vim.cmd [[
      " z fold index shortcuts
      " nmap <silent> zj za
      " nmap <silent> zk za
      for i in range(0, 9)
        execute "nnoremap <leader>z" . i . " :set foldlevel=". i . "<CR>"
      endfo
    ]]
  end,
})

return {
  {
    "anuvyklack/pretty-fold.nvim",
    enabled = false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    "kevinhwang91/nvim-ufo",
    enabled = false,
    dependencies = {
      "kevinhwang91/promise-async",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function(_, _opts)
      -- vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.statuscolumn =
      "%s %=%{%v:lnum == line('.') ? v:lnum : v:relnum%} %{%foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? '' : '%#DiagnosticSignOk#') : ' ' %}"

      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  %d lines'):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end

      require('ufo').setup({
        fold_virt_text_handler = handler,
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end
      })
    end
  },
}
