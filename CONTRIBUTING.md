# Contributing to cmp-natdat

Contributions are welcome!

For small changes, feel free to open a Pull Request right away.

For larger changes, please open an Issue first in the interest of both our time.
By discussing the feature/change request beforehand, we will spend less time in
a back-and-forth discussion in a Pull Request, and likely there will be fewer
necessary changes.

In either case, make sure to follow these guidelines:

1. Make sure [the tests](#tests) pass.

   I would also appreciate adding new tests for the functionalities you add.

2. Use [StyLua](https://github.com/JohnnyMorganz/StyLua) for formatting Lua
   code.
3. Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
   commit message format.

## Tests

Tests are run using
[plenary.nvim's test harness](https://github.com/nvim-lua/plenary.nvim#plenarytest_harness).
See
[their testing guide](https://github.com/nvim-lua/plenary.nvim/blob/master/TESTS_README.md)
for more information about the APIs available in tests.

Tests are stored in the [test](./test) directory. Their file structure matches
the structure of the [lua](./lua) directory.

## Running tests

The easiest way to run tests is using `make`:

```sh
make test
```

While working on a test, you can also run it with the following vim Ex command:

```raw
:PlenaryBustedFile %
```

## Code structure

The code is split into 3 layers. From innermost, the layers are:

1. `pcomb` - parser combinator library
2. `natdat` - natural language dates parser
3. `cmp_natdat` - nvim-cmp source

The first two can be used outside of `nvim-cmp`, just as libraries for general
parsing (`pcomb`), or parsing dates and time (`natdat`).

### pcomb

`pcomb` is a parser combinator library inspired by Rust's
[nom](https://docs.rs/nom/latest/nom/index.html).

It exposes multiple utilities that combine together into a parser for a
particular structure of text.

`pcomb` uses `tluser.Result` (an alternative to Rust's
[Result](https://doc.rust-lang.org/std/result/)) to represent errors in a more
structured way.

### natdat

`natdat` is a library for parsing dates and time represented in natural
language.

It exposes multiple `pcomb` parsers for various structures, such as
`AbsoluteDate` (e.g. `October 10 2023`), `RelativeDay` (e.g. `tomorrow`),
`DayOfWeek` (e.g. `last Monday`), and many others.

### `cmp_natdat`

This is a thin wrapper around `natdat` that adapts its results into `nvim-cmp`
suggestions.
