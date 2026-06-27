# Community Post Template

Use this template to write update posts about mojo.nvim for Discord, Reddit, or other
community channels.

## Format

```
🔥 **mojo.nvim update**

<1-2 sentences about what triggered this update>

**What we already support:**

- **<Feature name>** *(<related neovim plugin>)* — <brief description>
- **<Feature name>** — <brief description (no plugin needed)>

**Next up:** <teaser about what's coming>

<repo link>
```

## Annotations

Each feature line has one of two formats:

| Format | When |
|--------|------|
| `**Feature** *(plugin)* — description` | Feature integrates with a generic Neovim plugin (nvim-dap, nvim-lspconfig, conform.nvim, etc.) |
| `**Feature** — description` | Feature is self-contained (env detection, syntax, etc.) |

## Rules

- Keep the post short — Discord-friendly (no walls of text)
- Lead with what triggered the post (new VS Code release, new feature shipped, etc.)
- "Next up" is optional — only include if you have concrete plans
- Always include the repo link at the bottom
- Use bold for feature names, italics in parentheses for plugin references
- One feature per bullet, grouped logically

## Example

```markdown
🔥 **mojo.nvim update**

We audited the latest `vscode-mojo` v26.6.0 against mojo.nvim and the gap is narrowing fast.

**What we already support:**

- **Syntax highlighting & Treesitter** *(nvim-treesitter)* — self-hosted parser, auto-rebuilds on grammar changes
- **LSP: completions, diagnostics, hover, go-to-symbol** *(nvim-lspconfig + nvim-cmp / blink.cmp)* — env-aware `mojo-lsp-server` resolution
- **Code formatting** *(conform.nvim)* — `mojo format` with env-aware binary discovery
- **Debugging** *(nvim-dap)* — integrates the official `mojo-lldb-dap` server, supports `mojoFile` (compiles `.mojo` on the fly), `buildArgs`, binary debug, and attach-to-process
- **Terminal env auto-activation** — pixi/venv activated transparently in new terminals
- **Environment detection** — pixi `.pixi/` + `.venv` autodetection, PATH fallback
- **Statusline integration** *(lualine.nvim)* — shows env type/name
- **Completion sources** — 56 keywords, 42 builtins, 34 stdlib types, 13 snippets
- **Distro adapters** — LazyVim, AstroNvim, NvChad, kickstart.nvim

**Next up:** SDK version in status bar, LSP health indicator, `mojo.sdk.path` override, `.derived/` monorepo detection, refresh/restart commands.

https://github.com/Sarctiann/mojo.nvim
```
