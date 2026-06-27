# mojo.nvim — TODO

## VS Code Extension Feature Audit

> Based on `modular-mojotools.vscode-mojo` v26.6.0 (2026-06-24).
> Key: ✅ in mojo.nvim | 🟡 partial | ❌ missing | ⏳ blocked (no upstream binary)

### SDK Detection & Status Bar

| VS Code Feature                             | Status | Notes                                                       |
| ------------------------------------------- | ------ | ----------------------------------------------------------- |
| SDK auto-detection (pixi + venv + PATH)     | ✅     | `env/detect.lua` — pixi `.pixi` + `.venv`, filesystem-first |
| Status bar: SDK version / clickable warning | ✅     | lualine adapter shows env + SDK version; `status.MojoVersion()` |
| LSP status bar (running/stopped/crashed)    | ✅     | `status.lua` — lsp_status() runtime tracking in statusline  |
| Crashed-state distinction (26.6.0)          | 🟡     | Basic crash flag via on_exit; no capped-out/count yet       |
| Click-to-restart LSP from status bar        | ✅     | Clickable status component with action menu                 |
| `Mojo: Refresh SDK Detection` command       | ❌     | No user-facing command to re-detect                         |
| `mojo.sdk.path` override setting            | ✅     | `config.sdk_path` + `$MOJO_SDK_PATH` env var               |
| `mojo.preferWorkspaceEnv` setting           | 🟡     | sdk_path override bypasses auto-detect; no soft priority    |
| `.derived/` monorepo SDK detection          | ❌     | Not scanned                                                 |
| Python extension integration                | ❌     | Doesn't use Python extension at all (good for autonomy)     |
| SDK version display                         | ✅     | `env/version.lua` — `mojo --version` parsing with caching   |

### LSP Features

| VS Code Feature                       | Status | Notes                                             |
| ------------------------------------- | ------ | ------------------------------------------------- |
| Code completion                       | ✅     | Via nvim-cmp & blink.cmp adapters                 |
| Hover / doc hints                     | ✅     | LSP provides it, but no keybinding documented     |
| Signature help (overloaded functions) | ❌     | LSP provides it, no keybinding or docs            |
| Go to symbol                          | ✅     | LSP provides it via telescope/trouble             |
| Outline view                          | ❌     | LSP provides it; need to document `/docs`         |
| Code diagnostics                      | ✅     | Via LSP health in trouble/telescope               |
| Quick fixes / code actions            | ❌     | Lightbulb; would need adapter or mapping          |
| Doc string code blocks LSP            | 🟡     | LSP provides it automatically; no mention in docs |
| Filter diagnostics in docstrings      | ❌     | Config option missing                             |
| `mojo.lsp.includeDirs`                | ❌     | Not exposed in LSP config                         |
| Stop LSP server command               | ❌     | No user-facing command                            |
| Restart extension command             | ❌     | No wrapper/command                                |
| Inline error display                  | ❌     | No Error Lens equivalent                          |

### Debugging

| VS Code Feature                    | Status | Notes                                                              |
| ---------------------------------- | ------ | ------------------------------------------------------------------ |
| LLDB debug adapter                 | ✅     | `mojo-lldb-dap` → DAP server nativo LLDB, `_mojo-lldb-dap` (arm64) |
| AOT compile + LLDB attach (26.6.0) | ✅     | Soportado vía `mojoFile` — DAP server compila `.mojo` internamente |
| Debug Mojo File action             | ❌     | Falta adapter/config nvim-dap                                      |
| `mojoFile` (JIT compile on launch) | ❌     | Propiedad `mojoFile` soportada por el DAP server                   |
| `buildArgs` in debug config        | ❌     | Propiedad `buildArgs` soportada por el DAP server                  |
| Attach to process                  | ❌     | Propiedad `pid`/`program`/`waitFor` soportada                      |
| `mojo debug --vscode` support      | 🟡     | No necesario; DAP server es más directo                            |
| Mojo data formatters (visualizers) | ❌     | `lldbDataFormatters.py` + `mlirDataFormatters.py` en lib/          |
| LLDB init/pre-run/post-run cmds    | ❌     | Comandos LLDB pre/post lanzamiento soportados                      |

### Run

| VS Code Feature              | Status | Notes                                                      |
| ---------------------------- | ------ | ---------------------------------------------------------- |
| Run Mojo File                | 🟡     | Terminal module exists but no explicit run command exposed |
| Run in Dedicated Terminal    | 🟡     | Terminal reuse by bufname possible but not exposed         |
| Right-click / contextual run | ❌     | No Neovim equivalent (could add `:MojoRun`)                |
| Command palette run actions  | ❌     | No user commands                                           |

