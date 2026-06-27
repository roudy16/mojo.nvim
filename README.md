# 🔥 mojo.nvim

Neovim integration for [Mojo](https://www.modular.com/mojo).

Centralizes filetype detection, Treesitter, LSP, formatting, and environment activation—designed so each piece can be swapped when [Modular](https://www.modular.com) ships official tooling.

![mojo.nvim demo](docs/demo.gif)

## Index

- [What it provides](#what-it-provides)
- [Features](#features)
  - [Filetype](#filetype)
  - [Environment](#environment)
  - [Treesitter](#treesitter)
  - [LSP](#lsp)
  - [Format](#format)
  - [Terminal](#terminal)
  - [Indentation](#indentation)
- [Statusline](#statusline)
- [Installation](#installation)
- [Setup](#setup)
- [Configuration](#configuration)
- [Integrations](#integrations)
- [Notes](#notes)
  - [Tools that work without config](#tools-that-work-without-mojo-specific-config)

## What it provides

- `.mojo` and `🔥` filetype detection
- Treesitter parser registration for Mojo
- Environment helpers for Pixi, virtualenv, and manual SDK paths
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

`.mojo` and `🔥` files are automatically recognized as `mojo` filetype. The plugin adds these to Neovim's filetype detection and triggers environment activation for each Mojo buffer.

### Environment

Detects Pixi (`pixi.toml` / `.pixi/`) and virtualenv (`.venv/`) projects and activates them for LSP, formatting, and terminal buffers transparently. Also supports manual SDK path override via `config.sdk_path` or the `$MOJO_SDK_PATH` environment variable.

### Treesitter

Registers the self-hosted Mojo parser grammar with `nvim-treesitter`. The grammar files live in `tree-sitter/mojo/` — no external parser repo required. Automatically checks for grammar updates and recompiles when needed, with a `:MojoRebuildParser` command for manual rebuilds.

### LSP

Configures `mojo-lsp-server` via `nvim-lspconfig` with environment-aware binary resolution (finds the binary in the active Pixi/venv environment). Supports custom root markers for project detection.

### Format

Configures `mojo format` via `conform.nvim` with environment-aware binary resolution. Provides consistent formatting across the editor.

### Terminal

Auto-activates the project environment in new shell terminal buffers. Detects shell terminals and applies the correct activation command before they start.

### Indentation

Sets 4-space indentation for Mojo files (matching Python-style conventions) via `ftplugin/mojo.lua`.

## Statusline

The statusline provides comprehensive Mojo environment and tooling status with easy visibility and control.

**Default display:** `🔥 pixi 24.4.0 · lsp · fmt · dbg · e3 w2`

**Icons (Nerd Font required for check/cross symbols):**

**Features:**

- Environment type and name display (Pixi/dev, venv, manual)
- SDK version from `mojo --version`
- LSP status tracking (running/stopped/crashed) with auto-restart capability
- Debugger status (active/inactive/unavailable)
- Formatter availability status
- Diagnostic counts (errors and warnings)

**Clickability:** The entire statusline block is clickable and opens a menu with Mojo actions:

- Restart LSP server
- Stop LSP server
- Refresh SDK detection

**Customization:** Each indicator can be individually controlled via the `statusline` configuration options:

- `show_lsp`, `show_dbg`, `show_fmt`, `show_diag` (defaults: true)
- `show_env_name`, `show_sdk_version` (defaults: true)
- `clickable` (default: true)
- Colors and icon colors customizable via `color` and `icon_color` options

For non-lualine statuslines, use `require("mojo.status").display()`.

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
  sdk_path = nil, -- or "/path/to/mojo/sdk"
  statusline = {
    enabled = true,
    icon = "🔥",
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
  dap = {
    enabled = false,
  },
  debug = false,
  hooks = {},
}
```

</details>

## Integrations

- LSP (nvim-lspconfig)
- Formatting (conform.nvim)
- Treesitter (nvim-treesitter)
- Completion (nvim-cmp / blink.cmp)
- Debugging (nvim-dap)
- Statusline (lualine.nvim)
- LazyVim
- AstroNvim / NvChad / kickstart.nvim

## Notes

- The plugin does not ship the Mojo LSP binary or official toolchain
- Debugging is opt-in
- When `debug = true`, logs are written to `mojo-debug.log` in the current working directory
- The plugin auto-activates Pixi or venv project environments before Mojo LSP startup and in terminal buffers
- Treesitter is isolated behind `lua/mojo/treesitter.lua`. The parser grammar is self-hosted in `tree-sitter/mojo/`. The plugin auto-rebuilds the parser when the grammar source changes; `:MojoRebuildParser` is available for manual rebuilds
- Mojo files use 4-space indentation (configured via `ftplugin/mojo.lua`)

### Tools that work without Mojo-specific config

- telescope.nvim — picks up `.mojo`/`.🔥` files in standard pickers
- trouble.nvim — displays diagnostics from `mojo-lsp-server` automatically
- nvim-cmp / blink.cmp — receives LSP completions from `mojo-lsp-server` via the `nvim_lsp` source
- which-key.nvim — discovers any Mojo-related keymaps you define

Adapter-based integration for other tools is tracked in `docs/TODO.md`.
