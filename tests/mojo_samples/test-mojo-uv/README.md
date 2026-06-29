# test-mojo-uv

uv-based Mojo project for debugger testing.

> **macOS caveat:** uv-installed mojo lacks debugger entitlements.
> Native and DAP debug will fail with `Not allowed to attach to process`.
> To fix, re-sign the binary (see below) or use pixi.

## Setup

```bash
cd tests/mojo_samples/test-mojo-uv
uv sync
source .venv/bin/activate
nvim main.mojo
```

## macOS Re-sign Workaround

```bash
cat > debug.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>com.apple.security.get-task-allow</key><true/></dict></plist>
EOF
codesign --force --sign - --entitlements debug.plist $(which mojo)
```

## Workflow 1 — Native Debugger (`dbg_ntv`)

Uses `mojo-lldb` in a terminal split. Keybindings (normal mode): `r` run,
`n` next, `s` step, `c` continue, `v` variables, `b` sync breakpoints, `q` close.

| Step | Action                 | Expected                                                                     |
| ---- | ---------------------- | ---------------------------------------------------------------------------- |
| 1    | `:Mojo debug-native`   | Terminal split opens with `(lldb)` prompt. Build completes.                  |
| 2    | Press `r`              | Runs, stops at breakpoint (if set). Shows `Hello, debug!`.                   |
| 3    | Press `c`              | Continues to next breakpoint or exit.                                        |
| 4    | Press `v`              | Shows frame variables (`counter`, `i`).                                      |
| 5    | Press `q`              | Terminal closes.                                                             |

If `mojo-lldb` is not available in the uv venv, native debug falls back to
`:MojoDebug` (terminal `mojo debug`).

## Workflow 2 — DAP Debugger (`dbg_dap`)

Requires [nvim-dap]. Uses `mojo-lldb-dap` with nvim-dap UI.

| Step | Action                 | Expected                                                          |
| ---- | ---------------------- | ----------------------------------------------------------------- |
| 1    | Toggle breakpoint at line 6 | `<leader>db` — breakpoint sign appears in gutter.           |
| 2    | `:Mojo debug-dap`      | nvim-dap session starts, pauses at entry.                          |
| 3    | `<F5>` (continue)      | Runs to breakpoint at line 6.                                      |
| 4    | `<F10>` (step over)    | Steps to next line.                                                |
| 5    | `<F5>` until exit      | Program completes.                                                 |

## Statusline

| State               | Indicator               |
| ------------------- | ----------------------- |
| No session          | `dbg_ntv` / `dbg_dap` (dimmed) |
| Native debug active | `dbg_ntv` (highlighted) |
| DAP debug active    | `dbg_dap` (highlighted) |

[nvim-dap]: https://github.com/mfussenegger/nvim-dap
