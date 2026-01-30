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

---

## Updating

1. Read the doc fully before editing
2. Make targeted changes
3. Update `overview.md` status if needed
