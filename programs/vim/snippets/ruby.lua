local fmt = require("luasnip.extras.fmt").fmt

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function map(table, fn)
  local t = {}
  for index, value in pairs(table) do
    t[index] = fn(value)
  end
  return t
end


-- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- placeholder 2,...
local function copy(args)
	return args[1]
end

local function ruby_assign_instance_variables(args)
	local arguments = split(args[1][1], ",")
	local strip_argument_defaults = map(arguments, function(argument) return split(argument, ":")[1] end)
  local cleaned_arguments = map(strip_argument_defaults, function(argument) return string.gsub(argument, "[ |=]", "") end)
  local instance_variables = map(cleaned_arguments, function(argument) return "\t@"..argument.." = "..argument end)
  return instance_variables
end

return {
  s("initialize", {
		t({ "def initialize(" }),
		-- Placeholder to enter initial arguments
		i(1, "argument"),
		-- Linebreak
		t({ ")", "" }),
    -- Populate the instance variable assignment based on arguments
		f(ruby_assign_instance_variables, 1),
		-- Last Placeholder, exit Point of the snippet.
		i(0),
		t({ "", "end", "" }),
	}),

  -- Allow (any instance) to...
  s({trig = "allow", dscr = "allow|expect(any_instance) to..."}, {
    c(1, {
      sn(nil, { t("allow("), i(1, "object"), t(")") }),
      sn(nil, { t("allow_any_instance_of("), i(1, "Class"), t(")") }),
      sn(nil, { t("expect("), i(1, "object"), t(")") }),
      sn(nil, { t("expect_any_instance_of("), i(1, "Class"), t(")") })
    }),
		t(".to receive(:"), i(2, "method"), t(")"),
		c(3, {
      sn(nil, {t(".and_return("), i(1, "value"), t(")")}),
      sn(nil, {t(".and_call_original"), i(1)}),
      sn(nil, {
        t(".with("), i(1, "argument"), t(")"),
        c(2, {
          sn(nil, {t(".and_return("), i(1, "value"), t(")")}),
          sn(nil, {t(".and_call_original"), i(1), })
        })
      }),
		}),
    i(0)
  }),

  s({trig = "expect", dscr = "expect(...).to"}, {
    t("expect("),
		i(1, "something"),
    t(")."),
		c(2, {
      t("to"),
      t("not_to"),
		}),
    t(" "),
    c(3, {
      sn(nil, { t("eq("), i(1, "value"), t(")") }),
      sn(nil, { t("include("), i(1, "..."), t(")") }),
      sn(nil, { t("contain_exactly("), i(1, "..."), t(")") }),
      sn(nil, { t("be_"), i(1, "...") }),
    }),
    i(0)
  }),

  s("fn", {
		-- Simple static text.
		t("//Parameters: "),
		-- function, first parameter is the function, second the Placeholders
		-- whose text it gets as input.
		f(copy, 2),
		t({ "", "function " }),
		-- Placeholder/Insert.
		i(1),
		t("("),
		-- Placeholder with initial text.
		i(2, "int foo"),
		-- Linebreak
		t({ ") {", "\t" }),
		-- Last Placeholder, exit Point of the snippet.
		i(0),
		t({ "", "}" }),
	}),
}
