# OpenClaw Architecture Analysis

## What OpenClaw Is

OpenClaw is a **multi-channel AI agent gateway** that routes conversations from messaging platforms (Telegram, Discord, Slack, WhatsApp, etc.) to LLM-powered agents with persistent memory, tool access, and workspace isolation.

Think of it as: **A self-hosted AI assistant that lives across all your messaging apps, remembers everything, and can take actions.**

```
┌─────────────────────────────────────────────────────────────────┐
│                         GATEWAY                                  │
│  (WebSocket server, config hot-reload, device identity)         │
└─────────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│  Telegram   │      │   Discord   │      │   Slack     │
│  Channel    │      │   Channel   │      │   Channel   │
└─────────────┘      └─────────────┘      └─────────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AGENT ROUTER                                │
│  Session keys: <agent>:<account>:<peer>                         │
└─────────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Agent 1   │      │   Agent 2   │      │   Agent N   │
│  Workspace  │      │  Workspace  │      │  Workspace  │
│   Memory    │      │   Memory    │      │   Memory    │
│   Tools     │      │   Tools     │      │   Tools     │
└─────────────┘      └─────────────┘      └─────────────┘
```

---

## Core Components

### 1. Gateway (`src/gateway/`)
The control plane. A WebSocket server that:
- Manages client connections with protocol versioning
- Hot-reloads config without restart
- Handles device identity via crypto signatures
- Routes messages between channels and agents

### 2. Channels (`src/channels/`)
Adapters for messaging platforms. Each implements:
- `AuthAdapter` - Login/credentials
- `MessagingAdapter` - Send/receive messages
- `SecurityAdapter` - Allowlists, pairing codes
- `StatusAdapter` - Health checks

**Core channels (7):** Telegram, Discord, Slack, WhatsApp, Signal, Google Chat, iMessage
**Extension channels (32):** Matrix, Teams, Twitch, Nostr, etc.

### 3. Agents (`src/agents/`)
LLM-powered assistants with:
- Isolated workspace directories
- Session-scoped memory
- Tool access (bash, browser, file I/O, web search)
- Configurable model/provider

### 4. Memory (`src/memory/`)
Hybrid search system:
- **Vector store**: SQLite + sqlite-vec for semantic search
- **BM25**: Keyword matching for exact terms
- **Embeddings**: OpenAI, Gemini, or local providers
- **Files**: Markdown files in workspace (MEMORY.md, etc.)

### 5. Skills (`skills/`)
SKILL.md files that extend agent capabilities:
- YAML frontmatter with metadata
- Dynamic loading from workspace
- 52 bundled (GitHub, Slack, 1Password, etc.)

### 6. Browser (`src/browser/`)
Playwright-based web automation:
- Screenshot/video capture
- DOM interaction (click, type, scroll)
- Session persistence
- CDP protocol integration

---

## Primary Innovations

### 1. Session Key Architecture
```
<agent-id>:<account-id>:<peer-id>
```
Every conversation maps to a unique session. This enables:
- Multi-agent routing (different bots for different purposes)
- Multi-account support (same bot, different credentials)
- Peer isolation (DMs vs group chats stay separate)
- Clean workspace boundaries

**Why it matters:** Most frameworks treat agents as singletons. OpenClaw's session keys allow one gateway to serve many agents to many users without cross-contamination.

### 2. Channel Adapter Pattern
Unified interface across 39 messaging platforms:
```typescript
interface ChannelPlugin {
  AuthAdapter       // Credentials management
  MessagingAdapter  // Message send/receive
  SecurityAdapter   // Allowlists, pairing
  StatusAdapter     // Health monitoring
  ToolSend          // Agent → channel actions
}
```

**Why it matters:** Add a new platform by implementing 5 interfaces. No changes to core gateway or agent logic.

### 3. Hybrid Memory Search
Combines:
- **Vector similarity** for semantic "what did we discuss about X?"
- **BM25 keyword** for exact matches "find the API key"
- **File-based** for structured knowledge (MEMORY.md)

Batches embeddings (8000 tokens max) with automatic retry and provider fallback.

**Why it matters:** Pure vector search misses exact terms. Pure keyword misses context. Hybrid catches both.

### 4. Gateway Hot-Reload
Config changes apply without restart:
- Add/remove channels
- Update agent settings
- Modify tool permissions

**Why it matters:** Production systems can't restart for every config tweak.

