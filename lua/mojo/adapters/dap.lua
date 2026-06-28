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

	dap.adapters.mojo = function(callback, _)
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

	dap.configurations.mojo = {
		{
			type = "mojo",
			request = "launch",
			name = "Debug Mojo File",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
		{
			type = "mojo",
			request = "launch",
			name = "Debug Mojo File (with args)",
			program = "${file}",
			args = function()
				local args_str = vim.fn.input("Program args: ")
				return vim.split(args_str, "%s+")
			end,
			cwd = "${workspaceFolder}",
		},
		{
			type = "mojo",
			request = "launch",
			name = "Debug Binary",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
		},
		{
			type = "mojo",
			request = "attach",
			name = "Attach to Process",
			pid = require("dap.utils").pick_process,
		},
	}

	return true
end

return M
