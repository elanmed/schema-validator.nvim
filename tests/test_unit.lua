local eq = MiniTest.expect.equality
local err = MiniTest.expect.error
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

T["primitives"]["nil"] = MiniTest.new_set()
T["primitives"]["nil"]["should return true for nil"] = function()
  eq(validate({ type = "nil", }, nil), true)
end
T["primitives"]["nil"]["should return false for non-nils"] = function()
  eq(validate({ type = "nil", }, "hello"), false)
  eq(validate({ type = "nil", }, 123), false)
  eq(validate({ type = "nil", }, function() end), false)
  eq(validate({ type = "nil", }, {}), false)
  eq(validate({ type = "nil", }, false), false)
end
T["primitives"]["boolean"]["should handle optional"] = function()
  eq(validate({ type = "nil", optional = true, }, nil), true)
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
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, { "hello", 1, 2, }), true)
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
T["table"]["tuple"]["should handle top-level optional"] = function()
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
T["table"]["tuple"]["should handle level optional entries"] = function()
  eq(validate({
      type = "table",
      entries = {
        { type = "string", optional = true, },
        { type = "number", },
      },
    },
    { nil, 123, }
  ), true)
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

T["malformed schema"] = MiniTest.new_set()
T["malformed schema"]["when the schema.type is invalid, it should throw"] = function()
  err(
    function()
      validate({
        type = "hello",
      }, "there")
    end
  )
end
T["malformed schema"]["when the type(schema.type) is invalid, it should throw"] = function()
  err(
    function()
      validate({
        type = {},
      }, "there")
    end
  )
end
T["malformed schema"]["when the schema.entries is invalid, it should throw"] = function()
  err(
    function()
      validate({
        type = "table",
        entries = function() end,
      }, {})
    end
  )
  err(
    function()
      validate({
        type = "table",
        entries = 123,
      }, {})
    end
  )
  err(
    function()
      validate({
        type = "table",
        entries = nil,
      }, {})
    end
  )
  err(
    function()
      validate({
        type = "table",
        entries = true,
      }, {})
    end
  )
end

T["kitchen sink"] = MiniTest.new_set()

--- @type Schema
local kitchen_sink_schema = {
  type = "table",
  entries = {
    first = {
      type = "string",
    },
    second = {
      type = "number",
    },
    third = {
      type = "function",
      optional = true,
    },
    fourth = {
      type = function(val)
        return val == 123456
      end,
    },
    fifth = {
      type = union {
        { type = "boolean", },
        { type = str_literal "hello", },
      },
    },
    sixth = {
      type = "table",
      entries = "number",
    },
    seventh = {
      type = "table",
      entries = {
        { type = "boolean", },
        { type = "number", },
      },
    },
  },
}

T["kitchen sink"]["should return true when matched"] = function()
  eq(validate(kitchen_sink_schema, {
    first = "hello",
    second = 123,
    third = function() end,
    fourth = 123456,
    fifth = "hello",
    sixth = { 1, 2, 3, 4, 5, },
    seventh = { false, 1, },
  }), true)
  eq(validate(kitchen_sink_schema, {
    first = "hello",
    second = 123,
    nil,
    fourth = 123456,
    fifth = "hello",
    sixth = { 1, 2, 3, 4, 5, },
    seventh = { false, 1, },
  }), true)
  eq(validate(kitchen_sink_schema, {
    first = "hello",
    second = 123,
    third = function() end,
    fourth = 123456,
    fifth = true,
    sixth = { 1, 2, 3, 4, 5, },
    seventh = { false, 1, },
  }), true)
end
T["kitchen sink"]["should return false when not matched"] = function()
  eq(validate(kitchen_sink_schema, {
    first = {},
    second = "hello",
    third = function() end,
    fourth = 123456,
    fifth = true,
    sixth = { 1, 2, 3, 4, 5, },
    seventh = { false, 1, },
  }), false)
  eq(validate(kitchen_sink_schema, {
    first = "hello",
    second = {},
    third = function() end,
    fourth = 123456,
    fifth = true,
    sixth = { 1, 2, 3, 4, 5, },
    seventh = { false, 1, },
  }), false)
  eq(validate(kitchen_sink_schema, {
    first = "hello",
    second = 123,
    third = {},
    fourth = 123456,
    fifth = true,
    sixth = { 1, 2, 3, 4, 5, },
    seventh = { false, 1, },
  }), false)
  eq(validate(kitchen_sink_schema, {
    first = "hello",
    second = 123,
    third = function() end,
    fourth = {},
    fifth = true,
    sixth = { 1, 2, 3, 4, 5, },
    seventh = { false, 1, },
  }), false)
  eq(validate(kitchen_sink_schema, {
    first = "hello",
    second = 123,
    third = function() end,
    fourth = 123456,
    fifth = {},
    sixth = { 1, 2, 3, 4, 5, },
    seventh = { false, 1, },
  }), false)
  eq(validate(kitchen_sink_schema, {
    first = "hello",
    second = 123,
    third = function() end,
    fourth = 123456,
    fifth = true,
    sixth = { 1, 2, 3, 4, 5, "there", },
    seventh = { false, 1, },
  }), false)
  eq(validate(kitchen_sink_schema, {
    first = "hello",
    second = 123,
    third = function() end,
    fourth = 123456,
    fifth = true,
    sixth = { 1, 2, 3, 4, 5, },
    seventh = { false, "there", },
  }), false)
end


return T
