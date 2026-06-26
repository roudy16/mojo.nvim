---
name: mojo-todo-update
description: Use when updating docs/TODO.md after investigating Mojo language changes, VS Code releases, Neovim plugin API changes, completing a task, or auditing new tooling.
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  scope: project
---

# TODO Update

Maintain `docs/TODO.md` with accurate feature tracking and task priorities.
Every external change must be investigated and traced to a TODO entry — nothing
is adopted silently.

## Investigation rules

Each trigger requires a specific investigation before updating TODO:

### 1. New Mojo language release

Check: https://docs.modular.com/mojo/changelog

- Scan for new syntax, keywords, or semantic changes
- Does the treesitter grammar need updating?
- Does the completion source need new keywords/builtins?
- Does the filetype or indentation config need changes?
- Does the LSP now support new features we could expose?

### 2. New VS Code extension release

Check: `https://github.com/modular/vscode-mojo/blob/main/CHANGELOG.md`

- Read the full CHANGELOG, not just the latest version
- Categorize each change: SDK detection, LSP, debugger, formatter, run commands, status bar, settings
- For each new VS Code feature, determine if mojo.nvim already supports it (✅), partially supports it (🟡), or is missing it (❌)
- If blocked by missing upstream binary, mark as ⏳
- Update the audit table with the findings
- Create task entries for each ❌ or 🟡 that is worth implementing

### 3. New Mojo tool (LSP, debugger, formatter, CLI)

- Check the pixi/venv `bin/` directory for new binaries (e.g. `mojo-lldb-dap`, `mojo-lsp-server`)
- Check `lib/` for supporting files (e.g. `lldb-visualizers/`)
- For each new tool: does mojo.nvim discover it? Does it need an adapter?
- Add task entries for missing discovery or integration

### 4. Neovim plugin API change

Triggers: nvim-dap, nvim-lspconfig, nvim-treesitter, conform.nvim, blink.cmp, nvim-cmp, lualine.nvim

- Check the plugin's CHANGELOG or recent commits
- Does the API change break any mojo.nvim adapter?
- Does a new API allow a simpler adapter implementation?
- Does a new plugin ecosystem option exist (e.g. a new cmp engine)?
- Update adapters or add task entries as needed

## Priorities

| Priority | Meaning |
|----------|---------|
| **P0** | Sovereignty gaps — blocks autonomy, env detection, core architecture |
| **P1** | Feature parity — matches VS Code feature, high user impact |
| **P2** | Quality & completeness — docs, polish, minor features |

## Audit table format

When adding a new audit (e.g. after a VS Code release):

```
### Feature Area

| VS Code Feature | Status | Notes |
| --------------- | ------ | ----- |
| Feature name    | ✅/🟡/❌/⏳ | Details and module references |
```

Status key: ✅ implemented | 🟡 partial | ❌ missing | ⏳ blocked by upstream

## Task entry format

```
### N. Task name

**Why:** Context and motivation.

**Scope:**
- Action item 1
- Action item 2
```

## Rules

- Re-number all items after adding/removing any entry
- Existing P2 tools table uses columns: Tool, Needs adapter?, Needs README?, Notes
- Update the audit tables before adding task entries
- Never delete a completed task — mark it as `[done]` or note it inline
