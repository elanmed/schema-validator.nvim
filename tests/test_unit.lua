local eq = MiniTest.expect.equality
local err = MiniTest.expect.error
local validator = require "lua.schema-validator.init"
local validate = validator.validate
local literal = validator.literal
local union = validator.union

local T = MiniTest.new_set()

T["type string"] = MiniTest.new_set()
T["type string"]["string"] = MiniTest.new_set()
T["type string"]["string"]["should return true for strings"] = function()
  eq(validate({ type = "string", }, "hello"), true)
  eq(validate({ type = "string", }, ""), true)
end
T["type string"]["string"]["should return false for non-strings"] = function()
  eq(validate({ type = "string", }, 123), false)
  eq(validate({ type = "string", }, true), false)
  eq(validate({ type = "string", }, function() end), false)
  eq(validate({ type = "string", }, {}), false)
end
T["type string"]["string"]["should handle optional"] = function()
  eq(validate({ type = "string", }, nil), false)
  eq(validate({ type = "string", optional = true, }, nil), true)
end

T["type string"]["number"] = MiniTest.new_set()
T["type string"]["number"]["should return true for numbers"] = function()
  eq(validate({ type = "number", }, 123), true)
  eq(validate({ type = "number", }, 0), true)
end
T["type string"]["number"]["should return false for non-numbers"] = function()
  eq(validate({ type = "number", }, "hello"), false)
  eq(validate({ type = "number", }, true), false)
  eq(validate({ type = "number", }, function() end), false)
  eq(validate({ type = "number", }, {}), false)
end
T["type string"]["number"]["should handle optional"] = function()
  eq(validate({ type = "number", }, nil), false)
  eq(validate({ type = "number", optional = true, }, nil), true)
end

T["type string"]["boolean"] = MiniTest.new_set()
T["type string"]["boolean"]["should return true for booleans"] = function()
  eq(validate({ type = "boolean", }, true), true)
  eq(validate({ type = "boolean", }, false), true)
end
T["type string"]["boolean"]["should return false for non-booleans"] = function()
  eq(validate({ type = "boolean", }, "hello"), false)
  eq(validate({ type = "boolean", }, 123), false)
  eq(validate({ type = "boolean", }, function() end), false)
  eq(validate({ type = "boolean", }, {}), false)
end
T["type string"]["boolean"]["should handle optional"] = function()
  eq(validate({ type = "boolean", }, nil), false)
  eq(validate({ type = "boolean", optional = true, }, nil), true)
end

T["type string"]["any"] = MiniTest.new_set()
T["type string"]["any"]["should return true for any value"] = function()
  eq(validate({ type = "any", }, 123), true)
  eq(validate({ type = "any", }, "hello"), true)
  eq(validate({ type = "any", }, true), true)
  eq(validate({ type = "any", }, function() end), true)
  eq(validate({ type = "any", }, {}), true)
end
T["type string"]["any"]["should handle optional"] = function()
  eq(validate({ type = "any", }, nil), true)
  eq(validate({ type = "boolean", optional = true, }, nil), true)
end

T["type string"]["function"] = MiniTest.new_set()
T["type string"]["function"]["should return true for functions"] = function()
  eq(validate({ type = "function", }, function() end), true)
end
T["type string"]["function"]["should return false for non-functions"] = function()
  eq(validate({ type = "function", }, "hello"), false)
  eq(validate({ type = "function", }, 123), false)
  eq(validate({ type = "function", }, true), false)
  eq(validate({ type = "function", }, {}), false)
end
T["type string"]["function"]["should handle optional"] = function()
  eq(validate({ type = "function", }, nil), false)
  eq(validate({ type = "function", optional = true, }, nil), true)
end

T["type string"]["nil"] = MiniTest.new_set()
T["type string"]["nil"]["should return true for nil"] = function()
  eq(validate({ type = "nil", }, nil), true)
end
T["type string"]["nil"]["should return false for non-nils"] = function()
  eq(validate({ type = "nil", }, "hello"), false)
  eq(validate({ type = "nil", }, 123), false)
  eq(validate({ type = "nil", }, function() end), false)
  eq(validate({ type = "nil", }, {}), false)
  eq(validate({ type = "nil", }, false), false)
end
T["type string"]["boolean"]["should handle optional"] = function()
  eq(validate({ type = "nil", optional = true, }, nil), true)
end

T["type literla"] = MiniTest.new_set()
T["type literla"]["should return true for literals"] = function()
  eq(validate({ type = literal "hello", }, "hello"), true)
  eq(validate({ type = literal { 1, 2, 3, }, }, { 1, 2, 3, }), true)
