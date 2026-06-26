---
name: mojo-task-workflow
description: Use when executing a task from docs/TODO.md. Covers the full lifecycle: identify → spec → plan → implement → docs → merge.
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  scope: project
---

# Task Workflow

Full lifecycle for taking a TODO.md item to completion on `main`.

## Steps

### 1. Identify the task

Pick the highest-priority pending item from `docs/TODO.md`.
Create branch from `main` named after the task:

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

Execute each task from the plan. Use `executing-plans` skill for inline execution,
or `subagent-driven-development` for isolated per-task subagents.

Follow project conventions:
- One commit per logical step
- Commit messages use conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`)
- No commits without user request

### 5. Update documents

After implementation:
- `README.md` — add feature to "What it provides" and add a details block
- `AGENTS.md` — only if sovereignty rules or conventions change
- `docs/TODO.md` — mark task as complete, re-number items
- `docs/posts/` — optionally draft a community post

### 6. Merge to main

Load `finishing-a-development-branch` skill.
Verify tests pass, merge to `main`, delete branch.
