-- Review comments held in `.remarks/`, where the `remarks` CLI lets a coding agent read and resolve
-- them. Replaced the `REVIEW:` markers that used to be written into the source itself.
return {
  {
    "kizza/remarks.nvim",
    dev = true,
    event = "VeryLazy",
    config = function()
      require("remarks").setup()

      require("highlights").register(function()
        local colours = require("colours")

        -- Quiet by intent: a remark is marginalia, not a diagnostic. The rail and sign sit back
        -- against the gutter, and only an unlocated remark is allowed to draw the eye.
        colours.hi("RemarkText", { fg = 7, italic = true })
        colours.hi("RemarkRail", { fg = 3 })
        colours.hi("RemarkSign", { fg = 3 })
        colours.hi("RemarkRange", { bg = colours.darken(3, 0.8) })
        colours.hi("RemarkUncertain", { fg = colours.yellow })
      end)
    end,
  },
}
