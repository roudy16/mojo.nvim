# mojo.nvim — TODO

## VS Code Extension Feature Audit

> Based on `modular-mojotools.vscode-mojo` v26.6.0 (2026-06-24).
> Audited: 2026-06-29.
> Key: ✅ in mojo.nvim | 🟡 partial | ❌ missing | ⏳ blocked (no upstream binary)

### SDK Detection & Status Bar

| VS Code Feature                             | Status | Notes                                                           |
| ------------------------------------------- | ------ | --------------------------------------------------------------- |
| SDK auto-detection (pixi + venv + PATH)     | ✅     | `env/detect.lua` — pixi `.pixi` + `.venv`, filesystem-first     |
| Status bar: SDK version / clickable warning | ✅     | lualine adapter shows env + SDK version; `status.MojoVersion()` |
| LSP status bar (running/stopped/crashed)    | ✅     | `status.lua` — lsp_status() runtime tracking in statusline      |
| Crashed-state distinction (26.6.0)          | ✅     | Crash counter with capped-out state + exponential backoff       |
| Click-to-restart LSP from status bar        | ✅     | Clickable status component with action menu                     |
| `Mojo: Refresh SDK Detection` command       | ✅     | `:MojoRefreshSDK` user command                                  |
| `mojo.sdk.path` override setting            | ✅     | `config.sdk_path` + `$MOJO_SDK_PATH` env var                    |
| `mojo.preferWorkspaceEnv` setting           | 🟡     | sdk_path override bypasses auto-detect; no soft priority        |
| `.derived/` monorepo SDK detection          | ✅     | Added `derived` type to `detect.lua`                            |
| Python extension integration                | ❌     | Doesn't use Python extension at all (good for autonomy)         |
| SDK version display                         | ✅     | `env/version.lua` — `mojo --version` parsing with caching       |

### LSP Features

| VS Code Feature                       | Status | Notes                                                              |
| ------------------------------------- | ------ | ------------------------------------------------------------------ |
| Code completion                       | ✅     | Via nvim-cmp & blink.cmp adapters                                  |
| Hover / doc hints                     | ✅     | LSP provides it, but no keybinding documented                      |
| Signature help (overloaded functions) | ✅     | `<C-S-space>` mapped to `vim.lsp.buf.signature_help`              |
| Go to symbol                          | ✅     | LSP provides it via telescope/trouble                              |
| Outline view                          | ❌     | LSP provides it; need to document `/docs`                          |
| Code diagnostics                      | ✅     | Via LSP health in trouble/telescope                                |
| Quick fixes / code actions            | ✅     | `<leader>ca` mapped to `vim.lsp.buf.code_action` (n + v modes)    |
| Doc string code blocks LSP            | 🟡     | LSP provides it automatically; no mention in docs                  |
| Filter diagnostics in docstrings      | ✅     | `config.lsp.filter_docstring_diagnostics` option                   |
| `mojo.lsp.includeDirs`                | ✅     | `config.lsp.include_dirs` option                                   |
| Stop LSP server command               | ✅     | `:MojoStopLSP` command                                             |
| Restart extension command             | ✅     | `:MojoRestartLSP` command                                          |
| Inline error display                  | ❌     | No Error Lens equivalent                                           |

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

| VS Code Feature              | Status | Notes                                       |
| ---------------------------- | ------ | ------------------------------------------- |
| Run Mojo File                | ✅     | `:MojoRun` opens terminal split             |
| Run in Dedicated Terminal    | ✅     | `:MojoRunDedicated` dedicated buffer per file |
| Right-click / contextual run | ✅     | Covered by `:MojoRun`                       |
| Command palette run actions  | ✅     | Covered by `:MojoRun` / `:MojoRunDedicated` |

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
| Restart extension command    | ✅     | `:MojoRestartLSP` command         |
| Terminal env auto-activation | ✅     | `terminal.lua` — TermOpen autocmd |

---

## Mojo Language Changelog Audit

> Based on Mojo v1.0.0b2 (2026-06-18). Investigated: 2026-06-29.
> Key: ✅ handled | 🟡 partial | ❌ gap | ⏳ blocked

### Keywords & Syntax

| Mojo Change                                | Status | Notes                                                        |
| ------------------------------------------ | ------ | ------------------------------------------------------------ |
| `fn` keyword now a compilation error       | ❌     | Still in completion keywords, snippets, treesitter → Task #1 |
| `register_passable` effect keyword removed | ❌     | Still in completion keywords → Task #2                       |
| Trailing `where` on struct declarations    | 🟡     | Treesitter may not parse it yet → Task #5                    |
| Trailing `where` on `comptime` alias       | 🟡     | Treesitter may not parse it yet → Task #5                    |
| `@unavailable` decorator                   | 🟡     | Not in completion keywords → Task #5                         |
| Conditional ImplicitlyDestructible         | 🟡     | `where conforms_to` on struct traits                         |
| `@export` must have explicit `abi` effect  | 🟡     | Warning in v1.0.0b2, error in future release                 |
| `where` clauses in param lists deprecated  | 🟡     | Move to trailing `where` on declaration                      |

