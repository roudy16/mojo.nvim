# 🔥 mojo.nvim

Neovim integration for [Mojo](https://www.modular.com/mojo).

Centralizes filetype detection, Treesitter, LSP, formatting, and environment
activation — designed so each piece can be swapped when
[Modular](https://www.modular.com) ships official tooling.

## What it provides

- `.mojo` and `🔥` filetype detection
- Treesitter parser registration for Mojo
- Environment helpers for Pixi and virtualenv projects
- LSP and formatter integration (via `nvim-lspconfig` / `conform.nvim`)
- Terminal environment auto-activation
- Completion support (nvim-cmp / blink.cmp) with keywords, builtins, types, and snippets
- lualine.nvim statusline integration with SDK version display
- `MojoVersion` component for non-lualine statuslines
- Debugging support via nvim-dap + mojo-lldb-dap
- 4-space indentation for Mojo files
- LazyVim, AstroNvim, NvChad, and kickstart.nvim adapter helpers
- EmmyLua type annotations (module: `Mojo-lang`)

## Features

### Filetype

`.mojo` and `🔥` files are automatically recognized as `mojo` filetype.

### Environment

Detects Pixi (`pixi.toml` / `.pixi/`) and virtualenv (`.venv/`) projects and
activates them for LSP, formatting, and terminal buffers transparently.

### Treesitter

Registers the self-hosted Mojo parser grammar with `nvim-treesitter`.
The grammar files live in `tree-sitter/mojo/` — no external parser repo required.

When a `.mojo` file is opened, the plugin checks if the grammar source (`grammar.js`)
is newer than the compiled parser (`mojo.so`). If so, it automatically recompiles
and reloads. Use `:MojoRebuildParser` to rebuild manually.

### LSP

Configures `mojo-lsp-server` via `nvim-lspconfig` with environment-aware binary
resolution (finds the binary in the active Pixi/venv environment).

### Format

Configures `mojo format` via `conform.nvim` with environment-aware binary resolution.

### Terminal

Auto-activates the project environment in new shell terminal buffers.

### Indentation

Sets 4-space indentation for Mojo files (matching Python-style conventions).

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
  debug = true, -- writes mojo-debug.log to cwd
})
```

All features are enabled by default. Pass `enabled = false` to disable any feature.

**Note:** `opts` (lazy.nvim) and `setup()` accept the same config table.

## Integrations

Enabled by default unless noted. Disable any feature with `{ enabled = false }`.

- **LSP (nvim-lspconfig)** — `mojo-lsp-server` with env-aware binary resolution.
- **Formatting (conform.nvim)** — `mojo format` with env-aware binary resolution.
- **Treesitter (nvim-treesitter)** — Self-hosted Mojo parser grammar, auto-rebuilds on change.
- **Completion (nvim-cmp / blink.cmp)** — Auto-detects engine. Provides 56 keywords, 42 builtins, 34 types, 13 snippets. Use `completion.adapter` to force a specific engine.
- **Debugging (nvim-dap)** — Opt-in (`dap.enabled = true`). Launches `mojo-lldb-dap` with four configs: debug current file, debug with args, debug binary, attach to process.
- **Statusline (lualine.nvim)** — Shows `🔥 env version` with separate colors for icon and text. Customize via `statusline` config. For non-lualine statuslines, use `require("mojo.status").MojoVersion()`.
- **LazyVim** — Use `require("mojo.adapters.lazyvim")` helpers in your plugin specs.
- **AstroNvim / NvChad / kickstart.nvim** — Just add `{ "Sarctiann/mojo.nvim" }` to your plugins.

## Configuration

<details>
<summary>All options and their defaults</summary>

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
  },
  lsp = {
    enabled = true,
    root_markers = { "pixi.toml", "pyproject.toml", ".pixi", ".venv" },
  },
  format = {
    enabled = true,
    formatter_name = "mojo",
  },
  completion = {
    enabled = true,
  },
  statusline = {
    enabled = true,
    icon = "🔥",
    show_env_name = true,
    show_sdk_version = true,
    colored = true,
    color = "#d97706",
    icon_color = "#ff6f00",
  },
  debug = false,
  hooks = {},
}
```

</details>

## Notes

- The plugin does not ship the Mojo LSP binary or official toolchain.
- The plugin does not ship nvim-dap; debugging is opt-in via `dap.enabled = true`.
- When `debug = true`, logs are written to `mojo-debug.log` in the current working directory.
- The plugin auto-activates Pixi or venv project environments before Mojo LSP startup and in terminal buffers.
- Treesitter is isolated behind `lua/mojo/treesitter.lua`. The parser grammar is self-hosted in `tree-sitter/mojo/`. The plugin auto-rebuilds the parser when the grammar source changes; `:MojoRebuildParser` is available for manual rebuilds.
- Mojo files use 4-space indentation (configured via `ftplugin/mojo.lua`).

### Tools that work without Mojo-specific config

These tools work with Mojo files through standard Neovim protocols — no adapter or
Mojo-specific configuration is required:

- **telescope.nvim** — picks up `.mojo`/`.🔥` files in standard pickers
- **trouble.nvim** — displays diagnostics from `mojo-lsp-server` automatically
- **nvim-cmp / blink.cmp** — receives LSP completions from `mojo-lsp-server` via the `nvim_lsp` source
- **which-key.nvim** — discovers any Mojo-related keymaps you define

Adapter-based integration for other tools is tracked in `docs/TODO.md`.
