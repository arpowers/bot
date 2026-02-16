# Productivity Monitor Setup

Track coding activity, detect yak shaving, stay focused on revenue work.

## Quick Start (Local)

### 1. Test the script manually

```bash
# Check current activity
bash skills/productivity-monitor/productivity-check.sh

# See daily summary
bash skills/productivity-monitor/daily-summary.sh
```

### 2. Set up TASKS.md

```bash
# Copy template to workspace
cp skills/productivity-monitor/TASKS.template.md workspace/TASKS.md

# Edit it with your actual tasks
# Add your client repos, revenue goals, etc.
```

### 3. Enable in HEARTBEAT.md

Already configured! The bot will:
- Check hourly (9am-6pm weekdays) for yak shaving
- Send daily summary at 6pm
- Nudge via Telegram when off track

### 4. Run the bot locally

```bash
openclaw gateway run
```

The bot will now monitor your productivity automatically.

## How It Works

### Local Mode (Recommended)
- ✅ Monitors `~/dev/` directory for git activity
- ✅ Checks every hour during work hours
- ✅ Sends Telegram nudges when yak shaving detected
- ✅ Daily summary at 6pm with revenue ratio

### Cloud Mode (Limited)
- ❌ Cannot monitor your local machine's git activity
- ⚠️ Can only track what you tell it
- ✅ Can still do manual check-ins via Telegram

**Recommendation:** Run bot locally for productivity monitoring.

## Manual Commands

### Ask the bot directly:
- "Am I yak shaving?"
- "What am I working on?"
- "Productivity check"
- "Daily summary"

### Or run scripts directly:
```bash
# Quick check
bash skills/productivity-monitor/productivity-check.sh

# Full day analysis
bash skills/productivity-monitor/daily-summary.sh
```

## Configuration

### Customize repo categories

Edit `daily-summary.sh` line 16:

```bash
CLIENT_REPOS=("pagelines" "client" "your-client-name")
BOT_REPOS=("bot" "automation" "scripts")
```

### Adjust sensitivity

Edit `productivity-check.sh` yak scoring:
- Line 109: Bot repo penalty (default: +30)
- Line 115: Yak keyword penalty (default: +15)
- Line 123: Context switching penalty (default: +20)
- Line 128: Stuck penalty (default: +25)

Thresholds:
- 50+ points = HIGH RISK (exit code 2)
- 25-49 points = MEDIUM RISK (exit code 1)
- <25 points = ON TRACK (exit code 0)

### Change check frequency

Edit `workspace/HEARTBEAT.md`:
- Hourly checks: Change "9am-6pm" to your work hours
- Daily summary: Change "6pm" to your preferred time

## Privacy

- ✅ Only reads git logs (commit messages, timestamps)
- ✅ No keystroke logging
- ✅ No screen recording
- ✅ All data stays local or in your Google Drive workspace

## Troubleshooting

### "No recent git activity found"
- Make sure you're committing work in `~/dev/` directory
- Or update `DEV_DIR` in scripts to your actual dev folder

### Bot not checking hourly
- Make sure `openclaw gateway run` is running locally
- Check bot is reading `workspace/HEARTBEAT.md`

### Script errors
```bash
# Make sure scripts are executable
chmod +x skills/productivity-monitor/*.sh

# Test manually
bash skills/productivity-monitor/productivity-check.sh
```

## Example Output

### On Track:
```
✅ Looks productive!

Current work seems aligned with shipping features.
Keep going! 🚀
```

### Yak Shaving Detected:
```
🚨 HIGH RISK YAK SHAVING DETECTED

Red flags:
  ⚠️  Working in bot/ repo (unless it's client work)
  ⚠️  Commit message contains 'refactor'
  ⚠️  Working across 4 different repos today

Questions to ask yourself:
  1. Does this make money RIGHT NOW?
  2. Is this blocking a client deliverable?
  3. Can this wait until revenue goals are hit?
```

### Daily Summary:
```
📊 Daily Productivity Summary - 2026-02-09

⏱️  Time Allocation (estimated):
  💰💰💰 Client work:     4.5h (60%)
  🤖 Bot improvements:  2.5h (33%)
  📁 Other:             0.5h (7%)

✅ Revenue ratio: 60% (goal: 70%+) - Getting closer

🔍 Yak Shaving Analysis:
  ⚠️  Potential yak shaves detected:
    In bot:
      fix: improve Docker setup
      refactor: cleanup skills system

📋 Tomorrow's Plan:
  🎯 Block 9am-2pm for client work ONLY
  🎯 Defer all bot improvements until revenue goal hit
```

## Advanced Features (Coming Soon)

- Pattern recognition ("You usually yak shave on Fridays")
- Predictive nudges ("You're about to start optimizing aren't you?")
- Weekly trends and insights
- Integration with calendar (time blocking enforcement)
