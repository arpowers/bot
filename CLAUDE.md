# AP Bot

Personal AI assistant on OpenClaw. Local dev, cloud deploy.

## Architecture

```
Git Repo (version controlled)
├── openclaw.json          # Base config (relative paths)
├── openclaw-prod.json     # Production overrides
├── skills/                # Bot capabilities
└── workspace → symlink    # Points to Google Drive

Google Drive (shared persistence)
└── ari-bot/workspace/     # Memory, sessions, runtime data
    ├── MEMORY.md
    ├── IDENTITY.md
    └── ...
```

## Config System

| File | Purpose |
|------|---------|
| `openclaw.json` | Base config, used by local |
| `openclaw-prod.json` | Cloud overrides (merged on deploy) |
| `~/.openclaw/openclaw.json` | Symlink → repo's `openclaw.json` |

## Persistence

All runtime data (memory, sessions, etc.) lives on **Google Drive**:
- **Local**: `workspace/` symlink → `~/Google Drive/ari-bot/workspace/`
- **Cloud**: rclone mounts same Google Drive folder at `/app/workspace/`

Changes sync in real-time between local and cloud.

## Authentication (IMPORTANT)

**ALWAYS use Claude Max OAuth tokens, NEVER raw API keys.**

- OAuth tokens: `sk-ant-oat01-...` (subscription-based)
- Raw API keys: `sk-ant-api03-...` (pay-per-use, expensive)
- Get token: `claude setup-token`
- Set on Fly.io: `fly secrets set ANTHROPIC_API_KEY="sk-ant-oat01-..."`

## Workflow

1. Edit skills/config in repo
2. Test locally: `openclaw gateway run`
3. Push to GitHub → auto-deploys to Fly.io
4. Memory syncs via Google Drive (no manual sync needed)

## Telegram Bots

| Bot | Purpose | Token env var |
|-----|---------|---------------|
| @ari_local_bot | Local development | `TELEGRAM_TOKEN_LOCAL` |
| @ari_task_bot | Cloud production | `TELEGRAM_TOKEN_LIVE` |

## Commands

```bash
# Run local bot
openclaw gateway run

# Deploy to cloud
git push  # GitHub Actions handles it

# Check cloud logs
fly logs --app ap-assist-agent

# Approve Telegram pairing
openclaw pairing approve telegram <code>
```
