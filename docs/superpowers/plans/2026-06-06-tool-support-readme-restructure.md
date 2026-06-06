# README Restructure & Tool Support Tracking

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure mojo.nvim README with collapsible installation sections for multiple package managers and collapsible integration sections for popular Neovim tools. Add tracking table to TODO.md.

**Architecture:** Pure documentation changes to `README.md` and `docs/TODO.md`. No core module code changes. Each tool's README section follows a consistent `<details>` template. TODO.md gets a new P2 entry with a table tracking research/adapter/README per tool.

**Tech Stack:** Markdown, HTML `<details>` tags, Lua code blocks in examples.

---

### Task 1: Add tracking table to TODO.md

**Files:**
- Modify: `docs/TODO.md` — append new P2 entry at the end of P2 section (before P3)

- [ ] **Step 1: Read current TODO.md end to find insertion point**

Read the file to find where P2 ends and P3 begins.

```bash
rg "^## P3" docs/TODO.md -n
```

- [ ] **Step 2: Add the tracking table**

Append before `## P3 — Polish`:

```markdown
### 13. Support popular Neovim tools with README documentation

**Scope:** Ongoing — new tools are added here as they're identified.
Each tool follows: Research → Adapter (if needed) → README section.

**Initial batch:**

| Tool | Research | Adapter | README | Status |
|------|----------|---------|--------|--------|
| nvim-lint | ⬜ | ⬜ | ⬜ | 🔴 |
| nvim-cmp | ⬜ | ⬜ | ⬜ | 🔴 |
| blink.cmp | ⬜ | ⬜ | ⬜ | 🔴 |
| LuaSnip | ⬜ | ⬜ | ⬜ | 🔴 |
| nvim-dap | ⬜ | ⬜ | ⬜ | 🔴 |
| neotest | ⬜ | ⬜ | ⬜ | 🔴 |
| telescope.nvim | ⬜ | ⬜ | ⬜ | 🔴 |
| which-key.nvim | ⬜ | ⬜ | ⬜ | 🔴 |
| trouble.nvim | ⬜ | ⬜ | ⬜ | 🔴 |
| lualine.nvim | ⬜ | ⬜ | ⬜ | 🔴 |
| AstroNvim | ⬜ | ⬜ | ⬜ | 🔴 |
| NvChad | ⬜ | ⬜ | ⬜ | 🔴 |
| kickstart.nvim | ⬜ | ⬜ | ⬜ | 🔴 |

**Adding new tools:** Append a new row when a tool is identified.
Process: research → create adapter (if needed) → add README section → check off columns.
```

- [ ] **Step 3: Verify the insertion**

Run: `rg "### 13\. Support" docs/TODO.md`
Expected: shows the new entry

- [ ] **Step 4: Commit**

```bash
git add docs/TODO.md
git commit -m "docs: add tool support tracking table to TODO"
```

---

### Task 2: Rewrite README installation section with collapsibles

**Files:**
- Modify: `README.md` — replace current `## Installation` section

- [ ] **Step 1: Read current README to confirm content**

Read the file, note the current installation section lines.

- [ ] **Step 2: Replace the installation section**

Replace everything from `## Installation` to `## Setup` / `## Configuration` with:

```markdown
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
```

- [ ] **Step 3: Verify collapsibles render correctly**

Check that `<details>` and `</details>` tags are properly paired.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add collapsible installation section with multiple package managers"
```

---

### Task 3: Restructure existing tool sections into collapsible integrations

**Files:**
- Modify: `README.md` — move LSP, Format, Treesitter, LazyVim into new "Integrations" section

- [ ] **Step 1: Identify the insertion point**

The new Integrations section goes between Configuration and Notes.

- [ ] **Step 2: Add the Integrations section header and existing tools**

Before `## Configuration`, add:

```markdown
## Integrations

### 🔧 LSP (nvim-lspconfig)

<details open>
<summary>Configuration</summary>

```lua
require("mojo").setup({
  lsp = { enabled = true },
})
```

This registers `mojo-lsp-server` via `nvim-lspconfig` with environment-aware binary
resolution (finds the binary in the active Pixi/venv environment).

</details>

### 🎨 Formatting (conform.nvim)

<details open>
<summary>Configuration</summary>

```lua
require("mojo").setup({
  format = { enabled = true },
})
```

This configures `mojo format` via `conform.nvim` with environment-aware binary resolution.

</details>

### 🌳 Treesitter (nvim-treesitter)

<details open>
<summary>Configuration</summary>

```lua
require("mojo").setup({
  treesitter = { enabled = true },
})
```

This registers the Mojo parser with `nvim-treesitter`.

</details>

### 🚀 LazyVim

<details>
<summary>Configuration</summary>

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
```

- [ ] **Step 3: Remove duplicated feature descriptions**

The existing `## Features` section has LSP/Format/Treesitter descriptions. Either keep them as a quick overview or remove them now that Integrations has details. Keep the brief descriptions in Features as an overview, and link to Integrations for config details.

