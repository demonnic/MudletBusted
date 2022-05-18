local old_path = package.path
local old_cpath = package.cpath
local busted_dir = getMudletHomeDir() .. "/@PKGNAME@"
local lua_dir = f"{busted_dir}/?.lua"
local init_dir = f"{busted_dir}/?/init.lua"
local c_dir = f"{busted_dir}/?.dll"
local new_path = f"{old_path};{lua_dir};{init_dir}"
local new_cpath = f"{old_cpath};{c_dir}"
-- Checks to see if the "busted" package is available.

local function newPath()
  package.path = new_path
  package.cpath = new_cpath
end

local function oldPath()
  package.path = old_path
  package.cpath = old_cpath
end

bustedState = bustedState or {}
function bustedState.isBustedAvailable()
  newPath()
  if package.loaded["busted"] then
    oldPath()
    return true
  else
    for _, searcher in ipairs(package.searchers or package.loaders) do
      local loader = searcher("busted")
      if type(loader) == 'function' then
        oldPath()
        return true
      end
    end
    oldPath()
    return false
  end
end

			-- BEGIN Busted init section

-- This is where you change options. See the busted documentation
-- or execute 'busted --help' on the command line.
-- Note that changing these is not guaranteed to work, and the
-- languages supported are dictated by busted, not mudlet.
-- For adding more options, you will likely have to look at
-- the busted code.
local options = {}

-- BEGIN user modifiable options

-- If you change the following block of options, you will need to
-- quit and reload mudlet
options.output = 'plainTerminal'
options.suppressPending = false
options.language = "en"
options.deferPrint = false
options.verbose = false
options.quitOnError = false

-- if you change this you will need to call bustedState.setup()
options.recursive = true

-- if you change defaultPatterns, you can call bustedState.setup(nil,{})
--   to load the new default values
options.defaultPatterns = {"_spec"}
-- if you change defaultFiles, you can call bustedState.setup({},nil)
--   to load the new default values

-- if bustedState.isBustedAvailable() then
--   local path = require 'pl.path'
-- end
options.defaultFiles = options.defaultFiles or {getMudletHomeDir()}

-- END user modifiable options

bustedState.verbose = options.verbose
bustedState.recursive = options.recursive
bustedState.patternsTable = bustedState.patternsTable or options.defaultPatterns
bustedState.filesTable = bustedState.filesTable or options.defaultFiles


if bustedState.isBustedAvailable() then
  newPath()
  busted = busted or require 'busted.core'()

  -- The following needs to run only once. The if block prevents
  -- rerunning if the user edits this script in mudlet.
  -- If you're getting errors about calling a table in the
  -- following line, try closing and re-opening mudlet, or manually
  -- setting bustedState.initRun to true.
  if not bustedState.initRun then
    require 'busted'(busted)

    local quitOnError = options.quitOnError

    busted.subscribe({ 'error', 'output' }, function(element, parent, message)
        print(appName, ': error: Cannot load output library: ', element.name)
        print(message)
        return nil, true
      end)
    busted.subscribe({ 'error', 'helper' }, function(element, parent, message)
        print(appName, ': error: Cannot load helper script: ', element.name)
        print(message)
        return nil, true
      end)
    busted.subscribe({ 'error' }, function(element, parent, message)
        busted.skipAll = quitOnError
        return nil, true
      end)
    busted.subscribe({ 'failure' }, function(element, parent, message)
        busted.skipAll = quitOnError
        return nil, true
      end)

    local outputHandlerLoader = require 'busted.modules.output_handler_loader'()

    -- Set up output handler to listen to events
    outputHandlerLoader(busted, options.output, {
        defaultOutput = options.output,
        verbose = options.verbose,
        suppressPending = options.suppressPending,
        language = options.language,
        deferPrint = options.deferPrint,
        arguments = {},
      })
  end
  bustedState.initRun = true
  oldPath()
end

-- END busted init section

-- BEGIN busted function definitions.

-- bustedState.setup()
--
-- Sets up the lists of files and patterns, and loads the tests.
-- It must be rerun any time changes are made to the test directories
--   or files.
-- filesTable: a table with a list of files and/or directories you
--   would like busted to run.
-- patternsTable: a list of lua patterns. Any file in the directories
--   listed in filesTable which matches one of the patterns in
--   patternsTable will be loaded and run, and does not need to be
--   explicitly listed in filesTable.
-- Directories in filesTable will be recursively scanned for files
--   having one of the patterns in their name. Files listed explicitly
--   will be loaded regardless of matching patterns.

-- If either table is nil, it will be ignored, and the most recent value
--   used will be used again.
-- If either table is empty, it will be reset to the default value.

-- The default filesTable is a system dependent directory containing some
--   tests.
-- The default patternsTable is {"_spec"}, so in a directory, only
--   lua files with _spec in their name will be run. If you want
--   to run all files in a directory, pass {""}

