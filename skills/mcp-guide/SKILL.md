---
name: mcp-guide
description: Guidance for when to use MCP vs direct API calls
version: 1.0.0
triggers:
  - mcp
  - which tool
  - how to call
---

# MCP vs Skills/Direct API Guide

Decision framework for choosing between MCP tools and direct API calls.

## Quick Decision

```
Need to call an external service?
├─ Is there a skill for it? → Use the skill
├─ Is cost control important? → Use direct API
├─ Need complex multi-step workflow? → Consider MCP
└─ Simple one-off call? → Direct API is fine
```

## When to Use Skills (Direct API)

**Prefer skills/direct API when:**

| Scenario | Why |
|----------|-----|
| Cost-sensitive services | Control model selection (Perplexity) |
| Simple queries | Less overhead than MCP |
| High-frequency calls | Faster, no tool discovery |
| Need predictable behavior | Skills have explicit instructions |

**Services with skills:**

| Service | Skill | Why not MCP |
|---------|-------|-------------|
| Perplexity | `research` | MCP defaults to expensive models |
| PostHog | `analytics` | Direct API is simpler |
| Email | `email` | Himalaya CLI, no MCP needed |
| GitHub | `github` | gh CLI is more reliable |

## When to Use MCP

**Use MCP when:**

| Scenario | Why |
|----------|-----|
| Complex multi-step workflows | MCP handles tool chaining |
| Need tool discovery | Don't know exact endpoint |
| Official MCP server exists | Better maintained |
| Service has many endpoints | MCP abstracts complexity |

**Good MCP use cases:**

| Service | MCP Server | Use Case |
|---------|------------|----------|
| Apify | `apify` | Web scraping (many actors) |
| DataForSEO | `dfs-mcp` | SEO data (many endpoints) |
| Prospect | `prospect` | Lead enrichment |
| Google Workspace | `google-mcp` | Calendar, Sheets, Drive |

## MCP Gotchas

### 1. Bad Defaults

Some MCP servers have expensive defaults:

| MCP | Issue | Solution |
|-----|-------|----------|
| Perplexity MCP | Defaults to `sonar-deep-research` | Use `research` skill instead |

### 2. Token Overhead

MCP tool calls include:
- Tool discovery
- Schema validation
- Extra context

For simple calls, this overhead can exceed the actual API call.

### 3. Startup Time

MCP servers (especially npx-based) have cold start delays:
- First call: 5-15 seconds
- Subsequent: Normal

## Decision Matrix

| Factor | Use Skill | Use MCP |
|--------|-----------|---------|
| One endpoint | ✓ | |
| Many endpoints | | ✓ |
| Cost control needed | ✓ | |
| Complex workflow | | ✓ |
| Speed critical | ✓ | |
| Tool discovery needed | | ✓ |
| Explicit instructions exist | ✓ | |

## Available Skills

Check `skills/` directory or use `/list-skills` for current skills.

| Skill | Purpose |
|-------|---------|
| research | Perplexity web search |
| analytics | PostHog queries |
| email | Email via Himalaya |
| github | GitHub via gh CLI |
| lead-handler | Process incoming leads |

## Available MCP Servers

Check `workspace/mcporter.json` for configured MCP servers.

Current servers:
- `apify` - Web scraping actors
- `dfs-mcp` - DataForSEO
- `prospect` - Lead enrichment
- `google-mcp` - Google Workspace

## Examples

### Bad: Using MCP for simple Perplexity search
```
❌ mcp__perplexity__search("latest AI news")
   → May use sonar-deep-research ($0.40+)
```

### Good: Using research skill
```
✓ Use research skill with sonar model
   → Uses sonar ($0.006)
```

### Good: Using MCP for Apify web scraping
```
✓ mcp__apify__call-actor for complex scraping
   → Many actors, MCP handles discovery
```

## Adding New Integrations

1. **Simple service, one endpoint?** → Create a skill
2. **Complex service, many endpoints?** → Add MCP server to mcporter.json
3. **Cost-sensitive?** → Always create a skill with explicit cost controls
