local env = require("mojo.env")

local M = {}

--- Build the display string for the whole Mojo status block.
--- Returns something like "󰈸 pixi default 24.4.0 · 󰄬 lsp · 󰄬 dbg".
--- Returns "" if the buffer is not a Mojo file.
--- @param opts Mojo-lang.StatuslineConfig
--- @return string
local function _display(opts)
	if vim.bo.filetype ~= "mojo" then
		return ""
	end

	local parts = { opts.icon or "󰈸" }

	if opts.show_env_name then
		local detected = env.detect()
		if detected then
			local env_label = detected.type
			if detected.env_name and detected.env_name ~= "default" then
				env_label = string.format("%s %s", detected.type, detected.env_name)
			end
			table.insert(parts, env_label)
		end
	end

	if opts.show_sdk_version then
		local version = env.get_version()
		if version then
			table.insert(parts, version)
		end
	end

	if opts.show_binaries ~= false then
		local lsp_ok = env.get_lsp_cmd() ~= nil
		local dbg_ok = env.get_dap_cmd() ~= nil

		local bin_parts = {}
		table.insert(bin_parts, (lsp_ok and "󰄬" or "󰅖") .. " lsp")
		table.insert(bin_parts, (dbg_ok and "󰄬" or "󰅖") .. " dbg")

		table.insert(parts, "· " .. table.concat(bin_parts, " · "))
	end

	return table.concat(parts, " ")
end

--- Build a single lualine component table for the Mojo status.
--- @param opts Mojo-lang.StatuslineConfig
--- @return table
local function _component(opts)
	return {
		function()
			return _display(opts)
		end,
		color = function()
			if opts.colored == false then
				return nil
			end
			return { fg = opts.color or "#ff9e64" }
		end,
	}
end

--- Register the Mojo component into lualine's config.
--- @param opts Mojo-lang.StatuslineConfig
--- @return boolean
function M.setup(opts)
	opts = opts or {}

	local function inject_sections(sections)
		local target = sections.lualine_x or sections.lualine_y
		if target then
			table.insert(target, _component(opts))
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
