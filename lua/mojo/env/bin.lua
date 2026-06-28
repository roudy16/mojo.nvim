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

local function first_dap_in(dir)
	local real = vim.fs.joinpath(dir, "_mojo-lldb-dap")
	if util.has_file(real) then
		return real
	end
	local wrapper = vim.fs.joinpath(dir, "mojo-lldb-dap")
	if util.has_file(wrapper) then
		return wrapper
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
		local bin = util.find_pixi_binary(env.root, "_mojo-lldb-dap")
		if not bin then
			bin = util.find_pixi_binary(env.root, "mojo-lldb-dap")
		end
		if bin then
			log.log("dap_cmd", function()
				return { path = path or vim.fn.getcwd(), cmd = bin, source = "pixi_envs" }
			end)
			return { bin }, env.env_dir
		end
	end

	if vim.fn.executable("_mojo-lldb-dap") == 1 then
		log.log("dap_cmd", function()
			return { path = path or vim.fn.getcwd(), cmd = "_mojo-lldb-dap", source = "path" }
		end)
		return { "_mojo-lldb-dap" }, nil
	end

	if vim.fn.executable("mojo-lldb-dap") == 1 then
		log.log("dap_cmd", function()
			return { path = path or vim.fn.getcwd(), cmd = "mojo-lldb-dap", source = "path" }
		end)
		return { "mojo-lldb-dap" }, nil
	end

	log.log("dap_cmd_miss", function()
		return { path = path or vim.fn.getcwd() }
	end)
	return nil, nil
end

return M
