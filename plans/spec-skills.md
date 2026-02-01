# Skills Architecture

How to build and organize skills for the personal assistant.

---

## Skill vs MCP Decision Matrix

| Use Skill When | Use MCP When |
|----------------|--------------|
| Simple REST API (1-3 endpoints) | Complex OAuth flows |
| Static auth (API key in header) | Multi-step authentication |
| Stateless operations | Needs session management |
| Infrequent use | High-frequency tool calls |
| Custom workflows | Standard CRUD operations |

**Rule of thumb:** If it's just `curl` + API key, make it a skill.

---

## Skill File Format

```markdown
---
name: skill-name
description: One line explaining when to use this skill
emoji: "🔧"
---

# Skill Title

Brief overview of what this skill enables.

## Authentication

**API:** https://api.example.com/v1
**Auth:** Bearer ${ENV_VAR_NAME}

## Common Operations

### Operation Name
\`\`\`bash
curl -s "https://api.example.com/endpoint" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'
\`\`\`

## Workflows

Step-by-step for complex multi-call operations.

## Error Handling

Common errors and how to handle them.
```

---

## Capability Priority Matrix

Based on research: high-volume + high-value = highest ROI.

| Capability | Value | Complexity | Priority |
|------------|-------|------------|----------|
| Email triage & response | 🔴 High | Medium | P0 |
| Calendar management | 🔴 High | Low | P0 |
| Task management | 🔴 High | Low | P0 |
| Lead enrichment | 🟡 Medium | Low | P1 |
| Research (web/company) | 🟡 Medium | Low | P1 |
| Social posting | 🟡 Medium | Medium | P1 |
| Financial monitoring | 🟡 Medium | High | P2 |
| Image/video generation | 🟢 Low | Medium | P2 |
| SEO research | 🟢 Low | Low | P3 |

---

## Required Skills

### P0 - Daily Operations (build first)

1. **google-workspace** - Gmail, Calendar, Sheets, Drive
2. **ticktick** - Task management (or Sheets-based alternative)
3. **email-assistant** - Templates, triage rules, response drafting

### P1 - Growth & Research

4. **lead-enrichment** - EnrichLayer, LinkedIn lookup (exists)
5. **research** - Perplexity, web search, company intel
6. **social-posting** - Postiz/Mixpost for multi-platform

### P2 - Operations

7. **financial** - Transaction monitoring, subscription tracking
8. **image-gen** - Gemini, other models
9. **discord-ops** - Monitor, respond, engage

### P3 - Specialized

10. **seo-research** - DataForSEO, trends
11. **analytics** - PostHog integration

---

## Tool Recommendations

| Capability | Tool | Pricing | Notes |
|------------|------|---------|-------|
| Tasks | TickTick | Free tier + API | OAuth required |
| Tasks (alt) | Google Sheets | Free | Simpler, no new auth |
| Social posting | Postiz | Self-hosted, free | Best API support |
| Social (alt) | Mixpost | Self-hosted, free | Laravel-based |
| Image gen | Gemini Flash | $0.039/image | Fast, cheap |
| Video gen | Veo 3.1 Fast | $0.15/sec | 720p |
| Research | Perplexity | API pricing | Deep search |
| SEO | DataForSEO | Usage-based | Comprehensive |

---

## Environment Variables Needed

```bash
# Google (OAuth)
GOOGLE_OAUTH_CLIENT_ID=
GOOGLE_OAUTH_CLIENT_SECRET=

# Task Management
TICKTICK_CLIENT_ID=
TICKTICK_CLIENT_SECRET=

# Research
PERPLEXITY_API_KEY=
GEMINI_API_KEY=

# Enrichment
ENRICHLAYER_API_KEY=
APIFY_API_TOKEN=

# Social
POSTIZ_API_KEY=  # if using hosted
# or self-host Postiz/Mixpost

# SEO
DATAFORSEO_USERNAME=
DATAFORSEO_PASSWORD=

# Analytics
POSTHOG_API_KEY=

# Financial (TBD based on bank/service)
PLAID_CLIENT_ID=
PLAID_SECRET=
```

---

## Typical Personal Assistant Tasks

Based on research from executive assistant and chief of staff roles:

### Daily (Automate First)
- Email triage: categorize, prioritize, draft responses
- Calendar: schedule, reschedule, prep meeting briefs
- Task management: capture todos, send reminders, track deadlines
- Communications: route messages, follow up on pending items

### Weekly
- Report preparation: summarize metrics, compile updates
- Scheduling optimization: batch meetings, protect focus time
- Follow-up sequences: check on outstanding items
- Research briefs: competitor updates, industry news

### As-Needed
- Travel arrangements: flights, hotels, itineraries
- Document preparation: decks, memos, summaries
- Contact management: update CRM, enrich new leads
- Social engagement: draft posts, schedule content, monitor mentions

### Strategic (Chief of Staff level)
- Project oversight: track milestones, flag blockers
- Cross-functional coordination: align teams, resolve conflicts
- Analytics review: identify trends, recommend actions
- Process improvement: document workflows, suggest optimizations

---

## Implementation Order

1. **Week 1:** Google Workspace skill (Gmail + Calendar + Sheets)
2. **Week 2:** Task management (TickTick or Sheets-based)
3. **Week 3:** Research skill (Perplexity + web)
4. **Week 4:** Social posting (Postiz setup)
5. **Ongoing:** Add capabilities as needed

---

## Sources

- [Executive Assistant Responsibilities](https://proassisting.com/resources/articles/what-does-an-executive-assistant-do/)
- [AI Personal Assistants ROI 2025](https://kanerika.com/blogs/ai-personal-assistants/)
- [Postiz - Open Source Scheduler](https://github.com/gitroomhq/postiz-app)
- [TickTick Developer API](https://developer.ticktick.com/)
- [Gemini API Pricing](https://ai.google.dev/gemini-api/docs/pricing)