### Tooling

| Mojo Change                                        | Status | Notes                                                               |
| -------------------------------------------------- | ------ | ------------------------------------------------------------------- |
| `mojo package` → `mojo precompile`                 | 🟡     | No references in codebase; terminal cmds fine                       |
| `.mojopkg` deprecated → `.mojoc`                   | ❌     | `.mojoc` not registered in filetype detection → Task #3             |
| `mojo --print-cache-location`                      | ❌     | No user command exposed                                             |
| `mojo --clear-cache`                               | ❌     | No user command exposed                                             |
| LSP: `ContentModified` instead of `InvalidRequest` | ✅     | Server fix; benefits Neovim's built-in LSP                          |

### Stdlib

| Mojo Change                                    | Status | Notes                                            |
| ---------------------------------------------- | ------ | ------------------------------------------------ |
| Movable `__init__` arg: `take` → `move`        | 🟡     | Keyword completion may need updating → Task #4   |
| New: `BinaryHeap`, `WeakPointer`, `Allocation` | 🟡     | Not in completion builtins → Task #4             |
| `ExternalOrigin` → `UntrackedOrigin`           | 🟡     | Completion update needed → Task #4               |
| Reflection API: `reflect[T]` (no parens)       | 🟡     | Completion snippets may need updating            |
| Deprecated free-func reflection removed        | 🟡     | No user-facing impact                            |
| `UnsafePointer` default null ctor removed      | 🟡     | No user-facing impact                            |

---

## P1 — Language Sync

### 1. Remove `fn` keyword from completion source & snippets

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 1 (Centralization) — completion must reflect the current language.
**Why:** Mojo v1.0.0b2 made `fn` a compilation error (was a warning). `def` is now the single function-declaration keyword.

**Scope:**

- Remove `"fn"` from `completion.lua` keywords list
- Change `fn` snippet trigger to `def` with `def` body
- Change `sfn` snippet trigger to `sdef` with `def` body

### 2. Remove `register_passable` keyword from completion source

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 1 (Centralization) — completion must reflect the current language.
**Why:** Mojo v1.0.0b2 removed the `register_passable` effect keyword. Register passability is now computed implicitly.

**Scope:**

- Remove `"register_passable"` from `completion.lua` keywords list
- Update design spec `2026-06-06-mojo-grammar-1.0-update-design.md` to note the removal

### 3. Add `.mojoc` file extension to filetype detection

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 1 (Centralization) — all Mojo file types must be recognized.
**Why:** Mojo v1.0.0b2 renamed `mojo package` → `mojo precompile` and deprecated `.mojopkg` in favor of `.mojoc`.

**Scope:**

- Add `.mojoc` extension mapping to `mojo` filetype in `filetype.lua`

---

## P2 — Quality & Completeness

### 4. Re-audit completion builtins for Mojo v1.0.0b2 stdlib

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 1 (Centralization) — completion builtins must match the current stdlib.
**Why:** The completion builtins were last audited against v1.0.0b1. v1.0.0b2 added new stdlib APIs (`BinaryHeap`, `WeakPointer`, `Allocation`), renamed others (`Movable.__init__` `take` → `move`), and removed deprecated APIs (`ExternalOrigin` → `UntrackedOrigin`).

**Scope:**

- Compare current `completion.lua` builtins/attrs/types lists against v1.0.0b2 stdlib
- Add new types: `BinaryHeap`, `WeakPointer`, `Allocation`, `ThinAllocation`, `Layout`, `UntrackedOrigin`, `UnsafeAnyOrigin`, `CompletionFlag`, `DevicePointer`, `DeviceContextList`, `ReflectedFn`
- Remove/deprecate: `ExternalOrigin` → `UntrackedOrigin`, `AnyOrigin` → `UnsafeAnyOrigin`
- Update audit comment in `completion.lua` to reference v1.0.0b2

### 5. Update treesitter grammar for Mojo v1.0.0b2 syntax changes

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

### 6. Lualine icon documentation

**Created:** 2026-06-29 | **Updated:** 2026-06-29
**Sovereignty:** Rule 7 (One Breaking-Change Point) — docs must reflect current state.
**Why:** lualine adapter shows SDK version + env name in statusline; icon and config options need README documentation.

**Scope:**

- Document lualine icon configuration options in README
- Add example lualine config snippet showing SDK version + env name display
