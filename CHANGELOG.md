# Changelog

## 2026-01-31

### Bot Self-Modification
- MCP servers now in `workspace/mcporter.json` (Google Drive)
- Dynamic skills can be added to `workspace/skills/`
- Bot can modify its own capabilities without redeploy
- Changes sync instantly via Google Drive

### Twenty CRM Integration
- Added Twenty CRM MCP server (`twenty-crm-mcp-server`)
- Set `TWENTY_API_KEY` and `TWENTY_API_URL` in Fly.io secrets

### Infrastructure
- Removed Fly.io volumes (using Google Drive instead)
- Fixed deploy workflow (`--yes` flag for non-interactive)
- Single config file (`.openclaw/openclaw.json`)
- Simplified entrypoint.sh with config patching

### Documentation
- Updated README.md with current architecture
- Updated CLAUDE.md with bot self-modification docs
- Updated overview.md with correct status
- Added workspace/TOOLS.md for bot context

### Channels
- Telegram: @ari_local_bot (local), @ari_task_bot (cloud)
- Discord: Enabled (cloud working, local needs debugging)

### MCP Servers Configured
- `apify` - Web scraping
- `apollo` - Lead enrichment
- `google` - Gmail, Calendar, Drive
- `twenty` - Twenty CRM
