# 🔥 mojo.nvim

Neovim integration for [Mojo](https://www.modular.com/mojo).

Centralizes filetype detection, Treesitter, LSP, formatting, and environment
activation — designed so each piece can be swapped when
[Modular](https://www.modular.com) ships official tooling.

## What it provides

- `.mojo` and `🔥` filetype detection
- Treesitter parser registration for Mojo
- Environment helpers for Pixi and virtualenv projects
- LSP and formatter integration (opt-in, via `nvim-lspconfig` / `conform.nvim`)
- Terminal environment auto-activation
- LazyVim adapter helpers
- EmmyLua type annotations (module: `Mojo-lang`)

## Features

### Filetype
`.mojo` and `🔥` files are automatically recognized as `mojo` filetype.

### Environment
Detects Pixi (`pixi.toml` / `.pixi/`) and virtualenv (`.venv/`) projects and
activates them for LSP, formatting, and terminal buffers transparently.

### Treesitter
Registers the Mojo parser with `nvim-treesitter`.

### LSP
Configures `mojo-lsp-server` via `nvim-lspconfig` with environment-aware binary
resolution (finds the binary in the active Pixi/venv environment).

### Format
Configures `mojo format` via `conform.nvim` with environment-aware binary resolution.

### Terminal
Auto-activates the project environment in new shell terminal buffers.

## Installation

<details open>
<summary><a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></summary>

```lua
{
  "Sarctiann/mojo.nvim",
  main = "mojo",
  opts = {},
}
```

</details>

<details>
<summary><a href="https://github.com/wbthomason/packer.nvim">packer.nvim</a></summary>

```lua
use {
  "Sarctiann/mojo.nvim",
  config = function()
    require("mojo").setup({})
  end,
}
```

</details>

<details>
<summary><a href="https://github.com/echasnovski/mini.deps">mini.deps</a></summary>

```lua
local add = MiniDeps.add

add({
  source = "Sarctiann/mojo.nvim",
  depends = {},
})

require("mojo").setup({})
```

</details>

<details>
<summary><a href="https://github.com/tpope/vim-plug">vim-plug</a></summary>

```vim
Plug 'Sarctiann/mojo.nvim'

lua << EOF
require("mojo").setup({})
EOF
```

</details>

<details>
<summary><a href="https://github.com/lumen-oss/rocks.nvim">rocks.nvim</a></summary>

Run `:Rocks install mojo.nvim` then add to your init.lua:

```lua
require("mojo").setup({})
```

</details>

## Setup

```lua
require("mojo").setup({
  debug = true,       -- writes mojo-debug.log to cwd
  lsp = { enabled = true },
  format = { enabled = true },
  treesitter = { enabled = true },
  terminal = { enabled = true },
})
```

**Note:** `opts` (lazy.nvim) and `setup()` accept the same config table.

## Integrations

<details open>
<summary>🔧 LSP (nvim-lspconfig)</summary>

```lua
require("mojo").setup({
  lsp = { enabled = true },
})
```

This registers `mojo-lsp-server` via `nvim-lspconfig` with environment-aware binary
resolution (finds the binary in the active Pixi/venv environment).

</details>

<details open>
<summary>🎨 Formatting (conform.nvim)</summary>

```lua
require("mojo").setup({
  format = { enabled = true },
})
```

This configures `mojo format` via `conform.nvim` with environment-aware binary resolution.

</details>

<details open>
<summary>🌳 Treesitter (nvim-treesitter)</summary>

```lua
require("mojo").setup({
  treesitter = { enabled = true },
})
```

This registers the Mojo parser with `nvim-treesitter`.

</details>

<details>
<summary>🚀 LazyVim</summary>

```lua
local mojo = require("mojo.adapters.lazyvim")

-- nvim-treesitter
{ "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts) return mojo.treesitter(opts) end,
}

-- nvim-lspconfig
{ "neovim/nvim-lspconfig",
  opts = function(_, opts) return mojo.lsp(opts) end,
}

-- conform.nvim
{ "stevearc/conform.nvim",
  opts = function(_, opts) return mojo.format(opts) end,
}
```

</details>

<details>
<summary>🔍 Linting (nvim-lint)</summary>

```lua
require("lint").linters_by_ft = {
  mojo = { "mojo" },
}
```

**Note:** Full adapter integration is tracked in TODO.md (P2 #13).
The `mojo-lint` adapter in `lua/mojo/adapters/nvim-lint.lua` will wrap `mojo format --check`
as a lint source when implemented.

</details>

<details>
<summary>✨ Autocompletion (nvim-cmp)</summary>

nvim-cmp works out of the box with LSP configured via this plugin. No additional
Mojo-specific cmp source is needed — `mojo-lsp-server` provides completion items
through the standard LSP protocol.

```lua
require("cmp").setup({
  sources = {
    { name = "nvim_lsp" },  -- Mojo LSP completions come through here
  },
})
```

</details>

<details>
<summary>✨ Autocompletion (blink.cmp)</summary>

blink.cmp works out of the box with LSP configured via this plugin.

```lua
require("blink.cmp").setup({
  sources = {
    default = { "lsp" },
  },
})
```

</details>

<details>
<summary>📋 Snippets (LuaSnip)</summary>

Place Mojo snippets in `~/.config/nvim/snippets/mojo.lua` or use a snippet
collection like `friendly-snippets` (which includes Python snippets that overlap
with Mojo syntax).

```lua
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
```

</details>

<details>
<summary>🐛 Debugging (nvim-dap)</summary>

**Note:** Mojo debugging support depends on Modular shipping a DAP adapter.
When available, an adapter in `lua/mojo/adapters/nvim-dap.lua` will register it.
This section will be updated with configuration examples at that point.

For now, if you have a compatible debugger, configure it manually:

```lua
require("dap").adapters.mojo = {
  type = "executable",
  command = "mojo",
  args = { "debug" },
}
```

</details>

<details>
<summary>🧪 Testing (neotest)</summary>

**Note:** A neotest adapter for Mojo (`lua/mojo/adapters/neotest.lua`) will be
implemented when a standard Mojo test runner interface is established. This
section will be updated with configuration examples at that point.

For now, run tests directly:

```bash
mojo test
```

</details>

<details>
<summary>🔭 telescope.nvim</summary>

telescope works with Mojo files out of the box. No additional configuration needed.

```lua
require("telescope").setup({})
```

Mojo files are picked up by default pickers (`find_files`, `live_grep`, etc.).

</details>

<details>
<summary>⌨️ which-key.nvim</summary>

If you define Mojo-specific keymaps, which-key will discover them automatically.

```lua
require("which-key").add({
  { "<leader>m", group = "Mojo" },
  { "<leader>mr", "<cmd>MojoRun<CR>", desc = "Run Mojo file" },
  { "<leader>mt", "<cmd>MojoTest<CR>", desc = "Run Mojo tests" },
})
```

</details>

<details>
<summary>⚠️ trouble.nvim</summary>

trouble.nvim works with LSP diagnostics, which mojo-lsp-server provides
automatically. No additional Mojo-specific configuration needed.

```lua
require("trouble").setup({})
```

</details>

<details>
<summary>📊 lualine.nvim</summary>

Show the active Mojo environment in your statusline:

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      {
        function()
          local env = require("mojo.env").detect()
          if env and env.type == "pixi" then return " " end
          if env and env.type == "venv" then return " " end
          return ""
        end,
      },
    },
  },
})
```

</details>

<details>
<summary>🪐 AstroNvim</summary>

In `~/.config/nvim/lua/community.lua` or your user config:

```lua
return {
  "Sarctiann/mojo.nvim",
  opts = {
    lsp = { enabled = true },
    format = { enabled = true },
    treesitter = { enabled = true },
  },
}
```

</details>

<details>
<summary>⚡ NvChad</summary>

In `~/.config/nvim/lua/custom/plugins.lua`:

```lua
return {
  {
    "Sarctiann/mojo.nvim",
    config = function()
      require("mojo").setup({
        lsp = { enabled = true },
        format = { enabled = true },
        treesitter = { enabled = true },
      })
    end,
  },
}
```

</details>

<details>
<summary>🏁 kickstart.nvim</summary>

In your `init.lua`, add mojo.nvim to the plugins table:

```lua
{
  "Sarctiann/mojo.nvim",
  main = "mojo",
  opts = {
    lsp = { enabled = true },
    format = { enabled = true },
    treesitter = { enabled = true },
  },
},
```

</details>

## Configuration

All options and their defaults:

```lua
{
  filetype = { enabled = true },
  terminal = {
    enabled = true,
    auto_activate = true,
    delay_ms = 200,
  },
  treesitter = {
    enabled = true,
    parser = {
      install_info = {
        url = "https://github.com/oaustegard/tree-sitter-mojo",
        revision = "v1.0",
        queries = "queries",
      },
      filetype = "mojo",
      tier = 2,
    },
  },
  lsp = {
    enabled = false,
    root_markers = { "pixi.toml", "pyproject.toml", ".pixi", ".venv" },
  },
  format = {
    enabled = false,
    formatter_name = "mojo",
  },
  debug = false,
  hooks = {},
}
```

## Notes

- The plugin does not ship the Mojo LSP binary or official toolchain.
- When `debug = true`, logs are written to `mojo-debug.log` in the current working directory.
- The plugin auto-activates Pixi or venv project environments before Mojo LSP startup and in terminal buffers.
- Treesitter is isolated behind `lua/mojo/treesitter.lua` so the parser backend can be replaced later.
