# Manual Debugger Testing Guide

This guide walks through testing both debug backends (`dbg_ntv` and `dbg_dap`)
across both project types (pixi and uv) using the sample projects in
`tests/mojo_samples/`.

## Prerequisites

- Neovim 0.10+
- [mojo.nvim] installed and configured
- Mojo SDK installed (1.0.0b2+)
- For **pixi** project: [`pixi`] installed
- For **uv** project: [`uv`] installed
- For **dbg_dap**: [nvim-dap] + `mojo-lldb-dap` binary available

## Test Projects

| Project        | Location                             | Env Manager |
| -------------- | ------------------------------------ | ----------- |
| test-mojo-pixi | `tests/mojo_samples/test-mojo-pixi/` | pixi        |
| test-mojo-uv   | `tests/mojo_samples/test-mojo-uv/`   | uv          |

Both projects contain the same `main.mojo`:

```mojo
def main():
    print("Hello, debug!")

    var counter: Int = 0
    for i in range(5):
        counter += i + 1
        print("Step", i, "counter =", counter)

    print("\nFinal counter:", counter)
```

## Quick Health Check

Before testing, verify the plugin sees your tools:

```
:checkhealth mojo
```

You should see `mojo` and `mojo-lldb` (or `mojo-lldb-dap`) reported as found.

---

## 1. Testing Native Debugger (`dbg_ntv`)

The native debugger opens a terminal buffer running `mojo-lldb` directly.
Keybindings in normal mode: `r` run, `n` next, `s` step, `c` continue,
`v` variables, `b` sync breakpoints, `q` close.

### 1a. With pixi project

```bash
# 1. Open the project in Neovim
cd tests/mojo_samples/test-mojo-pixi
pixi install          # ensure dependencies are installed
pixi shell -e nvim    # or just open nvim from pixi shell
```

```
:e main.mojo
" Set a breakpoint at line 6 (counter += i + 1)
:Mojo debug-native
```

**What to verify:**

| Step | Action                                     | Expected                                                                                                     |
| ---- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| 1    | `:MojoDebugNative` or `:Mojo debug-native` | Terminal split opens with LLDB. Should see `(lldb)` prompt. Build completes without errors.                  |
| 2    | Press `r` (run)                            | Program runs and stops at breakpoint (line 6). Output shows `Hello, debug!` then `stop reason = breakpoint`. |
| 3    | Press `c` (continue)                       | Program continues, hits breakpoint again on next loop iteration.                                             |
| 4    | Press `c` repeatedly 5 times               | After the loop finishes, see `Final counter: 15`. Program exits normally.                                    |
| 5    | Press `v` (frame variable)                 | Shows local variables (`counter`, `i`).                                                                      |
| 6    | Press `q`                                  | Terminal closes.                                                                                             |

### 1b. With uv project

```bash
cd tests/mojo_samples/test-mojo-uv
uv sync                # install mojo into .venv
source .venv/bin/activate  # activate the venv
nvim main.mojo
```

```
:Mojo debug-native
```

**What to verify:** Same steps as 1a. However, on macOS the mojo binary
installed via uv lacks debugger entitlements. You may see:

> The mojo binary installed via uv/PyPI lacks macOS debugger entitlements.

If this happens, you have two options:

