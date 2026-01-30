# Tools

Local configuration and access notes.

---

## Accounts Configured

| Service | Status | Notes |
|---------|--------|-------|
| Gmail | Pending | Via google-mcp |
| Google Calendar | Pending | Via google-mcp |
| PostHog | Pending | API key needed |
| Notion | Pending | API key needed |
| GitHub | Pending | Token needed |
| Apollo | Ready | Via apollo MCP |
| Perplexity | Ready | Via perplexity MCP |
| Apify | Ready | Via apify MCP |

---

## API Keys Location

All keys stored as environment variables, never in config files.

```bash
# Check what's set
fly secrets list -a ap-assist-agent
```

---

## Google OAuth Setup

1. Google Cloud Console → APIs & Services → Credentials
2. Create OAuth 2.0 Client ID (Desktop app)
3. Set `GOOGLE_OAUTH_CLIENT_ID` and `GOOGLE_OAUTH_CLIENT_SECRET`
4. First use will prompt for auth flow

---

## PostHog Setup

1. PostHog → Settings → Project API Key
2. Set `POSTHOG_API_KEY` and `POSTHOG_PROJECT_ID`
3. API endpoint: `https://app.posthog.com/api/`

---

## Fidelity (Manual)

No API available. Use CSV export workflow:
1. Login to Fidelity
2. Accounts → Positions → Export
3. Save to `workspace/finance/positions.csv`
4. Tell bot: "Import portfolio"

---

*Update this as services are configured.*
