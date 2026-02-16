# Install Productivity Monitoring (Cloud + Local)

## What This Does

Your **Mac** tracks git activity hourly → writes to **Google Drive** → **Fly.io bot** reads it and nudges you via **Telegram** if you're yak shaving.

**Zero technical networking required!** Just uses Google Drive sync you already have.

---

## One-Command Install

```bash
bash skills/productivity-monitor/setup-monitoring.sh
```

This installs a background task that runs every hour (9am-6pm weekdays) on your Mac.

---

## What Happens After Install

### Every Hour (9am-6pm weekdays)
1. **Your Mac** checks git activity in `~/dev/`
2. Writes state to `workspace/memory/productivity-state.json`
3. **Google Drive** auto-syncs (already set up!)
4. **Cloud bot** reads it and checks status
5. **Telegram nudge** if you're yak shaving (high/medium risk)
6. **Silent** if you're on track

### You Get Messages Like:
```
🚨 YAK SHAVING ALERT

You're working in: bot
Commits today: 8

Check TASKS.md - are you working on:
  💰💰💰 Client work (top priority)?

If not, park this and switch back!
```

---

## Manual Test (Before Installing)

```bash
# 1. Test the productivity check
bash skills/productivity-monitor/productivity-check.sh

# 2. Test syncing to Google Drive
bash skills/productivity-monitor/sync-to-cloud.sh

# 3. Check the file was created
cat workspace/memory/productivity-state.json | jq .
```

If these work, the automatic hourly version will work too.

---

## Set Up TASKS.md (One-Time)

```bash
# Copy template
cp skills/productivity-monitor/TASKS.template.md workspace/TASKS.md

# Edit it
open workspace/TASKS.md
```

Add your actual:
- Client projects (💰💰💰)
- Infrastructure work (💰)
- Side projects / yak shaves (💸)

---

## Cloud Bot Setup

The cloud bot needs to be told to check the synced state.

### Option 1: Add to HEARTBEAT.md (Already Done!)

Edit `workspace/HEARTBEAT.md` and verify this section exists:

```yaml
## Hourly (9am-6pm weekdays)

- [ ] **Productivity check**
  - Read: workspace/memory/productivity-state.json
  - If status = "high_risk" → Send strong Telegram nudge
  - If status = "medium_risk" → Send gentle Telegram question
  - If status = "on_track" → Silent (no notification)
```

### Option 2: Ask Bot Manually

Via Telegram:
```
"Check my productivity"
"Am I yak shaving?"
```

Bot reads `/app/workspace/memory/productivity-state.json` on Fly.io.

---

## Architecture

```
┌──────────────────────┐
│  Your Mac (Local)    │
│                      │
│  • Git commits       │
│  • Hourly cron       │─┐
│    checks activity   │ │
└──────────────────────┘ │
                         │
                         ▼ writes JSON
┌─────────────────────────────────────┐
│     Google Drive (workspace/)       │
│                                     │
│  memory/productivity-state.json     │
│  (synced in real-time)              │
└─────────────────────────────────────┘
                         │
                         ▼ rclone mount
┌──────────────────────┐
│   Fly.io Cloud Bot   │
│                      │
│  • Reads JSON hourly │
│  • Sends Telegram    │
│    nudge if needed   │
└──────────────────────┘
```

**No webhooks, no exposed ports, no VPN needed!**

---

## Commands

### View Logs
```bash
tail -f ~/.openclaw/logs/productivity-monitor.log
```

### Test Sync Manually
```bash
bash skills/productivity-monitor/sync-to-cloud.sh
```

### Check If Installed
```bash
launchctl list | grep productivity-monitor
```

### Uninstall
```bash
launchctl unload ~/Library/LaunchAgents/com.apbot.productivity-monitor.plist
rm ~/Library/LaunchAgents/com.apbot.productivity-monitor.plist
```

---

## Troubleshooting

### "No recent git activity found"
- Make sure you're committing work in `~/dev/`
- Or edit scripts to point to your actual dev folder

### State file not updating
```bash
# Check if launchd job is running
launchctl list | grep productivity-monitor

# Check logs
tail ~/.openclaw/logs/productivity-monitor.log

# Test manually
bash skills/productivity-monitor/sync-to-cloud.sh
```

### Cloud bot not reading state
```bash
# SSH into Fly.io
fly ssh console -a ap-assist-agent

# Check if file exists and is fresh
ls -l /app/workspace/memory/productivity-state.json
cat /app/workspace/memory/productivity-state.json | jq .
```

### Bot never nudges
- Check `workspace/HEARTBEAT.md` has the productivity check task
- Make sure cloud bot is running (`fly status`)
- Check if state file is older than 90 minutes (stale)

---

## Next Steps

1. **Install:** Run `bash skills/productivity-monitor/setup-monitoring.sh`
2. **Set up TASKS.md:** Add your client projects
3. **Wait 1 hour:** Let it run during work hours
4. **Get nudged:** If you're yak shaving, you'll hear about it!

---

## Cost

**$0/month** - Uses only what you already have:
- ✅ Google Drive (already set up)
- ✅ Fly.io bot (already running)
- ✅ Telegram (free)
- ✅ macOS launchd (built-in)

No new services or subscriptions needed!