1. **Re-sign the binary** (temporary fix):

   ```bash
   codesign --force --sign - --entitlements debug.plist $(which mojo)
   ```

   Create `debug.plist` with:

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0"><dict><key>com.apple.security.get-task-allow</key><true/></dict></plist>
   ```

2. **Use pixi** (recommended for debugging) — pixi-installed mojo has
   the correct entitlements.

---

## 2. Testing DAP Debugger (`dbg_dap`)

Requires [nvim-dap] installed. The plugin auto-configures the adapter when
`mojo-lldb-dap` is found. Set a breakpoint with nvim-dap's keybinding
(default: `<leader>db` or `:DapToggleBreakpoint`).

### 2a. With pixi project

```bash
cd tests/mojo_samples/test-mojo-pixi
pixi install
pixi shell -e nvim
```

```
:e main.mojo
" Set a breakpoint at line 6
<leader>db    " or :DapToggleBreakpoint
:Mojo debug-dap
```

**What to verify:**

| Step | Action                               | Expected                                                           |
| ---- | ------------------------------------ | ------------------------------------------------------------------ |
| 1    | Toggle breakpoint                    | See breakpoint sign in the gutter.                                 |
| 2    | `:MojoDebugDap` or `:Mojo debug-dap` | nvim-dap session starts. Debugger pauses at entry (`stopOnEntry`). |
| 3    | Press `<F5>` (continue)              | Runs until your breakpoint at line 6.                              |
| 4    | Press `<F5>` again                   | Next loop iteration.                                               |
| 5    | Press `<F10>` (step over)            | Steps to next line in the loop.                                    |
| 6    | Hover over `counter`                 | Shows variable value (if nvim-dap-ui is installed).                |
| 7    | Press `<F5>` until exit              | Program completes.                                                 |

### 2b. With uv project

```bash
cd tests/mojo_samples/test-mojo-uv
uv sync
source .venv/bin/activate
nvim main.mojo
```

```
:Mojo debug-dap
```

**Same caveat as native:** uv-installed mojo may lack entitlements on macOS.
Use pixi or re-sign as described in section 1b.

---

## 3. Verifying Breakpoint Sync (`dbg_ntv`)

The native debugger syncs editor breakpoints to LLDB.

```bash
cd tests/mojo_samples/test-mojo-pixi
pixi shell -e nvim
```

```
:e main.mojo
" Toggle a breakpoint at line 4
<leader>db
" Toggle another at line 7
<leader>db    " move cursor to line 7, then toggle
:Mojo debug-native
```

**What to verify:**

- When LLDB starts, it should output `Breakpoint 1: where = main::main` at the
  correct file and lines.
- Press `r` → stops at the first breakpoint.
- Press `b` → syncs current breakpoints (removed/added after start).
- Save the file (`:w`) → breakpoints re-sync automatically.

---

## 4. Verifying the Statusline Indicator

With any Mojo file open, the statusline should show:

| State               | Indicator                                      |
| ------------------- | ---------------------------------------------- |
| No debug session    | `dbg_ntv` and/or `dbg_dap` (greyed, available) |
| Native debug active | `dbg_ntv` (highlighted)                        |
| DAP debug active    | `dbg_dap` (highlighted)                        |

Test by starting and stopping each backend and watching the indicator change.

---

## 5. Test Matrix Summary

| Project | Backend | Command              | macOS entitlement? |
| ------- | ------- | -------------------- | ------------------ |
| pixi    | native  | `:Mojo debug-native` | Yes (built-in)     |
| pixi    | dap     | `:Mojo debug-dap`    | Yes (built-in)     |
| uv      | native  | `:Mojo debug-native` | Needs re-sign      |
| uv      | dap     | `:Mojo debug-dap`    | Needs re-sign      |

---

## Troubleshooting

### "mojo binary not found"

The plugin can't find `mojo` on PATH. Make sure you've activated the
correct environment:

- pixi: run `pixi shell` before starting nvim, or use the `:terminal`
  integration that inherits pixi's env.
- uv: run `source .venv/bin/activate` before nvim.

### "mojo-lldb not found"

Native debug requires `mojo-lldb` (comes with pixi-installed mojo).
Run `which mojo-lldb` to check. The uv-installed mojo package may not
include it — use pixi for debug testing.

### "mojo-lldb-dap not found"

DAP debug requires `mojo-lldb-dap`. Check with `which mojo-lldb-dap`.
This binary is included with pixi-installed mojo.

### Build failure

The debug build runs `mojo build --debug-level=full -O0`. Check that
`main.mojo` compiles without errors:

```bash
mojo build main.mojo
```

### LLDB attach error (macOS)

If you see `Not allowed to attach to process`, the mojo binary lacks
`com.apple.security.get-task-allow`. See section 1b for the workaround.

---

[mojo.nvim]: https://github.com/Sarctiann/mojo.nvim
[nvim-dap]: https://github.com/mfussenegger/nvim-dap
[`pixi`]: https://pixi.sh
[`uv`]: https://docs.astral.sh/uv