### 5. Workspace-Driven Extensibility
Agents can modify their own capabilities:
- Drop a SKILL.md in `workspace/skills/` → new capability
- Edit `workspace/mcporter.json` → new MCP servers
- Update `workspace/MEMORY.md` → new knowledge

No redeploy. Changes sync via filesystem (Google Drive in the bot case).

**Why it matters:** Self-improving agents without deployment cycles.

### 6. Device Identity & Pairing
- Crypto-signed device identity
- Pairing codes for new users
- Per-channel allowlists
- Group chat sender-based tool policies

**Why it matters:** Security for personal assistants that have real capabilities.

---

## Architecture Decisions Worth Noting

### Good Patterns

| Pattern | Implementation | Benefit |
|---------|----------------|---------|
| Zod validation everywhere | `src/config/` | Runtime type safety |
| Subsystem loggers | Per-module logging | Debuggable in production |
| Plugin SDK | `src/channels/plugin-sdk/` | Clean extension API |
| Graceful degradation | Embedding provider fallback | Resilience |
| Config as JSON Schema | Enables UI generation | Self-documenting |

### Questionable Patterns

| Pattern | Location | Concern |
|---------|----------|---------|
| 2,400 LoC memory manager | `src/memory/manager.ts` | God file |
| 122K LoC config system | `src/config/` | Over-engineered |
| Multiple LLM providers | Auth failover chains | Complexity |
| Group chat policy | `src/config/group-policy.ts` | Byzantine rules |

---

## Bloat Identification

### Consumer-Focused Features (Business-Removable)

| Feature | Location | Purpose | Business Need |
|---------|----------|---------|---------------|
| Native apps | `apps/macos/`, `apps/ios/`, `apps/android/` | Menu bar, mobile companions | None (headless) |
| Canvas/A2UI | `src/canvas-host/`, `skills/canvas/` | Interactive HTML rendering | Low |
| Voice/TTS | `src/tts/` | ElevenLabs speech | Low |
| Wake word | Native apps | "Hey assistant" | None |
| 30+ hobby skills | `skills/spotify/`, `skills/sonos/`, etc. | Music, photos, games | None |

### Experimental/Incomplete

| Feature | Status | Notes |
|---------|--------|-------|
| Session transcript indexing | Feature-flagged | `experimental.sessionMemory: false` |
| iMessage channel | WIP comment | Undocumented macOS APIs |
| A2UI JSON push | WIP comment | "use HTML files for now" |
| Patch-apply tool | Experimental flag | Security implications |

### Redundancy

| Area | Current State | Consolidation |
|------|---------------|---------------|
| Embedding providers | OpenAI + Gemini + Local + fallback | Pick one |
| LLM providers | Anthropic + OpenAI + Gemini + local | Lock to Anthropic |
| Auth profiles | Complex failover chains | Single auth per provider |
| Channel allowlists | Per-channel pairing logic | SSO/LDAP instead |

---

## Professional Edition: What to Keep

### Core (Must Have)

```
src/
├── gateway/          # WebSocket control plane
├── agents/           # Agent runtime (stripped)
│   ├── agent-scope.ts
│   ├── bash-tools.ts
│   ├── system-prompt.ts
│   └── [core only]
├── channels/
│   ├── dock.ts       # Channel registry
│   ├── slack/        # Business channels only
│   ├── teams/
│   └── google-chat/
├── memory/
│   └── manager.ts    # Single-provider embeddings
├── browser/          # Keep for automation
└── config/           # Simplified schema
```

### Business Channels Only

| Keep | Remove |
|------|--------|
| Slack | Telegram |
| Microsoft Teams | Discord |
| Google Chat | WhatsApp |
| Email (future) | Signal |
| Webhook API | iMessage |
| | Matrix, Twitch, Nostr, etc. |

### Simplified Skills

| Keep | Remove |
|------|--------|
| GitHub | Spotify |
| Jira | Sonos |
| Linear | Camsnap |
| Notion | Food ordering |
| Salesforce (future) | Weather |
| Browser automation | Canvas games |
| File operations | Photo tools |

### Single-Provider Stack

| Component | Choice |
|-----------|--------|
| LLM | Anthropic Claude |
| Embeddings | OpenAI ada-002 |
| Vector DB | SQLite + sqlite-vec |
| Auth | OIDC/SAML |

---

## Professional Edition: Estimated Scope

### Current Size
- **433K LoC** in `src/`
- **52 skills** bundled
- **39 channels** (7 core + 32 extensions)
- **3 native apps**

