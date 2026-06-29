---
name: mojo-task-workflow
description: Use when executing any task from docs/TODO.md. Covers the full lifecycle: identify → spec → plan → implement → docs → PR.
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

## ⚠️ CRITICAL RULE: Never touch main

**NEVER make changes directly on the `main` branch.** All work happens on
feature branches. Main is always stable, always deployable, always clean.

## Steps

### 1. Identify the task

Pick the highest-priority pending item from `docs/TODO.md` (P0 before P1,
P1 before P2).

**Staleness check:** If the task's `Updated` date is 7 or more days old, load
`mojo-todo-update` first to verify the task is still relevant and up-to-date.
Resume only after the review is complete and the task has been refreshed.

Create a branch from `main`:

```
git checkout main
git pull origin main
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

### 6. Open a PR to main

Load `finishing-a-development-branch` skill.
Verify tests pass.

**NEVER merge directly to `main` locally.** Instead, push the branch and open
a pull request against `main` on the remote:

```
git push origin feat/<task-name>
gh pr create --base main --head feat/<task-name> --title "<description>"
```

The PR workflow keeps `main` protected and provides a review checkpoint before
changes land. Delete the local branch only after the PR is merged.
