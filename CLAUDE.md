# AP Bot

Personal AI assistant on OpenClaw. Local dev, cloud deploy.

## Key Files

| File | Purpose |
|------|---------|
| `overview.md` | Project hub, status, architecture |
| `config/openclaw.json` | Gateway configuration |
| `skills/` | Custom skills (SKILL.md format) |
| `plans/` | Specs and research |

## Structure

```
bot/
├── config/openclaw.json    # Symlinked to ~/.openclaw/openclaw.json
├── skills/                 # Symlinked to ~/.openclaw/skills
├── memory/                 # Synced from cloud sessions
├── plans/                  # Specs
└── .github/workflows/      # Deploy on push
```

## Conventions

- **Skills:** SKILL.md files with YAML frontmatter
- **Config:** JSON5 in `config/openclaw.json`
- **Secrets:** Environment variables, never in config

## Authentication (IMPORTANT)

**ALWAYS use Claude Max OAuth tokens, NEVER raw Anthropic API keys.**

- Claude Max subscription provides OAuth tokens (`sk-ant-oat01-...`)
- Raw API keys (`sk-ant-api03-...`) are pay-per-use and expensive
- To get OAuth token: `openclaw configure --section model` → select Claude Max
- Set on Fly.io: `fly secrets set ANTHROPIC_API_KEY="sk-ant-oat01-..." --app ap-assist-agent`
- The OAuth token goes in the same `ANTHROPIC_API_KEY` env var

## Workflow

1. Edit skills/config locally
2. Test with `openclaw gateway run`
3. Push to GitHub
4. GitHub Actions deploys to Fly.io

## Current Focus

- Lead handling via webhook
- Email triage
- Daily analytics/calendar briefing
- Sales task coaching

## Reference

See `overview.md` for full context.
