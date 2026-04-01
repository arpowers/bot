# AP Bot

Personal AI assistant on Hermes Agent. Local dev, cloud deploy, shared memory.

## Quick Reference

| Task | Command |
|------|---------|
| Run local | `hermes gateway` |
| Deploy | `git push` (auto via GitHub Actions) |
| Cloud logs | `fly logs --app ap-assist-agent` |
| Approve pairing | `hermes pairing approve telegram <code>` |

## Architecture

```
bot/                              # Git repo = Hermes Agent state dir
├── .hermes/                      # Hermes Agent state
│   ├── config.yaml               # Single config file (version controlled)
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

**Single config file:** `.hermes/config.yaml` (YAML format)

- Uses relative paths (`./workspace`, `./skills`) for local
- `entrypoint.sh` patches to absolute paths (`/app/workspace`, `/app/skills`) for prod
- No separate prod config file needed

```bash
# Hermes defaults to ~/.hermes/ but can be overridden via MESSAGING_CWD
# Cloud: env var in Dockerfile
ENV MESSAGING_CWD=/app
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
hermes pairing approve telegram <code>
```

## Deployment

1. Push to main branch
2. GitHub Actions runs `flyctl deploy --remote-only --yes`
3. Dockerfile copies `.hermes/` and `skills/`
4. `entrypoint.sh`:
   - Patches config with prod paths
   - Mounts Google Drive via rclone
   - Starts `hermes gateway`

### Fly.io Secrets Required

```bash
fly secrets set ANTHROPIC_API_KEY="sk-ant-oat01-..."
fly secrets set TELEGRAM_BOT_TOKEN="..."
fly secrets set ELEVENLABS_API_KEY="..."
fly secrets set RCLONE_CONFIG_GDRIVE_TOKEN='{"access_token":"...","token_type":"Bearer",...}'
# ... other service keys
```

## Bot Self-Modification

The bot can modify its own capabilities without redeploying:

| What | Location | How |
|------|----------|-----|
| MCP servers | `mcp_servers section in .hermes/config.yaml` | Edit YAML, restart gateway |
| Dynamic skills | `workspace/skills/` | Create SKILL.md |
| Skill npm deps | `workspace/skills/<name>/package.json` | Add package.json, redeploy |
| Memory | `workspace/*.md` | Edit directly |

These are on Google Drive and sync instantly. No git push or deploy needed.

**Skill Dependencies:** Skills can have their own `package.json`. The entrypoint auto-runs `npm install` for workspace skills with package.json after Google Drive mounts.

For core changes (gateway config, baked-in skills), use git commit → auto-deploy.

## Files to Know

| File | Purpose |
|------|---------|
| `.hermes/config.yaml` | Gateway config (model, channels, skills) |
| `mcp_servers section in .hermes/config.yaml` | MCP servers (bot-editable) |
| `workspace/skills/` | Dynamic skills (bot-editable) |
| `.env` | Local secrets (gitignored) |
| `.env.example` | Template for .env |
| `entrypoint.sh` | Prod setup (config patch + rclone) |
| `Dockerfile` | Container definition |
| `fly.toml` | Fly.io app config |
| `skills/*/SKILL.md` | Core skill definitions |
| `workspace/*.md` | Bot memory and context |

## Conventions

- **Skills:** SKILL.md files with YAML frontmatter
- **Config:** YAML in `.hermes/config.yaml`
- **Secrets:** Environment variables only, never in config files
- **Paths:** Relative in config, patched to absolute at runtime for prod

## Debugging

```bash
# Local logs
hermes gateway  # Logs to stdout

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

## Webhooks

External triggers via HTTP. See `plans/spec-webhooks.md` for full documentation.

**Quick reference:**

| Endpoint | Purpose | Response |
|----------|---------|----------|
| `POST /hooks/wake` | System event for main session | 200 |
| `POST /hooks/agent` | Isolated agent turn | 202 |

**PageLines integration:**
- URL: `https://assist.andrewpowers.com/hooks/agent`
- Auth: `Authorization: Bearer ${WEBHOOK_TOKEN}`
- Token must match in both PageLines and bot Fly.io secrets

## Cost Controls

### Perplexity API

**Always use `sonar` model by default.** Only use expensive models when explicitly requested.

| Model | Cost | When to Use |
|-------|------|-------------|
| `sonar` | $0.006 | **DEFAULT** - 95% of queries |
| `sonar-pro` | $0.02 | Only if sonar insufficient |
| `sonar-deep-research` | $0.40-1.30 | ONLY if user says "deep research" |

**Trigger phrases for expensive models:**
- "deep research" → sonar-deep-research
- "comprehensive analysis" → sonar-deep-research
- "thoroughly investigate" → sonar-deep-research

All other research queries → `sonar`

See `skills/research/SKILL.md` for full guidelines.

## Reference

| Document | Purpose |
|----------|---------|
| `plans/spec-deploy.md` | Deployment procedures, common failures, auto-healing |
| `skills/*/SKILL.md` | Skill definitions and usage |
| `.hermes/config.yaml` | MCP server config (mcp_servers section) |
| Hermes Agent docs | https://hermes-agent.nousresearch.com/docs/ |

## npm Commands

```bash
npm run deploy           # Push to main (triggers CI)
npm run deploy:force     # Force rebuild without cache
npm run deploy:check     # Check deploy health
npm run deploy:logs      # View cloud logs
npm run deploy:restart   # Restart machine
npm run deploy:ssh       # SSH into container
```

## Behavioral Principles

### Verification Before Done
- Never mark a task complete without proving it works
- Run tests, check logs, demonstrate correctness
- After deploy: `fly status`, check logs, verify bot responds
- Ask yourself: "Would a staff engineer approve this?"

### Self-Improvement Loop
- After ANY correction: update `workspace/LESSONS.md` with the pattern
- Write rules that prevent the same mistake
- Review lessons at session start

### Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests → then resolve them
- Zero context switching required from the user

### Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer

### Core Principles
- **Simplicity First:** Make every change as simple as possible
- **No Laziness:** Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact:** Changes should only touch what's necessary. Avoid introducing bugs.
