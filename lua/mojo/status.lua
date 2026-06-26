local env = require("mojo.env")
local config = require("mojo.config")
local log = require("mojo.log")

local M = {}

--- @type boolean
local lsp_has_crashed = false

function M._track_lsp_exit(code, signal)
	if code ~= 0 or (signal and signal ~= 0) then
		lsp_has_crashed = true
		log.log("lsp_crashed", function()
			return { code = code, signal = signal }
		end)
	end
end

function M._reset_lsp_crash()
	lsp_has_crashed = false
end

--- @return "running"|"stopped"|"crashed"|"unavailable"
function M.lsp_status()
	local clients = vim.lsp.get_active_clients({ bufnr = vim.fn.bufnr() })
	for _, client in ipairs(clients) do
		if client.name == "mojo" then
			return "running"
		end
	end
	if lsp_has_crashed then
		return "crashed"
	end
	return env.get_lsp_cmd() and "stopped" or "unavailable"
end

--- @return "active"|"inactive"|"unavailable"
function M.dbg_status()
	local lsp_ok = env.get_dap_cmd() ~= nil
	if not lsp_ok then
		return "unavailable"
	end
	local ok, dap = pcall(require, "dap")
	if ok and dap.session and dap.session() then
		return "active"
	end
	return "inactive"
end

--- @return "available"|"unavailable"
function M.fmt_status()
	return env.get_mojo_cmd() and "available" or "unavailable"
end

--- @param state string
--- @return string
function M.status_icon(state)
	if state == "running" or state == "active" or state == "available" then
		return "󰄬"
	elseif state == "stopped" or state == "inactive" then
		return "○"
	end
	return "󰅖"
end

--- @param state string
--- @return string|nil
function M.status_color(state)
	if state == "running" or state == "active" or state == "available" then
		return "#a6da95"
	elseif state == "stopped" or state == "inactive" then
		return nil
	end
	return "#ed8796"
end

--- @return integer, integer
local function diag_counts()
	local items = vim.diagnostic.get(vim.fn.bufnr())
	local errors = 0
	local warnings = 0
	for _, item in ipairs(items) do
		if item.severity == 1 then
			errors = errors + 1
		elseif item.severity == 2 then
			warnings = warnings + 1
		end
	end
	return errors, warnings
end

--- @return string|nil
function M.diag_text()
	local errors, warnings = diag_counts()
	if errors == 0 and warnings == 0 then
		return nil
	end
	local parts = {}
	if errors > 0 then
		table.insert(parts, "󰅙" .. errors)
	end
	if warnings > 0 then
		table.insert(parts, "⚠" .. warnings)
	end
	return table.concat(parts, " ")
end

--- @return string|nil
function M.diag_color()
	local errors = diag_counts()
	if errors > 0 then
		return "#ed8796"
	end
	return "#ff9e64"
end

--- Single-string display for non-lualine statuslines.
--- @return string
function M.display()
	if vim.bo.filetype ~= "mojo" then
		return ""
	end

	local opts = config.options.statusline or {}
	local parts = { opts.icon or "🔥" }

	local env_text = {}
	if opts.show_env_name ~= false then
		local detected = env.detect()
		if detected then
			local env_label = detected.type
			if detected.env_name and detected.env_name ~= "default" then
				env_label = string.format("%s %s", detected.type, detected.env_name)
			end
			table.insert(env_text, env_label)
		end
	end

	if opts.show_sdk_version ~= false then
		local version = env.get_version()
		if version then
			table.insert(env_text, version)
		end
	end

	if #env_text > 0 then
		table.insert(parts, table.concat(env_text, " "))
	end

	local status_parts = {}

	if opts.show_lsp ~= false then
		table.insert(status_parts, M.status_icon(M.lsp_status()) .. " lsp")
	end

	if opts.show_fmt ~= false then
		table.insert(status_parts, M.status_icon(M.fmt_status()) .. " fmt")
	end

	if opts.show_dbg ~= false then
		table.insert(status_parts, M.status_icon(M.dbg_status()) .. " dbg")
	end

	if opts.show_diag ~= false then
		local diag = M.diag_text()
		if diag then
			table.insert(status_parts, diag)
		end
	end

	if #status_parts > 0 then
		table.insert(parts, "· " .. table.concat(status_parts, " · "))
	end

	return table.concat(parts, " ")
end

M.actions = {
	["Restart LSP"] = function()
		M._reset_lsp_crash()
		local clients = vim.lsp.get_active_clients({ name = "mojo" })
		for _, client in ipairs(clients) do
			client.stop()
		end
		vim.schedule(function()
			vim.cmd("edit")
		end)
	end,
	["Stop LSP"] = function()
		local clients = vim.lsp.get_active_clients({ name = "mojo" })
		for _, client in ipairs(clients) do
			client.stop()
		end
	end,
	["Refresh SDK"] = function()
		local cache = require("mojo.env.detect")._cache()
		for k in pairs(cache) do
			cache[k] = nil
		end
		M._reset_lsp_crash()
		require("mojo.env.version").clear_cache()
	end,
}

--- Show action menu on click.
function M.show_menu()
	local items = vim.tbl_keys(M.actions)
	table.sort(items)
	vim.ui.select(items, {
		prompt = "Mojo actions:",
	}, function(choice)
		if choice then
			M.actions[choice]()
		end
	end)
	vim.schedule(function()
		vim.cmd("startinsert!")
	end)
end

return M