-- It is an error to pass anything other than nil, an empty table,
--   or a table of strings indexed by consecutive numbers.

-- Note: The current version of busted has the limitation
--   that there cannot be any hidden directories in the path
--   of a directory entry. So if your test files are in a hidden
--   directory or subdirectory thereof, they will have to be listed
--   individually. A pull request has been submitted and this should
--   eventually change.
function bustedState.setup( filesTable, patternsTable )
  newPath()
  if not bustedState.isBustedAvailable() then
    print("Warning: Package \"busted\" not found. See comments in run-tests README for instructions.")
    print("Warning: Without installing \"busted\", the test system will not work!")
    return
  end
  if type(filesTable) == "table" then
    if #filesTable > 0 then
      local fallback = bustedState.filesTable
      bustedState.filesTable = {}
      for _, v in ipairs(filesTable) do
        if type(v) == "string" then
          table.insert(bustedState.filesTable, v)
        else
          bustedState.filesTable = fallback
          print("Warning: Malformed argument filesTable in bustedState.setup(). Got:"..tostring(filesTable))
          break
        end
      end -- for
    else -- #filesTable == 0
      bustedState.filesTable = options.defaultFiles
    end
  elseif type(filesTable) ~= "nil" then
    print("Warning: Malformed argument filesTable in bustedState.setup(). Got:"..tostring(filesTable))
  end

  if type(patternsTable) == "table" then
    if #patternsTable > 0 then
      local fallback = bustedState.patternsTable
      bustedState.patternsTable = {}
      for _, v in ipairs(patternsTable) do
        if type(v) == "string" then
          table.insert(bustedState.patternsTable, v)
        else
          bustedState.patternsTable = fallback
          print("Warning: Malformed argument patternsTable in bustedState.setup(). Got:"..tostring(patternsTable))
          break
        end
      end -- for
		else -- #patternsTable == 0
      bustedState.patternsTable = options.defaultPatterns
    end
  elseif type(patternsTable) ~= "nil" then
    print("Warning: Malformed argument patternsTable in bustedState.setup(). Got:"..tostring(patternsTable))
  end

  -- if this is not the first time we have run setup, we need to clean
  -- out the previous set of tests.
  if bustedState.setupRun then
    local oldctx = busted.context.get()
    busted.context.clear()
    local ctx = busted.context.get()
    for k, v in pairs(oldctx) do
      ctx[k] = v
    end
    local root = busted.context.get()
    busted.safe_publish('suite', { 'suite', 'reset' }, root, 1, 1)
  end
  bustedState.setupRun = true
  newPath()
  local testFileLoader = testFileLoader or require 'busted.modules.test_file_loader'(busted, {'lua'})
  testFileLoader(bustedState.filesTable, bustedState.patternsTable, {
      excludes = {},
      verbose = bustedState.verbose,
      recursive = bustedState.recursive,
    })

  bustedState.execute = bustedState.execute or require 'busted.execute'(busted)
  oldPath()
end -- bustedState.setup()


-- bustedState.runTests()
--
-- This will run the tests which were loaded with bustedState.setup().
-- When mudlet is first started, bustedState.setup() must be run
--   before bustedState.runTests()
-- It does not reload the tests, so if the tests were edited after
--   bustedState.setup() was run, the changes will not take effect
--   until bustedState.setup() is re-run.
-- It does, however, run against the current state of mudlet. So if you
--   make changes to a script which a test is testing, it will run the test
--   against the current code in mudlet.
function bustedState.runTests()
  if not bustedState.isBustedAvailable() then
    print("Warning: Package \"busted\" not found. See comments in run-tests README for instructions.")
    print("Warning: Without installing \"busted\", the test system will not work!")
    return
  end
  -- Some cleanup is needed if busted has run already
  -- it doesn't really clean up after itself.
  if bustedState.runTestsRun then
    newPath()
    local tablex = require 'pl.tablex'
    local root = busted.context.get()
    local children = tablex.copy(busted.context.children(root))
    local oldctx = busted.context.get()
    busted.context.clear()
    local ctx = busted.context.get()
    for k, v in pairs(oldctx) do
      ctx[k] = v
    end
    for _, child in ipairs(children) do
      for descriptor, _ in pairs(busted.executors) do
        child[descriptor] = nil
      end
      busted.context.attach(child)
    end
    root = busted.context.get()
    busted.safe_publish('suite', { 'suite', 'reset' }, root, 1, 1)
  end
  bustedState.runTestsRun = true

  -- redirect io.write() to main screen temporarily
  -- this could have side-effects if other threads or the test cases use
  -- io.write() (which normally writes to the command line) before we
  -- reset it once the tests are done.
  local oldiowrite = io.write
  io.write = function (...)
    echo(...)
  end

  -- this is the actual busted call that runs the tests, which were
  --   loaded in bustedState.setup.
  bustedState.execute(1, {})

  io.write = oldiowrite
  oldPath()
end -- bustedState.runTests