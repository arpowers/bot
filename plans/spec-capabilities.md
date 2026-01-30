# Bot Capabilities

Complete list of skills and integrations, ranked by usefulness.

---

## Profile Context

**You:** Solo founder running PageLines (consulting) + Fiction (product). Need help with:
- Lead handling and sales (you avoid these)
- Email triage
- Analytics (PostHog)
- Calendar management
- Financial tracking (Fidelity)
- Content creation
- Research

---

## Tier 1: Must Have

Skills you'll use daily.

| Skill | What It Does | Source |
|-------|--------------|--------|
| **lead-handler** | Qualify leads, enrich, draft response, confirm | Custom |
| **email** | Gmail triage, summarize, draft replies | Custom + google-mcp |
| **calendar** | Daily briefing, prep reminders, scheduling | Custom + google-mcp |
| **sales-coach** | Track avoided tasks, nudge on sales activities | Custom |
| **analytics** | PostHog daily digest, visitor insights | Custom |
| **github** | PR reviews, issue management, repo ops | Bundled |
| **notion** | Knowledge base, CRM, task management | Bundled |

---

## Tier 2: High Value

Weekly use, significant time savings.

| Skill | What It Does | Source |
|-------|--------------|--------|
| **himalaya** | Email client (alternative to google-mcp) | Bundled |
| **coding-agent** | AI-assisted coding in conversations | Bundled |
| **summarize** | Condense long content, meeting notes | Bundled |
| **weather** | Daily briefing context | Bundled |
| **slack** | Team comms if you use Slack | Bundled |
| **trello** | Board management if you use Trello | Bundled |
| **things-mac** | Task management (macOS) | Bundled |
| **apple-reminders** | Quick capture, reminders | Bundled |
| **obsidian** | Notes/PKM if you use Obsidian | Bundled |

---

## Tier 3: Useful Occasionally

Nice to have, not critical.

| Skill | What It Does | Source |
|-------|--------------|--------|
| **openai-whisper** | Transcribe voice notes, meetings | Bundled |
| **openai-image-gen** | Generate images for content | Bundled |
| **blogwatcher** | Monitor competitor blogs | Bundled |
| **session-logs** | Review past conversations | Bundled |
| **model-usage** | Track API costs | Bundled |
| **skill-creator** | Build new skills dynamically | Bundled |
| **spotify-player** | Music control | Bundled |
| **discord** | Community management | Bundled |

---

## Tier 4: Niche/Skip

Unlikely to use unless specific need.

| Skill | What It Does | Why Skip |
|-------|--------------|----------|
| 1password | Credential management | Security risk |
| apple-notes | Notes | Use Notion/Obsidian instead |
| bear-notes | Notes | Use Notion/Obsidian instead |
| bluebubbles | iMessage server | Complex setup |
| camsnap | Camera capture | Niche |
| canvas | LMS integration | Not relevant |
| eightctl | Eight Sleep control | Hardware-specific |
| food-order | Food ordering | Niche |
| gemini | Google AI | Already using Claude |
| gifgrep | GIF search | Trivial |
| gog | Gaming | Not relevant |
| goplaces | Navigation | Use phone |
| imsg | iMessage | Use Telegram |
| local-places | Local search | Use phone |
| mcporter | MCP bridge | Meta-tool |
| openhue | Lighting | Hardware-specific |
| oracle | Database | Enterprise |
| peekaboo | Image viewer | Niche |
| sherpa-onnx-tts | TTS | Niche |
| sonoscli | Sonos control | Hardware-specific |
| tmux | Terminal | Dev-specific |
| video-frames | Video processing | Niche |
| voice-call | VoIP | Use phone |
| wacli | WhatsApp CLI | Use Telegram |

---

## Custom Skills Needed

### PostHog Analytics

PostHog has a REST API we can use directly.

**Approach:**
1. Create `skills/posthog/SKILL.md`
2. Use PostHog API for queries
3. Or use n8n workflow triggered by bot

**Key endpoints:**
- `GET /api/projects/{id}/insights/` - Saved insights
- `POST /api/projects/{id}/query/` - HogQL queries
- `GET /api/projects/{id}/persons/` - Identified visitors

**Daily digest query:**
```sql
SELECT
  count() as visitors,
  uniq(distinct_id) as unique_visitors,
  properties.$current_url as page
FROM events
WHERE timestamp > now() - interval 1 day
GROUP BY page
ORDER BY visitors DESC
LIMIT 10
```

**MCP Option:** [Composio PostHog MCP](https://mcp.composio.dev/posthog)

---

### Financial Tracking (Fidelity)

**Challenge:** Fidelity doesn't have a public API for retail accounts.

**Options:**

| Approach | Pros | Cons |
|----------|------|------|
| **Manual CSV export** | Simple, secure | Manual effort |
| **fidelity-api (Python)** | Automated | Unofficial, may break |
| **SnapTrade** | Official integration | Read-only, no trades |
| **Plaid** | Bank-grade | Expensive, overkill |

**Recommendation:** Start with manual CSV import.

1. Export positions weekly from Fidelity
2. Drop CSV in `memory/finance/`
3. Bot parses and summarizes

**Skill design:**
```markdown
# Finance Tracker

Track investment portfolio from CSV exports.

## Commands

- "Portfolio summary" - Current holdings, allocation
- "Performance" - Gains/losses, % change
- "Import [file]" - Parse new export

## Data location

memory/finance/positions.csv
```

**Future:** If automation needed, use [fidelity-api](https://github.com/kennyboy106/fidelity-api) Python package with Playwright.

---

## MCP Servers to Enable

Already configured in your setup:

| MCP | Purpose | Status |
|-----|---------|--------|
| **google-mcp** | Gmail, Calendar, Drive, Sheets | Ready |
| **apollo** | Lead enrichment | Ready |
| **perplexity** | Research | Ready |
| **apify** | Web scraping, LinkedIn | Ready |
| **prospect** | Lead enrichment | Ready |
| **dataforseo** | SEO/keyword data | Ready |

**Add:**

| MCP | Purpose | Install |
|-----|---------|---------|
| **posthog** | Analytics queries | `composio` or custom |

---

## Recommended Skill Set

For your use case, enable these:

```json
{
  "skills": {
    "load": {
      "include": [
        "github",
        "notion",
        "himalaya",
        "coding-agent",
        "summarize",
        "weather",
        "session-logs",
        "model-usage",
        "openai-whisper"
      ]
    }
  }
}
```

Plus your custom skills:
- `lead-handler`
- `email`
- `calendar`
- `analytics`
- `sales-coach`
- `finance`

---

## Implementation Priority

| Priority | Skill | Effort | Impact |
|----------|-------|--------|--------|
| 1 | lead-handler | Done | High |
| 2 | email | Low | High |
| 3 | sales-coach | Medium | High |
| 4 | calendar | Low | Medium |
| 5 | analytics (PostHog) | Medium | Medium |
| 6 | finance | Low | Low |

---

## Sources

- [PostHog API Docs](https://posthog.com/docs/api)
- [PostHog n8n Integration](https://n8n.io/integrations/posthog/)
- [Composio PostHog MCP](https://mcp.composio.dev/posthog)
- [fidelity-api Python](https://github.com/kennyboy106/fidelity-api)
- [SnapTrade Fidelity](https://snaptrade.com/brokerage-integrations/fidelity-api)
