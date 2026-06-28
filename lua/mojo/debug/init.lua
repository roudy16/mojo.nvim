local env = require("mojo.env")
local config = require("mojo.config")

local M = {}

--- @type "native"|"dap"|nil
local active_backend = nil

--- @return string|nil
function M.get_backend()
	return active_backend
end

--- @param backend "auto"|"native"|"dap"|nil
function M.start(backend)
	if backend == nil or backend == "auto" then
		backend = M._pick_backend()
	end
	if not backend then
		vim.notify(
			"mojo.nvim: no debugger available (mojo-lldb or mojo-lldb-dap not found)",
			vim.log.levels.ERROR
		)
		return
	end

	if backend == "dap" then
		active_backend = "dap"
		M._start_dap()
	elseif backend == "native" then
		active_backend = "native"
		require("mojo.debug.native").start()
		require("mojo.debug.breakpoints").sync_all()
		require("mojo.debug.breakpoints").watch()
	else
		vim.notify("mojo.nvim: unknown debug backend: " .. tostring(backend), vim.log.levels.ERROR)
	end
end

--- @return "native"|"dap"|nil
function M._pick_backend()
	if config.options.debug and config.options.debug.auto_backend then
		return config.options.debug.auto_backend
	end
	if env.get_dap_cmd() then
		return "dap"
	end
	if env.get_dbg_native_cmd() then
		return "native"
	end
	return nil
end

function M._start_dap()
	local ok, dap = pcall(require, "dap")
	if not ok then
		vim.notify("mojo.nvim: nvim-dap not installed, cannot start dbg_dap", vim.log.levels.ERROR)
		active_backend = nil
		return
	end
	local file = vim.fn.expand("%:p")
	if file == "" then
		vim.notify("mojo.nvim: no file to debug", vim.log.levels.ERROR)
		active_backend = nil
		return
	end
	dap.run({ type = "mojo", request = "launch", name = "Debug Mojo File", mojoFile = file })
end

function M.toggle_bp()
	require("mojo.debug.breakpoints").toggle()
	if active_backend == "native" then
		require("mojo.debug.breakpoints").sync_all()
	end
end

function M.clear_bps()
	require("mojo.debug.breakpoints").clear()
	if active_backend == "native" then
		require("mojo.debug.breakpoints").sync_all()
	end
end

--- @return { native: boolean, dap: boolean, active: string|nil }
function M.status()
	return {
		native = env.get_dbg_native_cmd() ~= nil,
		dap = env.get_dap_cmd() ~= nil,
		active = active_backend,
	}
end

return M
