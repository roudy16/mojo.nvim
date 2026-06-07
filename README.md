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
- lualine.nvim statusline integration
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

<details>
<summary>🔧 LSP (nvim-lspconfig)</summary>

Enabled by default. Configures `mojo-lsp-server` via `nvim-lspconfig` with
environment-aware binary resolution (finds the binary in the active Pixi/venv environment).

To disable:

```lua
require("mojo").setup({
  lsp = { enabled = false },
})
```

</details>

<details>
<summary>🎨 Formatting (conform.nvim)</summary>

Enabled by default. Configures `mojo format` via `conform.nvim` with environment-aware binary resolution.

To disable:

```lua
require("mojo").setup({
  format = { enabled = false },
})
```

</details>

<details>
<summary>🌳 Treesitter (nvim-treesitter)</summary>

Enabled by default. Registers the self-hosted Mojo parser grammar with `nvim-treesitter`.

To disable:

```lua
require("mojo").setup({
  treesitter = { enabled = false },
})
```

</details>

<details>
<summary>✨ Completion (nvim-cmp / blink.cmp)</summary>

Enabled by default. Provides Mojo keywords, builtins, stdlib types, and snippets through your
completion engine.

The static source supplies keyword/builtin/type/snippet completions at word
boundaries. After `.`, it returns nothing — letting `mojo-lsp-server` provide
contextual method/property completions through the LSP protocol.

The plugin auto-detects whether `blink.cmp` or `nvim-cmp` is installed and
configures the appropriate source — no extra plugins required. To force a specific engine, use the
`adapter` option:

```lua
-- Force blink.cmp
require("mojo").setup({
  completion = {
    adapter = function(opts)
      require("mojo.adapters.blink").setup(opts)
    end,
  },
})

-- Force nvim-cmp
require("mojo").setup({
  completion = {
    adapter = function(opts)
      require("mojo.adapters.nvim-cmp").setup(opts)
    end,
  },
})
```

Includes 56 keywords, 42 built-in functions, 34 standard-library types,
and 13 common snippets (`fn`, `struct`, `trait`, `vdef`, etc.).

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

-- blink.cmp (or nvim-cmp)
{ "saghen/blink.cmp",
  opts = function(_, opts)
    local cmp_opts = mojo.completion(opts)
    return vim.tbl_deep_extend("force", opts, cmp_opts)
  end,
}

-- lualine.nvim (auto-injected, no adapter needed)
-- The mojo component is automatically added to lualine_x on setup.
```

</details>

<details>
<summary>📊 Statusline (lualine.nvim)</summary>

Enabled by default. Shows the Mojo icon and active environment (pixi/venv)
in your statusline when editing `.mojo` files.

Customize the display:

```lua
require("mojo").setup({
  statusline = {
    icon = "🔥",           -- icon shown for Mojo buffers
    show_env_name = true,  -- show active pixi/venv environment name
    colored = true,        -- orange text highlight
  },
})
```

For a custom devicon (requires `nvim-tree/nvim-web-devicons`):

```lua
require("nvim-web-devicons").setup({
  override = {
    mojo = {
      icon = "🔥",
      color = "#ff6f00",
      name = "Mojo",
    },
  },
})
```

</details>

<details>
<summary>🌌 AstroNvim</summary>

Add mojo.nvim to your user configuration (`lua/plugins/mojo.lua`):

```lua
return {
  { "Sarctiann/mojo.nvim" },
}
```

AstroNvim already manages `nvim-lspconfig`, `nvim-treesitter`, and `conform.nvim` —
mojo.nvim hooks into them automatically. No additional adapter needed.

</details>

<details>
<summary>🎨 NvChad</summary>

Add mojo.nvim to your `lua/custom/plugins/init.lua` (or a separate plugins file):

```lua
return {
  { "Sarctiann/mojo.nvim" },
}
```

NvChad uses `nvim-lspconfig` and `conform.nvim` under the hood — mojo.nvim
integrates with them automatically. For Treesitter, ensure the mojo parser
is installed via `:TSInstall mojo` or let the plugin handle it.

</details>

<details>
<summary>🚀 kickstart.nvim</summary>

Add mojo.nvim to your `init.lua` after the kickstart plugins section:

```lua
{ 'Sarctiann/mojo.nvim' },
```

kickstart.nvim already includes `nvim-lspconfig` and `nvim-treesitter` —
mojo.nvim integrates with them automatically. The formatter requires
`conform.nvim` (add it if not present):

```lua
{
  'stevearc/conform.nvim',
  opts = {},
  config = function(_, opts)
    require('conform').setup(opts)
  end,
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
    colored = true,
  },
  debug = false,
  hooks = {},
}
```

## Notes

- The plugin does not ship the Mojo LSP binary or official toolchain.
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
