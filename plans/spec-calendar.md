# Calendar Skill

Daily calendar briefings and event management.

---

## Problem

Meetings sneak up. Need proactive reminders and daily schedule overview.

## Solution

Morning briefing with day's events plus smart reminders for prep.

---

## Morning Briefing

```
📅 Today (Jan 30)

9:00 - Team standup (15 min)
11:00 - Demo with Acme Corp [Prep: review their website]
2:00 - 1:1 with Sarah
4:30 - Free block

Tomorrow preview:
• 10:00 - Investor call [High priority]

Prep reminders:
• Acme demo in 2 hours - review notes?
```

---

## Capabilities

| Command | Action |
|---------|--------|
| "What's today?" | Full day schedule |
| "Tomorrow?" | Next day preview |
| "Free time this week?" | Open slots |
| "Schedule call with [name]" | Suggest times |

---

## Implementation

### MCP Server

Use `@pegasusheavy/google-mcp`:
- `calendar_today` - Today's events
- `calendar_upcoming` - Future events
- `calendar_list_events` - Date range query
- `calendar_create_event` - Scheduling

### Skill File

`skills/calendar/SKILL.md`:

```markdown
---
name: calendar
description: Daily calendar briefings and event management
user-invocable: true
---

# Calendar Assistant

Provide schedule overviews and manage events.

## Triggers

- "What's today?" - Day schedule
- "Calendar" - Same as above
- Scheduled: 7am daily briefing

## Prep Reminders

For important meetings, remind 2 hours before with:
- Meeting context
- Attendee info
- Suggested prep actions

## Rules

- Always show time zone
- Flag conflicts
- Note travel time between locations
```

---

## Success Criteria

- [ ] Morning briefing at 7am
- [ ] Prep reminders before important meetings
- [ ] Can query free slots
