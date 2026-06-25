# nvim-dap Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable debugging of Mojo `.mojo` files via nvim-dap + `mojo-lldb-dap`.

**Architecture:** Rename `debug.lua` → `log.lua` to free namespace, add `get_dap_cmd` to env/bin.lua, create `adapters/dap.lua` that registers the DAP adapter + launch configs, wire into init.lua behind opt-in config.

**Tech Stack:** nvim-dap (optional, pcall-guarded), mojo-lldb-dap (shipped in Mojo SDK)

---

### Task 1: Rename debug.lua → log.lua

**Files:**
- Rename: `lua/mojo/debug.lua` → `lua/mojo/log.lua`
- Modify: `lua/mojo/init.lua`
- Modify: `lua/mojo/lsp.lua`
- Modify: `lua/mojo/env/detect.lua`
- Modify: `lua/mojo/env/bin.lua`
- Modify: `lua/mojo/env/activate.lua`

- [ ] **Step 1: Create log.lua from debug.lua**

Content is identical — copy `lua/mojo/debug.lua` to `lua/mojo/log.lua` as-is.

- [ ] **Step 2: Update all consumers to require("mojo.log")**

In each file, replace `require("mojo.debug")` with `require("mojo.log")`:

| File | Line | Change |
|------|------|--------|
| `lua/mojo/init.lua:3` | `local debug = require("mojo.debug")` | `local log = require("mojo.log")` |
| `lua/mojo/lsp.lua:2` | `local debug = require("mojo.debug")` | `local log = require("mojo.log")` |
| `lua/mojo/env/detect.lua:2` | `local debug = require("mojo.debug")` | `local log = require("mojo.log")` |
| `lua/mojo/env/bin.lua:3` | `local debug = require("mojo.debug")` | `local log = require("mojo.log")` |
| `lua/mojo/env/activate.lua:3` | `local debug = require("mojo.debug")` | `local log = require("mojo.log")` |

- [ ] **Step 3: Update references from `debug.log` to `log.log`**

Same 5 files — rename all `debug.log(` → `log.log(`, `debug.setup(` → `log.setup(`.

In `init.lua`, also update:
```diff
- local debug = require("mojo.log")
+ local log = require("mojo.log")
...
- M.debug = debug
+ M.log = log
...
- log.setup({ debug = opts.debug })
+ log.setup({ debug = opts.debug })
```

- [ ] **Step 4: Delete old debug.lua**

```bash
rm lua/mojo/debug.lua
```

- [ ] **Step 5: Verify no stale references**

```bash
rg 'require\("mojo\.debug"\)' lua/
```
Expected: no matches

- [ ] **Step 6: Commit**

```bash
git add -A && git commit -m "refactor: rename debug.lua → log.lua"
```

---

### Task 2: Add get_dap_cmd to env/bin.lua

**Files:**
- Modify: `lua/mojo/env/bin.lua`

- [ ] **Step 1: Add get_dap_cmd after get_lsp_cmd**

Add to `lua/mojo/env/bin.lua` after line 63 (`end` of `get_lsp_cmd`):

```lua
--- @param path string|nil
--- @return string[]|nil, string|nil
function M.get_dap_cmd(path)
	local env = detect.detect(path)
	if env and env.bin_dir then
		local bin = vim.fs.joinpath(env.bin_dir, "mojo-lldb-dap")
		if util.has_file(bin) then
			log.log("dap_cmd", function()
				return { path = path or vim.fn.getcwd(), cmd = bin, source = "bin_dir" }
			end)
			return { bin }, env.env_dir
		end
	end

	if env and env.type == "pixi" then
		local bin = util.find_pixi_binary(env.root, "mojo-lldb-dap")
		if bin then
			log.log("dap_cmd", function()
				return { path = path or vim.fn.getcwd(), cmd = bin, source = "pixi_envs" }
			end)
			return { bin }, env.env_dir
		end
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
```