### Formatting

| VS Code Feature          | Status | Notes                                           |
| ------------------------ | ------ | ----------------------------------------------- |
| Format Document          | ✅     | Via conform.nvim adapter `adapters/conform.lua` |
| Format on Save           | ✅     | Standard conform.nvim feature, documented       |
| Default formatter config | ✅     | In README                                       |

### Other

| VS Code Feature              | Status | Notes                             |
| ---------------------------- | ------ | --------------------------------- |
| Syntax highlighting          | ✅     | Via treesitter + filetype         |
| `comptime` keyword support   | ✅     | Treesitter parses it              |
| Function modifier syntax     | ✅     | Treesitter handles `var`          |
| Restart extension command    | ❌     | No user-facing command            |
| Terminal env auto-activation | ✅     | `terminal.lua` — TermOpen autocmd |

---

## P0 — Sovereignty Gaps

### 14. SDK version detection in status bar — [done]

**Sovereignty:** Rule 6 (Environmental Autonomy) — users must see which SDK is active.
**Why:** VS Code shows SDK version + clickable warning. Users need to know which Mojo they're on.

**Implementation:**

- `mojo --version` parsing → `env/version.lua` with caching
- Exposed via `env.get_version()`
- `adapters/lualine.lua` — `show_sdk_version` option (default: true)
- `status.MojoVersion()` component for non-lualine statuslines

### 15. SDK path override setting — [done]

**Sovereignty:** Rule 6 (Environmental Autonomy) — users need manual SDK override for CI/remote.
**Why:** VS Code has `mojo.sdk.path` for CI/remote environments.

**Implementation:**

- `config.sdk_path` field + `$MOJO_SDK_PATH` env var fallback
- `detect.lua` checks override before auto-detection
- Validates path exists and contains `bin/mojo` or `bin/mojo-lsp-server`
- Surfaces error via `vim.notify` on invalid path
- Cached separately from auto-detected envs

### 16. SDK refresh command — [done]

**Sovereignty:** Rule 6 (Environmental Autonomy) — recovery mechanism when env changes.
**Why:** `Mojo: Refresh SDK Detection` clears cache and re-detects.

**Implementation:**

- `:MojoRefreshSDK` user command clears detect cache and resets LSP crash state

### 17. `.derived/` monorepo SDK detection — [done]

**Sovereignty:** Rule 6 (Environmental Autonomy) — missing SDK source = incomplete detection.
**Why:** VS Code scans `.derived/` as an SDK source.

**Implementation:** Added `"derived"` type to `detect.lua` — checks `.derived/bin/` before pixi/venv.

### 18. nvim-dap integration (mojo-lldb-dap adapter) — [done]

**Sovereignty:** Rule 1 (Centralization) + Rule 5 (Zero-Bundle) — debugging must use official binary.
**Why:** Tenemos `mojo-lldb-dap` (DAP server LLDB-based) en el SDK. `_mojo-lldb-dap` es un binario arm64 que implementa DAP completo con soporte para `mojoFile` (compila `.mojo` sobre la marcha), `buildArgs`, attach, y más. El wrapper `mojo-lldb-dap` importa visualizers Mojo via `CONDA_PREFIX`.

**Arquitectura:**

