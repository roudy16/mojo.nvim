# test-mojo-pixi

Pixi-based Mojo project for debugger testing.

## Setup

```bash
cd tests/mojo_samples/test-mojo-pixi
pixi install
pixi shell -e nvim
nvim main.mojo
```

## Workflow 1 — Native Debugger (`dbg_ntv`)

Uses `mojo-lldb` in a terminal split. Keybindings (normal mode): `r` run,
`n` next, `s` step, `c` continue, `v` variables, `b` sync breakpoints, `q` close.

| Step | Action               | Expected                                                    |
| ---- | -------------------- | ----------------------------------------------------------- |
| 1    | `:Mojo debug-native` | Terminal split opens with `(lldb)` prompt. Build completes. |
| 2    | Press `r`            | Runs, stops at breakpoint (if set). Shows `Hello, debug!`.  |
| 3    | Press `c`            | Continues to next breakpoint or exit.                       |
| 4    | Press `v`            | Shows frame variables (`counter`, `i`).                     |
| 5    | Press `q`            | Terminal closes.                                            |

## Workflow 2 — DAP Debugger (`dbg_dap`)

Requires [nvim-dap]. Uses `mojo-lldb-dap` with nvim-dap UI.
Binary discovery is configurable via `debug.search_for` in the plugin config.

| Step | Action                      | Expected                                          |
| ---- | --------------------------- | ------------------------------------------------- |
| 1    | Toggle breakpoint at line 6 | `<leader>db` — breakpoint sign appears in gutter. |
| 2    | `:Mojo debug-dap`           | nvim-dap session starts, pauses at entry.         |
| 3    | `<F5>` (continue)           | Runs to breakpoint at line 6.                     |
| 4    | `<F10>` (step over)         | Steps to next line.                               |
| 5    | `<F5>` until exit           | Program completes.                                |

## Breakpoint Sync (`dbg_ntv`)

Editor breakpoints are synced to LLDB on start, save, and manual `b` trigger.

1. Toggle breakpoints at lines 4 and 7 with `<leader>db`
2. `:Mojo debug-native`
3. LLDB output shows `Breakpoint 1: where = main::main` at correct lines
4. Press `r` → stops at first breakpoint
5. `:w` → breakpoints re-sync automatically

## Statusline

| State               | Indicator                      |
| ------------------- | ------------------------------ |
| No session          | `dbg_ntv` / `dbg_dap` (dimmed) |
| Native debug active | `dbg_ntv` (highlighted)        |
| DAP debug active    | `dbg_dap` (highlighted)        |

[nvim-dap]: https://github.com/mfussenegger/nvim-dap
