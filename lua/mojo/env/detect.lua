local util = require("mojo.env.util")
local log = require("mojo.log")

local M = {}

--- @type table<string, Mojo-lang.DetectedEnv|false>
local cache = {}

--- @type string
local MANUAL_KEY = "__manual__"

--- Resolve the SDK path from config or env var.
--- Priority: config.sdk_path > MOJO_SDK_PATH env var
--- @return string|nil
local function resolve_sdk_path()
	local config = require("mojo.config")
	if config.options and config.options.sdk_path then
		return config.options.sdk_path
	end
	local env_path = vim.env.MOJO_SDK_PATH
	if env_path and env_path ~= "" then
		return env_path
	end
	return nil
end

--- Validate a manual SDK path.
--- @param sdk_path string
--- @return boolean
local function valid_sdk_path(sdk_path)
	if not util.has_dir(sdk_path) then
		return false
	end
	return util.has_file(vim.fs.joinpath(sdk_path, "bin", "mojo"))
		or util.has_file(vim.fs.joinpath(sdk_path, "bin", "mojo-lsp-server"))
		or false
end

--- @param path string|nil
--- @return Mojo-lang.DetectedEnv|nil
function M.detect(path)
	-- Manual SDK path override
	local sdk_path = resolve_sdk_path()
	if sdk_path then
		if cache[MANUAL_KEY] ~= nil then
			return cache[MANUAL_KEY] or nil
		end

		if not valid_sdk_path(sdk_path) then
			log.log("sdk_path_invalid", function()
				return { sdk_path = sdk_path }
			end)
			vim.notify(
				string.format("mojo.nvim: sdk_path %q not found or missing mojo binaries", sdk_path),
				vim.log.levels.WARN
			)
			cache[MANUAL_KEY] = false
			return nil
		end

		local bin_dir = vim.fs.joinpath(sdk_path, "bin")
		cache[MANUAL_KEY] = {
			type = "manual",
			root = sdk_path,
			bin_dir = bin_dir,
			env_dir = sdk_path,
		}
		log.log("detect_manual", function()
			return { sdk_path = sdk_path, bin_dir = bin_dir }
		end)
		return cache[MANUAL_KEY] or nil
	end

	-- Auto-detection (original logic)
	local root = util.root_for(path, { "pixi.toml", "pyproject.toml", ".pixi", ".venv", ".derived" })
	if not root then
		log.log("detect_miss", function()
			return { path = path or vim.fn.getcwd() }
		end)
		return nil
	end

	if cache[root] ~= nil then
		log.log("detect_cache", function()
			return { root = root, hit = true, type = cache[root] and cache[root].type or "none" }
		end)
		return cache[root] or nil
	end

	local derived_bin = vim.fs.joinpath(root, ".derived", "bin")
	if util.has_dir(derived_bin) then
		cache[root] = {
			type = "derived",
			root = root,
			bin_dir = derived_bin,
			env_dir = vim.fs.joinpath(root, ".derived"),
		}
		log.log("detect_derived", function()
			return { root = root, bin_dir = derived_bin }
		end)
		return cache[root] or nil
	end

	if util.has_file(vim.fs.joinpath(root, "pixi.toml")) or util.has_dir(vim.fs.joinpath(root, ".pixi")) then
		local env_name, pixi_env = util.first_pixi_env(root)
		cache[root] = {
			type = "pixi",
			root = root,
			env_name = env_name,
			env_dir = pixi_env,
			bin_dir = pixi_env and vim.fs.joinpath(pixi_env, "bin") or nil,
			activate_cmd = env_name and string.format('eval "$(pixi shell-hook --environment %s)"', env_name)
				or 'eval "$(pixi shell-hook)"',
		}
		log.log("detect_pixi", function()
			return { root = root, env_name = env_name or "none", env_dir = pixi_env or "none" }
		end)
		return cache[root] or nil
	end

	local venv_dir = vim.fs.joinpath(root, ".venv")
	local venv_activate = vim.fs.joinpath(venv_dir, "bin", "activate")
	if util.has_file(venv_activate) then
		cache[root] = {
			type = "venv",
			root = root,
			env_dir = venv_dir,
			bin_dir = vim.fs.joinpath(venv_dir, "bin"),
			activate_cmd = "source .venv/bin/activate",
		}
		log.log("detect_venv", function()
			return { root = root, env_dir = venv_dir }
		end)
		return cache[root] or nil
	end

	cache[root] = false
	log.log("detect_none", function()
		return { root = root }
	end)
	return nil
end

--- @param path string|nil
--- @return string|nil
function M.activate_command(path)
	local env = M.detect(path)
	if not env then
		return nil
	end
	return env.activate_cmd
end

--- Expose cache for sibling modules (activate, bin) but not publicly.
--- @return table<string, Mojo-lang.DetectedEnv|false>
function M._cache()
	return cache
end

return M
