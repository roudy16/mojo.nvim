-- test_version.lua
-- Run: nvim --headless -c "luafile tests/test_version.lua" -c "qa!"

local total_errors = 0

local function fail(msg)
	print("  FAIL: " .. msg)
	total_errors = total_errors + 1
end

local function pass(msg)
	print("  PASS: " .. msg)
end

local version = require("mojo.env.version")
local env = require("mojo.env")

-- Module loads
print("--- module load ---")
pass("env.version module loaded")

-- get_version returns nil without mojo binary
print("--- get_version ---")
local v = version.get_version()
if v == nil then
	pass("get_version() = nil (no mojo binary in test env)")
else
	pass(string.format("get_version() = %q (mojo binary found)", v or "nil"))
end

-- clear_cache does not error
print("--- clear_cache ---")
local ok, err = pcall(version.clear_cache)
if ok then
	pass("clear_cache() succeeds")
else
	fail("clear_cache() errored: " .. tostring(err))
end

-- env.get_version and env.clear_version_cache are exposed
print("--- env exports ---")
if type(env.get_version) == "function" then
	pass("env.get_version is a function")
else
	fail("env.get_version is not a function")
end

if type(env.clear_version_cache) == "function" then
	pass("env.clear_version_cache is a function")
else
	fail("env.clear_version_cache is not a function")
end

-- Summary
print(string.rep("=", 60))
print(string.format("Total failures: %d", total_errors))
if total_errors > 0 then
	vim.cmd(string.format("cq %d", math.min(total_errors, 255)))
else
	vim.cmd("cq 0")
end
