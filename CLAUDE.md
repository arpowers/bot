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
