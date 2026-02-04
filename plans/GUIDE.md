# Planning Guide

How to write and maintain specs in this project.

---

## Structure

```
plans/
├── GUIDE.md              # This file
├── spec-*.md             # Feature specs
├── research-*.md         # Analysis docs
└── _archive/             # Superseded docs
```

---

## Spec Template

```markdown
# Feature Name

One sentence: what it does.

---

## Problem

What pain this solves.

## Solution

How we solve it.

## Implementation

Technical approach, file changes, config.

## Success Criteria

How we know it worked.
```

---

## Writing Style

| Do | Don't |
|----|-------|
| Direct statements | "It appears that..." |
| Tables for comparisons | Walls of text |
| Code blocks for config | Prose descriptions |
| Lead with findings | "After analyzing..." |

---

## Naming

- `spec-*.md` — Feature specifications
- `research-*.md` — Analysis and feasibility studies
- `_archive/` — Superseded docs (don't delete, move)

## Key Specs

| Spec | Purpose |
|------|---------|
| `spec-webhooks.md` | External HTTP triggers, endpoint formats, PageLines integration |
| `spec-lead-handler.md` | Lead qualification workflow |
| `spec-deploy.md` | Deployment procedures |

---

## Updating

1. Read the doc fully before editing
2. Make targeted changes
3. Update `overview.md` status if needed

---

## Bot Memory Maintenance

Guidelines for keeping the bot's memory files accurate.

### File Ownership

| File | Owner | Purpose |
|------|-------|---------|
| TOOLS.md | Human | Reference for current tools, APIs, skills |
| USER.md | Human | Info about Andrew |
| MEMORY.md | Bot | Log of learnings, decisions, milestones |
| CONTACTS.md | Bot | People the bot learns about |

### When to Update

**TOOLS.md** (human maintains):
- When APIs are added, removed, or change status
- When skills are created or modified
- When OAuth tokens are refreshed or reconfigured

**MEMORY.md** (bot maintains):
- When significant decisions are made
- When new facts are learned about projects/people
- When milestones are reached

### Don't Modify

- Bot-added entries in MEMORY.md (unless outdated or instructed)
- Bot-added contacts in CONTACTS.md
- Daily logs in memory/ folder