### After Trimming
- **~80-100K LoC** (core gateway + essential agents)
- **~10 skills** (developer tools only)
- **3-5 channels** (Slack, Teams, Google Chat, Webhook)
- **0 native apps** (headless deployment)

### Removed
- All native apps (~50K LoC)
- 30+ hobby skills
- 34 channels
- Canvas/voice subsystems
- Multi-provider auth chains
- Experimental features

---

## What a Business Edition Looks Like

```yaml
# Simplified config
gateway:
  port: 8080
  auth:
    provider: oidc
    issuer: https://auth.company.com

agent:
  model: claude-sonnet-4-20250514
  workspace: /data/workspace
  tools:
    - bash
    - browser
    - file_read
    - file_write
    - web_search

channels:
  slack:
    app_id: ${SLACK_APP_ID}
    bot_token: ${SLACK_BOT_TOKEN}

memory:
  embeddings:
    provider: openai
    model: text-embedding-3-small
```

### Deployment
```dockerfile
FROM node:20-slim
COPY dist/ /app/
COPY config.yaml /app/
CMD ["node", "/app/gateway.js"]
```

No native apps. No canvas. No voice. No pairing codes. Just an agent that responds in Slack.

---

## Deep Dive: SOUL.md System

The SOUL.md pattern is a key innovation - **user-owned system prompts as markdown files**.

### Traditional vs. SOUL.md Approach

| Aspect | Traditional System Prompt | SOUL.md |
|--------|---------------------------|---------|
| Location | Hardcoded in source | User's workspace (syncs via Google Drive) |
| Modification | Code change + redeploy | Edit file → instant effect |
| Per-user | Same for everyone | Unique per workspace |
| Ownership | Developer owns | User owns |
| Evolution | Static | Agent can modify its own soul |

### Bootstrap File Hierarchy

```
workspace/
├── SOUL.md       # Values, personality, tone
├── IDENTITY.md   # Name, avatar, vibe
├── AGENTS.md     # Operating instructions
├── USER.md       # Context about the human
├── TOOLS.md      # Tool configuration notes
├── MEMORY.md     # Long-term knowledge (private sessions only)
└── HEARTBEAT.md  # Proactive task checklist
```

### How It's Injected