end
T["type literla"]["should return false for non-string literals"] = function()
  eq(validate({ type = literal "hello", }, "there"), false)
  eq(validate({ type = literal "hello", }, function() end), false)
  eq(validate({ type = literal "hello", }, 123), false)
  eq(validate({ type = literal "hello", }, true), false)
  eq(validate({ type = literal "hello", }, {}), false)
end
T["type literla"]["should handle optional"] = function()
  eq(validate({ type = literal "hello", }, nil), false)
  eq(validate({ type = literal "hello", optional = true, }, nil), true)
end

T["type table"] = MiniTest.new_set()
T["type table"]["arbitrary length"] = MiniTest.new_set()
T["type table"]["arbitrary length"]["should return false for non-tables"] = function()
  eq(validate({ type = "table", entries = "number", }, "there"), false)
  eq(validate({ type = "table", entries = "number", }, function() end), false)
  eq(validate({ type = "table", entries = "number", }, 123), false)
  eq(validate({ type = "table", entries = "number", }, true), false)
end
T["type table"]["arbitrary length"]["should handle optional"] = function()
  eq(validate({ type = "table", entries = "number", }, nil), false)
  eq(validate({ type = "table", entries = "number", optional = true, }, nil), true)
end
T["type table"]["arbitrary length"]["should return true for tables where every value matches the entries type"] = function()
  eq(validate({ type = "table", entries = "number", }, {}), true)
  eq(validate({ type = "table", entries = "number", }, { 1, 2, 3, }), true)
  eq(validate({ type = "table", entries = "number", }, { 1, nil, 3, }), true)
  eq(validate({ type = "table", entries = "number", }, { 1, hello = nil, 3, }), true)
  eq(validate({ type = "table", entries = "number", }, { 1, 2, hello = 3, }), true)
end
T["type table"]["arbitrary length"]["should return false for tables where not every value matches the entries type"] = function()
  eq(validate({ type = "table", entries = "number", }, { 1, 2, "hello", }), false)
end

T["type table"]["fixed length"] = MiniTest.new_set()
T["type table"]["fixed length"]["key-value pairs"] = MiniTest.new_set()
T["type table"]["fixed length"]["key-value pairs"]["should return true for tables where every value matches the entries"] = function()
  eq(validate(
    {
      type = "table",
      entries = {
        first = { type = "string", },
        second = { type = "number", },
      },
    },
    { first = "hello", second = 1, }), true)
  eq(validate(
    {
      type = "table",
      entries = {
        first = { type = "string", },
        second = { type = "number", },
      },
    },
    { first = "hello", second = 1, nil, }), true)
  eq(validate(
    {
      type = "table",
      entries = {
        first = { type = "string", },
        second = { type = "number", },
      },
    },
    -- known limitation, `pairs` skips over nil values for tables
    { first = "hello", second = 1, third = nil, }), true)
end
T["type table"]["fixed length"]["key-value pairs"]["should return false for tables where not every value matches the entries"] = function()
  eq(validate({
    type = "table",
    entries = {
      first = { type = "string", },
      second = { type = "number", },
    },
  }, {}), false)
  eq(validate({
    type = "table",
    entries = {
      first = { type = "string", },
      second = { type = "number", },
    },
  }, { first = "hello", }), false)
  eq(validate({
    type = "table",
    entries = {
      first = { type = "string", },
      second = { type = "number", },
    },
  }, { first = "hello", second = true, }), false)
end
T["type table"]["fixed length"]["key-value pairs"]["exact"] = MiniTest.new_set()
T["type table"]["fixed length"]["key-value pairs"]["exact"]["should return false for tables with more values than the schema when exact is true"] = function()
  eq(validate({
    type = "table",
    entries = {
      first = { type = "string", },
      second = { type = "number", },
    },
    exact = true,
  }, { first = "hello", second = 1, third = 2, }), false)
end
T["type table"]["fixed length"]["key-value pairs"]["exact"]["should return true for tables with more values than the schema when exact is false"] = function()
  eq(validate({
    type = "table",
    entries = {
      first = { type = "string", },
      second = { type = "number", },
    },
  }, { first = "hello", second = 1, third = 2, }), true)
  eq(validate({
    type = "table",
    entries = {
      first = { type = "string", },
      second = { type = "number", },
    },
    exact = false,
  }, { first = "hello", second = 1, third = 2, }), true)
end

