---
name: mojo-task-workflow
description: Use when executing any task from docs/TODO.md. Covers the full lifecycle: identify → spec → plan → implement → docs → merge.
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  scope: project
---

# Task Workflow

Full lifecycle for taking a `docs/TODO.md` item to completion on `main`.
This skill **consumes** TODO entries — it does not define them (see
`mojo-todo-update` for that).

If during implementation you discover something that should be tracked but
isn't, load `mojo-todo-update` to update the TODO, then resume here.

## Steps

### 1. Identify the task

Pick the highest-priority pending item from `docs/TODO.md` (P0 before P1,
P1 before P2). Create a branch from `main`:

```
git checkout -b feat/<task-name>
```

### 2. Spec (if needed)

If the task introduces a new subsystem or significant behavior:

- Load `brainstorming` skill
- Create a spec at `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
- Get user approval before proceeding

For trivial tasks or pure bugfixes, skip the spec.

### 3. Plan

Write an implementation plan at `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`.
Load `writing-plans` skill for the format. Get user approval on execution approach.

### 4. Implement

Execute each task from the plan. Use `executing-plans` for inline execution,
or `subagent-driven-development` for isolated per-task subagents.

Project conventions:
- One commit per logical step
- Conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`)
- No commits without user request

### 5. Update documents

- `README.md` — add to "What it provides" + feature details block
- `AGENTS.md` — only if sovereignty rules or conventions change
- `docs/posts/` — optionally draft a community update post (see `mojo-community-post`)

Then load `mojo-todo-update` to mark the task as `[done]` and re-number.

Finally, load `update-docs` to audit cross-document consistency and suggest
any remaining doc improvements before merging.

### 6. Merge to main

Load `finishing-a-development-branch` skill.
Verify tests pass, merge to `main`, delete branch.
