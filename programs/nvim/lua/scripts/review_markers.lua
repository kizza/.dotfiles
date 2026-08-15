-- `REVIEW:` comments dropped in during a `git review-commits` pass, then amended into the commit
-- they belong to so an agent can find them, fix the line, and delete the marker in the same amend.
--
-- Highlighting is foreground-only and drawn above treesitter, so a marker sitting on a `+` line
-- keeps its green background and reads as purple *within* the addition rather than replacing it.
local M = {}

local NAMESPACE = vim.api.nvim_create_namespace("review_markers")

-- Matched from the comment leader rather than from `REVIEW`, so the whole marker lifts out of the
-- surrounding code. Vimscript's `"` is left out: unanchored it would swallow half the strings in a
-- buffer, and nothing here is written in vimscript any more.
local MARKER = vim.regex([[\v(#+|//+|--+|;+|/\*+|\<!--)\s*REVIEW>]])

-- Rendered per visible line on redraw, which keeps the markers live while typing without a cache to
-- invalidate and without walking lines that are scrolled off screen.
function M.setup()
  require("highlights").register(function()
    local colours = require("colours")
    colours.hi("ReviewMarker", { fg = colours.magenta, bold = true, italic = true })
  end)

  vim.api.nvim_set_decoration_provider(NAMESPACE, {
    on_win = function()
      return true
    end,
    on_line = function(_, _, buffer, row)
      local line = vim.api.nvim_buf_get_lines(buffer, row, row + 1, false)[1]
      if not line then
        return
      end

      local start = MARKER:match_str(line)
      if start then
        vim.api.nvim_buf_set_extmark(buffer, NAMESPACE, row, start, {
          end_col = #line,
          hl_group = "ReviewMarker",
          priority = 200, -- Above treesitter's 100, so the marker wins inside a highlighted comment
          ephemeral = true,
        })
      end
    end,
  })

  vim.api.nvim_create_user_command("ReviewMarkerAdd", M.insert, {
    desc = "Open a REVIEW marker above the cursor",
  })

  vim.api.nvim_create_user_command("ReviewMarkers", M.populate_quickfix, {
    desc = "Send every REVIEW marker in the repository to the quickfix list",
  })
end

-- Opens the marker on its own line above the cursor, the way a review comment sits above the line
-- it is about. The leader comes from the buffer's own `commentstring`, so the same key writes `#` in
-- Ruby and `//` in TypeScript, and the marker stays greppable in every language.
function M.insert()
  local commentstring = vim.bo.commentstring
  if commentstring == "" then
    commentstring = "# %s"
  end

  local prefix, suffix = commentstring:match("^(.-)%%s(.-)$")
  if not prefix then
    prefix, suffix = "# ", ""
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local indent = vim.api.nvim_get_current_line():match("^%s*")
  local opening = indent .. prefix .. "REVIEW: "

  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { opening .. suffix })
  vim.api.nvim_win_set_cursor(0, { row, #opening })

  -- A closing `*/` or `-->` has to stay to the right of the cursor, so only an empty suffix can use
  -- the append-at-end-of-line form.
  vim.cmd(suffix == "" and "startinsert!" or "startinsert")
end

-- The markers are scattered across the branch by design, so the quickfix list is how you read the
-- review back as a whole: `:ReviewMarkers` then `]q`/`[q` walks every comment in place.
function M.populate_quickfix()
  local completed = vim.system(
    -- Long-bracket level raised because `[[:space:]]` would otherwise close a plain `[[` string.
    { "git", "grep", "-nE", "--no-color", [==[(#+|//+|--+|;+|/\*+|<!--)[[:space:]]*REVIEW]==] },
    { text = true, cwd = vim.fn.getcwd() }
  ):wait()

  -- git grep exits 1 when nothing matched, which is the happy "review is addressed" case.
  if completed.code > 1 then
    vim.notify(vim.trim(completed.stderr or "git grep failed"), vim.log.levels.ERROR, { title = "Review" })
    return
  end

  local items = {}
  for _, match in ipairs(vim.split(vim.trim(completed.stdout or ""), "\n", { trimempty = true })) do
    local filename, lnum, text = match:match("^(.-):(%d+):(.*)$")
    if filename then
      table.insert(items, { filename = filename, lnum = tonumber(lnum), text = vim.trim(text) })
    end
  end

  vim.fn.setqflist({}, " ", { title = "REVIEW markers", items = items })

  if vim.tbl_isempty(items) then
    vim.notify("No REVIEW markers left", vim.log.levels.INFO, { title = "Review" })
  else
    vim.cmd("copen")
  end
end

return M