T["type table"]["fixed length"]["lists"] = MiniTest.new_set()
T["type table"]["fixed length"]["lists"]["should return true for tables where every value matches the entries"] = function()
  eq(validate(
    {
      type = "table",
      entries = {
        { type = "string", },
        { type = "number", },
      },
    },
    { "hello", 1, }), true)
  eq(validate(
    {
      type = "table",
      entries = {
        { type = "string", },
        { type = "number", },
      },
    },
    { "hello", 1, nil, }), true)
  eq(validate(
    {
      type = "table",
      entries = {
        { type = "string", },
        { type = "number", },
      },
    },
    -- known limitation, `pairs` skips over nil values for tables
    { "hello", 1, third = nil, }), true)
end
T["type table"]["fixed length"]["lists"]["should return false for tables where not every value matches the entries"] = function()
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
  }, { "hello", true, }), false)
end
T["type table"]["fixed length"]["lists"]["exact"] = MiniTest.new_set()
T["type table"]["fixed length"]["lists"]["exact"]["should return false for tables with more values than the schema when exact is true"] = function()
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
    exact = true,
  }, { "hello", 1, 2, }), false)
end
T["type table"]["fixed length"]["lists"]["exact"]["should return true for tables with more values than the schema when exact is false"] = function()
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
  }, { "hello", 1, 2, }), true)
  eq(validate({
    type = "table",
    entries = {
      { type = "string", },
      { type = "number", },
    },
    exact = false,
  }, { "hello", 1, 2, }), true)
end

T["type table"]["fixed length"]["should return false for non-tables"] = function()
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
T["type table"]["fixed length"]["should handle top-level optional"] = function()
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
T["type table"]["fixed length"]["key-value pairs"] = MiniTest.new_set()
T["type table"]["fixed length"]["key-value pairs"]["should handle level optional entries"] = function()
  eq(validate({
      type = "table",
      entries = {
        first = { type = "string", optional = true, },
        second = { type = "number", },
      },
    },
    { nil, second = 123, }
  ), true)
  eq(validate({
      type = "table",
      entries = {
        first = { type = "string", optional = true, },
        second = { type = "number", },
      },
    },
    { first = nil, second = 123, }
  ), true)
end
T["type table"]["fixed length"]["lists"] = MiniTest.new_set()
T["type table"]["fixed length"]["lists"]["should handle level optional entries"] = function()
  eq(validate({
      type = "table",
      entries = {
        { type = "string", optional = true, },
        { type = "number", },
      },
    },
    { nil, 123, }
  ), true)
  eq(validate({
      type = "table",
      entries = {
        { type = "number", },
        { type = "string", optional = true, },
      },
    },
    { 123, nil, }
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
    validate(
      {
        type = union {
          { type = "string", },
          { type = "boolean", },
        },
      },
      "hello"
    ),
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
  err(function() validate({ type = "hello", }, "there") end)
end
T["malformed schema"]["when the schema.optional is not a boolean or nil, it should throw"] = function()
  err(function() validate({ type = "string", optional = function() end, }, "there") end)
  err(function() validate({ type = "string", optional = 123, }, "there") end)
  err(function() validate({ type = "string", optional = "hello", }, "there") end)
  err(function() validate({ type = "string", optional = {}, }, "there") end)
end
T["malformed schema"]["when the schema.exact is not a boolean or nil, it should throw"] = function()
  err(function() validate({ type = "table", entries = { 1, 2, 3, }, exact = function() end, }, {}) end)
  err(function() validate({ type = "table", entries = { 1, 2, 3, }, exact = 123, }, {}) end)
  err(function() validate({ type = "table", entries = { 1, 2, 3, }, exact = "hello", }, {}) end)
  err(function() validate({ type = "table", entries = { 1, 2, 3, }, exact = {}, }, {}) end)
end
T["malformed schema"]["when the type(schema.type) is not a string or function, it should throw"] = function()
  err(function() validate({ type = {}, }, "there") end)
  err(function() validate({ type = true, }, "there") end)
  err(function() validate({ type = 123, }, "there") end)
  err(function() validate({ type = nil, }, "there") end)
end
T["malformed schema"]["when the schema.entries is not a string or table, it should throw"] = function()
  err(function() validate({ type = "table", entries = function() end, }, {}) end)
  err(function() validate({ type = "table", entries = true, }, {}) end)
  err(function() validate({ type = "table", entries = 123, }, {}) end)
  err(function() validate({ type = "table", entries = nil, }, {}) end)
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
        { type = literal "hello", },
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
