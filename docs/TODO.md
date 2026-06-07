# mojo.nvim — TODO

> Priorities are based on AGENTS.md sovereignty rules. P0 = blocks sovereignty.

## Workflow Rules

1. **One branch per task** — each item below is done in a separate branch from `main`. No mixing concerns.
2. **No commits without request** — never commit unless I explicitly ask.
3. **Merge then next** — once tested and committed, merge to `main`, then start the next task on a fresh branch.

---

## Support popular Neovim tools with README documentation

**Scope:** Ongoing — new tools are added here as they're identified.

| Tool           | Needs adapter? | Needs README? | Notes                              |
| -------------- | -------------- | ------------- | ---------------------------------- |
| lualine.nvim   | Yes            | Done          | Adapter + statusline component        |
| AstroNvim      | No             | Done          | Config format in README            |
| NvChad         | No             | Done          | Config format in README            |
| kickstart.nvim | No             | Done          | Minimal config in README           |
| nvim-dap       | Blocked        | Blocked       | No Mojo DAP adapter exists yet     |
| neotest        | Blocked        | Blocked       | `mojo test` not stable yet         |
| nvim-lint      | Blocked        | Blocked       | No Mojo linter binary exists       |
