local env = require("mojo.env")

local M = {}

--- @class Mojo-lang.LualineOpts
--- @field icon string|nil
--- @field show_env_name boolean|nil
--- @field show_sdk_version boolean|nil
--- @field colored boolean|nil

--- @type Mojo-lang.LualineOpts
M.defaults = {
	icon = "🔥",
	show_env_name = true,
	show_sdk_version = true,
	colored = true,
}

--- Return the display string for the current buffer.
--- Returns "" (hidden) if the buffer is not a Mojo file.
--- @param opts Mojo-lang.LualineOpts|nil
--- @return string
local function _display(opts)
	if vim.bo.filetype ~= "mojo" then
		return ""
	end

	opts = vim.tbl_deep_extend("force", M.defaults, opts or {})

	local parts = { opts.icon or "Mojo" }

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

--- Return a color function for lualine.
--- @param opts Mojo-lang.LualineOpts
--- @return fun(): table|nil
local function _color(opts)
	return function()
		if opts.colored == false then
			return nil
		end
		return { fg = "#ff6f00" }
	end
end

--- Build a lualine component table.
--- @param opts Mojo-lang.LualineOpts
--- @return table
local function _component(opts)
	return {
		function()
			return _display(opts)
		end,
		color = _color(opts),
	}
end

--- Register the Mojo component into lualine's config.
--- @param opts Mojo-lang.LualineOpts|nil
--- @return boolean
function M.setup(opts)
	opts = vim.tbl_deep_extend("force", M.defaults, opts or {})

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
