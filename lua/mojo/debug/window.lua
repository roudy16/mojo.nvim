local M = {}

--- @param buf integer
--- @param win integer
--- @param job integer|nil
function M.setup(buf, win, job)
	vim.bo[buf].buflisted = false
	vim.b[buf].mojo_debug = true

	vim.api.nvim_set_hl(0, "MojoDebugWinBar", { bg = "#4e8cbf", fg = "#ffffff" })
	vim.wo[win].winbar =
		"%#MojoDebugWinBar#  [r]un [n]ext [s]tep [c]ontinue [v]ars [b]ps  |  [q] [Esc] [Enter] close  "
	vim.wo[win].winhl = "Normal:NormalFloat"
	vim.wo[win].statusline = " "
	vim.api.nvim_create_autocmd("WinEnter", {
		buffer = buf,
		callback = function()
			local cur_win = vim.api.nvim_get_current_win()
			if vim.api.nvim_win_is_valid(cur_win) and vim.api.nvim_win_get_buf(cur_win) == buf then
				vim.wo[cur_win].statusline = " "
			end
		end,
	})

	M._map(buf, "n", "q", function()
		require("mojo.debug.native").close()
	end, "Close debug terminal")
	M._map(buf, "n", "<Esc>", function()
		require("mojo.debug.native").close()
	end, "Close debug terminal")
	M._map(buf, "n", "<CR>", function()
		require("mojo.debug.native").close()
	end, "Close debug terminal")
	local function close_term()
		vim.cmd("stopinsert")
		require("mojo.debug.native").close()
	end
	M._map(buf, "t", "q", close_term, "Close debug terminal")
	M._map(buf, "t", "<Esc>", close_term, "Close debug terminal")
	M._map(buf, "t", "<CR>", close_term, "Close debug terminal")

	local function lldb(cmd)
		return function()
			require("mojo.debug.native").send(cmd)
		end
	end
	M._map(buf, "n", "r", function()
		require("mojo.debug.native").run()
	end, "LLDB: run")
	M._map(buf, "n", "n", lldb("next"), "LLDB: next")
	M._map(buf, "n", "s", lldb("step"), "LLDB: step")
	M._map(buf, "n", "c", lldb("continue"), "LLDB: continue")
	M._map(buf, "n", "v", lldb("frame variable"), "LLDB: variables")
	M._map(buf, "n", "b", function()
		require("mojo.debug.breakpoints").sync_all()
		vim.notify("mojo.nvim: breakpoints synced to LLDB", vim.log.levels.INFO)
	end, "Sync breakpoints")
end

--- @param buf integer
--- @param win integer
function M.auto_scroll(buf, win)
	if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
		return
	end
	local line_count = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_win_set_cursor(win, { line_count, 0 })
end

--- @param buf integer
--- @param mode string
--- @param lhs string
--- @param rhs function
--- @param desc string
function M._map(buf, mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { buffer = buf, noremap = true, silent = true, desc = desc })
end

return M
