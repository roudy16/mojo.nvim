local config = require("mojo.config")
local window = require("mojo.debug.window")

local M = {}

--- @type integer|nil
local term_buf = nil

--- @type integer|nil
local term_win = nil

--- @type integer|nil
local term_job = nil

--- @type string|nil
local current_file = nil

function M.start()
	local file = vim.fn.expand("%:p")
	if file == "" then
		vim.notify("mojo.nvim: no file to debug", vim.log.levels.ERROR)
		return
	end
	current_file = file

	local mojo = require("mojo.env").get_mojo_cmd()
	if not mojo then
		vim.notify("mojo.nvim: mojo binary not found", vim.log.levels.ERROR)
		return
	end

	if vim.fn.has("mac") == 1 and mojo:sub(1, 1) == "/" then
		pcall(function()
			vim.fn.system({ "xattr", "-p", "com.apple.quarantine", mojo })
			if vim.v.shell_error == 0 then
				local dir = vim.fs.dirname(mojo)
				vim.notify(
					"mojo.nvim: mojo binary has quarantine — run:\n  xattr -dr com.apple.quarantine "
						.. dir,
					vim.log.levels.WARN
				)
			end
		end)
	end

	vim.cmd("belowright terminal " .. mojo .. " debug " .. vim.fn.shellescape(file))
	term_buf = vim.api.nvim_get_current_buf()
	term_win = vim.api.nvim_get_current_win()
	term_job = vim.bo[term_buf].channel

	window.setup(term_buf, term_win, term_job)

	-- Esperar el prompt (lldb) antes de enviar breakpoints
	M._wait_for_prompt()
end

--- Poll the terminal buffer until LLDB prompt appears, then sync BPs.
function M._wait_for_prompt()
	local lib = vim.uv or vim.loop
	local timer = lib.new_timer()
	local elapsed = 0
	timer:start(100, 200, vim.schedule_wrap(function()
		elapsed = elapsed + 1
		if not M.is_active() or elapsed > 50 then
			timer:stop()
			timer:close()
			return
		end
		local lines = vim.api.nvim_buf_get_lines(term_buf, 0, -1, false)
		for _, line in ipairs(lines) do
			if line:match("%(lldb%)") then
				timer:stop()
				timer:close()
				require("mojo.debug.breakpoints").sync_all()
				return
			end
		end
	end))
end

--- @param cmd string
function M.send(cmd)
	if not term_job or term_job <= 0 then
		return
	end
	vim.api.nvim_chan_send(term_job, cmd .. "\n")
	local opts = config.options.debug or {}
	if opts.auto_scroll ~= false then
		window.auto_scroll(term_buf, term_win)
	end
end

--- @param line integer
function M.send_breakpoint(line)
	if not current_file then
		return
	end
	local escaped = vim.fn.shellescape(current_file)
	M.send(string.format('breakpoint set --file %s --line %d', escaped, line))
end

--- @param lldb_id integer
function M.remove_breakpoint(lldb_id)
	M.send(string.format('breakpoint delete %d', lldb_id))
end

function M.close()
	if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
		local win = vim.fn.bufwinid(term_buf)
		if win > 0 and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	term_buf = nil
	term_win = nil
	term_job = nil
	current_file = nil
	require("mojo.debug.breakpoints").unwatch()
end

function M.is_active()
	return term_buf ~= nil and vim.api.nvim_buf_is_valid(term_buf)
end

--- @return integer|nil
function M.get_job()
	return term_job
end

--- @return string|nil
function M.get_file()
	return current_file
end

return M
