-- test_sdk_path.lua
-- Run: nvim --headless -c "luafile tests/test_sdk_path.lua" -c "qa!"

local total_errors = 0

local function fail(msg)
	print("  FAIL: " .. msg)
	total_errors = total_errors + 1
end

local function pass(msg)
	print("  PASS: " .. msg)
end

local detect = require("mojo.env.detect")
local config = require("mojo.config")

-- Without sdk_path, detect returns nil or auto-detected env
print("--- no override ---")
local env = detect.detect()
if env and env.type == "pixi" or env and env.type == "venv" or env == nil then
	pass("detect() works without sdk_path override (auto or nil)")
else
	fail(string.format("unexpected env type: %s", env and env.type or "nil"))
end

-- Clear cache between tests
for k in pairs(detect._cache()) do
	detect._cache()[k] = nil
end

-- With invalid sdk_path, detect returns nil and warns
print("--- invalid sdk_path ---")
config.setup({ sdk_path = "/nonexistent/mojo" })

local warned = false
local orig_notify = vim.notify
vim.notify = function(msg, level)
	if msg:find("sdk_path") then
		warned = true
	end
end

env = detect.detect()
if env == nil then
	pass("detect() returns nil for invalid sdk_path")
else
	fail("detect() should return nil for invalid sdk_path")
end

if warned then
	pass("vim.notify warning shown for invalid sdk_path")
else
	fail("no warning shown for invalid sdk_path")
end

vim.notify = orig_notify

-- Clear cache
for k in pairs(detect._cache()) do
	detect._cache()[k] = nil
end

-- With valid sdk_path (pointing to a dir that exists, even if not a real SDK)
print("--- valid sdk_path ---")
local tmpdir = vim.fn.tempname()
os.execute("mkdir -p " .. tmpdir .. "/bin")
os.execute("touch " .. tmpdir .. "/bin/mojo")
os.execute("chmod +x " .. tmpdir .. "/bin/mojo")

config.setup({ sdk_path = tmpdir })

env = detect.detect()
if env then
	pass(string.format("detect() returns env for valid sdk_path (type=%s)", env.type))
	if env.type == "manual" then
		pass("env.type = manual")
	else
		fail(string.format("env.type expected 'manual', got %q", env.type))
	end
	if env.bin_dir and env.bin_dir:find("bin$") then
		pass("env.bin_dir points to bin/ subdirectory")
	else
		fail("env.bin_dir should end with /bin")
	end
else
	fail("detect() should return env for valid sdk_path")
end

-- Cache hit for manual key
env = detect.detect()
if env then
	pass("cached manual env returned on second call")
else
	fail("cached manual env not returned")
end

-- Cleanup
os.execute("rm -rf " .. tmpdir)
for k in pairs(detect._cache()) do
	detect._cache()[k] = nil
end

-- Summary
print(string.rep("=", 60))
print(string.format("Total failures: %d", total_errors))
if total_errors > 0 then
	vim.cmd(string.format("cq %d", math.min(total_errors, 255)))
else
	vim.cmd("cq 0")
end
