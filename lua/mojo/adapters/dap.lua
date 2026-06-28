local env = require("mojo.env")

local M = {}

--- @param opts Mojo-lang.DapConfig|nil
--- @return boolean
function M.setup(opts)
	if not opts or opts.enabled ~= true then
		return false
	end

	local ok, dap = pcall(require, "dap")
	if not ok then
		return false
	end

	if not env.get_dap_cmd() then
		return false
	end

	dap.adapters["mojo-lldb"] = function(callback, _)
		local cmd, env_dir = env.get_dap_cmd()
		if not cmd then
			callback(nil)
			return
		end
		local adapter_env = {}
		if env_dir then
			local detect = require("mojo.env.detect")
			local detected = detect.detect()
			adapter_env.CONDA_PREFIX = env_dir
			adapter_env.MODULAR_HOME = vim.fs.joinpath(env_dir, "share", "max")
			if detected and detected.bin_dir then
				adapter_env.PATH = detected.bin_dir .. ":" .. (vim.env.PATH or "")
			end
			local lib = vim.fs.joinpath(env_dir, "lib")
			local swift = vim.fs.joinpath(lib, "swift")
			if vim.fn.has("mac") == 1 then
				adapter_env.DYLD_FALLBACK_LIBRARY_PATH = lib .. ":" .. swift
			else
				adapter_env.LD_LIBRARY_PATH = lib .. ":" .. swift
			end
		end
		callback({
			type = "executable",
			command = cmd[1],
			options = {
				env = adapter_env,
			},
		})
	end

	local function build_mojo_file()
		local file = vim.fn.expand("%:p")
		if file == "" then
			vim.notify("mojo.nvim: no file to debug", vim.log.levels.ERROR)
			return nil, nil
		end
		local mojo = require("mojo.env").get_mojo_cmd()
		if not mojo then
			vim.notify("mojo.nvim: mojo binary not found", vim.log.levels.ERROR)
			return nil, nil
		end
		local out = file .. ".mojo-dap-bin"
		local result = vim.fn.system({ mojo, "build", "--debug-level=full", "-O0", file, "-o", out })
		if vim.v.shell_error ~= 0 then
			vim.notify("mojo.nvim: build failed before debugging:\n" .. result, vim.log.levels.ERROR)
			return nil, nil
		end
		return out, file
	end

	local function build_config(name, build_opts)
		build_opts = build_opts or {}
		local cwd = vim.fn.getcwd()
		local config = {
			type = "mojo-lldb",
			request = "launch",
			name = name,
			runInTerminal = true,
			cwd = cwd,
			sourceMap = { { ".", cwd } },
			initCommands = {
				"settings set target.source-map . " .. cwd,
			},
		}
		if build_opts.stop_on_entry then
			config.stopOnEntry = true
		end
		if build_opts.args_fn then
			config.args = build_opts.args_fn
		end
		if build_opts.program_fn then
			config.program = build_opts.program_fn
		end
		if build_opts.mojo_file then
			config.mojoFile = function()
				local _, src = build_mojo_file()
				return src
			end
			config.program = function()
				local bin, _ = build_mojo_file()
				return bin
			end
		end
		return config
	end

	dap.configurations.mojo = {
		build_config("Debug Mojo File", { mojo_file = true, stop_on_entry = true }),
		build_config("Debug Mojo File (with args)", {
			mojo_file = true,
			args_fn = function()
				local args_str = vim.fn.input("Program args: ")
				return vim.split(args_str, "%s+")
			end,
		}),
		build_config("Debug Binary", {
			program_fn = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
		}),
		{
			type = "mojo-lldb",
			request = "attach",
			name = "Attach to Process",
			pid = require("dap.utils").pick_process,
		},
	}

	return true
end

return M
