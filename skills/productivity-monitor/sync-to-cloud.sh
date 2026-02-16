#!/bin/bash
# Sync Script: Runs locally, writes state to Google Drive for cloud bot

set -uo pipefail  # Removed -e to see errors

WORKSPACE_DIR="/Users/arpowers/dev/bot/workspace"
STATE_FILE="$WORKSPACE_DIR/memory/productivity-state.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure memory directory exists
mkdir -p "$WORKSPACE_DIR/memory"

# Run productivity check and capture output (strip ALL color codes)
cd "$(dirname "$SCRIPT_DIR")"
CHECK_OUTPUT=$(bash "$SCRIPT_DIR/productivity-check.sh" 2>&1 | perl -pe 's/\e\[[0-9;]*m//g' | sed 's/\\033\[[0-9;]*m//g')
CHECK_EXIT_CODE=$?

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_STR=$(date +"%Y-%m-%d")

# Determine status
case $CHECK_EXIT_CODE in
  0)  STATUS="on_track" ;;
  1)  STATUS="medium_risk" ;;
  2)  STATUS="high_risk" ;;
  *)  STATUS="error" ;;
esac

# Extract key info from output (color codes already stripped)
CURRENT_REPO=$(echo "$CHECK_OUTPUT" | grep "Currently working in:" | sed 's/.*: //' | xargs || echo "unknown")
LAST_COMMIT_TIME=$(echo "$CHECK_OUTPUT" | grep "Last commit:" | sed 's/.*: //' | xargs || echo "unknown")
LAST_COMMIT_MSG=$(echo "$CHECK_OUTPUT" | grep "Last message:" | sed 's/.*: //' | sed 's/"//g' | xargs || echo "unknown")

# Count today's commits across all repos
TOTAL_COMMITS=0
for dir in ~/dev/*/; do
  if [ -d "$dir/.git" ]; then
    count=$(cd "$dir" && git log --since="midnight" --author="$(git config user.name)" --oneline 2>/dev/null | wc -l | xargs)
    TOTAL_COMMITS=$((TOTAL_COMMITS + count))
  fi
done

# Create JSON state
cat > "$STATE_FILE" << EOF
{
  "timestamp": "$TIMESTAMP",
  "date": "$DATE_STR",
  "status": "$STATUS",
  "current_repo": "$CURRENT_REPO",
  "last_commit_time": "$LAST_COMMIT_TIME",
  "last_commit_message": "$LAST_COMMIT_MSG",
  "commits_today": $TOTAL_COMMITS,
  "check_output": $(echo "$CHECK_OUTPUT" | jq -Rs .),
  "exit_code": $CHECK_EXIT_CODE
}
EOF

echo "✅ Productivity state synced to: $STATE_FILE"
echo "   Status: $STATUS"
echo "   Commits today: $TOTAL_COMMITS"

# Google Drive will auto-sync this file to cloud
