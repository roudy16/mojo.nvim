local M = {}

--- @return string
local function plugin_root()
	local source = debug.getinfo(1, "S").source
	local path = source:sub(2)
	return vim.fn.fnamemodify(path, ":h:h:h")
end

--- @return boolean
function M.register()
	local ok, parsers = pcall(require, "nvim-treesitter.parsers")
	if not ok then
		return false
	end

	local root = plugin_root()
	local grammar_dir = "tree-sitter/mojo"

	parsers.mojo = {
		install_info = {
			path = root,
			location = grammar_dir,
			files = { "src/parser.c", "src/scanner.c" },
			queries = grammar_dir .. "/queries",
			revision = "HEAD",
		},
		filetype = "mojo",
		tier = 2,
	}

	return true
end

--- @param opts Mojo-lang.TreesitterConfig|nil
--- @return nil
function M.setup(opts)
	opts = opts or {}
	if opts.enabled == false then
		return
	end

	M.register()

	local group = vim.api.nvim_create_augroup("mojo_nvim_treesitter", { clear = true })

	vim.api.nvim_create_autocmd("User", {
		pattern = "TSUpdate",
		group = group,
		callback = function()
			M.register()
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "mojo",
		group = group,
		callback = function()
			local ok, config = pcall(require, "nvim-treesitter.config")
			if not ok then
				pcall(vim.treesitter.start, 0, "mojo")
				return
			end
			local installed = config.get_installed()
			if vim.tbl_contains(installed, "mojo") then
				pcall(vim.treesitter.start, 0, "mojo")
				return
			end

			vim.schedule(function()
				vim.cmd("TSInstall mojo")
				local install_dir = config.get_install_dir("parser")
				local done = false
				local timer = vim.uv.new_timer()
				timer:start(500, 500, vim.schedule_wrap(function()
					if done then
						return
					end
					if vim.uv.fs_stat(install_dir .. "/mojo.so") then
						done = true
						timer:close()
						pcall(vim.cmd, "edit!")
					end
				end))
			end)
		end,
	})
end

return M
