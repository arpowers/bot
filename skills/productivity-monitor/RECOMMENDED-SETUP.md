# Recommended Setup: Cloud Bot Only

## What You Should Run

```
┌─────────────────────────────────┐
│ Your Mac                        │
│                                 │
│ • sync-to-cloud.sh              │  ← Background task (NOT a bot)
│   (runs hourly via launchd)     │     Just writes JSON to Drive
│                                 │
└─────────────────────────────────┘
                ↓ writes JSON
┌─────────────────────────────────┐
│ Google Drive                    │
│ workspace/memory/               │
│   productivity-state.json       │
└─────────────────────────────────┘
                ↓ auto-sync
┌─────────────────────────────────┐
│ Fly.io (Cloud Bot)              │  ← The ONE bot you talk to
│                                 │
│ @ari_task_bot                   │
│                                 │
│ • Reads state hourly            │
│ • Sends Telegram nudges         │
│ • Handles PageLines webhooks    │
│ • Always available              │
└─────────────────────────────────┘
```

**You only need ONE bot running: the cloud bot on Fly.io**

The sync script is just a lightweight background task (like a cron job).

---

## Why This Is Best

### 1. **Simple**
- One Telegram bot to talk to
- One config to manage
- No confusion about which bot to message

### 2. **Always Available**
- Works 24/7 even when Mac sleeps
- Handles webhooks from PageLines
- Scheduled tasks run reliably

### 3. **Productivity Monitoring Still Works**
- Sync script checks git activity hourly
- Cloud bot reads state and nudges
- ~1 hour delay is fine for this use case

### 4. **Low Resource Usage**
- Sync script uses almost zero resources
- No need to run full bot on Mac
- Mac battery life unaffected

### 5. **Cost Effective**
- One bot = half the API calls
- Sync script is free (just bash)

---

## Installation

### 1. Install Sync Script (One-Time)

```bash
cd /Users/arpowers/dev/bot
bash skills/productivity-monitor/setup-monitoring.sh
```

This installs a launchd job that runs hourly (9am-6pm weekdays).

### 2. Set Up TASKS.md (One-Time)

```bash
cp skills/productivity-monitor/TASKS.template.md workspace/TASKS.md
open workspace/TASKS.md  # Add your client projects
```

### 3. Done!

Your cloud bot is already running on Fly.io. It will:
- Read the synced state hourly
- Nudge you via Telegram if yak shaving detected
- Handle all your other tasks (webhooks, email, etc.)

---

## How Cloud Bot Uses The State

The cloud bot checks `workspace/memory/productivity-state.json` hourly (via HEARTBEAT.md):

```javascript
{
  "timestamp": "2026-02-10T18:17:07Z",
  "status": "medium_risk",  // ← Cloud bot reads this
  "current_repo": "pagelines-app",
  "commits_today": 8,
  "last_commit_message": "wip: agents"
}
```

Based on status:
- `on_track` → Silent (no notification)
- `medium_risk` → Gentle Telegram question
- `high_risk` → Strong nudge to switch tasks

---

## Workflow Example

**9am Monday:**
```
You: (Start coding in client repo)
Sync: (Runs at 10am, writes state: "on_track")
Bot: (Reads state, sees on_track, stays silent)
```

**2pm Monday:**
```
You: (Switch to bot repo, start refactoring)
Sync: (Runs at 3pm, writes state: "high_risk")
Bot: (Reads state, sends Telegram)
```

**Telegram message:**
```
🚨 YAK SHAVING ALERT

You're working in: bot
Commits today: 12

Check TASKS.md - are you working on:
  💰💰💰 Client work (top priority)?

If not, park this and switch back!
```

---

## When Would You Run Local Bot Instead?

Only if you need:
- **Real-time nudges** (instant, not hourly)
- **No cloud dependency** (everything local)
- **Mac is always on** (not sleeping)

For most people, cloud bot + sync script is better.

---

## FAQ

### Q: Do I need openclaw running on my Mac?
**A:** No! Just the sync script (background task).

### Q: What if my Mac is asleep when sync script tries to run?
**A:** It skips that hour. Next run will update. Cloud bot uses last known state.

### Q: Can I still ask the bot questions via Telegram?
**A:** Yes! Cloud bot handles all Telegram messages, webhooks, etc.

### Q: Will this drain my Mac battery?
**A:** No, sync script runs for ~2 seconds per hour. Negligible impact.

### Q: What if I want real-time monitoring?
**A:** Run local bot instead. Trade-off: won't work when Mac sleeps.

### Q: Can I test the sync script manually?
**A:** Yes: `bash skills/productivity-monitor/sync-to-cloud.sh`

### Q: How do I know it's working?
**A:** Check `workspace/memory/productivity-state.json` after running sync script.

---

## Verify It's Working

### 1. Test Sync Script
```bash
bash skills/productivity-monitor/sync-to-cloud.sh
cat workspace/memory/productivity-state.json | jq .
```

Should see fresh JSON with current status.

### 2. Check Launchd Job
```bash
launchctl list | grep productivity-monitor
```

Should see: `com.apbot.productivity-monitor`

### 3. Check Logs
```bash
tail ~/.openclaw/logs/productivity-monitor.log
```

Should see hourly entries.

### 4. Ask Cloud Bot
Via Telegram:
```
"Check my productivity"
```

Bot should read the JSON and respond.

---

## If You Change Your Mind

### Switch to Local Bot Only

1. Uninstall sync script:
```bash
launchctl unload ~/Library/LaunchAgents/com.apbot.productivity-monitor.plist
rm ~/Library/LaunchAgents/com.apbot.productivity-monitor.plist
```

2. Run local bot:
```bash
openclaw gateway run
```

3. Use @ari_local_bot on Telegram

### Switch to Dual Mode

1. Keep sync script running
2. Also run local bot: `openclaw gateway run`
3. Use both bots (local for real-time, cloud for always-on)

But honestly, **cloud only is simpler and works great** for this use case.

---

## Summary

✅ **Recommended:** Cloud bot + sync script
⚠️ **Alternative:** Local bot only (if always on)
❌ **Not recommended:** Dual mode (too complex)

**Install now:**
```bash
bash skills/productivity-monitor/setup-monitoring.sh
```
