local eq = MiniTest.expect.equality
local validator = require "lua.schema-validator.init"
local validate = validator.validate
local str_literal = validator.str_literal
local union = validator.union

local T = MiniTest.new_set()

T["primitives"] = MiniTest.new_set()
T["primitives"]["string"] = MiniTest.new_set()
T["primitives"]["string"]["should return true for strings"] = function()
  eq(validate({ type = "string", }, "hello"), true)
  eq(validate({ type = "string", }, ""), true)
end
T["primitives"]["string"]["should return false for non-strings"] = function()
  eq(validate({ type = "string", }, 123), false)
  eq(validate({ type = "string", }, true), false)
  eq(validate({ type = "string", }, function() end), false)
  eq(validate({ type = "string", }, {}), false)
end
T["primitives"]["string"]["should handle optional"] = function()
  eq(validate({ type = "string", }, nil), false)
  eq(validate({ type = "string", optional = true, }, nil), true)
end

T["primitives"]["number"] = MiniTest.new_set()
T["primitives"]["number"]["should return true for numbers"] = function()
  eq(validate({ type = "number", }, 123), true)
  eq(validate({ type = "number", }, 0), true)
end
T["primitives"]["number"]["should return false for non-numbers"] = function()
  eq(validate({ type = "number", }, "hello"), false)
  eq(validate({ type = "number", }, true), false)
  eq(validate({ type = "number", }, function() end), false)
  eq(validate({ type = "number", }, {}), false)
end
T["primitives"]["number"]["should handle optional"] = function()
  eq(validate({ type = "number", }, nil), false)
  eq(validate({ type = "number", optional = true, }, nil), true)
end

T["primitives"]["boolean"] = MiniTest.new_set()
T["primitives"]["boolean"]["should return true for booleans"] = function()
  eq(validate({ type = "boolean", }, true), true)
  eq(validate({ type = "boolean", }, false), true)
end
T["primitives"]["boolean"]["should return false for non-booleans"] = function()
  eq(validate({ type = "boolean", }, "hello"), false)
  eq(validate({ type = "boolean", }, 123), false)
  eq(validate({ type = "boolean", }, function() end), false)
  eq(validate({ type = "boolean", }, {}), false)
end
T["primitives"]["boolean"]["should handle optional"] = function()
  eq(validate({ type = "boolean", }, nil), false)
  eq(validate({ type = "boolean", optional = true, }, nil), true)
end

T["primitives"]["function"] = MiniTest.new_set()
T["primitives"]["function"]["should return true for functions"] = function()
  eq(validate({ type = "function", }, function() end), true)
end
T["primitives"]["function"]["should return false for non-functions"] = function()
  eq(validate({ type = "function", }, "hello"), false)
  eq(validate({ type = "function", }, 123), false)
  eq(validate({ type = "function", }, true), false)
  eq(validate({ type = "function", }, {}), false)
end
T["primitives"]["function"]["should handle optional"] = function()
  eq(validate({ type = "function", }, nil), false)
  eq(validate({ type = "function", optional = true, }, nil), true)
end

T["str_literal"] = MiniTest.new_set()
T["str_literal"]["should return true for string literals"] = function()
  eq(validate({ type = str_literal "hello", }, "hello"), true)
end
T["str_literal"]["should return false for non-string literals"] = function()
  eq(validate({ type = str_literal "hello", }, "there"), false)
  eq(validate({ type = str_literal "hello", }, function() end), false)
  eq(validate({ type = str_literal "hello", }, 123), false)
  eq(validate({ type = str_literal "hello", }, true), false)
  eq(validate({ type = str_literal "hello", }, {}), false)
end
T["str_literal"]["should handle optional"] = function()
  eq(validate({ type = str_literal "hello", }, nil), false)
  eq(validate({ type = str_literal "hello", optional = true, }, nil), true)
end

T["table"] = MiniTest.new_set()
T["table"]["array"] = MiniTest.new_set()
T["table"]["array"]["should return true for tables where every value matches the entries type"] = function()
  eq(validate({ type = "table", entries = "number", }, {}), true)
  eq(validate({ type = "table", entries = "number", }, { 1, 2, 3, }), true)
  eq(validate({ type = "table", entries = "number", }, { 1, nil, 3, }), true)
end
T["table"]["array"]["should return false for tables where not every value matches the entries type"] = function()
  eq(validate({ type = "table", entries = "number", }, { 1, 2, "hello", }), false)
end
T["table"]["array"]["should return false for non-tables"] = function()
  eq(validate({ type = "table", entries = "number", }, "there"), false)
  eq(validate({ type = "table", entries = "number", }, function() end), false)
  eq(validate({ type = "table", entries = "number", }, 123), false)
  eq(validate({ type = "table", entries = "number", }, true), false)
end
T["table"]["array"]["should handle optional"] = function()
  eq(validate({ type = "table", entries = "number", }, nil), false)
  eq(validate({ type = "table", entries = "number", optional = true, }, nil), true)
end

T["table"]["tuple"] = MiniTest.new_set()
T["table"]["tuple"]["should return true for tables where every value matches the entries"] = function()
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, { "hello", 1, }), true)
end
T["table"]["tuple"]["should return false for tables where not every value matches the entries"] = function()
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, {}), false)
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, { "hello", }), false)
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, { "hello", 1, 2, }), false)
end
T["table"]["tuple"]["should return false for non-tables"] = function()
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, "there"), false)
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, function() end), false)
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, 123), false)
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, true), false)
end
T["table"]["tuple"]["should handle optional"] = function()
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, nil), false)
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
    optional = true,
  }, nil), true)
end

T["functions"] = MiniTest.new_set()
T["functions"]["should return true when the fn returns true"] = function()
  eq(validate({
    type = function()
      return true
    end,
  }, "hello"), true)
  eq(validate({
    type = function(val)
      return validate({ type = "string", }, val)
    end,
  }, "hello"), true)
end
T["functions"]["should return false when the fn returns false"] = function()
  eq(validate({
    type = function()
      return false
    end,
  }, 123), false)
  eq(validate({
    type = function(val)
      return validate({ type = "string", }, val)
    end,
  }, 123), false)
end

T["union"] = MiniTest.new_set()
T["union"]["should return true when one of the schemas is true"] = function()
  eq(
    validate({
      type = union {
        { type = "string", },
        { type = "boolean", },
      },
    }, "hello"),
    true
  )
  eq(
    validate({
      type = union {
        { type = "string", },
        { type = "boolean", },
      },
    }, false),
    true
  )
end
T["union"]["should return false when both schemas are false"] = function()
  eq(
    validate({
      type = union {
        { type = "string", },
        { type = "boolean", },
      },
    }, 123),
    false
  )
end

return T
