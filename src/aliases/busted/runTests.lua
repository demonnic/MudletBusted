-- Alias to run busted tests, which should be sufficient
-- for simple cases.
--
-- IT DOES NOT WORK WITHOUT SOME SETUP - YOU NEED BUSTED INSTALLED
-- PLEASE READ THE README UNDER SCRIPTS
--
-- Called without an argument, it will run the last tests run, or the
-- default tests if this is the first invocation.
-- Called with a filename, it will run the tests in that filename.
-- Called with a directory, it will run tests in all files in that
-- directory with the pattern "_spec" in their name.
-- Example with file:
-- runBusted /path/to/my/testFile_spec.lua
-- Example with directory:
-- runBusted /path/to/my
-- Note that the file doesn't need to contain _spec if the filename is
-- specified explicitly.
if not bustedState.isBustedAvailable() then
  print("Warning: Package \"busted\" not found. See script run-tests README for instructions.")
  print("Warning: Without installing \"busted\", the test system will not work!")
  return
end
if (not matches[2]) or (#matches[2] == 0) then
  bustedState.setup()
else
  local entry = getMudletHomeDir() .. "/" .. matches[2]
  bustedState.setup({entry})
end
bustedState.runTests()