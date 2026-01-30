# Sales Coach

Track avoided tasks and nudge on sales activities.

---

## Problem

Sales tasks get avoided. Easy to rationalize skipping outreach, follow-ups, content creation. Need accountability partner that doesn't accept excuses.

## Solution

Bot tracks task completion, identifies avoidance patterns, sends escalating nudges.

---

## Tracked Activities

| Activity | Cadence | Nudge Trigger |
|----------|---------|---------------|
| LinkedIn outreach | 3x/week | 2 days missed |
| Follow-up emails | Daily | 1 day missed |
| Content creation | 2x/week | 4 days missed |
| Lead response | <4 hours | 2 hours delayed |

---

## Nudge Escalation

### Level 1: Gentle Reminder
```
Hey, noticed you haven't done any LinkedIn outreach in 2 days.
Quick 15 min session today?
```

### Level 2: Pattern Call-out
```
This is day 4 without outreach. You've avoided this 3 times this month.
What's blocking you? Let's talk about it.
```

### Level 3: Direct Challenge
```
Andrew, you're avoiding sales again. This is why revenue is inconsistent.
I'm blocking your calendar for 30 min right now.
What one outreach can you do in the next 10 minutes?
```

---

## Implementation

### Tracking

Store in memory:
```json
{
  "sales_tracking": {
    "linkedin_outreach": {
      "last_done": "2025-01-28",
      "this_week": 1,
      "target": 3
    },
    "follow_ups": {
      "last_done": "2025-01-29",
      "pending": ["john@acme.com", "sarah@techco.com"]
    }
  }
}
```

### Triggers

- Scheduled check: 10am, 2pm, 5pm
- On session start: "Any avoided tasks?"
- Manual: "What am I avoiding?"

### Skill File

`skills/sales-coach/SKILL.md`:

```markdown
---
name: sales-coach
description: Track sales activities and provide accountability nudges
user-invocable: true
---

# Sales Coach

Track avoided tasks. Provide accountability. No excuses accepted.

## Philosophy

- Be direct, not harsh
- Call out patterns, not incidents
- Offer small next actions
- Celebrate wins genuinely

## Tracked Activities

- LinkedIn outreach (3x/week)
- Follow-up emails (daily)
- Content creation (2x/week)
- Lead response (<4 hours)

## Commands

- "What am I avoiding?" - Show patterns
- "Log [activity]" - Mark complete
- "Streak" - Show current streaks

## Nudge Rules

- Day 1 missed: Gentle reminder
- Day 2+: Call out pattern
- Day 4+: Direct challenge
- Never shame, always redirect to action
```

---

## Memory Integration

Use OpenClaw's memory to persist:
- Activity timestamps
- Completion streaks
- Avoidance patterns
- Wins/milestones

---

## Success Criteria

- [ ] Tracks activity completion
- [ ] Sends nudges on avoidance
- [ ] Escalates appropriately
- [ ] User actually does more sales tasks
