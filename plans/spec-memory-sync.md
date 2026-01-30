# Memory Sync

Sync session memory between cloud and local repo.

---

## Problem

Bot runs on Fly.io but we want:
- Memory persisted in git for backup
- Local dev can access cloud conversation history
- Continuity if cloud instance is recreated

## Solution

Scheduled sync script that pulls session data from Fly.io to `memory/` folder.

---

## Implementation

### Storage Locations

| Location | Path |
|----------|------|
| Cloud | `/data/agents/default/sessions/` |
| Local | `~/dev/bot/memory/sessions/` |

### Session Files

```
sessions/
├── sessions.json           # Session metadata index
├── <sessionId>.jsonl       # Conversation transcript
└── <sessionId>-topic-*.jsonl  # Thread-specific transcripts
```

### Sync Script

```bash
#!/bin/bash
# scripts/sync-memory.sh

APP="ap-assist-agent"
LOCAL_DIR="./memory"

mkdir -p "$LOCAL_DIR/sessions"

# Pull session files
fly ssh console -a "$APP" -C "tar czf - /data/agents/default/sessions/" | \
  tar xzf - -C "$LOCAL_DIR" --strip-components=4

echo "Memory synced to $LOCAL_DIR"
```

### GitHub Action (Optional)

Run sync daily and commit changes:

```yaml
name: Sync Memory
on:
  schedule:
    - cron: '0 6 * * *'  # Daily 6am UTC
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: superfly/flyctl-action/setup-flyctl@master
      - run: |
          ./scripts/sync-memory.sh
          git add memory/
          git diff --staged --quiet || git commit -m "sync: memory $(date +%Y-%m-%d)"
          git push
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

---

## Challenges

| Challenge | Mitigation |
|-----------|------------|
| Large session files | Only sync recent sessions (last 30 days) |
| Conflicts | Cloud is authoritative, always overwrites local |
| Sensitive data | `.gitignore` specific patterns if needed |
| Session format changes | Track openclaw version in repo |

---

## Success Criteria

- [ ] `./scripts/sync-memory.sh` pulls cloud sessions
- [ ] Sessions viewable in `memory/` folder
- [ ] Local gateway can reference synced history (if configured)
