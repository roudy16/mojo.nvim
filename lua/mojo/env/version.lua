local bin = require("mojo.env.bin")
local log = require("mojo.log")

local M = {}

--- @type string|nil|false
local cached_version = nil

--- @type boolean
local cache_valid = false

--- Parse version from `mojo --version` output.
--- Example input: "Mojo 24.4.0 (abc1234)" or "Mojo 1.0.0b1 (a9591de6)"
--- @param output string
--- @return string|nil
local function parse_version(output)
	return output:match("^Mojo%s+([%w%.]+)")
end

--- @param path string|nil
--- @return string|nil
function M.get_version(path)
	if cache_valid then
		return cached_version or nil
	end

	local mojo_cmd = bin.get_mojo_cmd(path)
	if not mojo_cmd then
		log.log("version_miss", function()
			return { path = path or vim.fn.getcwd(), reason = "mojo binary not found" }
		end)
		cached_version = false
		cache_valid = true
		return nil
	end

	local handle = io.popen(mojo_cmd .. " --version 2>/dev/null")
	if not handle then
		cached_version = false
		cache_valid = true
		return nil
	end

	local output = handle:read("*a")
	handle:close()

	local version = parse_version(output)
	if version then
		cached_version = version
		cache_valid = true
		log.log("version", function()
			return { path = path or vim.fn.getcwd(), version = version, source = mojo_cmd }
		end)
		return version
	end

	log.log("version_parse_miss", function()
		return { path = path or vim.fn.getcwd(), output = output:sub(1, 100) }
	end)
	cached_version = false
	cache_valid = true
	return nil
end

--- Clear cached version for re-detection.
function M.clear_cache()
	cached_version = nil
	cache_valid = false
end

return M
