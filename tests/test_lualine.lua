-- test_lualine.lua
-- Run: nvim --headless -c "luafile tests/test_lualine.lua" -c "qa!"

local total_errors = 0

local function fail(msg)
	print("  FAIL: " .. msg)
	total_errors = total_errors + 1
end

local function pass(msg)
	print("  PASS: " .. msg)
end

-- Setup config first
local config = require("mojo.config")
config.setup({
	statusline = {
		icon = "󰈸",
		show_env_name = true,
		show_sdk_version = true,
		show_lsp = true,
		show_dbg = true,
		show_fmt = true,
		show_diag = true,
		clickable = true,
		colored = true,
		color = "#ff9e64",
		icon_color = "#ff6f00",
	},
})

local lualine_adapter = require("mojo.adapters.lualine")

-- setup returns true (even without lualine installed)
print("--- setup ---")
local ok, result = pcall(lualine_adapter.setup, config.options.statusline)
if ok then
	pass("lualine adapter setup() succeeds")
else
	fail("lualine adapter setup() errored: " .. tostring(result))
end

-- Highlight groups are defined after setup
print("--- highlight groups ---")
local hl_groups = { "MojoIcon", "MojoText", "MojoSep", "MojoGood", "MojoNeutral", "MojoWarn", "MojoErr" }
for _, name in ipairs(hl_groups) do
	local id = vim.api.nvim_get_hl_id_by_name(name)
	if id and id ~= 0 then
		pass(string.format("highlight %s defined (id=%d)", name, id))
	else
		fail(string.format("highlight %s not defined", name))
	end
end

-- Verify highlight colors
local icon_hl = vim.api.nvim_get_hl(0, { name = "MojoIcon" })
if icon_hl and icon_hl.fg then
	pass(string.format("MojoIcon fg = #%06x", icon_hl.fg))
else
	fail("MojoIcon has no fg color")
end

-- Summary
print(string.rep("=", 60))
print(string.format("Total failures: %d", total_errors))
if total_errors > 0 then
	vim.cmd(string.format("cq %d", math.min(total_errors, 255)))
else
	vim.cmd("cq 0")
end
