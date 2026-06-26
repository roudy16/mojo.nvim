---
name: mojo-community-post
description: Use when writing community update posts about mojo.nvim for Discord, Reddit, or other channels. Triggered by "write a post", "share an update", "draft a message".
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  scope: project
---

# Community Post

Write short update posts about mojo.nvim for community channels.

## When to use

- A new feature was shipped and needs to be announced
- A VS Code release was audited and the gap is closing
- The plugin reached a milestone worth sharing

## Format

```
🔥 **mojo.nvim update**

<1-2 sentences about what triggered this update>

**What we already support:**

- **Feature name** *(plugin)* — description
- **Feature name** — description

**Next up:** <teaser>

https://github.com/Sarctiann/mojo.nvim
```

## Rules

- Keep posts short — Discord-friendly
- Lead with the trigger (new release, new feature, etc.)
- One feature per bullet, grouped logically
- `**Feature** *(plugin)* — desc` for plugin integrations
- `**Feature** — desc` for self-contained features
- "Next up" only if there are concrete plans
- Always include the repo link at the bottom

## Reference

See `docs/posts/TEMPLATE.md` for the annotated template with examples.
