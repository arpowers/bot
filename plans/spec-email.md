# Email Skill

Gmail triage, summarization, and response drafting.

---

## Problem

Email piles up. Need quick triage from mobile without opening inbox.

## Solution

Skill that summarizes inbox, identifies urgent items, drafts responses on request.

---

## Capabilities

### Inbox Summary

```
"Any urgent emails?"

→ 3 need attention:
  • John (Acme) - pricing inquiry [Hot]
  • Sarah - contract review, Friday deadline [Urgent]
  • Newsletter from HubSpot [Junk]
```

### Draft Response

```
"Draft reply to John, mention enterprise plan"

→ Draft:
---
Hi John,

Thanks for reaching out about pricing...

---

Send? (y/n/edit)
```

### Quick Actions

| Command | Action |
|---------|--------|
| "Archive newsletters" | Bulk archive by label |
| "Snooze Sarah's email to Monday" | Gmail snooze |
| "Mark all promo as read" | Bulk mark read |

---

## Implementation

### MCP Server

Use `@pegasusheavy/google-mcp` for Gmail access:
- `gmail_list_messages` - Inbox scan
- `gmail_get_message` - Full message
- `gmail_send` - Send (with confirmation)
- `gmail_mark_read` - Mark read
- `gmail_trash` - Delete

### Skill File

`skills/email/SKILL.md`:

```markdown
---
name: email
description: Gmail triage, summarization, and response drafting
user-invocable: true
---

# Email Assistant

Help triage inbox and draft responses.

## Commands

- "Check email" - Summarize unread
- "Any urgent?" - Filter by importance
- "Draft reply to [name]" - Write response
- "Archive [category]" - Bulk archive

## Rules

- Never send without "y" confirmation
- Summarize, don't dump full emails
- Flag time-sensitive items clearly
```

---

## Gmail Labels

| Label | Purpose |
|-------|---------|
| `IMPORTANT` | Gmail's auto-importance |
| `CATEGORY_PROMOTIONS` | Marketing emails |
| `CATEGORY_UPDATES` | Notifications |
| `Needs Reply` | Custom: flagged for response |

---

## Success Criteria

- [ ] "Check email" returns useful summary
- [ ] Can draft and send with confirmation
- [ ] Bulk actions work (archive, mark read)
