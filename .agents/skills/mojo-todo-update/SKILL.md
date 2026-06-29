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

This skill defines the **rules and triggers** for maintaining `docs/TODO.md`.
The TODO is the **output** of this skill — a dynamic list of tasks that drives
plugin development. Every external change must be investigated and traced to a
TODO entry. Nothing is adopted silently.

## North Star

Achieve full Mojo editor sovereignty in Neovim:

- Every VS Code feature has a Neovim equivalent wired through mojo.nvim
- No Mojo-specific third-party plugin required
- When Modular ships an official tool, only one module changes

## Investigation triggers

Each trigger below describes what to investigate and how to translate findings
into TODO entries.

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
- For each new VS Code feature, determine if mojo.nvim already supports it (✅), partially (🟡), or missing (❌)
- If blocked by missing upstream binary, mark as ⏳
- Output: update the audit tables in TODO.md
- Create task entries for each ❌ or 🟡 worth implementing

### 3. New Mojo tool (LSP, debugger, formatter, CLI)

- Check pixi/venv `bin/` for new binaries (e.g. `mojo-lldb-dap`, `mojo-lsp-server`)
- Check `lib/` for supporting files (e.g. `lldb-visualizers/`)
- For each new tool: does mojo.nvim discover it? Does it need an adapter?
- Output: add task entries for missing discovery or integration

### 4. Neovim plugin API change

Triggers: nvim-dap, nvim-lspconfig, nvim-treesitter, conform.nvim, blink.cmp, nvim-cmp, lualine.nvim

- Check the plugin's CHANGELOG or recent commits
- Does the API change break any mojo.nvim adapter?
- Does a new API allow a simpler adapter implementation?
- Does a new plugin ecosystem option exist?
- Output: update adapters or add task entries

### 5. Task completed

- Mark the task as `[done]` in TODO.md
- Re-number all remaining items
- Update the P2 tools table if the completed task involved a Neovim tool
- Load `update-docs` to audit docs consistency after the TODO change

### 6. New feature gap discovered

- If the gap blocks a sovereignty rule → P0
- If it matches VS Code parity → P1
- Otherwise → P2

## Priority definitions

| Priority | Meaning                                                              | Sovereignty rules       |
| -------- | -------------------------------------------------------------------- | ----------------------- |
| **P0**   | Sovereignty gaps — blocks autonomy, env detection, core architecture | Rules 1-7               |
| **P1**   | VS Code feature parity, high user impact                             | Rule 1 (centralization) |
| **P2**   | Quality, polish, docs, minor features                                | Rules 4, 7              |

## TODO output format

The TODO.md document has two kinds of content:

### Audit tables

After each VS Code release audit:

```
### <Feature Area> (audited: YYYY-MM-DD)

| VS Code Feature | Status | Notes |
| --------------- | ------ | ----- |
| Feature name    | ✅/🟡/❌/⏳ | Module reference |
```

Status: ✅ implemented | 🟡 partial | ❌ missing | ⏳ blocked by upstream

Each audit table group MUST include the investigation date in the heading.

### Task entries

```
### N. Task name
**Created:** YYYY-MM-DD | **Updated:** YYYY-MM-DD
**Sovereignty:** Rule X (name) — how it relates.
**Why:** Context and motivation.

**Scope:**
- Action item 1
- Action item 2
```

Every task MUST have a `Created` date (when first added) and an `Updated` date
(when last modified). When creating a new task, both dates are the same. When
updating an existing task, only bump the `Updated` date.

## Maintenance rules

- Re-number all items after adding/removing any entry
- Update audit tables before adding task entries
- Never delete a completed task — mark `[done]` inline
- P2 tools table uses columns: Tool, Needs adapter?, Needs README?, Notes
- Each task references the sovereignty rule it serves
- Every task group (audit table or task group) MUST have a timestamp
- Every individual task MUST have `Created` and `Updated` date fields
- When investigation is triggered (Mojo release, VS Code release, new tool, API change),
  record the investigation date in the corresponding section heading
