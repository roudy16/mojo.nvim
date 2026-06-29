# mojo.nvim — TODO

## VS Code Extension Feature Audit

> Based on `modular-mojotools.vscode-mojo` v26.6.0 (2026-06-24).
> Key: ✅ in mojo.nvim | 🟡 partial | ❌ missing | ⏳ blocked (no upstream binary)

### SDK Detection & Status Bar

| VS Code Feature                             | Status | Notes                                                           |
| ------------------------------------------- | ------ | --------------------------------------------------------------- |
| SDK auto-detection (pixi + venv + PATH)     | ✅     | `env/detect.lua` — pixi `.pixi` + `.venv`, filesystem-first     |
| Status bar: SDK version / clickable warning | ✅     | lualine adapter shows env + SDK version; `status.MojoVersion()` |
| LSP status bar (running/stopped/crashed)    | ✅     | `status.lua` — lsp_status() runtime tracking in statusline      |
| Crashed-state distinction (26.6.0)          | 🟡     | Basic crash flag via on_exit; no capped-out/count yet           |
| Click-to-restart LSP from status bar        | ✅     | Clickable status component with action menu                     |
| `Mojo: Refresh SDK Detection` command       | ❌     | No user-facing command to re-detect                             |
| `mojo.sdk.path` override setting            | ✅     | `config.sdk_path` + `$MOJO_SDK_PATH` env var                    |
| `mojo.preferWorkspaceEnv` setting           | 🟡     | sdk_path override bypasses auto-detect; no soft priority        |
| `.derived/` monorepo SDK detection          | ❌     | Not scanned                                                     |
| Python extension integration                | ❌     | Doesn't use Python extension at all (good for autonomy)         |
| SDK version display                         | ✅     | `env/version.lua` — `mojo --version` parsing with caching       |

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

| VS Code Feature                    | Status | Notes                                                                                                                       |
| ---------------------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------- |
| LLDB debug adapter                 | ✅     | `mojo-lldb-dap` + `_mojo-lldb-dap` (arm64); also `lldb-dap` from system PATH                                                |
| AOT compile + LLDB attach (26.6.0) | ✅     | AOT via `mojo build --debug-level=full -O0`; re-signed with `get-task-allow` on macOS                                       |
| Debug Mojo File action             | ✅     | `:MojoDebug` (auto), `:MojoDebugNative`, `:MojoDebugDap`                                                                    |
| `mojoFile` (JIT compile on launch) | 🟡     | DAP via `adapters/dap.lua` (compile first, pass `program`); native AOT only                                                 |
| `buildArgs` in debug config        | ❌     | Build args not exposed in launch config                                                                                     |
| Attach to process                  | ✅     | Via `dap.configurations.mojo` `Attach to Process` entry                                                                     |
| `mojo debug --vscode` support      | 🟡     | DAP + native `mojo-lldb <bin>` cover the case                                                                               |
| Mojo data formatters (visualizers) | ❌     | `lldbDataFormatters.py` + `mlirDataFormatters.py` not loaded by our adapter                                                 |
| LLDB init/pre-run/post-run cmds    | 🟡     | Source-map set via `initCommands`; pre/post commands not exposed                                                            |
| Editor → LLDB breakpoint sync      | 🟡     | Reads buffer signs and sends to LLDB; works with our `MojoBreakpoint`; unreliable with plugins that manage signs volatilely |

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

## Mojo Language Changelog Audit

> Based on Mojo v1.0.0b2 (2026-06-18). Investigated: 2026-06-29.
> Key: ✅ handled | 🟡 partial | ❌ gap | ⏳ blocked

### Keywords & Syntax

| Mojo Change                                | Status | Notes                                                    |
| ------------------------------------------ | ------ | -------------------------------------------------------- |
| `fn` keyword now a compilation error       | ❌     | Still in completion keywords, snippets, treesitter       |
| `register_passable` effect keyword removed | ❌     | Still in completion keywords; spec says keep but removed |
| Trailing `where` on struct declarations    | 🟡     | Treesitter may not parse it yet                          |
| Trailing `where` on `comptime` alias       | 🟡     | Treesitter may not parse it yet                          |
| `@unavailable` decorator                   | 🟡     | Not in completion keywords                               |
| Conditional ImplicitlyDestructible         | 🟡     | `where conforms_to` on struct traits                     |
| `@export` must have explicit `abi` effect  | 🟡     | Warning in v1.0.0b2, error in future release             |
| `where` clauses in param lists deprecated  | 🟡     | Move to trailing `where` on declaration                  |

### Tooling

| Mojo Change                                        | Status | Notes                                         |
| -------------------------------------------------- | ------ | --------------------------------------------- |
| `mojo package` → `mojo precompile`                 | 🟡     | No references in codebase; terminal cmds fine |
| `.mojopkg` deprecated → `.mojoc`                   | ❌     | `.mojoc` not registered in filetype detection |
| `mojo --print-cache-location`                      | ❌     | No user command exposed                       |
| `mojo --clear-cache`                               | ❌     | No user command exposed                       |
| LSP: `ContentModified` instead of `InvalidRequest` | ✅     | Server fix; benefits Neovim's built-in LSP    |

