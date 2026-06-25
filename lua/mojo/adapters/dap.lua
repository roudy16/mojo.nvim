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

	dap.adapters.mojo = {
		type = "executable",
		command = function()
			local cmd, _ = env.get_dap_cmd()
			return (cmd and cmd[1]) or "mojo-lldb-dap"
		end,
		options = {
			env = function()
				local _, env_dir = env.get_dap_cmd()
				if env_dir then
					return { CONDA_PREFIX = env_dir }
				end
				return {}
			end,
		},
	}

	dap.configurations.mojo = {
		{
			type = "mojo",
			request = "launch",
			name = "Debug Mojo File",
			mojoFile = "${file}",
			cwd = "${workspaceFolder}",
		},
		{
			type = "mojo",
			request = "launch",
			name = "Debug Mojo File (with args)",
			mojoFile = "${file}",
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