1. **Load** - Files read from workspace on session start
2. **Hook** - Hooks can modify in-memory (e.g., "SOUL Evil" swaps persona)
3. **Filter** - Session type determines access (group chats can't see SOUL.md)
4. **Truncate** - Smart 70% head + 20% tail if file exceeds 20KB
5. **Inject** - Added to system prompt under "# Project Context"

### Security Filtering by Session Type

| Session Type | Files Visible |
|--------------|---------------|
| Private DM | All (SOUL, IDENTITY, MEMORY, etc.) |
| Group chat | AGENTS.md, TOOLS.md only (no personal context) |
| Subagent | AGENTS.md, TOOLS.md only (no leakage to sub-tasks) |

### Example SOUL.md

```markdown
# SOUL.md - Who You Are

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip "Great question!"
and "I'd be happy to help!" — just help.

**Have opinions.** You're allowed to disagree, prefer things, find stuff
amusing or boring.

**Be resourceful before asking.** Try to figure it out. Read the file.
Check the context. Search for it. Then ask if you're stuck.

**Earn trust through competence.** Be careful with external actions
(emails, tweets). Be bold with internal ones (reading, organizing).

## Boundaries

- Private things stay private
- When in doubt, ask before acting externally
- Never send half-baked replies to messaging surfaces

## Continuity

Each session, you wake up fresh. These files ARE your memory.
Read them. Update them. They're how you persist.
```

### Why This Works

1. **User ownership** - The human controls the agent's personality
2. **Self-modification** - Agent can update its own SOUL.md as it learns
3. **Hook extensibility** - Runtime persona swaps without file I/O
4. **Clean isolation** - Group chats never see personal identity files

---

## Deep Dive: Memory System

The memory system's practical design is what makes it work in production.

### Explicit Recall, Not Magic RAG

System prompt instruction:

```
Before answering anything about prior work, decisions, dates, people,
preferences, or todos: run memory_search on MEMORY.md + memory/*.md;
then use memory_get to pull only the needed lines.
If low confidence after search, say you checked.
```

The agent **decides** to search. It's not automatic injection. This means:
- Agent knows it searched (can reason about confidence)
- Agent can admit "I checked but didn't find anything"
- No surprise context pollution

### Confidence Signals Are First-Class

```typescript
{
  snippet: "Andrew prefers async email...",
  path: "MEMORY.md",
  startLine: 42,
  endLine: 45,
  score: 0.78,           // Overall confidence
  vectorScore: 0.82,     // Semantic similarity
  textScore: 0.71,       // Keyword match strength
  provider: "openai",    // Which embedding model
  fallback: false        // Did it fall back from local?
}
```

The agent sees **why** something matched. No blind trust in retrieval.

### Hybrid Search Catches Both Modes

| Query | Vector Only | BM25 Only | Hybrid |
|-------|-------------|-----------|--------|
| "the machine running the gateway" | ✓ | ✗ | ✓ |
| "sqlite-vec error" | ✗ | ✓ | ✓ |
| "Andrew's email preferences" | ✓ | ✓ | ✓ |
| "API key sk-ant-..." | ✗ | ✓ | ✓ |

Vector fails on exact tokens (IDs, error strings). BM25 fails on paraphrases. Hybrid catches both.

### Two-Step Retrieval Pattern

1. **Search** → Get snippets (700 chars max) with line numbers
2. **Get** → Pull full context for specific lines if needed

```typescript
// Step 1: Find relevant chunks
memory_search("contract terms")
// → { snippet: "30-day exit...", path: "MEMORY.md", startLine: 42, endLine: 45 }

// Step 2: Get more context if needed
memory_get("MEMORY.md", 40, 50)
// → Full text of lines 40-50
```

Keeps initial retrieval light. Agent decides how much to pull.

### Session Isolation

| Session Type | Memory Access |
|--------------|---------------|
| Private DM | MEMORY.md + memory/*.md (full) |
| Group chat | memory/YYYY-MM-DD.md only (daily notes) |
| Subagent | Separate index (no parent memory) |

MEMORY.md is **never mentioned** in group chat system prompts. The agent doesn't know it exists.

### Silent Pre-Compaction Flush

When context nears compaction threshold:

```
Session nearing compaction. Store durable memories now.
Write any lasting notes to memory/YYYY-MM-DD.md;
reply with NO_REPLY if nothing to store.
```

The agent writes memory, responds with `NO_REPLY` token, user never sees it. Invisible housekeeping that prevents "forgot to save" problems.

### Graceful Degradation

```
Local embeddings (node-llama-cpp)
    ↓ fails
OpenAI text-embedding-3-small
    ↓ fails
Gemini embedding-001
    ↓ fails
Return { results: [], disabled: true, error: "..." }
```

Agent sees `disabled: true` and adapts. No crash, no hallucinated context.

### Auto-Reindex on Config Change

Index stores: embedding model + provider fingerprint + chunk params.

If any change → automatic full reindex. Switch models? System detects mismatch, rebuilds everything.

### Why This Works in the Wild

1. **Explicit over automatic** - Agent decides when to search
2. **Confidence visible** - Scores help agent judge trust
3. **Hybrid catches edge cases** - Vector + keyword together
4. **Isolation at prompt level** - Session type determines access
5. **Graceful degradation** - Failures return empty, not crash
6. **Silent housekeeping** - Pre-compaction flush preserves durability

The core insight: **Memory is "facts you wrote down" not magic retrieval.** The agent has to ask, gets scored snippets, can pull more if needed, knows when search failed, admits uncertainty.

---

## Summary

**OpenClaw's innovations:**
1. **Session key routing** - Multi-agent isolation without separate servers
2. **Channel adapter pattern** - 39 platforms, one interface
3. **SOUL.md system** - User-owned, self-modifying system prompts as files
4. **Hybrid memory search** - Vector + BM25 with confidence scores exposed to agent
5. **Explicit recall pattern** - Agent decides when to search, sees why things matched
6. **Gateway hot-reload** - Zero-downtime config changes
7. **Workspace-driven extensibility** - Drop files to add capabilities, no redeploy

**What's bloat for business:**
1. Native apps (macOS, iOS, Android)
2. Consumer channels (Discord, Telegram, WhatsApp)
3. Hobby skills (Spotify, Sonos, cameras)
4. Voice/canvas systems
5. Multi-provider fallback complexity

**Professional edition would be:**
- 80K LoC instead of 433K
- 5 channels instead of 39
- 10 skills instead of 52
- Single LLM/embedding provider
- Headless, container-native deployment
- OIDC/SAML auth instead of pairing codes
