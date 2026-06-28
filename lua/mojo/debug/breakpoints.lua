local native = require("mojo.debug.native")

local M = {}

--- @type table<integer, integer>
local lldb_bps = {}

--- @type integer|nil
local watch_augroup = nil

local SIGN_NAME = "MojoBreakpoint"
local SIGN_TEXT = "●"
local SIGN_HIGHLIGHT = "DiagnosticSignError"

local function ensure_sign()
	local defined = vim.fn.sign_defined(SIGN_NAME)
	if defined == 0 then
		vim.fn.sign_define(SIGN_NAME, { text = SIGN_TEXT, texthl = SIGN_HIGHLIGHT })
	end
end

local function get_signs(buf)
	buf = buf or vim.fn.bufnr()
	local placed = vim.fn.sign_getplaced(buf, { group = "mojo" })
	local lines = {}
	for _, sign in ipairs(placed) do
		if sign.name == SIGN_NAME then
			lines[sign.lnum] = true
		end
	end
	return lines
end

function M.toggle()
	ensure_sign()
	local buf = vim.fn.bufnr()
	local line = vim.fn.line(".")
	local placed = vim.fn.sign_getplaced(buf, {
		group = "mojo",
		name = SIGN_NAME,
		lnum = line,
	})
	if placed and #placed > 0 then
		vim.fn.sign_unplace("mojo", { buffer = buf, id = placed[1].id })
	else
		vim.fn.sign_place(0, "mojo", SIGN_NAME, buf, { lnum = line })
	end
end

function M.clear()
	local buf = vim.fn.bufnr()
	vim.fn.sign_unplace("mojo", { buffer = buf })
	lldb_bps = {}
end

--- @param buf integer|nil
--- @return integer[]
function M.get_lines(buf)
	buf = buf or vim.fn.bufnr()
	local lines = {}
	for line, _ in pairs(get_signs(buf)) do
		table.insert(lines, line)
	end
	table.sort(lines)
	return lines
end

--- @return integer
function M.count()
	return #M.get_lines()
end

function M.sync_all()
	if not native.is_active() then
		return
	end
	local file = native.get_file()
	if not file then
		return
	end
	local buf = vim.fn.bufnr()
	local lines = M.get_lines(buf)

	for _, line in ipairs(lines) do
		if not lldb_bps[line] then
			native.send_breakpoint(line)
		end
	end

	for line, lldb_id in pairs(lldb_bps) do
		local found = false
		for _, l in ipairs(lines) do
			if l == line then
				found = true
				break
			end
		end
		if not found then
			native.remove_breakpoint(lldb_id)
			lldb_bps[line] = nil
		end
	end
end

function M.watch()
	if watch_augroup then
		return
	end
	watch_augroup = vim.api.nvim_create_augroup("MojoDebugBPs", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = watch_augroup,
		pattern = "*.mojo",
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
