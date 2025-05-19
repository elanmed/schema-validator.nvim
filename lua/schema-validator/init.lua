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

local M = {}

--- @alias CustomValidator fun(val: any): boolean
--- @alias Type "nil" | "number" | "string" | "boolean" | "function" | "table" | CustomValidator

--- @class BaseSchema
--- @field type Type
--- @field optional? boolean

--- @class TableSchema : BaseSchema
--- @field entries? Type | Schema[]

--- @alias Schema BaseSchema | TableSchema

--- @param schema Schema
--- @return boolean
M.validate = function(schema, val)
  local optional = default(schema.optional, false)
  if val == nil and optional then return true end

  if type(schema.type) == "string" then
    if not vim.tbl_contains({ "nil", "number", "string", "boolean", "function", "table", }, schema.type) then
      error(
        string.format("Expected `schema.type` to be one of the following: %s, received `%s`. Schema: %s",
          "`nil`, `number`, `string`, `boolean`, `function`, `table`",
          schema.type,
          vim.inspect(schema)
        )
      )
    end

    if schema.type == "table" then
      if type(val) ~= "table" then return false end

      if type(schema.entries) == "string" then
        for _, curr_val in pairs(val) do
          if not M.validate({ type = schema.entries, }, curr_val) then
            return false
          end
        end

        return true
      elseif type(schema.entries) == "table" then
        for key, entry in pairs(schema.entries) do
          if val[key] == nil then return false end

          if not M.validate(entry, val[key]) then
            return false
          end
        end

        if vim.tbl_count(val) ~= vim.tbl_count(schema.entries) then
          return false
        end

        return true
      else
        error(
          string.format(
            "Expected `type(schema.entries)` to be a `string` or `table`, received `%s`. Schema: %s",
            type(schema.entries),
            vim.inspect(schema)
          )
        )
      end
    end

    if type(val) == schema.type then return true end

    return false
  elseif type(schema.type) == "function" then
    return schema.type(val)
  else
    error(
      string.format(
        "Expected `type(schema.type)` to be a `string` or `function`, received `%s`. Schema: %s",
        type(schema.type),
        vim.inspect(schema)
      )
    )
  end
end

--- @param literal string
M.str_literal = function(literal)
  return function(val) return val == literal end
end

--- @param schemas Schema[]
M.union = function(schemas)
  return function(val)
    for _, schema in pairs(schemas) do
      if M.validate(schema, val) then return true end
    end
    return false
  end
end

return M
