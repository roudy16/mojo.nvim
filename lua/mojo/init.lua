local config = require("mojo.config")
local hooks = require("mojo.hooks")
local log = require("mojo.log")

local M = {}

M.hooks = hooks.defaults
M.log = log

--- @param user_config Mojo-lang.Config|nil
--- @return Mojo-lang.Config
function M.setup(user_config)
	local opts = config.setup(user_config)
	M.hooks = hooks.merge(opts.hooks)

	log.setup({ debug = opts.debug })
	log.log("setup", function()
		return {
			debug = opts.debug or false,
			filetype = opts.filetype and opts.filetype.enabled ~= false,
			treesitter = opts.treesitter and opts.treesitter.enabled ~= false,
			lsp = opts.lsp and opts.lsp.enabled ~= false,
			format = opts.format and opts.format.enabled ~= false,
			terminal = opts.terminal and opts.terminal.enabled ~= false,
			statusline = opts.statusline and opts.statusline.enabled ~= false,
			dap = opts.dap and opts.dap.enabled == true,
		}
	end)

	if opts.filetype and opts.filetype.enabled ~= false then
		require("mojo.filetype").setup()
	end

	if opts.treesitter and opts.treesitter.enabled ~= false then
		local ts_opts = opts.treesitter
		if ts_opts and ts_opts.adapter then
			ts_opts.adapter(ts_opts)
		else
			require("mojo.adapters.treesitter").setup(ts_opts)
		end
	end

	if opts.lsp and opts.lsp.enabled ~= false then
		local lsp_opts = opts.lsp
		if lsp_opts and lsp_opts.adapter then
			lsp_opts.adapter(lsp_opts)
		else
			require("mojo.adapters.lspconfig").setup(lsp_opts)
		end
	end

	if opts.format and opts.format.enabled ~= false then
		local fmt_opts = opts.format
		if fmt_opts and fmt_opts.adapter then
			fmt_opts.adapter(fmt_opts)
		else
			require("mojo.adapters.conform").setup(fmt_opts)
		end
	end

	if opts.completion and opts.completion.enabled then
		local cmp_opts = opts.completion
		if cmp_opts and cmp_opts.adapter then
			cmp_opts.adapter(cmp_opts)
		elseif not require("mojo.adapters.blink").setup(cmp_opts) then
			require("mojo.adapters.nvim-cmp").setup(cmp_opts)
		end
	end

	local sl_opts = opts.statusline
	if sl_opts and sl_opts.enabled ~= false then
		if sl_opts.adapter then
			sl_opts.adapter(sl_opts)
		else
			require("mojo.adapters.lualine").setup(sl_opts)
		end
	end

	if opts.terminal and opts.terminal.enabled ~= false then
		require("mojo.terminal").setup(opts.terminal)
	end

	if opts.dap and opts.dap.enabled then
		local dap_opts = opts.dap
		if dap_opts and dap_opts.adapter then
			dap_opts.adapter(dap_opts)
		else
			require("mojo.adapters.dap").setup(dap_opts)
		end
	end

	local mojo_augroup = vim.api.nvim_create_augroup("MojoKeymaps", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = mojo_augroup,
		pattern = "mojo",
		callback = function()
			vim.keymap.set("n", "<C-S-space>", vim.lsp.buf.signature_help, { buffer = true, desc = "Signature help" })
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = true, desc = "Code action" })
		end,
	})

	vim.api.nvim_create_user_command("MojoMenu", function()
		require("mojo.status").show_menu()
	end, { desc = "Open Mojo actions menu" })

	vim.api.nvim_create_user_command("MojoRefreshSDK", function()
		local detect = require("mojo.env.detect")
		local cache = detect._cache()
		for k in pairs(cache) do
			cache[k] = nil
		end
		require("mojo.status")._reset_lsp_crash()
		require("mojo.env.version").clear_cache()
		vim.notify("mojo.nvim: SDK cache cleared", vim.log.levels.INFO)
	end, { desc = "Clear SDK cache and re-detect environment" })

	vim.api.nvim_create_user_command("MojoRestartLSP", function()
		require("mojo.status").actions["Restart LSP"]()
	end, { desc = "Restart Mojo LSP server" })

	vim.api.nvim_create_user_command("MojoStopLSP", function()
		require("mojo.status").actions["Stop LSP"]()
	end, { desc = "Stop Mojo LSP server" })

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

	vim.api.nvim_create_user_command("MojoRun", function()
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
	end, { desc = "Run current Mojo file in terminal split" })

	vim.api.nvim_create_user_command("MojoRunDedicated", function()
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
	end, { desc = "Run current Mojo file in dedicated terminal buffer" })

	return opts
end

return M