Note: Returns `cmd, env_dir`. The `env_dir` is needed so the caller can set `CONDA_PREFIX` for the `mojo-lldb-dap` shell wrapper to find `_mojo-lldb-dap` and the visualizers. When found via PATH, `env_dir` is nil and `CONDA_PREFIX` must come from the already-activated environment.

- [ ] **Step 2: Verify**

```bash
rg 'function M\.' lua/mojo/env/bin.lua
```
Expected: `get_mojo_cmd`, `get_lsp_cmd`, `get_dap_cmd`

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat: add get_dap_cmd to env/bin.lua"
```

---

### Task 3: Export get_dap_cmd from env/init.lua

**Files:**
- Modify: `lua/mojo/env/init.lua`

- [ ] **Step 1: Add get_dap_cmd to the public API**

```diff
 M.get_mojo_cmd = bin.get_mojo_cmd
 M.get_lsp_cmd = bin.get_lsp_cmd
+M.get_dap_cmd = bin.get_dap_cmd
```

- [ ] **Step 2: Commit**

```bash
git add -A && git commit -m "feat: export get_dap_cmd from env module"
```

---

### Task 4: Add DapConfig class + defaults to config.lua

**Files:**
- Modify: `lua/mojo/config.lua`

- [ ] **Step 1: Add DapConfig class annotation after StatuslineConfig**

```lua
--- @class Mojo-lang.DapConfig
--- @field enabled boolean|nil
--- @field adapter (fun(opts: Mojo-lang.DapConfig): boolean)|nil
```

- [ ] **Step 2: Add `dap` field to Mojo-lang.Config**

```diff
 --- @class Mojo-lang.Config
 --- @field filetype Mojo-lang.FiletypeConfig|nil
 ...
 --- @field statusline Mojo-lang.StatuslineConfig|nil
+--- @field dap Mojo-lang.DapConfig|nil
 --- @field debug boolean|nil
