# cmp-natdat

A [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) source for turning natural
dates into ISO dates.

## Demo

https://github.com/Gelio/cmp-natdat/assets/889383/1d6d388d-2a10-4923-9156-b99764c5a342

## Examples

- `@now` -> `2023-10-13 12:38`
- `@tomorrow` -> `2023-10-14`
- `@last Friday 2pm` -> `2023-10-06 14:00`
- `@Oct 8 2021` -> `2021-10-08`
- `@today 14:20` -> `2023-10-13 14:20`

## Features

- autocomplete for partially typed month names, relative dates
- supported formats:
  - `now`
  - `yesterday`, `today`, `tomorrow` with optional time
  - days of week (Monday -> Sunday), with optional `last`/`next` modifier and
    time
  - full dates: month, day, optional year, optional time
  - time: am/pm, or 24h format

## Setup

1. Install the plugin

   Using [lazy.nvim](https://github.com/folke/lazy.nvim):

   ```lua
   { "Gelio/cmp-natdat", config = true }
   ```

   `config = true` is necessary so lazy.nvim calls
   `require("cmp_natdat").setup()` to register the source.

   Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

   ```lua
   use {
       "Gelio/cmp-natdat",
       config = function()
            require("cmp_natdat").setup()
       end
   }
   ```

2. Add the source to the list in your nvim-cmp configuration

   ```lua
   sources = {
       { name = "natdat" },
       --- other sources...
   }
   ```

## Configuration (optional)

`cmp-natdat` accepts the following optional configuration, passed as a table to
the `setup()` method:

- `cmp_kind_text` - the text to use as the completion item's label in the
  nvim-cmp completions popup.

  Default: `Text`

- `highlight_group` - the name of an existing highlight group to use for that
  completion item's label in the nvim-cmp completions popup.

  Default: `CmpItemKindText`

Example:

```lua
{
    "Gelio/cmp-natdat",
    config = function()
        require("cmp_natdat").setup({
            cmp_kind_text = "NatDat",
            highlight_group = "Red",
        })
    end,
}
```

![cmp-natdat completions in the nvim-cmp popup are labeled "NatDat" in red](https://github.com/Gelio/cmp-natdat/assets/889383/52730df8-e355-4f4e-842f-d4cb283fbb12)

To get the most out of the custom cmp kind text, you can also use
[lspkind.nvim](https://github.com/onsails/lspkind.nvim) to show the calendar
icon (📆) for cmp-natdat completions:

```lua
require("lspkind").init({
    symbol_map = {
        NatDat = "📅",
    },
})
```

![cmp-natdat completions use the calendar icon](https://github.com/Gelio/cmp-natdat/assets/889383/9bf4df4c-fdfb-44d7-a60f-2a8370c94935)

## WARNING: cool tech inside

Parsing the dates is done using [pcomb](./lua/pcomb/), a Lua parser combinator
library. Its API is inspired by Rust's [nom](https://github.com/rust-bakery/nom)
crate.

`pcomb` can also be used in other plugins to parse other text input into a more
structured format. It is flexible and makes it easy to build parsers from the
bottom-up:

```lua
---@type pcomb.Parser<{ [1]: integer, [2]: pcomb.NIL | integer }>
local day_of_month_and_opt_year = psequence.sequence({
    -- Day of month
    pcharacter.integer,
    pcombinator.opt(psequence.preceded(
        pcharacter.multispace1,
        -- Year
        pcharacter.integer,
    ))
})
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).