### Stdlib

| Mojo Change                                    | Status | Notes                                 |
| ---------------------------------------------- | ------ | ------------------------------------- |
| Movable `__init__` arg: `take` → `move`        | 🟡     | Keyword completion may need updating  |
| New: `BinaryHeap`, `WeakPointer`, `Allocation` | 🟡     | Not in completion builtins            |
| `ExternalOrigin` → `UntrackedOrigin`           | 🟡     | Completion updated needed             |
| Reflection API: `reflect[T]` (no parens)       | 🟡     | Completion snippets may need updating |
| Deprecated free-func reflection removed        | 🟡     | No user-facing impact                 |
| `UnsafePointer` default null ctor removed      | 🟡     | No user-facing impact                 |

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

### 23. Doc string diagnostics filter — [done]

**Sovereignty:** Rule 2 (Official Replacement Path) — LSP config must expose all server options.
**Why:** 26.1.0 added option to filter diagnostics in docstrings.

**Implementation:**

- `config.lua`: `lsp.filter_docstring_diagnostics` field
- `lsp.lua`: passed via `settings.mojo.filterDocstringDiagnostics` on new_config

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

### 26. Run Mojo file commands — [done]

**Sovereignty:** Rule 1 (Centralization) — run/debug belongs in the plugin, not external.
**Why:** VS Code provides run + dedicated terminal run.

**Implementation:**

- `:MojoRun` — opens terminal split running `mojo run <file>`
- `:MojoRunDedicated` — same, dedicated buffer per file

### 27. Remove `fn` keyword from completion source & snippets

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 1 (Centralization) — completion must reflect the current language.
**Why:** Mojo v1.0.0b2 made `fn` a compilation error (was a warning). `def` is now the single function-declaration keyword.

**Scope:**

- Remove `"fn"` from `completion.lua` keywords list
- Change `fn` snippet trigger to `def` with `def` body
- Change `sfn` snippet trigger to `sdef` with `def` body

### 28. Remove `register_passable` keyword from completion source

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 1 (Centralization) — completion must reflect the current language.
**Why:** Mojo v1.0.0b2 removed the `register_passable` effect keyword. Register passability is now computed implicitly.

**Scope:**

- Remove `"register_passable"` from `completion.lua` keywords list
- Update design spec `2026-06-06-mojo-grammar-1.0-update-design.md` to note the removal

### 29. Add `.mojoc` file extension to filetype detection

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 1 (Centralization) — all Mojo file types must be recognized.
**Why:** Mojo v1.0.0b2 renamed `mojo package` → `mojo precompile` and deprecated `.mojopkg` in favor of `.mojoc`.

**Scope:**

- Add `.mojoc` extension mapping to `mojo` filetype in `filetype.lua`

---

## P2 — Quality & Completeness

### 30. Support popular Neovim tools with README documentation — [done]

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
| nvim-dap       | Done           | Done          | `adapters/dap.lua` — launches `mojo-lldb-dap` with 4 configs            |
| neotest        | ⏳ Blocked     | ⏳ Blocked    | `mojo test` not stable yet                                              |
| nvim-lint      | ⏳ Blocked     | ⏳ Blocked    | No Mojo linter binary exists                                            |
| AstroNvim      | No             | Yes           | Docs section showing config format                                      |
| NvChad         | No             | Yes           | Docs section showing config format                                      |
| kickstart.nvim | No             | Yes           | Docs section showing minimal config                                     |
| ftplugin/mojo  | Yes            | Done          | 4-space indentation                                                     |

**Remaining work:** lualine icon docs.

### 31. Debug UX — env-adaptive debugger (uv vs pixi) — [done]

**Sovereignty:** Rule 1 (Centralization) + Rule 6 (Environmental Autonomy)

**Why:** Different environments (uv vs pixi) ship different debug binaries. Plugin detects availability and adapts: prefers DAP when `mojo-lldb-dap` is available (pixi), falls back to native `mojo-lldb`/`lldb` CLI; falls back further to `mojo debug` terminal when no debug server is present (uv).

**Architecture:**

```
lua/mojo/debug/
├── init.lua       — public entry: start(backend), _pick_backend(), _start_dap(), toggle_bp(), clear_bps(), status()
├── native.lua     — AOT build + `mojo-lldb <bin>` terminal backend; macOS re-signs with get-task-allow
├── breakpoints.lua — generic all-signs reader, syncs source buffer BPs to LLDB
└── window.lua     — mode-aware winbar (normal vs terminal mode), keymaps, auto-scroll
```

**Implementation:**

