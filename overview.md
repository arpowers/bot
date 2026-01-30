# AP Bot

Personal AI assistant running on OpenClaw. Handles leads, email, analytics, calendar, sales coaching, social media, and workflow automation.

**Local:** Runs on this machine, skills edited here
**Cloud:** Deployed to Fly.io on push
**Memory:** Synced between local and cloud

---

## Goals

| Area | What it does |
|------|--------------|
| **Lead handling** | Qualify, enrich, draft responses to inbound leads |
| **Email triage** | Scan inbox, summarize, draft replies |
| **Calendar** | Daily briefings, scheduling assistance |
| **Analytics** | PostHog digest, visitor insights |
| **Sales coaching** | Track avoidance, nudge on stalled tasks |
| **Social media** | Content generation, scheduling, posting |
| **Ad management** | Campaign monitoring, optimization suggestions |
| **Workflows** | Replace n8n/Zapier with conversational automation |

---

## Philosophy

| Principle | Meaning |
|-----------|---------|
| **Skills over MCP** | Skills are lighter (~100 tokens vs 8K for MCP), more flexible |
| **Minimal surface** | Only channels/tools actually needed |
| **Memory first** | Persistent context across sessions, synced to repo |
| **Human-in-loop** | Confirmations for emails, CRM adds, high-stakes actions |

---

## Architecture

```
~/dev/bot/                      # This repo IS the OpenClaw state dir
├── openclaw.json               # Gateway config
├── .env                        # Secrets (gitignored)
├── agents/                     # Runtime state (gitignored)
├── skills/                     # Custom skills
├── workspace/                  # OpenClaw workspace
│   ├── IDENTITY.md             # Bot identity (name, vibe)
│   ├── SOUL.md                 # Bot values, boundaries
│   ├── USER.md                 # About you (Andrew)
│   ├── MEMORY.md               # Curated long-term facts
│   ├── TOOLS.md                # Service configs
│   ├── HEARTBEAT.md            # Scheduled tasks
│   ├── AGENTS.md               # Workspace home base
│   ├── CONTACTS.md             # People database
│   ├── TASKS.md                # Sales activity tracking
│   ├── memory/                 # Session transcripts
│   └── finance/                # Fidelity exports
├── config/                     # Extra configs (himalaya)
├── plans/                      # Specs and docs
└── .github/workflows/          # CI/CD
```

**No ~/.openclaw needed.** `run.sh` sets `OPENCLAW_STATE_DIR` to this repo.

---

## Status

| Component | Status | Notes |
|-----------|--------|-------|
| Local gateway | Setup | Run via `openclaw gateway run` |
| Cloud deploy | Setup | Fly.io via GitHub Actions |
| Memory sync | Planned | Cloud → repo sync script |
| Lead handler | Migrate | From automation repo |
| Email skill | Planned | Gmail via google-mcp |
| Analytics skill | Planned | PostHog daily digest |
| Calendar skill | Planned | Google Calendar briefing |
| Sales coach | Planned | Daily nudges |

---

## Use Cases

### 1. Lead Handling (Webhook)
```
n8n webhook → POST /hooks/agent → Bot qualifies, enriches, drafts response → Telegram confirm
```

### 2. Email Triage
```
"Any urgent emails?" → Bot scans inbox → Summarizes → Draft replies on request
```

### 3. Daily Briefing (Scheduled)
```
6am daily → Analytics summary, calendar, pending sales tasks → Telegram
```

### 4. Sales Coaching
```
Bot tracks avoided tasks → Nudges via Telegram → "You've been avoiding outreach for 3 days"
```

### 5. Social Media
```
"Draft a LinkedIn post about our new feature" → Bot writes → You approve → Posts via API
```

### 6. Ad Management
```
"How are my Meta ads doing?" → Bot pulls campaign data → Summarizes spend/ROAS → Suggests optimizations
```

### 7. Workflow Automation
```
Replace n8n/Zapier → "When someone signs up, enrich them and add to CRM" → Bot handles via conversation
```

---

## Channels

| Channel | Purpose |
|---------|---------|
| **Telegram** | Primary interface, notifications, approvals |
| **Webhook** | Inbound triggers from n8n, forms, etc. |

---

## Skills

### Custom (in this repo)

