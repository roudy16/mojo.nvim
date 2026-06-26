---
name: mojo-todo-update
description: Use when updating docs/TODO.md after auditing a VS Code release, completing a task, or adding new feature requirements.
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  scope: project
---

# TODO Update

Maintain `docs/TODO.md` with accurate feature tracking and task priorities.

## When to use

- A new VS Code extension release was published (check CHANGELOG)
- A task from the TODO was completed (re-number items, update status)
- A new feature gap was discovered
- Prioritization needs review

## Priorities

| Priority | Meaning |
|----------|---------|
| **P0** | Sovereignty gaps — blocks autonomy, env detection, core architecture |
| **P1** | Feature parity — matches VS Code feature, high user impact |
| **P2** | Quality & completeness — docs, polish, minor features |

## Audit table format

When adding a new audit (e.g. after a VS Code release):

```
### Feature Area

| VS Code Feature | Status | Notes |
| --------------- | ------ | ----- |
| Feature name    | ✅/🟡/❌/⏳ | Details and module references |
```

Status key: ✅ implemented | 🟡 partial | ❌ missing | ⏳ blocked by upstream

## Task entry format

```
### N. Task name

**Why:** Context and motivation.

**Scope:**
- Action item 1
- Action item 2
```

## Rules

- Re-number all items after adding/removing any entry
- Existing P2 tools table uses columns: Tool, Needs adapter?, Needs README?, Notes
- Update the audit tables before adding task entries
- Never delete a completed task — mark it as `[done]` or note it inline
