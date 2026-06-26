local env = require("mojo.env")
local status = require("mojo.status")

local M = {}

--- @type Mojo-lang.StatuslineConfig|nil
local setup_opts = nil

--- Define highlight groups for inline coloring via %#...#%* syntax.
local function _define_highlights()
	if not setup_opts then
		return
	end
	local opts = setup_opts
	local c = opts.color or "#ff9e64"
	local ic = opts.icon_color or "#ff6f00"
	local green = "#a6da95"
	local yellow = "#d4b44e"
	local red = "#ed8796"

	vim.api.nvim_set_hl(0, "MojoIcon", { fg = ic })
	vim.api.nvim_set_hl(0, "MojoText", { fg = c })
	vim.api.nvim_set_hl(0, "MojoSep", { fg = c })
	vim.api.nvim_set_hl(0, "MojoGood", { fg = green })
	vim.api.nvim_set_hl(0, "MojoNeutral", { fg = "#5a5a5a" })
	vim.api.nvim_set_hl(0, "MojoWarn", { fg = yellow })
	vim.api.nvim_set_hl(0, "MojoErr", { fg = red })
end

--- Build the display string with inline highlight groups.
--- @param opts Mojo-lang.StatuslineConfig
--- @return string
local function _display(opts)
	if vim.bo.filetype ~= "mojo" then
		return ""
	end

	_define_highlights()

	local parts = {}

	table.insert(parts, "%#MojoIcon#" .. (opts.icon or "🔥") .. "%*")

	local env_parts = {}
	if opts.show_env_name then
		local detected = env.detect()
		if detected then
			local label = detected.type
			if detected.env_name and detected.env_name ~= "default" then
				label = string.format("%s %s", detected.type, detected.env_name)
			end
			table.insert(env_parts, label)
		end
	end
	if opts.show_sdk_version then
		local v = env.get_version()
		if v then
			table.insert(env_parts, v)
		end
	end
	if #env_parts > 0 then
		table.insert(parts, "%#MojoText#" .. table.concat(env_parts, " ") .. "%*")
	end

	local function add_indicator(state, label)
		local icon = status.status_icon(state)
		local hl = "MojoNeutral"
		if state == "running" or state == "active" or state == "available" then
			hl = "MojoGood"
		elseif state == "crashed" or state == "unavailable" then
			hl = "MojoErr"
		end
		table.insert(parts, "%#MojoSep#·%*")
		table.insert(parts, "%#" .. hl .. "#" .. icon .. "%*" .. " " .. label)
	end

	if opts.show_lsp ~= false then
		add_indicator(status.lsp_status(), "lsp")
	end

	if opts.show_fmt ~= false then
		add_indicator(status.fmt_status(), "fmt")
	end

	if opts.show_dbg ~= false then
		add_indicator(status.dbg_status(), "dbg")
	end

	if opts.show_diag ~= false then
		local dt = status.diag_text()
		if dt then
			local hl = status.diag_color() == "#ed8796" and "MojoErr" or "MojoWarn"
			table.insert(parts, "%#MojoSep#·%*")
			table.insert(parts, "%#" .. hl .. "#" .. dt .. "%*")
		end
	end

	return table.concat(parts, " ")
end

--- @param opts Mojo-lang.StatuslineConfig
--- @return boolean
function M.setup(opts)
	opts = opts or {}
	setup_opts = opts

	_define_highlights()

	local augroup = vim.api.nvim_create_augroup("MojoLualine", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = augroup,
		callback = _define_highlights,
	})
	vim.api.nvim_create_autocmd("WinEnter", {
		group = augroup,
		callback = _define_highlights,
	})

	local component = {
		function()
			return _display(opts)
		end,
	}

	if opts.clickable ~= false then
		component.on_click = function()
			status.show_menu()
		end
	end

	local function inject_sections(sections)
		local target = sections.lualine_x or sections.lualine_y
		if target then
			table.insert(target, component)
		end
	end

	if package.loaded["lualine"] then
		local lualine_config = require("lualine.config")
		if lualine_config and lualine_config.config and lualine_config.config.sections then
			inject_sections(lualine_config.config.sections)
			require("lualine").refresh()
			return true
		end
		return false
	end

	local orig_setup
	local function wrap_setup(lualine)
		orig_setup = lualine.setup
		lualine.setup = function(config)
			if config and config.sections then
				inject_sections(config.sections)
			end
			orig_setup(config)
		end
	end

	local orig_require = _G.require
	_G.require = function(modname)
		if modname == "lualine" then
			_G.require = orig_require
			local lualine = orig_require("lualine")
			wrap_setup(lualine)
			return lualine
		end
		return orig_require(modname)
	end

	return true
end

return M
