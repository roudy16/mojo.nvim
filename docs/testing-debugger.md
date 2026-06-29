# Manual Debugger Testing Guide

Tests both debug backends (`dbg_ntv`, `dbg_dap`) across pixi and uv projects
using the sample projects in `tests/mojo_samples/`.

## Prerequisites

- Neovim 0.10+
- [mojo.nvim] installed and configured
- Mojo SDK 1.0.0b2+
- For **pixi**: [`pixi`] installed
- For **uv**: [`uv`] installed
- For **dbg_dap**: [nvim-dap] + DAP binary (`mojo-lldb-dap` on pixi, `lldb-dap` on uv)

## Test Projects

| Project        | Location                             | Env Manager |
| -------------- | ------------------------------------ | ----------- |
| test-mojo-pixi | `tests/mojo_samples/test-mojo-pixi/` | pixi        |
| test-mojo-uv   | `tests/mojo_samples/test-mojo-uv/`   | uv          |

See each project's `README.md` for per-project test workflows.

Both contain the same `main.mojo`:

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

```
:checkhealth mojo
```

Verify `mojo` and a debug binary are found (`mojo-lldb` / `mojo-lldb-dap` on pixi,
`mojo-lldb` / `lldb-dap` on uv).

## Test Matrix

| Project | Backend | Command              | macOS entitlement? |
| ------- | ------- | -------------------- | ------------------ |
| pixi    | native  | `:Mojo debug-native` | Built-in           |
| pixi    | dap     | `:Mojo debug-dap`    | Built-in           |
| uv      | native  | `:Mojo debug-native` | Needs re-sign      |
| uv      | dap     | `:Mojo debug-dap`    | Needs re-sign      |

## Troubleshooting

### "mojo binary not found"

Activate the correct environment before launching Neovim:

- pixi: `pixi shell -e nvim`
- uv: `source .venv/bin/activate`

### Debug binary not found

- **pixi**: `mojo-lldb` and `mojo-lldb-dap` are included.
- **uv**: `mojo-lldb` and `lldb-dap` may not be included. Use pixi for full debug
  or fall back to `:Mojo debug` (terminal `mojo debug`).

### Build failure

```bash
mojo build main.mojo
```

### LLDB attach error (macOS)

`Not allowed to attach to process` means the binary lacks debugger entitlements.
See the uv project README for the re-sign workaround. Use pixi when possible.

[mojo.nvim]: https://github.com/Sarctiann/mojo.nvim
[nvim-dap]: https://github.com/mfussenegger/nvim-dap
[`pixi`]: https://pixi.sh
[`uv`]: https://docs.astral.sh/uv