- [ ] **Step 4: Verify no broken anchors or formatting**

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: restructure existing tool sections into collapsible integrations"
```

---

### Task 4: Add new tool integration sections (documentation only)

**Files:**
- Modify: `README.md` — append integrations after LazyVim section

- [ ] **Step 1: Add Linting section**

After LazyVim `<details>`, add:

```markdown
### 🔍 Linting (nvim-lint)

<details>
<summary>Configuration</summary>

```lua
require("lint").linters_by_ft = {
  mojo = { "mojo" },
}
```

**Note:** Full adapter integration is tracked in TODO.md (P2 #13).
The `mojo-lint` adapter in `lua/mojo/adapters/nvim-lint.lua` will wrap `mojo format --check`
as a lint source when implemented.

</details>
```

- [ ] **Step 2: Add Autocompletion sections**

```markdown
### ✨ Autocompletion (nvim-cmp)

<details>
<summary>Configuration</summary>

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

### ✨ Autocompletion (blink.cmp)

<details>
<summary>Configuration</summary>

blink.cmp works out of the box with LSP configured via this plugin.

```lua
require("blink.cmp").setup({
  sources = {
    default = { "lsp" },
  },
})
```

</details>
```

- [ ] **Step 3: Add Snippets section**

```markdown
### 📋 Snippets (LuaSnip)

<details>
<summary>Configuration</summary>

Place Mojo snippets in `~/.config/nvim/snippets/mojo.lua` or use a snippet
collection like `friendly-snippets` (which includes Python snippets that overlap
with Mojo syntax).

```lua
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
```

</details>
```

- [ ] **Step 4: Add Debugging section**

```markdown
### 🐛 Debugging (nvim-dap)

<details>
<summary>Configuration</summary>

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
```

- [ ] **Step 5: Add Testing section**

```markdown
### 🧪 Testing (neotest)

<details>
<summary>Configuration</summary>

**Note:** A neotest adapter for Mojo (`lua/mojo/adapters/neotest.lua`) will be
implemented when a standard Mojo test runner interface is established. This
section will be updated with configuration examples at that point.

For now, run tests directly:

```bash
mojo test
```

</details>
```

- [ ] **Step 6: Add Utility sections**

```markdown
### 🔭 telescope.nvim

<details>
<summary>Configuration</summary>

telescope works with Mojo files out of the box. No additional configuration needed.

```lua
require("telescope").setup({})
```

Mojo files are picked up by default pickers (`find_files`, `live_grep`, etc.).

</details>

### ⌨️ which-key.nvim

<details>
<summary>Configuration</summary>

If you define Mojo-specific keymaps, which-key will discover them automatically.

```lua
require("which-key").add({
  { "<leader>m", group = "Mojo" },
  { "<leader>mr", "<cmd>MojoRun<CR>", desc = "Run Mojo file" },
  { "<leader>mt", "<cmd>MojoTest<CR>", desc = "Run Mojo tests" },
})
```

</details>

### ⚠️ trouble.nvim

<details>
<summary>Configuration</summary>

trouble.nvim works with LSP diagnostics, which mojo-lsp-server provides
automatically. No additional Mojo-specific configuration needed.

```lua
require("trouble").setup({})
```

</details>

### 📊 lualine.nvim

<details>
<summary>Configuration</summary>

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
```

- [ ] **Step 7: Commit**

```bash
git add README.md
git commit -m "docs: add collapsible sections for new tool integrations"
```

---

### Task 5: Add distro integration sections

**Files:**
- Modify: `README.md` — append after utility sections

- [ ] **Step 1: Add AstroNvim section**

```markdown
### 🪐 AstroNvim

<details>
<summary>Configuration</summary>

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
```

- [ ] **Step 2: Add NvChad section**

```markdown
### ⚡ NvChad

<details>
<summary>Configuration</summary>

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
```

- [ ] **Step 3: Add kickstart.nvim section**

```markdown
### 🏁 kickstart.nvim

<details>
<summary>Configuration</summary>

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
```

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add distro integration sections for AstroNvim, NvChad, kickstart"
```

---

### Task 6: Polish and verify

**Files:**
- Verify: `README.md` — full document integrity
- Verify: `docs/TODO.md` — tracking table correct

- [ ] **Step 1: Verify README structure**

Read the full README and check:
- All `<details>` tags are properly paired
- No duplicate sections
- Installation section has all 5 package managers
- Integrations section covers all planned tools
- Configuration section is intact
- Notes section is intact

- [ ] **Step 2: Verify TODO.md tracking table**

Check the table renders correctly with proper column alignment.

- [ ] **Step 3: Check for broken markdown**

Run a quick syntax check (no linter available? Just visual scan for unclosed code blocks).

- [ ] **Step 4: Verify collapsibles work in GitHub rendering**

Check that:
- lazy.nvim `<details open>` is open by default
- All other `<details>` are closed by default
- No raw HTML leaks into visible content

- [ ] **Step 5: Final commit**

```bash
git add README.md docs/TODO.md
git commit -m "docs: polish README restructure and verify integrity"
```
