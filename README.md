# schema-validator.nvim

A schema validator for your Neovim plugins. 

Built for Neovim to use the `vim.*` helper functions.

> All examples return `true`

### Values compared with the `type` function

```lua 
validate({ type = "nil", }, nil)
validate({ type = "number", }, 123)
validate({ type = "string", }, "hello")
validate({ type = "boolean", }, true)
validate({ type = "function", }, function() end)
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
validate(
  {
    type = "table",
    entries = "number",
  },
  { 1, nil, 3, 4, } -- `true` because `nil` is ignored by `pairs`
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
  { nil, 123, } -- or `optional` can mean the entry itself
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
