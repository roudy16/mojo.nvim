local detect = require("mojo.env.detect")
local util = require("mojo.env.util")
local log = require("mojo.log")

local M = {}

--- @param path string|nil
--- @return string|nil
function M.get_mojo_cmd(path)
	local env = detect.detect(path)
	if env and env.bin_dir then
		local bin = vim.fs.joinpath(env.bin_dir, "mojo")
		if util.has_file(bin) then
			return bin
		end
	end

	if env and env.type == "pixi" then
		local bin = util.find_pixi_binary(env.root, "mojo")
		if bin then
			return bin
		end
	end

	return vim.fn.executable("mojo") == 1 and "mojo" or nil
end

--- @param path string|nil
--- @return string[]|nil
function M.get_lsp_cmd(path)
	local env = detect.detect(path)
	if env and env.bin_dir then
		local bin = vim.fs.joinpath(env.bin_dir, "mojo-lsp-server")
		if util.has_file(bin) then
			log.log("lsp_cmd", function()
				return { path = path or vim.fn.getcwd(), cmd = bin, source = "bin_dir" }
			end)
			return { bin }
		end
	end

	if env and env.type == "pixi" then
		local bin = util.find_pixi_binary(env.root, "mojo-lsp-server")
		if bin then
			log.log("lsp_cmd", function()
				return { path = path or vim.fn.getcwd(), cmd = bin, source = "pixi_envs" }
			end)
			return { bin }
		end
	end

	if vim.fn.executable("mojo-lsp-server") == 1 then
		log.log("lsp_cmd", function()
			return { path = path or vim.fn.getcwd(), cmd = "mojo-lsp-server", source = "path" }
		end)
		return { "mojo-lsp-server" }
	end

	log.log("lsp_cmd_miss", function()
		return { path = path or vim.fn.getcwd() }
	end)
	return nil
end

local DAP_NAMES = { "_mojo-lldb-dap", "mojo-lldb-dap", "mojo-lldb" }

local function first_dap_in(dir)
	for _, name in ipairs(DAP_NAMES) do
		local bin = vim.fs.joinpath(dir, name)
		if util.has_file(bin) then
			return bin
		end
	end
	return nil
end

--- @param path string|nil
--- @return string[]|nil, string|nil
function M.get_dap_cmd(path)
	local env = detect.detect(path)
	if env and env.bin_dir then
		local bin = first_dap_in(env.bin_dir)
		if bin then
			log.log("dap_cmd", function()
				return { path = path or vim.fn.getcwd(), cmd = bin, source = "bin_dir" }
			end)
			return { bin }, env.env_dir
		end
	end

	if env and env.type == "pixi" then
		for _, name in ipairs(DAP_NAMES) do
			local bin = util.find_pixi_binary(env.root, name)
			if bin then
				log.log("dap_cmd", function()
					return { path = path or vim.fn.getcwd(), cmd = bin, source = "pixi_envs" }
				end)
				return { bin }, env.env_dir
			end
		end
	end

	for _, name in ipairs(DAP_NAMES) do
		if vim.fn.executable(name) == 1 then
			log.log("dap_cmd", function()
				return { path = path or vim.fn.getcwd(), cmd = name, source = "path" }
			end)
			return { name }, nil
		end
	end

	log.log("dap_cmd_miss", function()
		return { path = path or vim.fn.getcwd() }
	end)
	return nil, nil
end

return M
