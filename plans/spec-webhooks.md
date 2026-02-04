# Webhooks

External triggers for the OpenClaw gateway.

---

## Configuration

```json
{
  "hooks": {
    "enabled": true,
    "token": "${WEBHOOK_TOKEN}",
    "path": "/hooks"
  }
}
```

- `hooks.token` required when `hooks.enabled=true`
- `hooks.path` defaults to `/hooks`

---

## Authentication

Every request must include the hook token:

| Method | Example |
|--------|---------|
| `Authorization` header (recommended) | `Authorization: Bearer <token>` |
| `x-openclaw-token` header | `x-openclaw-token: <token>` |
| Query param (deprecated) | `?token=<token>` |

---

## Endpoints

### POST /hooks/wake

Enqueues a system event for the main session.

```json
{
  "text": "System line",
  "mode": "now"
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `text` | Yes | Event description |
| `mode` | No | `now` (default) or `next-heartbeat` |

**Response:** `200`

### POST /hooks/agent

Runs an isolated agent turn with its own session.

```json
{
  "message": "Run this",
  "name": "Email",
  "sessionKey": "hook:email:msg-123",
  "wakeMode": "now",
  "deliver": true,
  "channel": "telegram",
  "to": "chat-id",
  "model": "anthropic/claude-sonnet-4",
  "thinking": "low",
  "timeoutSeconds": 120
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `message` | Yes | Prompt for the agent |
| `name` | No | Human-readable name (e.g., "GitHub"), used in session summaries |
| `sessionKey` | No | Session identifier. Defaults to `hook:<uuid>`. Consistent key = multi-turn conversation |
| `wakeMode` | No | `now` (default) or `next-heartbeat` |
| `deliver` | No | If true, response sent to messaging channel. Default: true |
| `channel` | No | `last`, `telegram`, `discord`, `whatsapp`, `slack`, `signal`, `imessage`, `msteams` |
| `to` | No | Recipient ID (chat ID, phone number, etc.) |
| `model` | No | Model override |
| `thinking` | No | Thinking level: `low`, `medium`, `high` |
| `timeoutSeconds` | No | Max duration for agent run |

**Response:** `202` (async run started)

### POST /hooks/<name> (mapped)

Custom hook names resolved via `hooks.mappings`. Turns arbitrary payloads into wake or agent actions.

---

## Response Codes

| Code | Meaning |
|------|---------|
| `200` | Success (wake endpoint) |
| `202` | Async run started (agent endpoint) |
| `400` | Invalid payload |
| `401` | Auth failure |
| `413` | Oversized payload |

---

## Examples

### Wake endpoint

```bash
curl -X POST http://127.0.0.1:3000/hooks/wake \
  -H 'Authorization: Bearer SECRET' \
  -H 'Content-Type: application/json' \
  -d '{"text":"New email received","mode":"now"}'
```

### Agent endpoint

```bash
curl -X POST http://127.0.0.1:3000/hooks/agent \
  -H 'Authorization: Bearer SECRET' \
  -H 'Content-Type: application/json' \
  -d '{"message":"Summarize inbox","name":"Email","deliver":true,"channel":"telegram"}'
```

### With model override

```bash
curl -X POST http://127.0.0.1:3000/hooks/agent \
  -H 'Authorization: Bearer SECRET' \
  -H 'Content-Type: application/json' \
  -d '{"message":"Quick task","model":"openai/gpt-4o-mini"}'
```

---

## PageLines Integration

PageLines form submissions POST to `/api/lead`, which forwards to the bot webhook.

**URL:** `https://assist.andrewpowers.com/hooks/agent`

**Payload format:**

```json
{
  "message": "New PageLines lead submission:\n\nEmail: user@example.com\nLinkedIn: ...\nNotes: ...\n\nPlease qualify this lead and draft a personalized response.",
  "name": "PageLines Lead",
  "deliver": true,
  "channel": "telegram"
}
```

**Token:** Must match `WEBHOOK_TOKEN` in both PageLines and bot Fly.io secrets.

---

## Security

- Keep hook endpoints behind loopback, tailnet, or trusted reverse proxy
- Use dedicated hook token (don't reuse gateway auth tokens)
- Payloads treated as untrusted, wrapped with safety boundaries by default
- Set `allowUnsafeExternalContent: true` in mapping to disable (dangerous)

---

## Current Setup

| Service | URL | Token Source |
|---------|-----|--------------|
| Bot (cloud) | `https://assist.andrewpowers.com/hooks/agent` | `WEBHOOK_TOKEN` env var |
| PageLines | Posts to bot webhook | `WEBHOOK_TOKEN` env var |

Both must use the same token value.
