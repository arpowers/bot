# AP Bot

Personal AI assistant on OpenClaw. Local dev, cloud deploy, shared memory.

## Quick Reference

| Task | Command |
|------|---------|
| Run local | `openclaw gateway run` |
| Deploy | `git push` (auto via GitHub Actions) |
| Cloud logs | `fly logs --app ap-assist-agent` |
| Approve pairing | `openclaw pairing approve telegram <code>` |

## Architecture

```
bot/                              # Git repo = OpenClaw state dir
├── .openclaw/                    # OpenClaw state (OPENCLAW_STATE_DIR points here)
│   ├── openclaw.json             # Single config file (version controlled)
│   ├── agents/                   # Runtime state (gitignored)
│   ├── credentials/              # Auth tokens (gitignored)
│   └── telegram/                 # Pairing data (gitignored)
├── skills/                       # Custom skills (SKILL.md format)
├── workspace/                    # → Symlink to Google Drive
├── config/                       # Extra configs (legacy)
├── plans/                        # Specs and research
├── .env                          # Secrets (gitignored)
├── Dockerfile                    # Cloud container
├── entrypoint.sh                 # Prod config patching + rclone mount
├── fly.toml                      # Fly.io config
└── .github/workflows/            # Deploy on push

Google Drive (shared persistence)
└── ari-bot/workspace/            # Real-time sync between local & cloud
    ├── MEMORY.md
    ├── IDENTITY.md
    ├── TASKS.md
    └── ...
```

## Config System

**Single config file:** `.openclaw/openclaw.json`

- Uses relative paths (`./workspace`, `./skills`) for local
- `entrypoint.sh` patches to absolute paths (`/app/workspace`, `/app/skills`) for prod
- No separate prod config file needed

```bash
# Local: env var in .env
OPENCLAW_STATE_DIR="./.openclaw"

# Cloud: env var in Dockerfile
ENV OPENCLAW_STATE_DIR=/app/.openclaw
```

## Persistence (Google Drive)

Both local and cloud use the same Google Drive folder for real-time sync:

| Environment | How it connects |
|-------------|-----------------|
| **Local** | `workspace/` symlink → `~/Library/CloudStorage/GoogleDrive-.../ari-bot/workspace/` |
| **Cloud** | rclone mounts `gdrive:ari-bot/workspace` → `/app/workspace/` |

Changes sync automatically. No manual memory sync scripts needed.

### Setting up local workspace symlink

```bash
ln -s "/Users/arpowers/Library/CloudStorage/GoogleDrive-arpowers@gmail.com/My Drive/ari-bot/workspace" workspace
```

## Authentication

**CRITICAL: Always use Claude Max OAuth tokens, NEVER raw API keys.**

| Token type | Format | Use |
|------------|--------|-----|
| OAuth (use this) | `sk-ant-oat01-...` | Subscription-based, cost-effective |
| Raw API (never) | `sk-ant-api03-...` | Pay-per-token, expensive |

```bash
# Get OAuth token
claude setup-token

# Set on Fly.io
fly secrets set ANTHROPIC_API_KEY="sk-ant-oat01-..."
```

The `ANTHROPIC_API_KEY` env var holds the OAuth token, not a raw API key.

## Telegram Bots

| Bot | Purpose | Token source |
|-----|---------|--------------|
| @ari_local_bot | Local development | `TELEGRAM_TOKEN_LOCAL` in .env |
| @ari_task_bot | Cloud production | Set via `fly secrets` |

Both use `dmPolicy: "pairing"` - first message returns a pairing code, approve with:
```bash
openclaw pairing approve telegram <code>
```

## Deployment

1. Push to main branch
2. GitHub Actions runs `flyctl deploy --remote-only --yes`
3. Dockerfile copies `.openclaw/` and `skills/`
4. `entrypoint.sh`:
   - Patches config with prod paths
   - Mounts Google Drive via rclone
   - Starts `openclaw gateway run`

### Fly.io Secrets Required

```bash
fly secrets set ANTHROPIC_API_KEY="sk-ant-oat01-..."
fly secrets set TELEGRAM_BOT_TOKEN="..."
fly secrets set ELEVENLABS_API_KEY="..."
fly secrets set RCLONE_CONFIG_GDRIVE_TOKEN='{"access_token":"...","token_type":"Bearer",...}'
# ... other service keys
```

## Files to Know

| File | Purpose |
|------|---------|
| `.openclaw/openclaw.json` | Gateway config (model, channels, skills) |
| `.env` | Local secrets (gitignored) |
| `.env.example` | Template for .env |
| `entrypoint.sh` | Prod setup (config patch + rclone) |
| `Dockerfile` | Container definition |
| `fly.toml` | Fly.io app config |
| `skills/*/SKILL.md` | Custom skill definitions |
| `workspace/*.md` | Bot memory and context |

## Conventions

- **Skills:** SKILL.md files with YAML frontmatter
- **Config:** JSON in `.openclaw/openclaw.json`
- **Secrets:** Environment variables only, never in config files
- **Paths:** Relative in config, patched to absolute at runtime for prod

## Debugging

```bash
# Local logs
openclaw gateway run  # Logs to stdout

# Cloud logs
fly logs --app ap-assist-agent

# SSH into cloud
fly ssh console --app ap-assist-agent

# Check rclone mount in cloud
ls -la /app/workspace/
```

## Current Focus

- Lead handling via webhook
- Email triage
- Daily analytics/calendar briefing
- Sales task coaching

## Reference

- `overview.md` - Full project context, use cases, specs
- `plans/` - Implementation specs for each feature
- OpenClaw docs: https://docs.openclaw.ai