- **Backend selection** (`debug/init.lua:_pick_backend`): respects `config.debug.auto_backend` override; otherwise tries DAP first, then native (`mojo-lldb` / `lldb`), then `mojo` (any).
- **Shared binary discovery** (`env/bin.lua`): `find_debug_binary(path, role)` reads `config.debug.search_for` ordered list. Defaults: `_mojo-lldb-dap`, `mojo-lldb-dap`, `lldb-dap` (dap role); `mojo-lldb`, `lldb` (native role). Users can extend for custom SDK layouts.
- **Native backend** (`debug/native.lua`): builds `.mojo` via `mojo build --debug-level=full -O0` → outputs to `_mojo-debug/<file>.bin`; on macOS re-signs with `com.apple.security.get-task-allow` (matches what Xcode does for Debug builds); launches `mojo-lldb <bin>` in a terminal split with mode-aware keymaps.
- **DAP backend** (`debug/init.lua:_start_dap`): requires nvim-dap. Uses `adapters/dap.lua:M.build()` to compile, then `dap.run({ program = bin, ... })`.
- **macOS quarantine detection** (`debug/native.lua`): checks if the `mojo` binary has `com.apple.quarantine` xattr and notifies the user with the `xattr -dr` fix command.
- **Auto-add to `.gitignore`** (`adapters/dap.lua:ensure_gitignore`): on first build, appends `_mojo-debug/` to the project's `.gitignore` if not present. Notifies once per Neovim session.
- **Commands** (`commands.lua`): `:MojoDebug` (auto), `:MojoDebugNative`, `:MojoDebugDap` (spread); master subcommands `:Mojo debug`, `:Mojo debug-native`, `:Mojo debug-dap`.
- **Statusline** (`status.lua` + `adapters/lualine.lua`): `dbg_status()` distinguishes "active DAP session" from "backend available, no session" from "unavailable". Icons and labels (`dbg_ntv` / `dbg_dap` / `dbg`) reflect the active backend. Mojo status also rendered in debug/run terminal windows via `vim.b.mojo_debug` / `vim.b.mojo_run` markers.
- **Config** (`config.lua`): `DebugConfig` with `enabled`, `auto_scroll`, `auto_backend`, `search_for`. Note: `debug` was renamed to `verbose` in the root config to avoid a name collision with the new `debug` config table.

**Known limitations / workarounds:**

- **Editor → LLDB breakpoint sync in native mode is unreliable** when breakpoints are set by a third-party plugin (e.g. LazyExtras' `<Space>db`) that uses a volatile sign management strategy. The signs may be cleared before our sync runs. Workaround: set breakpoints manually in the LLDB terminal with `breakpoint set --file <path> --line <N>`, or use DAP.
- **uv projects on macOS**: the `mojo` binary installed via `pip install modular` lacks macOS debugger entitlements. Native debug fails with "Not allowed to attach to process" or "Library not loaded" (sandbox). Workaround: use pixi projects for full debug, or use `mojo run` for execution-only.
- **macOS first-run prompts**: Gatekeeper / TCC prompts for folder access when the re-signed binary first runs. Expected, not a bug.
- **Step into stdlib**: stepping into functions like `range()` opens Mojo's standard library files (`std/range.mojo`, etc.). Use step over to stay in user code.

**Status:** Implementation complete. Native debug and DAP debug both work end-to-end on pixi projects. uv projects can run `mojo` but full debug requires pixi. The breakpoint sync from editor signs to native LLDB remains unreliable — see "Known limitations".

### 32. Re-audit completion builtins for Mojo v1.0.0b2 stdlib

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 1 (Centralization) — completion builtins must match the current stdlib.
**Why:** The completion builtins were last audited against v1.0.0b1. v1.0.0b2 added new stdlib APIs (`BinaryHeap`, `WeakPointer`, `Allocation`), renamed others (`Movable.__init__` `take` → `move`), and removed deprecated APIs (`ExternalOrigin` → `UntrackedOrigin`).

**Scope:**

- Compare current `completion.lua` builtins/attrs/types lists against v1.0.0b2 stdlib
- Add new types: `BinaryHeap`, `WeakPointer`, `Allocation`, `ThinAllocation`, `Layout`, `UntrackedOrigin`, `UnsafeAnyOrigin`, `CompletionFlag`, `DevicePointer`, `DeviceContextList`, `ReflectedFn`
- Remove/deprecate: `ExternalOrigin` → `UntrackedOrigin`, `AnyOrigin` → `UnsafeAnyOrigin`
- Update audit comment in `completion.lua` to reference v1.0.0b2

### 33. Update treesitter grammar for Mojo v1.0.0b2 syntax changes

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 3 (No Third-Party) — treesitter grammar bundled in the repo.
**Why:** Mojo v1.0.0b2 changed several syntax rules: `fn` is an error, `register_passable` removed, trailing `where` on struct/comptime declarations added, `@unavailable` decorator added, param-`where` deprecated.

**Scope:**

- Deprecate `fn` in grammar (keep parsing for legacy code, mark as `@keyword.error` in highlights)
- Remove `register_passable` from effect keywords
- Add trailing `where` clause support to struct and comptime alias declarations
- Add `@unavailable` decorator parsing
- Mark param-list `where` as `@keyword.deprecated` in highlights
- ⏳ Blocked if upstream `tree-sitter-mojo` hasn't released these updates
