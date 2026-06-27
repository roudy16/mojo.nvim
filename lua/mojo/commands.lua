local M = {}

local function setup_run_terminal()
	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	vim.bo[buf].buflisted = false
	vim.api.nvim_set_hl(0, "MojoRunWinBar", { bg = "#f0903a", fg = "#ffffff" })
	vim.wo[win].winbar = "%#MojoRunWinBar#  Press [q] [Esc] or [Enter] to close this pane  "
	vim.wo[win].winhl = "Normal:NormalFloat"
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "t", "q", "<C-\\><C-N>:close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "t", "<Esc>", "<C-\\><C-N>:close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "t", "<CR>", "<C-\\><C-N>:close<CR>", { noremap = true, silent = true })
end

local function do_menu()
	require("mojo.status").show_menu()
end

local function do_refresh()
	local detect = require("mojo.env.detect")
	local cache = detect._cache()
	for k in pairs(cache) do
		cache[k] = nil
	end
	require("mojo.status")._reset_lsp_crash()
	require("mojo.env.version").clear_cache()
	vim.notify("mojo.nvim: SDK cache cleared", vim.log.levels.INFO)
end

local function do_restart()
	require("mojo.status").actions["Restart LSP"]()
end

local function do_stop()
	require("mojo.status").actions["Stop LSP"]()
end

local function do_run()
	local file = vim.fn.expand("%:p")
	if vim.bo.filetype ~= "mojo" then
		vim.notify("mojo.nvim: not a Mojo file", vim.log.levels.ERROR)
		return
	end
	local mojo = require("mojo.env").get_mojo_cmd()
	if not mojo then
		vim.notify("mojo.nvim: mojo binary not found", vim.log.levels.ERROR)
		return
	end
	vim.cmd("belowright terminal " .. mojo .. " run " .. vim.fn.shellescape(file))
	setup_run_terminal()
end

local function do_dedicated()
	local file = vim.fn.expand("%:p")
	if vim.bo.filetype ~= "mojo" then
		vim.notify("mojo.nvim: not a Mojo file", vim.log.levels.ERROR)
		return
	end
	local mojo_cmd = require("mojo.env").get_mojo_cmd()
	if not mojo_cmd then
		vim.notify("mojo.nvim: mojo binary not found", vim.log.levels.ERROR)
		return
	end
	local bufname = "mojo-run://" .. file
	local buf = vim.fn.bufnr(bufname)
	if buf > 0 then
		local win = vim.fn.bufwinid(buf)
		if win > 0 then
			vim.api.nvim_set_current_win(win)
		else
			vim.cmd("belowright sbuffer " .. buf)
			setup_run_terminal()
		end
		return
	end
	vim.cmd("belowright terminal " .. mojo_cmd .. " run " .. vim.fn.shellescape(file))
	vim.api.nvim_buf_set_name(vim.api.nvim_get_current_buf(), bufname)
	setup_run_terminal()
end

local function do_rebuild()
	local ts = require("mojo.treesitter")
	if ts.compile_parser() then
		vim.notify("[mojo.nvim] Parser rebuilt.", vim.log.levels.INFO)
		vim.cmd("edit!")
	end
end

local function show_keymaps()
	local km = require("mojo.config").options.keymaps or {}
	local sig = km.signature_help or "K"
	local ca = km.code_action or "<leader>ca"
	vim.notify(
		table.concat({
			"mojo.nvim keymaps:",
			("  %-16s Signature help inside parens, hover otherwise"):format(sig),
			("  %-16s Code action"):format(ca),
			"  q, <Esc>, <CR>    Close run terminal",
		}, "\n"),
		vim.log.levels.INFO
	)
end

local function show_help()
	vim.notify(
		table.concat({
			"mojo.nvim subcommands:",
			"  menu       Open floating actions menu",
			"  run        Run current file in terminal split",
			"  dedicated  Run current file in dedicated buffer",
			"  restart    Restart Mojo LSP server",
			"  stop       Stop Mojo LSP server",
			"  refresh    Clear SDK cache and re-detect",
			"  rebuild    Rebuild tree-sitter parser",
			"  keymaps    Show available keymaps",
			"  help       Show this help",
		}, "\n"),
		vim.log.levels.INFO
	)
end

--- @param opts Mojo-lang.Config
function M.setup(opts)
	local cmds = opts.commands or {}

	if cmds.spread then
		vim.api.nvim_create_user_command("MojoMenu", do_menu, { desc = "Open Mojo actions menu" })
		vim.api.nvim_create_user_command("MojoRefreshSDK", do_refresh, { desc = "Clear SDK cache and re-detect environment" })
		vim.api.nvim_create_user_command("MojoRestartLSP", do_restart, { desc = "Restart Mojo LSP server" })
		vim.api.nvim_create_user_command("MojoStopLSP", do_stop, { desc = "Stop Mojo LSP server" })
		vim.api.nvim_create_user_command("MojoRun", do_run, { desc = "Run current Mojo file in terminal split" })
		vim.api.nvim_create_user_command("MojoRunDedicated", do_dedicated, { desc = "Run current Mojo file in dedicated terminal buffer" })
		vim.api.nvim_create_user_command("MojoRebuildParser", do_rebuild, { desc = "Rebuild the self-hosted tree-sitter Mojo parser" })
	end

	if cmds.master then
		local dispatch = {
			menu = do_menu,
			run = do_run,
			dedicated = do_dedicated,
			restart = do_restart,
			stop = do_stop,
			refresh = do_refresh,
			rebuild = do_rebuild,
		}

		vim.api.nvim_create_user_command("Mojo", function(info)
			local subcommand = vim.trim(info.args)
			if subcommand == "" or subcommand == "help" then
				show_help()
				return
			end

			local fn = dispatch[subcommand]
			if fn then
				fn()
			elseif subcommand == "keymaps" then
				show_keymaps()
			else
				vim.notify("mojo.nvim: unknown subcommand '" .. subcommand .. "'. See ':Mojo help'", vim.log.levels.ERROR)
			end
		end, {
			nargs = "?",
			complete = function(ArgLead)
				local all = { "menu", "run", "dedicated", "restart", "stop", "refresh", "rebuild", "keymaps", "help" }
				return vim.iter(all):filter(function(s)
					return s:find(ArgLead) ~= nil
				end):totable()
			end,
			desc = "Mojo plugin master command",
		})
	end
end

return M
