# Busted, packaged for Windows Mudlet

Busted is a robust testing framework for Lua with a lot of functionality, but it has some compiled C components and is not trivial for Windows users to install for use with their Mudlet systems. Since we use busted for testing Mudlet itself I thought it would be good to get a version repackaged which Mudlet users could install for their own use.
## Usage

This comes with one alias, `runTests`. By default, it will look for every file in your profile directory named `*_spec.lua` and run the tests defined within. If you wish to only run tests for a specific package, you can use the package name as the argument to the alias, for instance `runTests REPLet` will run any test files in the REPLet package if installed. If you want to run a specific test file, you can use `runTests REPLet/coreTests_spec.lua` to point to the specific file.

## Writing tests

There are some very good [docs](https://olivinelabs.com/busted/) available from the authors. For some practical examples, you can check out the [Mudlet busted tests](https://github.com/Mudlet/Mudlet/tree/development/src/mudlet-lua/tests)

## TO-DO

I have not yet included the libraries to enable asynchronous testing (libev and the copas and lua-libev luarocks) so you won't be able to 