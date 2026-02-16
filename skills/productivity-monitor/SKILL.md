---
name: productivity-monitor
description: Track coding activity, detect yak shaving, keep focus on revenue tasks
version: 1.0.0
triggers:
  - productivity check
  - what am i working on
  - am i yak shaving
  - focus check
  - time check
---

# Productivity Monitor Skill

Track Andrew's coding activity and detect when he's yak shaving instead of working on revenue-generating tasks.

## How It Works

1. **Git Activity Analysis** - Check recent commits across repos
2. **Yak Shaving Detection** - Flag low-value work (configs, refactoring, side projects)
3. **Financial Priority Check** - Compare current work against TASKS.md priorities
4. **Gentle Nudge** - Send Telegram message if off track

## Usage

### Manual Check
When Andrew asks "what am I working on?" or "am I yak shaving?"

### Scheduled (via HEARTBEAT.md)
- Every hour during work hours (9am-6pm weekdays)
- End of day summary (6pm)

## Detection Logic

### Step 1: Analyze Git Activity

```bash
# Get commits from last hour across all repos in ~/dev
cd ~/dev
for dir in */; do
  if [ -d "$dir/.git" ]; then
    echo "=== $dir ==="
    cd "$dir"
    git log --since="1 hour ago" --author="Andrew" --oneline 2>/dev/null || true
    cd ..
  fi
done
```

### Step 2: Classify Work Type

