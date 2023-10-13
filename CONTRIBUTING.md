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

2. Use [StyLua](https://github.com/JohnnyMorganz/StyLua) formatting.
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
