# Changelog

## 2026-02-15

### Memory System

- Switched embeddings from Gemini (`gemini-embedding-001`) to Voyage AI (`voyage-3`)
- Uses OpenAI-compatible provider with Voyage API directly
- Replaced Gemini model fallback with `anthropic/claude-haiku-4-5`

### Skills

- Added `productivity-monitor` skill

## 2026-02-02

### Midjourney Integration

- Created `/midjourney` skill at `workspace/skills/midjourney/`
  - `SKILL.md` - Usage instructions
  - `package.json` - Declares `midjourney@4` dependency
  - `generate.js` - Script for Discord-based image generation
- Entrypoint auto-installs npm deps for workspace skills with package.json
- Set up secrets: `SALAI_TOKEN`, `MJ_SERVER_ID`, `MJ_CHANNEL_ID` (Fly.io, .env, GitHub)

### Attio CRM

- Created `workspace/skills/attio/SKILL.md` with full Attio API reference
- Set up `ATTIO_API_KEY` (Fly.io, .env, GitHub)

### ClawHub Skills

Installed from ClawHub registry:
- `ai-humanizer` - 24 AI writing pattern detectors, vocabulary tiers (trimmed to heuristics only)
- `youtube-watcher` - YouTube transcript fetching via yt-dlp
- `clawdbot-security-check` - 13-domain security audit framework

Removed:
- `marketing-mode` - Too verbose (encyclopedia, not heuristics)
- `deep-research` - Requires paid CRAFTED_API_KEY

### Dockerfile

- Added `python3`, `python3-pip`, `yt-dlp` for YouTube transcript support

### Skills Routing & Knowledge System

- Added skill routing heuristics to `workspace/SOUL.md`
- Moved skills to Google Drive (`workspace/skills/`) for bot self-modification
  - `social-media` - Split into SKILL.md (heuristics) + EXAMPLES.md
  - `images` - Split into SKILL.md (heuristics) + EXAMPLES.md
  - `book-notes` - New skill for Kindle highlights

### Standards Directory

Created `workspace/standards/` with adapted principles:
- `core.md` - First principles, YAGNI, simplicity
- `writing-style.md` - Voice: Tony Robbins meets Steve Jobs
- `copywriting.md` - Claude Hopkins principles
- `design-ui.md` - Swiss minimalism, Tufte data-ink ratio

### Book Notes System

- Created `scripts/export-readwise.sh` to export all Kindle highlights
- Exported 463 books to `workspace/book-notes/` (snake_case filenames)
- Added `READWISE_ACCESS_TOKEN` to .env, Fly.io, GitHub
- Highlights stored as markdown files, no API calls needed

### OpenClaw

- Updated to 2026.2.1
- Updated Dockerfile cache-bust comment

## 2026-02-01

### Discord Channel
- Configured Discord bot for DMs with allowlist policy
- User ID `354714361379684363` (arpowers@gmail.com) whitelisted
- Set `DISCORD_BOT_TOKEN` in local .env and Fly.io secrets
- Updated `openclaw.json` with Discord channel config

## 2026-01-31

### MCP Server Support
- Added `mcporter` to Docker image for cloud MCP support
- Twenty CRM MCP server configured (`twenty-crm-mcp-server`)
- MCP config in `workspace/mcporter.json` (bot-editable via Google Drive)

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
