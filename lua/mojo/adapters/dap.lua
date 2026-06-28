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

	dap.adapters["mojo-lldb"] = function(callback, _)
		local cmd, env_dir = env.get_dap_cmd()
		if not cmd then
			callback(nil)
			return
		end
		callback({
			type = "executable",
			command = cmd[1],
			options = {
				env = env_dir and { CONDA_PREFIX = env_dir } or {},
			},
		})
	end

	local function build_config(name, opts)
		opts = opts or {}
		local config = {
			type = "mojo-lldb",
			request = "launch",
			name = name,
			runInTerminal = true,
			cwd = "${workspaceFolder}",
		}
		if opts.args_fn then
			config.args = opts.args_fn
		end
		if opts.program_fn then
			config.program = opts.program_fn
		end
		if opts.mojo_file then
			config.program = function()
				local file = vim.fn.expand("%:p")
				if file == "" then
					vim.notify("mojo.nvim: no file to debug", vim.log.levels.ERROR)
					return nil
				end
				local mojo = require("mojo.env").get_mojo_cmd()
				if not mojo then
					vim.notify("mojo.nvim: mojo binary not found", vim.log.levels.ERROR)
					return nil
				end
				local out = file .. ".mojo-dap-bin"
				local result = vim.fn.system({ mojo, "build", "--debug-level=full", "-O0", file, "-o", out })
				if vim.v.shell_error ~= 0 then
					vim.notify("mojo.nvim: build failed before debugging:\n" .. result, vim.log.levels.ERROR)
					return nil
				end
				return out
			end
		end
		return config
	end

	dap.configurations.mojo = {
		build_config("Debug Mojo File", { mojo_file = true }),
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
