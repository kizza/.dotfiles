local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("lua", {
  s({
    trig = "print",
    name = "Print with vim.inspect",
    dscr = "Expands 'print' to 'print(vim.inspect())' with cursor on vim.inspect()",
  }, {
    t("print("),
    i(1, "vim.inspect()"), -- First insert node, initially highlighted with vim.inspect()
    t(")"),
    i(0),                  -- Final insert node, inside vim.inspect()
  }, {
    -- Define tab stops explicitly
    jump_index = 1,
    -- Transform first insert node to place cursor inside vim.inspect()
    nodes = {
      [1] = {
        transform = function(text)
          print(text)
          if text == "vim.inspect()" then
            return "vim.inspect()"
          end
          return text
        end,
        next_jump = function()
          return "vim.inspect(|)"
        end,
      },
    },
  }),
})
