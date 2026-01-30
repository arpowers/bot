# Analytics Skill

Daily digest of website analytics and visitor insights.

---

## Problem

Analytics data sits in PostHog. Need proactive daily summary without logging into dashboards.

## Solution

Scheduled daily briefing with key metrics, notable visitors, and trends.

---

## Daily Digest Format

```
📊 Daily Analytics (Jan 30)

Traffic:
• 1,247 visitors (+12% vs yesterday)
• Top pages: /pricing (342), /features (198)
• Top sources: Google (45%), Direct (28%)

Notable Visitors:
• Acme Corp (3 visits, viewed pricing)
• TechStartup Inc (demo page, 8 min)

Trends:
• Pricing page traffic up 34% this week
• Mobile traffic down 8%

Action items:
• Follow up: Acme Corp (high intent signals)
```

---

## Implementation

### Data Sources

| Source | Data |
|--------|------|
| PostHog | Traffic, events, funnels |
| RB2B | Visitor identification |
| Google Analytics | Backup/comparison |

### Scheduled Trigger

Via OpenClaw heartbeat or n8n webhook:
- 6am daily → trigger analytics skill
- Bot compiles data → sends to Telegram

### Skill File

`skills/analytics/SKILL.md`:

```markdown
---
name: analytics
description: Daily analytics digest and visitor insights
user-invocable: true
---

# Analytics Assistant

Compile and deliver daily analytics briefings.

## Triggers

- "Analytics update" - On-demand summary
- Scheduled: 6am daily briefing

## Data Points

- Traffic: visitors, page views, sources
- Notable: identified visitors with high intent
- Trends: week-over-week comparisons

## Format

Use bullet points. Lead with numbers. Flag action items.
```

---

## PostHog Integration

Query via PostHog API or MCP:
- `/api/projects/{id}/insights/` - Saved dashboards
- `/api/projects/{id}/events/` - Raw events
- Filter by date range, group by page/source

---

## Success Criteria

- [ ] Daily briefing arrives at 6am
- [ ] Shows meaningful metrics (not vanity)
- [ ] Identifies high-intent visitors
- [ ] Suggests follow-up actions
