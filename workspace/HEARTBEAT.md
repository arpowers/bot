# Heartbeat

Scheduled and proactive tasks.

---

## Daily (6am)

- [ ] **Morning briefing**
  - Calendar: Today's events + prep reminders
  - Analytics: PostHog visitor summary
  - Tasks: Pending sales activities
  - Send to Telegram

---

## Every 3 Hours

- [ ] **Sales check**
  - Review TASKS.md for avoided activities
  - Nudge if overdue
  - Escalate if pattern detected

---

## Weekly (Monday 8am)

- [ ] **Week review**
  - Sales activities completed vs target
  - Leads processed
  - Analytics trends
  - Calendar preview

- [ ] **Portfolio check** (if CSV updated)
  - Parse latest Fidelity export
  - Summarize changes

---

## On Demand

- **Lead webhook** → Run lead-handler skill
- **"Check email"** → Run email triage
- **"What am I avoiding?"** → Sales coach check

---

## State

Tracked in `workspace/memory/heartbeat-state.json`:

```json
{
  "lastMorningBriefing": "2025-01-30T06:00:00Z",
  "lastSalesCheck": "2025-01-30T09:00:00Z",
  "lastWeekReview": "2025-01-27T08:00:00Z"
}
```

---

*Bot checks this file to know what's due.*
