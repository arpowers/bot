#!/bin/bash
# Daily Summary Script
# Analyzes full day's git activity and generates report

set -euo pipefail

DEV_DIR="${HOME}/dev"
DATE_STR=$(date +"%Y-%m-%d")

echo "📊 Daily Productivity Summary - $DATE_STR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -d "$DEV_DIR" ]; then
  echo "❌ Dev directory not found: $DEV_DIR"
  exit 1
fi

cd "$DEV_DIR"

# Categorize repos
CLIENT_REPOS=("pagelines" "client" "project")  # Add your client repo patterns
BOT_REPOS=("bot" "automation" "scripts")
OTHER_REPOS=()

declare -A repo_commits
declare -A repo_category
total_commits=0

# Collect all commits from today
echo "📝 Commits by repository:"
echo ""

for dir in */; do
  if [ -d "$dir/.git" ]; then
    repo_name="${dir%/}"
    count=$(cd "$dir" && git log --since="midnight" --author="$(git config user.name)" --oneline 2>/dev/null | wc -l | xargs)

    if [ "$count" -gt 0 ]; then
      repo_commits["$repo_name"]=$count
      total_commits=$((total_commits + count))

      # Categorize repo
      category="other"
      for client_pattern in "${CLIENT_REPOS[@]}"; do
        if [[ "$repo_name" == *"$client_pattern"* ]]; then
          category="client"
          break
        fi
      done

      if [ "$category" = "other" ]; then
        for bot_pattern in "${BOT_REPOS[@]}"; do
          if [[ "$repo_name" == *"$bot_pattern"* ]]; then
            category="bot"
            break
          fi
        done
      fi

      repo_category["$repo_name"]=$category

      # Print with emoji
      case $category in
        client) echo "  💰 $repo_name: $count commits" ;;
        bot)    echo "  🤖 $repo_name: $count commits" ;;
        *)      echo "  📁 $repo_name: $count commits" ;;
      esac
    fi
  fi
done

if [ $total_commits -eq 0 ]; then
  echo "  (no commits today)"
  echo ""
  echo "Did you:"
  echo "  • Work without committing?"
  echo "  • Have meetings all day?"
  echo "  • Take the day off?"
  exit 0
fi

echo ""
echo "Total: $total_commits commits"
echo ""

# Calculate time allocation (rough estimate: 1 commit ≈ 30min)
client_commits=0
bot_commits=0
other_commits=0

for repo in "${!repo_commits[@]}"; do
  count=${repo_commits[$repo]}
  category=${repo_category[$repo]}

  case $category in
    client) client_commits=$((client_commits + count)) ;;
    bot)    bot_commits=$((bot_commits + count)) ;;
    *)      other_commits=$((other_commits + count)) ;;
  esac
done

client_pct=$((client_commits * 100 / total_commits))
bot_pct=$((bot_commits * 100 / total_commits))
other_pct=$((other_commits * 100 / total_commits))

# Estimate hours (rough: 1 commit = 30 min)
client_hours=$(awk "BEGIN {print $client_commits * 0.5}")
bot_hours=$(awk "BEGIN {print $bot_commits * 0.5}")
other_hours=$(awk "BEGIN {print $other_commits * 0.5}")

echo "⏱️  Time Allocation (estimated):"
echo ""
echo "  💰💰💰 Client work:     ${client_hours}h (${client_pct}%)"
echo "  🤖 Bot improvements:  ${bot_hours}h (${bot_pct}%)"
echo "  📁 Other:             ${other_hours}h (${other_pct}%)"
echo ""

# Calculate revenue ratio
revenue_ratio=$client_pct
goal=70

if [ $revenue_ratio -ge $goal ]; then
  echo "✅ Revenue ratio: ${revenue_ratio}% (goal: ${goal}%+) - GREAT JOB! 🎉"
elif [ $revenue_ratio -ge 50 ]; then
  echo "⚠️  Revenue ratio: ${revenue_ratio}% (goal: ${goal}%+) - Getting closer"
else
  echo "🚨 Revenue ratio: ${revenue_ratio}% (goal: ${goal}%+) - NEEDS IMPROVEMENT"
fi
echo ""

# Detect yak shaving
echo "🔍 Yak Shaving Analysis:"
echo ""

yak_detected=0

# Check all commits for yak keywords
for repo in "${!repo_commits[@]}"; do
  cd "$DEV_DIR/$repo"

  yak_commits=$(git log --since="midnight" --author="$(git config user.name)" --oneline 2>/dev/null | \
    grep -iE "refactor|cleanup|improve|upgrade|docker|config|setup|fix build|dependencies" || true)

  if [ -n "$yak_commits" ]; then
    if [ $yak_detected -eq 0 ]; then
      echo "⚠️  Potential yak shaves detected:"
      yak_detected=1
    fi
    echo ""
    echo "  In $repo:"
    echo "$yak_commits" | sed 's/^/    /'
  fi
done

if [ $yak_detected -eq 0 ]; then
  echo "  ✅ No obvious yak shaving detected"
fi
echo ""

# Recommendations
echo "📋 Tomorrow's Plan:"
echo ""

if [ $revenue_ratio -lt $goal ]; then
  echo "  🎯 Block 9am-2pm for client work ONLY"
  echo "  🎯 Defer all bot improvements until revenue goal hit"
  echo "  🎯 Check TASKS.md and tackle 💰💰💰 tasks first"
else
  echo "  🎯 Keep up the good work on client projects"
  echo "  🎯 You've earned some bot improvement time"
fi
echo ""

# Summary emoji
if [ $revenue_ratio -ge $goal ]; then
  echo "Overall rating: 🌟🌟🌟🌟🌟"
elif [ $revenue_ratio -ge 50 ]; then
  echo "Overall rating: ⭐⭐⭐"
else
  echo "Overall rating: 💩 (but tomorrow is a new day!)"
fi
echo ""
