# AP Bot

Personal AI assistant on OpenClaw. Handles leads, email, analytics, calendar, and sales coaching.

---

## Local Setup

```bash
# Install OpenClaw
npm install -g openclaw@latest

# Run from this folder
cd ~/dev/bot
./run.sh
```

That's it. Everything stays in this repo.

---

## Fly.io Deployment

### First Time Setup

```bash
# 1. Create app
fly apps create ap-assist-agent

# 2. Create volume for persistent data (matches fly.toml)
fly volumes create bot_data --size 2 --region sjc -a ap-assist-agent

# 3. Set secrets (use values from .env)
fly secrets set -a ap-assist-agent \
  GATEWAY_TOKEN="$(openssl rand -hex 32)" \
  WEBHOOK_TOKEN="$(openssl rand -hex 32)" \
  ANTHROPIC_API_KEY="..." \
  TELEGRAM_BOT_TOKEN="..." \
  GOOGLE_OAUTH_CLIENT_ID="..." \
  GOOGLE_OAUTH_CLIENT_SECRET="..." \
  APOLLO_API_KEY="..." \
  APIFY_API_TOKEN="..." \
  PERPLEXITY_API_KEY="..." \
  ENRICHLAYER_API_KEY="..."

# 4. Deploy
fly deploy -a ap-assist-agent
```

### Subsequent Deploys

```bash
# Auto-deploy on push (via GitHub Actions)
git push

# Or manual
fly deploy -a ap-assist-agent
```

### Configure Channels (First Time)

```bash
# SSH in and run onboard for Telegram/WhatsApp setup
fly ssh console -a ap-assist-agent
openclaw onboard
```

---

## Commands

```bash
# Local
./run.sh                              # Start bot
openclaw health                       # Check status
openclaw doctor                       # Validate config

# Cloud
fly logs -a ap-assist-agent           # View logs
fly ssh console -a ap-assist-agent    # SSH access
fly status -a ap-assist-agent         # App status

# Secrets
fly secrets list -a ap-assist-agent   # List secrets
fly secrets set -a ap-assist-agent KEY=value  # Add secret

# Memory sync (cloud → local)
./scripts/sync-memory.sh
```

---

## Structure

```
~/dev/bot/
├── openclaw.json       # Gateway config
├── .env                # Local secrets (gitignored)
├── run.sh              # Local runner
├── workspace/          # Bot memory & context
├── skills/             # Custom skills
├── config/             # Extra configs (himalaya)
├── plans/              # Specs and docs
├── Dockerfile          # Cloud build
├── fly.toml            # Fly.io config
└── .github/workflows/  # CI/CD
```

---

## Webhook

**Endpoint:** `POST https://[your-app].fly.dev/hooks/agent`

```bash
curl -X POST https://ap-assist-agent.fly.dev/hooks/agent \
  -H "Authorization: Bearer $WEBHOOK_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "New lead: John from Acme", "channel": "telegram"}'
```

---

## Docs

- [overview.md](overview.md) - Project hub, status, specs
- [plans/](plans/) - Feature specs
- [OpenClaw Docs](https://docs.openclaw.ai)
