#!/bin/bash
# Productivity Check Script
# Analyzes recent git activity and detects yak shaving

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DEV_DIR="${HOME}/dev"
TIME_WINDOW="${1:-2 hours ago}"  # Default: last 2 hours

echo "🔍 Productivity Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if dev directory exists
if [ ! -d "$DEV_DIR" ]; then
  echo "❌ Dev directory not found: $DEV_DIR"
  exit 1
fi

cd "$DEV_DIR"

# Find most recently modified repo
RECENT_REPO=""
RECENT_TIME=0
RECENT_COMMIT=""

echo "📂 Scanning repos in $DEV_DIR..."
echo ""

for dir in */; do
  if [ -d "$dir/.git" ]; then
    repo_name="${dir%/}"

    # Get last commit time and message
    last_commit_time=$(cd "$dir" && git log -1 --format=%ct 2>/dev/null || echo "0")
    last_commit_msg=$(cd "$dir" && git log -1 --format="%s" 2>/dev/null || echo "")

    if [ "$last_commit_time" -gt "$RECENT_TIME" ]; then
      RECENT_TIME=$last_commit_time
      RECENT_REPO="$repo_name"
      RECENT_COMMIT="$last_commit_msg"
    fi
  fi
done

if [ -z "$RECENT_REPO" ] || [ "$RECENT_TIME" -eq 0 ]; then
  echo "ℹ️  No recent git activity found"
  echo ""
  echo "Either:"
  echo "  - You haven't committed anything recently"
  echo "  - You're working outside ~/dev"
  echo ""
  exit 0
fi

# Calculate time since last commit
CURRENT_TIME=$(date +%s)
TIME_DIFF=$((CURRENT_TIME - RECENT_TIME))
HOURS_AGO=$((TIME_DIFF / 3600))
MINS_AGO=$(((TIME_DIFF % 3600) / 60))

echo "📍 Currently working in: ${GREEN}${RECENT_REPO}${NC}"
echo "⏱️  Last commit: ${HOURS_AGO}h ${MINS_AGO}m ago"
echo "💬 Last message: \"$RECENT_COMMIT\""
echo ""

# Get recent commits from this repo
cd "$RECENT_REPO"

echo "📝 Recent commits (since $TIME_WINDOW):"
COMMITS=$(git log --since="$TIME_WINDOW" --pretty=format:"  %cr: %s" --author="$(git config user.name)" 2>/dev/null | head -10)

if [ -z "$COMMITS" ]; then
  echo "  (none in this time window)"
else
  echo "$COMMITS"
fi
echo ""

# Count commits per repo today
echo "📊 Activity today:"
cd "$DEV_DIR"

total_commits=0
num_repos=0

for dir in */; do
  if [ -d "$dir/.git" ]; then
    repo_name="${dir%/}"
    count=$(cd "$dir" && git log --since="midnight" --author="$(git config user.name)" --oneline 2>/dev/null | wc -l | xargs)

    if [ "$count" -gt 0 ]; then
      total_commits=$((total_commits + count))
      num_repos=$((num_repos + 1))
      echo "  $repo_name: $count commits"
    fi
  fi
done

if [ $total_commits -eq 0 ]; then
  echo "  (no commits today yet)"
fi
echo ""

# Yak shaving detection
echo "🔍 Yak Shaving Analysis:"
echo ""

YAK_SCORE=0
YAK_REASONS=()

# Check 1: Working in bot repo
if [[ "$RECENT_REPO" == "bot" ]]; then
  YAK_SCORE=$((YAK_SCORE + 30))
  YAK_REASONS+=("Working in bot/ repo (unless it's client work)")
fi

# Check 2: Commit message indicators
YAK_KEYWORDS=("refactor" "cleanup" "improve" "upgrade" "docker" "config" "setup" "fix build" "dependencies")
for keyword in "${YAK_KEYWORDS[@]}"; do
  if echo "$RECENT_COMMIT" | grep -iq "$keyword"; then
    YAK_SCORE=$((YAK_SCORE + 15))
    YAK_REASONS+=("Commit message contains '$keyword'")
    break
  fi
done

# Check 3: Multiple repos (context switching)
if [ "$num_repos" -gt 3 ]; then
  YAK_SCORE=$((YAK_SCORE + 20))
  YAK_REASONS+=("Working across ${num_repos} different repos today")
fi

# Check 4: Long time since last commit (might be stuck/debugging)
if [ $HOURS_AGO -gt 2 ]; then
  YAK_SCORE=$((YAK_SCORE + 25))
  YAK_REASONS+=("${HOURS_AGO}h since last commit - might be stuck")
fi

# Determine verdict
if [ $YAK_SCORE -ge 50 ]; then
  echo "${RED}🚨 HIGH RISK YAK SHAVING DETECTED${NC}"
  echo ""
  echo "Red flags:"
  for reason in "${YAK_REASONS[@]}"; do
    echo "  ⚠️  $reason"
  done
  echo ""
  echo "Questions to ask yourself:"
  echo "  1. Does this make money RIGHT NOW?"
  echo "  2. Is this blocking a client deliverable?"
  echo "  3. Can this wait until revenue goals are hit?"
  echo ""
  exit 2

elif [ $YAK_SCORE -ge 25 ]; then
  echo "${YELLOW}⚠️  MEDIUM RISK - Possible yak shaving${NC}"
  echo ""
  echo "Warning signs:"
  for reason in "${YAK_REASONS[@]}"; do
    echo "  • $reason"
  done
  echo ""
  echo "Check TASKS.md - are you working on the top priority?"
  echo ""
  exit 1

else
  echo "${GREEN}✅ Looks productive!${NC}"
  echo ""
  echo "Current work seems aligned with shipping features."
  echo "Keep going! 🚀"
  echo ""
  exit 0
fi
