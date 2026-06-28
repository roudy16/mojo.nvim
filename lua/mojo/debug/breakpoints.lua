local native = require("mojo.debug.native")

local M = {}

--- @type integer|nil
local watch_augroup = nil

local BP_GROUPS = { "mojo", "dap" }

local function is_breakpoint_name(name)
	return name == "MojoBreakpoint" or name:find("^DapBreakpoint") ~= nil
end

--- Read breakpoint signs from all known groups.
--- @param buf integer|nil
--- @return integer[]
local function get_lines(buf)
	buf = buf or vim.fn.bufnr()
	local seen = {}
	for _, group in ipairs(BP_GROUPS) do
		local result = vim.fn.sign_getplaced(buf, { group = group })
		for _, entry in ipairs(result) do
			for _, sign in ipairs(entry.signs or {}) do
				if is_breakpoint_name(sign.name) then
					seen[sign.lnum] = true
				end
			end
		end
	end
	local lines = {}
	for line, _ in pairs(seen) do
		table.insert(lines, line)
	end
	table.sort(lines)
	return lines
end

function M.toggle()
	local buf = vim.fn.bufnr()
	local line = vim.fn.line(".")

	-- Check if there's already a breakpoint sign at this line
	for _, group in ipairs(BP_GROUPS) do
		local result = vim.fn.sign_getplaced(buf, { group = group, lnum = line })
		for _, entry in ipairs(result) do
			for _, sign in ipairs(entry.signs or {}) do
				if is_breakpoint_name(sign.name) then
					vim.fn.sign_unplace(group, { buffer = buf, id = sign.id })
					return
				end
			end
		end
	end

	-- No existing BP, place one in our group
	local defined = vim.fn.sign_defined("MojoBreakpoint")
	if defined == 0 then
		vim.fn.sign_define("MojoBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
	end
	vim.fn.sign_place(0, "mojo", "MojoBreakpoint", buf, { lnum = line })
end

function M.clear()
	local buf = vim.fn.bufnr()
	for _, group in ipairs(BP_GROUPS) do
		vim.fn.sign_unplace(group, { buffer = buf })
	end
end

--- @return integer
function M.count()
	return #get_lines()
end

--- Send all current breakpoints to the native debugger.
function M.sync_all()
	if not native.is_active() then
		return
	end
	local file = native.get_file()
	if not file then
		return
	end
	local lines = get_lines()
	for _, line in ipairs(lines) do
		native.send_breakpoint(line)
	end
end

function M.watch()
	if watch_augroup then
		return
	end
	watch_augroup = vim.api.nvim_create_augroup("MojoDebugBPs", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = watch_augroup,
		pattern = { "*.mojo", "*.🔥" },
		callback = function()
			if native.is_active() then
				M.sync_all()
			end
		end,
	})
end

function M.unwatch()
	if watch_augroup then
		vim.api.nvim_del_augroup_by_id(watch_augroup)
		watch_augroup = nil
	end
end

return M
