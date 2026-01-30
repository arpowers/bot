# OpenClaw Setup

Local development and cloud deployment configuration.

---

## Architecture

```
~/dev/bot/                      # This repo (source of truth)
├── openclaw.json               # Gateway config
├── config/
│   ├── mcporter.json           # MCP server config
│   └── himalaya.toml           # Email client config
├── skills/                     # Custom skills
├── workspace/                  # Bot workspace + memory
├── agents/                     # Session state (created at runtime)
├── credentials/                # OAuth tokens (created at runtime)
└── .env                        # Secrets (gitignored)
```

**Key insight:** Set `OPENCLAW_STATE_DIR` to repo root. No symlinks needed. Everything version controlled except secrets and OAuth tokens.

---

## Installation

### 1. Install OpenClaw CLI

```bash
npm install -g openclaw@latest
```

### 2. Run Onboarding

```bash
openclaw onboard --install-daemon
```

Accept the security warning, configure Telegram when prompted.

### 3. Verify Config

Config lives at repo root (`openclaw.json`). The `run.sh` script sets `OPENCLAW_STATE_DIR` to use this directly.

```bash
# Verify config exists
cat openclaw.json | head -10
```

### 4. Create .env File

```bash
cp .env.example .env
# Edit .env and fill in values
```

### 5. Run Locally

```bash
./run.sh
# Or manually:
set -a && source .env && set +a && openclaw gateway run --port 3000
```

---

## Configuration

### Environment Variables

| Variable | Purpose | Required |
|----------|---------|----------|
| `GATEWAY_TOKEN` | Gateway auth | Yes |
| `WEBHOOK_TOKEN` | Webhook auth | Yes |
| `ANTHROPIC_API_KEY` | Claude API | Yes |
| `TELEGRAM_BOT_TOKEN` | Telegram bot | Yes |
| `GOOGLE_OAUTH_CLIENT_ID` | Google services | For email/calendar |
| `GOOGLE_OAUTH_CLIENT_SECRET` | Google services | For email/calendar |
| `PERPLEXITY_API_KEY` | Research | For lead enrichment |
| `APOLLO_API_KEY` | Lead enrichment | For lead enrichment |
| `APIFY_API_TOKEN` | Web scraping | For lead enrichment |

Generate tokens:
```bash
openssl rand -hex 32  # For GATEWAY_TOKEN, WEBHOOK_TOKEN
```

### Config File Schema

Valid root-level keys in `openclaw.json`:

| Key | Purpose |
|-----|---------|
| `gateway` | Port, auth, hooks, bind mode |
| `agents` | Model, workspace, compaction, context pruning |
| `session` | Scope, reset policy, identity links |
| `skills` | Bundled skills, extra directories |
| `plugins` | MCP servers, external tools |
| `channels` | Telegram, Discord, WhatsApp |
| `commands` | Slash commands, restart |
| `tools` | Tool policies, allow/deny lists |

See [docs.openclaw.ai/gateway/configuration](https://docs.openclaw.ai/gateway/configuration) for full schema.

---

## Skills & MCP Servers

OpenClaw uses **skills** for capabilities. External tools (Apify, Apollo, Google) connect via **mcporter**.

### Install mcporter

```bash
npm install -g mcporter@latest
```

### Configure MCP Servers

Config in `config/mcporter.json`:

```json
{
  "mcpServers": {
    "apify": {
      "baseUrl": "https://mcp.apify.com",
      "headers": { "Authorization": "Bearer ${APIFY_API_TOKEN}" }
    },
    "apollo": {
      "command": "npx",
      "args": ["-y", "@thevgergroup/apollo-io-mcp"],
      "env": { "APOLLO_API_KEY": "${APOLLO_API_KEY}" }
    },
    "google": {
      "command": "npx",
      "args": ["-y", "@pegasusheavy/google-mcp@latest"],
      "env": {
        "GOOGLE_OAUTH_CLIENT_ID": "${GOOGLE_OAUTH_CLIENT_ID}",
        "GOOGLE_OAUTH_CLIENT_SECRET": "${GOOGLE_OAUTH_CLIENT_SECRET}"
      }
    }
  }
}
```

### Available Skills

Check with `openclaw skills list`. Key skills:

| Skill | Purpose | Status |
|-------|---------|--------|
| `gemini` | Q&A, summaries, generation | Ready |
| `mcporter` | MCP server connections | Ready |
| `openai-image-gen` | Image generation (DALL-E) | Ready |
| `himalaya` | Email via IMAP/SMTP | Ready |
| `github` | GitHub CLI integration | Ready |
| `lead-handler` | Custom lead processing | Ready |

### Using MCP Tools

Via mcporter CLI:
```bash
mcporter list                    # Show servers
mcporter call apify.search query="scrape linkedin"
mcporter call apollo.enrich_person email="john@example.com"
```

The bot can use these via the mcporter skill.

---

## Cloud Deployment (Fly.io)

### 1. Set Secrets

```bash
fly secrets set \
  GATEWAY_TOKEN="..." \
  WEBHOOK_TOKEN="..." \
  ANTHROPIC_API_KEY="..." \
  TELEGRAM_BOT_TOKEN="..." \
  # ... other secrets
```

### 2. Deploy

Push to GitHub triggers deploy via `.github/workflows/deploy.yml`.

### 3. Environment Overrides

Cloud uses environment variables to override paths:

```bash
BOT_WORKSPACE=/app/workspace
BOT_SKILLS=/app/skills
```

These override the `${BOT_WORKSPACE:-~/dev/bot/workspace}` defaults in config.

---

## Version Control Strategy

| What | Where | Git? |
|------|-------|------|
| Gateway config | `openclaw.json` | Yes |
| MCP config | `config/mcporter.json` | Yes |
| Skills | `skills/` | Yes |
| Workspace | `workspace/` | Yes |
| Memory | `workspace/memory/` | Yes |
| Sessions | `agents/` | No (.gitignore) |
| Secrets | `.env` | No (.gitignore) |
| OAuth tokens | `credentials/` | No (.gitignore) |

### Memory Sync (Cloud → Local)

Cloud writes memory to `workspace/memory/`. Sync script pulls it:

```bash
./scripts/sync-memory.sh
```

See [spec-memory-sync.md](spec-memory-sync.md) for details.

---

## Validation

```bash
# Check config
openclaw doctor

# Health check
openclaw health

# Test webhook
curl -X POST http://localhost:3000/hooks/agent \
  -H "Authorization: Bearer $WEBHOOK_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| "Missing env var" | Run with `set -a && source .env && set +a` prefix |
| "Unrecognized keys" | Check config against schema, `mcp` → `plugins` |
| Config not loading | Verify symlink: `ls -la ~/.openclaw/openclaw.json` |
| Gateway won't start | Check `gateway.mode: "local"` is set |

---

## Commands Reference

```bash
# Development
./run.sh                              # Start gateway locally
openclaw doctor                       # Validate config
openclaw health                       # Check status

# Deployment
git push                              # Auto-deploy to Fly.io
fly logs -a ap-assist-agent           # View cloud logs
fly ssh console                       # SSH into cloud

# Memory
./scripts/sync-memory.sh              # Pull cloud memory
```