- `mojo-lldb-dap` → shell script wrapper que usa `$CONDA_PREFIX/bin/_mojo-lldb-dap`
- `_mojo-lldb-dap` → binario arm64, DAP server LLDB-based (Apple's lldb-dap adaptado)
- Visualizers en `$CONDA_PREFIX/lib/lldb-visualizers/` (lldbDataFormatters.py + mlirDataFormatters.py)

**Scope:**

- Detectar `mojo-lldb-dap` vía env module (misma mecánica que `mojo-lsp-server`)
- Crear adapter nvim-dap con `type = "executable"` y env correcto (CONDA_PREFIX)
- Keyboard: `mojoFile` → debug de archivo actual, `program` → debug de binario, `attach` → attach PID
- Exponer `buildArgs`, `initCommands`, `stopOnEntry`, etc.
- Documentar en README la configuración básica

**DAP configs a soportar:**
| Config | VS Code equiv | Descripción |
| ------ | ------------- | ----------- |
| Debug current Mojo file | `mojo.file.debug` | Usa `mojoFile` = `${file}`, compila y debuggea |
| Debug binary | `program` | Debuggea binario precompilado |
| Attach to process | `mojo.debug.attach-to-process` | Attach por PID/nombre |

---

## P1 — Feature Parity

### 19. LSP status bar indicator — [done]

**Sovereignty:** Rule 1 (Centralization) — central LSP management needs health visibility.
**Why:** VS Code shows LSP server state (running/stopped/crashed) with click-to-restart.

**Implementation:**

- `status.lua` tracks LSP state via `vim.lsp.get_clients` and crash flag
- `g:mojo_lsp_status` viml variable set on each status check
- lualine adapter shows runtime state with colored icons
- Clickable menu with restart/stop options

### 20. LSP crash detection & recovery — [done]

**Sovereignty:** Rule 1 (Centralization) — plugin must handle LSP lifecycle, not just delegate.
**Why:** 26.6.0 distinguishes capped-out (repeated crashes) from normal stopped.

**Implementation:**

- Restart counter per session with cap at 3
- Capped-out state `"capped"` in lsp_status
- Exponential restart backoff: 5s → 30s → 60s
- Backoff resets when LSP stays running >30s

### 21. Signature help keybinding & docs — [done]

**Sovereignty:** Rule 1 (Centralization) — all LSP affordances must be documented centrally.
**Why:** VS Code documents `ctrl+shift+space` for overloaded function scrolling.

**Implementation:**

- `<C-S-space>` mapped to `vim.lsp.buf.signature_help` for mojo filetype

### 22. Code actions / quick fixes — [done]

**Sovereignty:** Rule 1 (Centralization) — must document all LSP capabilities.
**Why:** LSP provides textDocument/codeAction but no mojo.nvim adapter exposes it.

**Implementation:**

- `<leader>ca` mapped to `vim.lsp.buf.code_action` for mojo filetype (n + v modes)

### 23. Doc string diagnostics filter

**Sovereignty:** Rule 2 (Official Replacement Path) — LSP config must expose all server options.
**Why:** 26.1.0 added option to filter diagnostics in docstrings.

**Scope:**

- Add `lsp.filter_docstring_diagnostics` config option
- Implement filter in LSP handler

### 24. `mojo.lsp.includeDirs` setting — [done]

**Sovereignty:** Rule 2 (Official Replacement Path) — LSP config must expose all server options.
**Why:** Lets users add extra include paths for LSP.

**Implementation:**

- `config.lua`: `lsp.include_dirs` field
- `lsp.lua`: passed via `settings.mojo.includeDirs` on new_config

### 25. Restart & stop LSP commands — [done]

**Sovereignty:** Rule 1 (Centralization) — central LSP lifecycle management.
**Why:** `Mojo: Restart the extension` is a documented VS Code troubleshooting tool.

**Implementation:**

- `:MojoRestartLSP` — stop + start LSP (delegates to status.actions)
- `:MojoStopLSP` — stop only
- Available via clickable menu and `:MojoMenu`

### 26. Run Mojo file commands

**Sovereignty:** Rule 1 (Centralization) — run/debug belongs in the plugin, not external.
**Why:** VS Code provides run + dedicated terminal run.

**Scope:**

- `:MojoRun` — run current file in shared terminal
- `:MojoRunDedicated` — run in per-file terminal
- Port of `mojo-terminal` code or reuse terminal.lua

---

## P2 — Quality & Completeness

### 27. Support popular Neovim tools with README documentation

**Scope:** Ongoing — new tools are added here as they're identified.

| Tool           | Needs adapter? | Needs README? | Notes                                                                   |
| -------------- | -------------- | ------------- | ----------------------------------------------------------------------- |
| nvim-cmp       | Done           | Done          | `adapters/nvim-cmp.lua` — context-aware: returns empty after `.` or `:` |
| blink.cmp      | Done           | Done          | `adapters/blink.lua` — native blink.cmp Source provider, context-aware  |
| LuaSnip        | No             | No            | Snippets served through completion adapters                             |
| telescope.nvim | No             | No            | Works automatically                                                     |
| which-key.nvim | No             | No            | Works automatically                                                     |
| trouble.nvim   | No             | No            | Works automatically                                                     |
| lualine.nvim   | No             | Yes           | SDK version display + env name in statusline                            |
| nvim-dap       | ❌ Missing     | ❌ Missing    | `mojo-lldb-dap` existe — adapter nvim-dap pendiente                     |
| neotest        | ⏳ Blocked     | ⏳ Blocked    | `mojo test` not stable yet                                              |
| nvim-lint      | ⏳ Blocked     | ⏳ Blocked    | No Mojo linter binary exists                                            |
| AstroNvim      | No             | Yes           | Docs section showing config format                                      |
| NvChad         | No             | Yes           | Docs section showing config format                                      |
| kickstart.nvim | No             | Yes           | Docs section showing minimal config                                     |
| ftplugin/mojo  | Yes            | Done          | 4-space indentation                                                     |

**Remaining work:** lualine icon docs, AstroNvim/NvChad/kickstart config sections.
