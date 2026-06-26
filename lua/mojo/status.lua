local env = require("mojo.env")
local config = require("mojo.config")

local M = {}

--- Component for non-lualine statuslines.
--- Returns a string like "🔥 pixi 24.4.0" or empty if not a Mojo file.
--- @return string
function M.MojoVersion()
	if vim.bo.filetype ~= "mojo" then
		return ""
	end

	local opts = config.options.statusline or {}
	local parts = { opts.icon or "󰈸" }

	if opts.show_env_name ~= false then
		local detected = env.detect()
		if detected then
			local env_label = detected.type
			if detected.env_name and detected.env_name ~= "default" then
				env_label = string.format("%s %s", detected.type, detected.env_name)
			end
			table.insert(parts, env_label)
		end
	end

	if opts.show_sdk_version ~= false then
		local version = env.get_version()
		if version then
			table.insert(parts, version)
		end
	end

	return table.concat(parts, " ")
end

return M
