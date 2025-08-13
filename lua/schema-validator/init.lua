--- @alias CustomValidator fun(val: any): boolean
--- @alias Type "nil" | "number" | "string" | "boolean" | "function" | "table" | "any" | CustomValidator

--- @class BaseSchema
--- @field type Type
--- @field optional? boolean

--- @class TableSchema : BaseSchema
--- @field entries? Type | Schema[]
--- @field exact? boolean

--- @alias Schema BaseSchema | TableSchema

--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
local function default(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end

--- @param schema Schema
--- @param val any
--- @return boolean
local function _validate(schema, val)
  local optional = default(schema.optional, false)
  if val == nil and optional then
    return true
  end

  if type(schema.type) == "string" then
    if schema.type == "table" then
      if type(val) ~= "table" then
        return false
      end

      if type(schema.entries) == "string" or type(schema.entries) == "function" then
        for _, curr_val in pairs(val) do
          if not _validate({ type = schema.entries, }, curr_val) then
            return false
          end
        end

        return true
      elseif type(schema.entries) == "table" then
        for key, schema_entry in pairs(schema.entries) do
          if not _validate(schema_entry, val[key]) then
            return false
          end
        end

        local exact = default(schema.exact, false)
        if exact then
          for key, val_entry in pairs(val) do
            local schema_entry = schema.entries[key]
            if schema_entry == nil then
              return false
            end

            if not _validate(schema_entry, val_entry) then
              return false
            end
          end
        end

        return true
      end
    end

    if schema.type == "any" then return true end
    if type(val) == schema.type then return true end
    return false
  elseif type(schema.type) == "function" then
    return schema.type(val)
  end
end

--- @type Schema
local schema_type_schema = {
  type = function(val)
    if type(val) == "string" then
      return vim.tbl_contains({ "nil", "number", "string", "boolean", "function", "table", "any", }, val)
    end

    if type(val) == "function" then
      return true
    end

    return false
  end,
}

local schema_schema

local schema_entries_schema = {
  type = function(val)
    if type(val) == "string" or type(val) == "function" then
      return _validate(schema_type_schema, val)
    elseif type(val) == "table" then
      for _, schema in pairs(val) do
        if not _validate(schema_schema, schema) then
          return false
        end
      end
      return true
    else
      return false
    end
  end,
  optional = true,
}

--- @type Schema
schema_schema = {
  type = "table",
  exact = true,
  entries = {
    type = schema_type_schema,
    optional = {
      type = "boolean",
      optional = true,
    },
    exact = {
      type = "boolean",
      optional = true,
    },
    entries = schema_entries_schema,
  },
}

local M = {}

--- @param schema Schema
--- @param val any
--- @return boolean
M.validate = function(schema, val)
  M.assert { name = "validate.schema", schema = schema_schema, val = schema, }

  return _validate(schema, val)
end

--- @param literal any
M.literal = function(literal)
  return function(val)
    return vim.deep_equal(val, literal)
  end
end

--- @param schemas Schema[]
M.union = function(schemas)
  --- @type Schema
  local schemas_schema = {
    type = "table",
    entries = "any",
  }
  M.assert { name = "union.schemas", schema = schemas_schema, val = schemas, }

  return function(val)
    for _, schema in pairs(schemas) do
      if M.validate(schema, val) then return true end
    end
    return false
  end
end

--- @param schemas Schema[]
M.intersection = function(schemas)
  --- @type Schema
  local schemas_schema = {
    type = "table",
    entries = "any",
  }
  M.assert { name = "intersection.schemas", schema = schemas_schema, val = schemas, }

  return function(val)
    for _, schema in pairs(schemas) do
      if not M.validate(schema, val) then return false end
    end
    return true
  end
end

--- @class GetAssertMessageOpts
--- @field prefix? string
--- @field name string
--- @field expected any
--- @field actual any

--- @param opts GetAssertMessageOpts
local function get_assert_message(opts)
  local prefix = default(opts.prefix, "")

  return
      prefix ..
      "ERROR! Schema validation failed when parsing `" ..
      opts.name .. "`\n" ..
      "Expected:\n" ..
      "---------\n" ..
      vim.inspect(opts.expected) .. "\n" ..
      "Actual:\n" ..
      "-------\n" ..
      vim.inspect(opts.actual)
end

--- @class AssertOpts
--- @field name string
--- @field schema Schema
--- @field val any

--- @type Schema
local assert_opts_schema = {
  type = "table",
  exact = true,
  entries = {
    name = { type = "string", },
    schema = schema_schema,
    val = { type = "any", },
  },
}

--- @param opts AssertOpts
M.assert = function(opts)
  if not _validate(assert_opts_schema, opts) then
    error(get_assert_message { name = "assert.opts", actual = opts, expected = assert_opts_schema, })
  end

  assert(
    _validate(opts.schema, opts.val),
    get_assert_message { name = opts.name, actual = opts.val, expected = opts.schema, }
  )
end

--- @param opts AssertOpts
M.safe_assert = function(opts)
  M.assert { name = "safe_assert.opts", schema = assert_opts_schema, val = opts, }
  local validate_res = _validate(opts.schema, opts.val)

  if not validate_res then
    vim.notify(
      get_assert_message { name = opts.name, actual = opts.val, expected = opts.schema, },
      vim.log.levels.ERROR
    )
  end
  return validate_res
end

return M
