local env = require("mojo.env")

local M = {}

--- @class Mojo-lang.LualineOpts
--- @field icon string|nil
--- @field show_env_name boolean|nil
--- @field show_sdk_version boolean|nil
--- @field colored boolean|nil
--- @field color string|nil
--- @field icon_color string|nil

--- @type Mojo-lang.LualineOpts
M.defaults = {
	icon = "🔥",
	show_env_name = true,
	show_sdk_version = true,
	colored = true,
}

--- Return the text portion (env + version) for the current buffer.
--- @param opts Mojo-lang.LualineOpts
--- @return string
local function _text(opts)
	if vim.bo.filetype ~= "mojo" then
		return ""
	end

	local parts = {}

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

	return table.concat(parts, " ")
end

--- Build two lualine component tables: one for the icon, one for the text.
--- Each has its own color function.
--- @param opts Mojo-lang.LualineOpts
--- @return table[]
local function _components(opts)
	local icon_comp = {
		function()
			if vim.bo.filetype ~= "mojo" then
				return ""
			end
			return opts.icon or "Mojo"
		end,
		color = function()
			if opts.colored == false then
				return nil
			end
			return { fg = opts.icon_color }
		end,
	}

	local text_comp = {
		function()
			return _text(opts)
		end,
		color = function()
			if opts.colored == false then
				return nil
			end
			return { fg = opts.color }
		end,
	}

	return { icon_comp, text_comp }
end

--- Register the Mojo components into lualine's config.
--- @param opts Mojo-lang.LualineOpts|nil
--- @return boolean
function M.setup(opts)
	opts = vim.tbl_deep_extend("force", M.defaults, opts or {})
	opts.color = opts.color or "#d97706"
	opts.icon_color = opts.icon_color or "#ff6f00"

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