**High Risk Yak Shaving:**
- Commits in `bot/` repo (unless it's client work)
- File changes in: `Dockerfile`, `docker-compose.yml`, `.github/`, `entrypoint.sh`
- Commit messages containing: "refactor", "cleanup", "improve", "upgrade", "fix build"
- Multiple different repos in short time (context switching)

**Medium Risk:**
- Test improvements (without failing tests)
- Documentation updates
- Code organization/renaming

**Good Work:**
- Client project repos
- Feature development
- Bug fixes for client work
- Direct revenue tasks

### Step 3: Check Against TASKS.md

Load `workspace/TASKS.md` and check:
- What are the 💰💰💰 (high revenue) tasks?
- Are any DUE TODAY or DUE THIS WEEK?
- Does current git activity align with top priority?

### Step 4: Calculate Metrics

```bash
# Time allocation today (rough estimate from commit timestamps)
commits_in_client_work=X
commits_in_bot=Y
commits_in_other=Z

revenue_ratio=$(( commits_in_client_work * 100 / (commits_in_client_work + commits_in_bot + commits_in_other) ))
```

Goal: 70%+ time on revenue work.

## Response Templates

### ✅ On Track
```
✅ You're on track!

Last hour: Working on [repo name]
Priority: Matches "PageLines feature" (💰💰💰)
Revenue ratio today: 75%

Keep going! 🚀
```

### 🚨 Yak Shaving Detected
```
🚨 YAK SHAVING ALERT

You've been in bot/ for 2.5 hours
Recent commits:
  - "refactor skills system"
  - "improve Docker setup"
  - "update dependencies"

Meanwhile, TASKS.md shows:
  💰💰💰 "PageLines feature" - DUE FRIDAY
  💰💰💰 "Client bug fix" - DUE TODAY

Revenue ratio today: 35% (goal: 70%)

Options:
1. Keep shaving (I'll bug you again in 30min)
2. Park this and switch to client work
3. Explain why this is revenue-critical

Reply with 1, 2, or 3
```

### 📊 End of Day Summary
```
📊 Day Summary - [Date]

Time allocation:
  💰💰💰 Client work: 4h (50%)
  💸 Bot improvements: 3h (38%)
  🔧 Yak shaving: 1h (12%)

Revenue ratio: 50% (goal: 70%)

Completed:
  ✅ Client feature X (partial)
  ✅ Fixed deployment

Yak shaves detected:
  ⚠️ 1.5h debugging Docker (low priority)
  ⚠️ 1h refactoring bot skills (deferred)

Tomorrow plan:
  🎯 Finish PageLines feature BEFORE touching bot
  🎯 Block 9am-2pm for client work only
```

## Implementation

### Bash Script: Check Current Activity

```bash
#!/bin/bash
# Script: productivity-check.sh

echo "🔍 Checking what you're working on..."

# Find most recently modified repo
RECENT_REPO=""
RECENT_TIME=0

cd /Users/arpowers/dev 2>/dev/null || cd ~/dev || exit 1

for dir in */; do
  if [ -d "$dir/.git" ]; then
    LAST_COMMIT=$(cd "$dir" && git log -1 --format=%ct 2>/dev/null)
    if [ -n "$LAST_COMMIT" ] && [ "$LAST_COMMIT" -gt "$RECENT_TIME" ]; then
      RECENT_TIME=$LAST_COMMIT
      RECENT_REPO="${dir%/}"
    fi
  fi
done

if [ -z "$RECENT_REPO" ]; then
  echo "No recent git activity found"
  exit 0
fi

echo "📂 Current repo: $RECENT_REPO"
echo ""

# Get recent commits
cd "$RECENT_REPO"
echo "Recent commits (last 2 hours):"
git log --since="2 hours ago" --pretty=format:"  %cr: %s" --author="Andrew\|arpowers" 2>/dev/null | head -10

# Check if this is a yak shave
YAK_INDICATORS=(
  "bot"
  "docker"
  ".github"
  "config"
  "setup"
)

IS_YAK=0
for indicator in "${YAK_INDICATORS[@]}"; do
  if [[ "$RECENT_REPO" == *"$indicator"* ]]; then
    IS_YAK=1
    break
  fi
done

echo ""
if [ $IS_YAK -eq 1 ]; then
  echo "🚨 WARNING: Potential yak shave detected!"
  echo "   This might not be revenue-critical work"
else
  echo "✅ Looks like productive work"
fi
```

### Integration with HEARTBEAT.md

Add to `workspace/HEARTBEAT.md`:

```yaml
## Hourly (9am-6pm weekdays)

- [ ] **Productivity check**
  - Run: `bash skills/productivity-monitor/productivity-check.sh`
  - Load: workspace/TASKS.md
  - Compare: Current activity vs priorities
  - If yak shaving detected → Telegram nudge
  - If on track → Silent (no notification)

## End of Day (6pm weekdays)

- [ ] **Daily retrospective**
  - Analyze all commits today
  - Calculate revenue ratio
  - List yak shaves
  - Send summary to Telegram
  - Suggest tomorrow's plan
```

## TASKS.md Template

The bot should help maintain `workspace/TASKS.md` like this:

```markdown
# Tasks

## 💰💰💰 Direct Revenue (Client Work)

- [ ] **PageLines feature X** - $5k deliverable - **DUE FRIDAY**
- [ ] **Client bug fix** - $500 - **DUE TODAY**
- [x] ~~Client dashboard updates~~ - DONE

## 💰 Revenue Enablement (Infrastructure)

- [ ] Fix deployment pipeline - **BLOCKING** client work
- [ ] Set up staging environment - Client requested

## 💸 Nice-to-Have (Defer if busy)

- [ ] Refactor bot skills system
- [ ] Improve Docker setup
- [ ] Update documentation
- [ ] Research new tools

## Rules

- Work 70%+ time on 💰💰💰 tasks
- Only do 💰 tasks if **BLOCKING** revenue
- Only do 💸 tasks after weekly revenue goals hit
- If you're working on 💸 for >1 hour, you're yak shaving

## This Week's Goal

$10k billable work + ship PageLines feature

## Revenue Tracking

| Day | Client Hours | Revenue Work % |
|-----|-------------|----------------|
| Mon | 4h | 60% |
| Tue | 6h | 80% |
| Wed | ? | ? |
```

## Advanced: Predictive Nudges

Track patterns over time:
- "You usually yak shave on Friday afternoons"
- "You've avoided outreach for 3 days"
- "Client work drops when you start a side project"

Store in `workspace/memory/productivity-patterns.json`:

```json
{
  "yak_shaving_triggers": [
    "Friday afternoons",
    "After deployment issues",
    "When new tools are discovered"
  ],
  "productive_patterns": [
    "Morning blocks (9am-12pm)",
    "Right after daily briefing",
    "Tuesdays and Wednesdays"
  ],
  "avoidance_signals": [
    "3+ days without client commits",
    "Multiple bot commits in one day",
    "Context switching >5 times/day"
  ]
}
```

## Testing

Test the skill:
1. Make some commits in bot repo
2. Ask bot: "am I yak shaving?"
3. Bot should detect bot repo activity
4. Bot should check TASKS.md for priorities
5. Bot should nudge if misaligned

## Escalation

If yak shaving continues:
- Hour 1: Gentle nudge
- Hour 2: Stronger warning + show revenue loss
- Hour 3: "I'm telling your future self about this"
- Hour 4: Daily summary will roast you

## Privacy Note

This tracks git commits only - no keystroke logging, no screen recording. All analysis stays local or in your Google Drive workspace.
