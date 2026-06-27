-- test_detect.lua
-- Run: nvim --headless -c "luafile tests/test_detect.lua" -c "qa!"

local total_errors = 0

local function fail(msg)
	print("  FAIL: " .. msg)
	total_errors = total_errors + 1
end

local function pass(msg)
	print("  PASS: " .. msg)
end

local detect = require("mojo.env.detect")

-- Simulate a .derived/ directory with mojo-lsp-server
local tmpdir = vim.fn.tempname()
os.execute("mkdir -p " .. tmpdir .. "/.derived/bin")
os.execute("touch " .. tmpdir .. "/.derived/bin/mojo-lsp-server")

local cwd = vim.fn.getcwd()
vim.api.nvim_set_current_dir(tmpdir)
local env = detect.detect()
vim.api.nvim_set_current_dir(cwd)

if env and env.type == "derived" then
	pass("detect() finds .derived/ env")
else
	fail(string.format("detect() expected derived env, got %s", env and env.type or "nil"))
end

-- Cleanup
os.execute("rm -rf " .. tmpdir)
for k in pairs(detect._cache()) do
	detect._cache()[k] = nil
end

print(string.rep("=", 60))
print(string.format("Total failures: %d", total_errors))
if total_errors > 0 then
	vim.cmd(string.format("cq %d", math.min(total_errors, 255)))
else
	vim.cmd("cq 0")
end
