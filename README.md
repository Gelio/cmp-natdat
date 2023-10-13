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