| Skill | Purpose | Status |
|-------|---------|--------|
| `lead-handler` | Qualify, enrich, draft response | Ready |
| `email` | Gmail triage, draft, send | Planned |
| `calendar` | Event briefings, scheduling | Planned |
| `analytics` | PostHog digest, visitor insights | Planned |
| `sales-coach` | Track avoidance, nudge on tasks | Planned |
| `social` | Content generation, scheduling, posting | Planned |
| `ads` | Campaign monitoring, optimization | Planned |
| `finance` | Portfolio tracking from Fidelity | Planned |

### Bundled (enable in config)

| Skill | Purpose |
|-------|---------|
| `github` | PR reviews, issues, repo ops |
| `notion` | Knowledge base, CRM |
| `himalaya` | Email client |
| `coding-agent` | AI-assisted coding |
| `summarize` | Condense content |
| `openai-whisper` | Transcribe voice/meetings |

See [spec-capabilities.md](plans/spec-capabilities.md) for full skill analysis.

---

## Config

### Environment Variables

```bash
# Required
ANTHROPIC_API_KEY          # Claude API
OPENCLAW_GATEWAY_TOKEN     # Gateway security
TELEGRAM_BOT_TOKEN         # Telegram bot

# MCP Servers
GOOGLE_OAUTH_CLIENT_ID     # Google services
GOOGLE_OAUTH_CLIENT_SECRET
PERPLEXITY_API_KEY         # Research
APOLLO_IO_API_KEY          # Lead enrichment
APIFY_API_TOKEN            # Web scraping
POSTHOG_API_KEY            # Analytics
POSTHOG_PROJECT_ID         # Analytics project
```

### Memory Config

```json
{
  "compaction": {
    "memoryFlush": { "enabled": true }
  },
  "memorySearch": {
    "experimental": {
      "sessionMemory": true,
      "sources": ["memory", "sessions"]
    }
  }
}
```

---

## Commands

```bash
# Local development
openclaw gateway run --port 3000       # Start gateway
openclaw health                        # Check status
openclaw doctor                        # Validate config

# Deployment
git push                               # Auto-deploy to Fly.io
fly logs -a ap-assist-agent            # View cloud logs
fly ssh console                        # SSH into cloud

# Memory sync
./scripts/sync-memory.sh               # Pull cloud memory to repo
```

---

## Workspace Files (OpenClaw Standard)

Bot reads these for context. Follows OpenClaw template conventions.

| File | About | Purpose |
|------|-------|---------|
| [IDENTITY.md](workspace/IDENTITY.md) | **Bot** | Name, creature type, vibe, emoji |
| [SOUL.md](workspace/SOUL.md) | **Bot** | Values, boundaries, personality |
| [USER.md](workspace/USER.md) | **You** | Your context, preferences, companies |
| [MEMORY.md](workspace/MEMORY.md) | **Facts** | Curated long-term knowledge |
| [TOOLS.md](workspace/TOOLS.md) | **Config** | Service access, credentials |
| [HEARTBEAT.md](workspace/HEARTBEAT.md) | **Schedules** | Proactive/scheduled tasks |
| [AGENTS.md](workspace/AGENTS.md) | **Operations** | Session guidelines, home base |
| [CONTACTS.md](workspace/CONTACTS.md) | **People** | Clients, leads, partners |
| [TASKS.md](workspace/TASKS.md) | **Sales** | Activity tracking, avoidance |

---

## Specs

| Doc | Purpose |
|-----|---------|
| [spec-setup.md](plans/spec-setup.md) | Installation and configuration |
| [spec-capabilities.md](plans/spec-capabilities.md) | All skills ranked by usefulness |
| [spec-lead-handler.md](plans/spec-lead-handler.md) | Lead qualification workflow |
| [spec-email.md](plans/spec-email.md) | Email triage and response |
| [spec-analytics.md](plans/spec-analytics.md) | PostHog daily digest |
| [spec-calendar.md](plans/spec-calendar.md) | Calendar briefings |
| [spec-sales-coach.md](plans/spec-sales-coach.md) | Sales task coaching |
| [spec-memory-sync.md](plans/spec-memory-sync.md) | Cloud-local memory sync |
| [research-fork.md](plans/research-fork.md) | OpenClaw fork feasibility |

---

## Links

- **OpenClaw Docs:** https://docs.openclaw.ai
- **Fly Dashboard:** https://fly.io/apps/ap-assist-agent
- **Production:** https://assist.andrewpowers.com
