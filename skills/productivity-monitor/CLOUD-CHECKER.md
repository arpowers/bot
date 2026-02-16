# Cloud-Side Productivity Checker

This runs on Fly.io and reads the synced state from Google Drive.

## How the Cloud Bot Uses This

When HEARTBEAT.md triggers "hourly productivity check", the cloud bot should:

1. **Read the state file**
```bash
STATE_FILE="workspace/memory/productivity-state.json"
cat "$STATE_FILE"
```

2. **Parse the status**
```bash
STATUS=$(jq -r '.status' "$STATE_FILE")
TIMESTAMP=$(jq -r '.timestamp' "$STATE_FILE")
CURRENT_REPO=$(jq -r '.current_repo' "$STATE_FILE")
COMMITS_TODAY=$(jq -r '.commits_today' "$STATE_FILE")
```

3. **Check if state is fresh**
```bash
# State should be < 90 minutes old
STATE_TIME=$(date -d "$TIMESTAMP" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$TIMESTAMP" +%s)
CURRENT_TIME=$(date +%s)
AGE_MINUTES=$(( (CURRENT_TIME - STATE_TIME) / 60 ))

if [ $AGE_MINUTES -gt 90 ]; then
  echo "⚠️ Productivity state is stale (${AGE_MINUTES}m old)"
  echo "Is your Mac asleep or the sync script not running?"
  exit 0
fi
```

4. **Send Telegram nudge based on status**

### Status: `high_risk`
```
🚨 YAK SHAVING ALERT

You're working in: $CURRENT_REPO
Commits today: $COMMITS_TODAY

Check TASKS.md - are you working on:
  💰💰💰 Client work (top priority)?

If not, park this and switch back!
```

### Status: `medium_risk`
```
⚠️ Productivity Check

Current: $CURRENT_REPO
Status: Possible yak shaving detected

Quick question: Does this make money RIGHT NOW?
  1. Yes - keep going
  2. No - should switch to client work
```

### Status: `on_track`
```
(No message - silent when on track)
```

### Status: `error` or stale
```
(No nudge - system issue, not user issue)
```

## Example HEARTBEAT.md Task

```yaml
## Hourly (9am-6pm weekdays)

- [ ] **Cloud productivity check**
  - Read: workspace/memory/productivity-state.json
  - If status = "high_risk" → Send strong Telegram nudge
  - If status = "medium_risk" → Send gentle Telegram question
  - If status = "on_track" → Silent (no notification)
  - If state stale (>90 min) → Ignore (Mac might be asleep)
```

## Testing

1. **On Mac (local):**
```bash
bash skills/productivity-monitor/sync-to-cloud.sh
```

2. **Check Google Drive:**
```bash
cat workspace/memory/productivity-state.json
```

Should see fresh JSON with current status.

3. **Ask cloud bot (via Telegram):**
```
"Check my productivity"
```

Bot reads the JSON and responds based on status.

## End of Day Summary

The cloud bot can also generate daily summaries:

```yaml
## End of Day (6pm weekdays)

- [ ] **Daily productivity summary**
  - Read: workspace/memory/productivity-state.json
  - Count total commits_today
  - Check if mostly client work
  - Send summary to Telegram:
    - Commits today: X
    - Current status: [on_track/medium/high_risk]
    - If high_risk detected during day: gentle roast
```

## Architecture Diagram

```
┌─────────────────────┐
│   Your Mac (Local)  │
│                     │
│  1. Git commits     │
│  2. sync-to-cloud   │─┐
│     (hourly cron)   │ │
└─────────────────────┘ │
                        │
                        ▼
┌─────────────────────────────────┐
│      Google Drive (Sync)        │
│                                 │
│  workspace/memory/              │
│    productivity-state.json      │
│                                 │
└─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────┐
│  Fly.io Cloud Bot   │
│                     │
│  1. Read JSON       │
│  2. Check status    │
│  3. Send Telegram   │
│     nudge if needed │
└─────────────────────┘
```

## Privacy

- ✅ Git logs stay on your Mac
- ✅ Only commit counts/messages sync to Drive
- ✅ No keystroke logging
- ✅ No screen recording
- ✅ Bot only sees what you commit

## Troubleshooting

### State file not updating
```bash
# Check if sync script works
bash skills/productivity-monitor/sync-to-cloud.sh

# Check Google Drive is mounted
ls -la workspace/memory/

# Check launchd job is loaded
launchctl list | grep productivity-monitor
```

### Cloud bot not reading state
```bash
# SSH into Fly.io
fly ssh console -a ap-assist-agent

# Check if file exists
ls -la /app/workspace/memory/productivity-state.json

# Check rclone mount
mount | grep workspace
```

### State is always stale
```bash
# Your Mac might be sleeping during checks
# Ensure Mac is awake during work hours
# Or adjust check times in setup-monitoring.sh
```
