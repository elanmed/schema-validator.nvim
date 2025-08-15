# schema-validator.nvim

Runtime schema-validation built with Neovim's Lua utilities. 

## API

### `validate`

`validate` will return `false` and when the `val` does not match the `schema`, otherwise `true`.

```lua
--- @alias CustomValidator fun(val: any): boolean
--- @alias Type "nil" | "number" | "string" | "boolean" | "function" | "table" | "any" | CustomValidator

--- @class BaseSchema
--- @field type Type
--- @field optional? boolean

--- @class TableSchema : BaseSchema
--- @field entries? Type | Schema[]
--- @field exact? boolean

--- @alias Schema BaseSchema | TableSchema

--- @param schema Schema
--- @param val any
--- @return boolean
validate(schema, val)
```

### `assert`

`assert` will throw an error when the `val` does not match the `schema`, similar to the native `assert`.

```lua
--- @class AssertOpts
--- @field name string
--- @field schema Schema
--- @field val any

--- @param opts AssertOpts
assert(opts)
```

### `notify_assert`

`notify_assert` will return `false` and call `vim.notify` when the `val` does not match the `schema`, otherwise `true`.

```lua
--- @class AssertOpts
--- @field name string
--- @field schema Schema
--- @field val any

--- @param opts AssertOpts
notify_assert(opts)
```

## Examples

> All examples return `true` unless otherwise noted

### Values compared with the `type` function

```lua 
validate({ type = "nil", }, nil)
validate({ type = "number", }, 123)
validate({ type = "string", }, "hello")
validate({ type = "boolean", }, true)
validate({ type = "function", }, function() end)
```

### Tables with an arbitrary number of items

```lua 
validate(
  {
    type = "table",
    entries = "number",
  },
  { 1, 2, 3, 4, }
)
```

### Tables with a set number of items

```lua 
validate(
  {
    type = "table",
    entries = {
      first = { type = "string", },
      { type = "number", },
    },
  },
  { first = "hello", 123, }
)
validate(
  {
    type = "table",
    entries = {
      first = { type = "string", },
      { type = "number", },
    },
  },
  { first = "hello", 123, "there" } -- default behavior is to return `true` for tables which include more items than its schema
)
```

#### `exact`

```lua 
validate(
  {
    type = "table",
    entries = {
      first = { type = "string", },
      { type = "number", },
    },
    exact = true
  },
  { first = "hello", 123, "there" } -- returns `false`
)
```

### Optional

```lua 
validate({ type = "number", optional = true }, nil)
validate(
  {
    type = "table",
    entries = {
      first = { type = "string", optional = true },
      { type = "number", },
    },
  },
  { first = nil, 123, } -- `optional` can either mean the value of the entry
)
validate(
  {
    type = "table",
    entries = {
      first = { type = "string", optional = true },
      { type = "number", },
    },
  },
  { nil, 123, } -- or `optional` can mean the entry itself. No way to differentiate between the two in lua
)
```

### Any
```lua
validate({ type = "any", }, --[[returns true for anything]] )
```

### Custom validators

```lua
-- a function that takes the value to be validated as an argument and returns a boolean
validate({ type = function(val) return val % 2 == 0 end, }, 2)
```

#### `literal`

```lua 
validate({ type = literal "hello", }, "hello")
validate({ type = literal { 1, 2, 3 }, }, { 1, 2, 3, })
```

#### `union`

```lua 
validate(
  {
    type = union {
      { type = "string", },
      { type = "boolean", },
    },
  },
  "hello"
)
validate(
  {
    type = union {
      { type = "string", },
      { type = "boolean", },
    },
  },
  true
)
```
