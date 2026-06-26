local status = require("mojo.status")

local M = {}

--- Register the Mojo component into lualine's config.
--- @param opts Mojo-lang.StatuslineConfig
--- @return boolean
function M.setup(opts)
	opts = opts or {}

	local component = {
		function()
			return status.display()
		end,
		color = function()
			if opts.colored == false then
				return nil
			end
			return { fg = opts.color or "#ff9e64" }
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
