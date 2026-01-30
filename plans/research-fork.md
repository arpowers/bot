# OpenClaw Fork Feasibility

Analysis of forking OpenClaw for a streamlined version.

---

## The Question

Should we fork OpenClaw to create a lighter, more focused bot?

---

## Current OpenClaw Architecture

```
openclaw/
├── src/                    # Core TypeScript (~50K lines)
├── apps/                   # Platform apps (macOS, iOS, Android)
├── packages/               # Shared libraries
├── ui/                     # Web interface
├── extensions/             # Channel integrations
└── skills/                 # Bundled skills (50+)
```

**Dependencies:** pnpm workspaces, Node 22, extensive npm packages

---

## What We Actually Need

| Feature | Need | OpenClaw Has |
|---------|------|--------------|
| Telegram channel | Yes | Yes |
| Webhook endpoint | Yes | Yes |
| Claude API | Yes | Yes |
| Memory/sessions | Yes | Yes |
| Skills system | Yes | Yes (overkill) |
| WhatsApp | Maybe | Yes |
| Discord | No | Yes |
| Slack/Teams | No | Yes |
| iOS/Android apps | No | Yes |
| Web UI | No | Yes |
| Docker sandbox | No | Yes |

**~70% of OpenClaw is features we don't need.**

---

## Fork Options

### Option A: Config-Only (Recommended)

Keep using OpenClaw, just disable unused features.

| Pros | Cons |
|------|------|
| Zero maintenance | Still ships unused code |
| Get updates free | Memory/resources for unused features |
| Community support | Dependent on project direction |

**Effort:** None

### Option B: Thin Wrapper

Build minimal gateway that uses Claude API directly.

```
gateway.ts (~500 lines)
├── telegram.ts     # Telegram bot integration
├── webhook.ts      # Inbound webhooks
├── claude.ts       # Anthropic API client
├── memory.ts       # Session persistence
└── skills.ts       # Skill loader (SKILL.md parser)
```

| Pros | Cons |
|------|------|
| Full control | Build from scratch |
| Minimal footprint | No community |
| Exactly what we need | Maintain everything |

**Effort:** 1-2 weeks initial, ongoing maintenance

### Option C: Selective Fork

Fork OpenClaw, strip unused features.

| Pros | Cons |
|------|------|
| Start with working code | Merge conflicts with upstream |
| Remove bloat | Maintenance burden |
| Keep skill system | Complex codebase to understand |

**Effort:** 1 week initial, ongoing merge pain

---

## Analysis

### OpenClaw Complexity

- 50K+ lines TypeScript
- Complex build (pnpm workspaces)
- Heavy abstraction for multi-platform
- Gateway architecture overkill for single-user

### What We'd Build

Minimal viable bot:
1. **Telegram listener** - ~100 lines (node-telegram-bot-api)
2. **Webhook server** - ~50 lines (Express)
3. **Claude client** - ~100 lines (Anthropic SDK)
4. **Memory** - ~100 lines (JSON file storage)
5. **Skills loader** - ~150 lines (parse SKILL.md, inject into prompt)

**Total:** ~500 lines vs 50K+

---

## Recommendation

**Start with Option A (Config-Only), prototype Option B.**

### Phase 1: Config-Only (Now)
- Deploy OpenClaw as-is
- Disable unused channels in config
- Build skills for our use cases
- Learn what we actually need

### Phase 2: Evaluate (30 days)
- Track pain points
- Note unused features consuming resources
- Identify missing capabilities

### Phase 3: Build or Stay (If needed)
- If OpenClaw works: stay
- If too heavy: build thin wrapper with lessons learned

---

## Thin Wrapper Prototype

```typescript
// gateway.ts - minimal implementation sketch
import Anthropic from '@anthropic-ai/sdk';
import TelegramBot from 'node-telegram-bot-api';
import express from 'express';
import fs from 'fs';

const client = new Anthropic();
const bot = new TelegramBot(process.env.TELEGRAM_TOKEN, { polling: true });
const app = express();

// Memory
const sessions = new Map<string, Message[]>();

// Telegram handler
bot.on('message', async (msg) => {
  const history = sessions.get(msg.chat.id.toString()) || [];
  history.push({ role: 'user', content: msg.text });

  const response = await client.messages.create({
    model: 'claude-opus-4-5-20250514',
    system: loadSkills(),
    messages: history
  });

  history.push({ role: 'assistant', content: response.content[0].text });
  sessions.set(msg.chat.id.toString(), history);

  bot.sendMessage(msg.chat.id, response.content[0].text);
});

// Webhook
app.post('/hooks/agent', async (req, res) => {
  // Handle webhook trigger
});

app.listen(3000);
```

---

## Success Criteria

- [ ] Bot works reliably with OpenClaw
- [ ] Clear understanding of actual requirements
- [ ] Decision made with real usage data
