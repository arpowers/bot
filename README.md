# AP Bot

Personal AI assistant on OpenClaw. Local dev, cloud deploy, shared memory via Google Drive.

## Quick Start

```bash
# Install OpenClaw
npm install -g openclaw@latest

# Clone and setup
cd ~/dev/bot
cp .env.example .env  # Fill in secrets

# Run locally
source .env && openclaw gateway run
```

## Deploy to Cloud

```bash
# Push to GitHub - auto deploys via GitHub Actions
git push

# Or manual
fly deploy --app ap-assist-agent
```

## Architecture

```
bot/
├── .openclaw/              # OpenClaw config (version controlled)
├── workspace/              # → Google Drive (bot memory, dynamic config)
│   ├── mcporter.json       # MCP servers (bot-editable)
│   ├── skills/             # Dynamic skills (bot-editable)
│   ├── MEMORY.md           # Bot memory
│   └── ...
├── skills/                 # Core skills (deployed with code)
├── config/                 # mcporter.json symlink
└── .github/workflows/      # Auto-deploy on push
```

## Key Concepts

| What | Where | Editable by |
|------|-------|-------------|
| MCP servers | `workspace/mcporter.json` | Bot (instant) |
| Dynamic skills | `workspace/skills/` | Bot (instant) |
| Core skills | `skills/` | Human (deploy) |
| Gateway config | `.openclaw/openclaw.json` | Human (deploy) |
| Bot memory | `workspace/*.md` | Bot (instant) |

## Commands

```bash
# Local
openclaw gateway run          # Start bot
openclaw health               # Check status

# Cloud
fly logs --app ap-assist-agent    # View logs
fly ssh console --app ap-assist-agent  # SSH access

# MCP servers
mcporter config list          # List configured servers
mcporter list twenty --schema # Show server tools
```

## Telegram Bots

| Bot | Environment |
|-----|-------------|
| @ari_local_bot | Local development |
| @ari_task_bot | Cloud production |

First message returns pairing code. Approve with:
```bash
openclaw pairing approve telegram <code>
```

## Docs

- [CLAUDE.md](CLAUDE.md) - Full architecture details
- [overview.md](overview.md) - Project goals and status
- [plans/](plans/) - Feature specs
