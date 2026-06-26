local env = require("mojo.env")
local status = require("mojo.status")

local M = {}

--- @param opts Mojo-lang.StatuslineConfig
--- @return table[]
local function _components(opts)
	local comps = {}
	local sep = "·"

	local function click()
		if opts.clickable ~= false then
			status.show_menu()
		end
	end

	local function colored()
		return opts.colored ~= false
	end

	-- Icon component
	table.insert(comps, {
		function()
			if vim.bo.filetype ~= "mojo" then
				return ""
			end
			return opts.icon or "󰈸"
		end,
		color = function()
			if not colored() then
				return nil
			end
			return { fg = opts.icon_color or "#ff6f00" }
		end,
		on_click = click,
	})

	-- Env + version text component
	local function env_text()
		if vim.bo.filetype ~= "mojo" then
			return ""
		end
		local parts = {}
		if opts.show_env_name then
			local detected = env.detect()
			if detected then
				local label = detected.type
				if detected.env_name and detected.env_name ~= "default" then
					label = string.format("%s %s", detected.type, detected.env_name)
				end
				table.insert(parts, label)
			end
		end
		if opts.show_sdk_version then
			local v = env.get_version()
			if v then
				table.insert(parts, v)
			end
		end
		return table.concat(parts, " ")
	end

	table.insert(comps, {
		env_text,
		color = function()
			if not colored() then
				return nil
			end
			return { fg = opts.color or "#ff9e64" }
		end,
		on_click = click,
	})

	-- Separator helper
	local function sep_comp()
		return {
			function()
				if vim.bo.filetype ~= "mojo" then
					return ""
				end
				return sep
			end,
			color = function()
				if not colored() then
					return nil
				end
				return { fg = opts.color or "#ff9e64" }
			end,
			on_click = click,
		}
	end

	-- Indicator helper
	local function indicator_comp(text_fn, color_fn)
		local comp = {
			function()
				if vim.bo.filetype ~= "mojo" then
					return ""
				end
				return text_fn()
			end,
			on_click = click,
		}
		if color_fn then
			comp.color = function()
				if not colored() then
					return nil
				end
				return { fg = color_fn() }
			end
		end
		return comp
	end

	-- LSP indicator
	if opts.show_lsp ~= false then
		table.insert(comps, sep_comp())
		table.insert(comps, indicator_comp(
			function() return status.status_icon(status.lsp_status()) .. " lsp" end,
			function() return status.status_color(status.lsp_status()) end
		))
	end

	-- DAP indicator
	if opts.show_dbg ~= false then
		table.insert(comps, sep_comp())
		table.insert(comps, indicator_comp(
			function() return status.status_icon(status.dbg_status()) .. " dbg" end,
			function() return status.status_color(status.dbg_status()) end
		))
	end

	-- Formatter indicator
	if opts.show_fmt ~= false then
		table.insert(comps, sep_comp())
		table.insert(comps, indicator_comp(
			function() return status.status_icon(status.fmt_status()) .. " fmt" end,
			function() return status.status_color(status.fmt_status()) end
		))
	end

	-- Diagnostics (separator + count baked into one component so both hide when empty)
	if opts.show_diag ~= false then
		table.insert(comps, {
			function()
				if vim.bo.filetype ~= "mojo" then
					return ""
				end
				local t = status.diag_text()
				if not t then
					return ""
				end
				return "· " .. t
			end,
			color = function()
				if not colored() then
					return nil
				end
				return { fg = status.diag_color() or opts.color or "#ff9e64" }
			end,
			on_click = click,
		})
	end

	return comps
end

function M.setup(opts)
	opts = opts or {}

	local function inject_sections(sections)
		local target = sections.lualine_x or sections.lualine_y
		if target then
			for _, comp in ipairs(_components(opts)) do
				table.insert(target, comp)
			end
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
	---@diagnostic disable-next-line: duplicate-set-field
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