```

- [ ] **Step 3: Add dap defaults**

```diff
 M.defaults = {
 	...
 	statusline = { ... },
+	dap = {
+		enabled = false,
+	},
 	debug = false,
```

Note: `dap.enabled = false` makes it opt-in, since most users won't have nvim-dap installed.

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "feat: add DapConfig to config.lua"
```

---

### Task 5: Create adapters/dap.lua

**Files:**
- Create: `lua/mojo/adapters/dap.lua`

- [ ] **Step 1: Write the adapter module**

```lua
local env = require("mojo.env")

local M = {}

--- @param opts Mojo-lang.DapConfig|nil
--- @return boolean
function M.setup(opts)
	if not opts or opts.enabled ~= true then
		return false
	end

	local ok, dap = pcall(require, "dap")
	if not ok then
		return false
	end

	dap.adapters.mojo = {
		type = "executable",
		command = function()
			local cmd, _ = env.get_dap_cmd()
			return (cmd and cmd[1]) or "mojo-lldb-dap"
		end,
		options = {
			env = function()
				local _, env_dir = env.get_dap_cmd()
				if env_dir then
					return { CONDA_PREFIX = env_dir }
				end
				return {}
			end,
		},
	}

	dap.configurations.mojo = {
		{
			type = "mojo",
			request = "launch",
			name = "Debug Mojo File",
			mojoFile = "${file}",
			cwd = "${workspaceFolder}",
		},
		{
			type = "mojo",
			request = "launch",
			name = "Debug Mojo File (with args)",
			mojoFile = "${file}",
			args = function()
				local args_str = vim.fn.input("Program args: ")
				return vim.split(args_str, "%s+")
			end,
			cwd = "${workspaceFolder}",
		},
		{
			type = "mojo",
			request = "launch",
			name = "Debug Binary",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
		},
		{
			type = "mojo",
			request = "attach",
			name = "Attach to Process",
			pid = require("dap.utils").pick_process,
		},
	}

	return true
end

return M
```

**Key design decisions:**
- `command` is a function (lazy eval) so we get the current buffer's env, not the setup-time env
- `adapter` passes `CONDA_PREFIX` so `mojo-lldb-dap` wrapper can find `_mojo-lldb-dap` and the visualizers
- `env_dir` is the pixi/venv root (e.g., `.pixi/envs/default`) — this is what `mojo-lldb-dap` expects as `$CONDA_PREFIX`
- Debugging `.mojo` uses `mojoFile` (DAP server compiles internally via `mojo build`)
- `dap.utils.pick_process` provides the process picker UI

- [ ] **Step 2: Commit**

```bash
git add -A && git commit -m "feat: create adapters/dap.lua with launch configs"
```

---

### Task 6: Wire dap in init.lua

**Files:**
- Modify: `lua/mojo/init.lua`

- [ ] **Step 1: Add dap setup block after statusline**

```diff
 	if opts.terminal and opts.terminal.enabled ~= false then
 		require("mojo.terminal").setup(opts.terminal)
 	end

+	if opts.dap and opts.dap.enabled then
+		local dap_opts = opts.dap
+		if dap_opts and dap_opts.adapter then
+			dap_opts.adapter(dap_opts)
+		else
+			require("mojo.adapters.dap").setup(dap_opts)
+		end
+	end
+
 	return opts
```

Use `opts.dap and opts.dap.enabled` (truthy check, not `~= false`) to ensure dap is opt-in. The adapter pattern mirrors completion:

```lua
-- completion pattern (existing):
if opts.completion and opts.completion.enabled then
    local cmp_opts = opts.completion
    if cmp_opts and cmp_opts.adapter then
        cmp_opts.adapter(cmp_opts)
    elseif not require("mojo.adapters.blink").setup(cmp_opts) then
        require("mojo.adapters.nvim-cmp").setup(cmp_opts)
    end
end
```

- [ ] **Step 2: Add dap to setup log**

```diff
 	log.log("setup", function()
 		return {
 			debug = opts.debug or false,
 			...
 			terminal = opts.terminal and opts.terminal.enabled ~= false,
+			dap = opts.dap and opts.dap.enabled == true,
 		}
 	end)
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat: wire dap adapter in init.lua"
```

---

### Task 7: Add nvim-dap section to README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add dap section after completion section**

Add after the "✨ Completion" details block (~line 225):

````markdown
<details>
<summary>🐛 Debugging (nvim-dap)</summary>

Opt-in. Debug `.mojo` files via nvim-dap and the official `mojo-lldb-dap` DAP server (shipped in the Mojo SDK).

Requires [nvim-dap](https://github.com/mfussenegger/nvim-dap):

```lua
require("mojo").setup({
  dap = { enabled = true },
})
```

Provides four launch configurations:
- **Debug Mojo File** — compiles and debugs the current `.mojo` file (uses `mojoFile`)
- **Debug Mojo File (with args)** — same, with prompts for program arguments
- **Debug Binary** — debug a pre-compiled binary
- **Attach to Process** — attach by PID

Default keybindings (via nvim-dap):
- `<F5>` — start/continue debugging
- `<F10>` — step over
- `<F11>` — step into
- `<F12>` — step out
- `<leader>db` — toggle breakpoint

</details>
````

- [ ] **Step 2: Update "What it provides" section**

Add debugging to the list:

```diff
 - Completion support (nvim-cmp / blink.cmp) with keywords, builtins, types, and snippets
 - lualine.nvim statusline integration
+- Debugging support via nvim-dap + mojo-lldb-dap
 - 4-space indentation for Mojo files
```

- [ ] **Step 3: Update "Notes" to mention debugger**

```diff
 - The plugin does not ship the Mojo LSP binary or official toolchain.
+- The plugin does not ship nvim-dap; debugging is opt-in via `dap.enabled = true`.
```

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "docs: add nvim-dap setup section to README"
```
