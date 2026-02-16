#!/bin/bash
# Setup Script: Install hourly productivity monitoring (macOS)

set -e

echo "🔧 Setting up productivity monitoring..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="$SCRIPT_DIR/sync-to-cloud.sh"

# Verify sync script exists
if [ ! -f "$SYNC_SCRIPT" ]; then
  echo "❌ Error: sync-to-cloud.sh not found"
  exit 1
fi

echo "📋 This will set up hourly productivity checks using macOS launchd"
echo "   (launchd is like cron but better for macOS)"
echo ""
echo "What it does:"
echo "  • Runs every hour (9am-6pm weekdays)"
echo "  • Checks your git activity"
echo "  • Writes state to Google Drive"
echo "  • Cloud bot reads it and can nudge you"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Create launchd plist
PLIST_FILE="$HOME/Library/LaunchAgents/com.apbot.productivity-monitor.plist"

cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.apbot.productivity-monitor</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SYNC_SCRIPT</string>
    </array>

    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>9</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>10</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>11</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>12</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>13</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>14</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>15</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>16</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>17</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>18</integer>
        </dict>
        <!-- Tuesday through Friday (same hours) -->
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>9</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>10</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>11</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>12</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>13</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>14</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>15</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>16</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>17</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>18</integer>
        </dict>
        <!-- Repeat for Wed (3), Thu (4), Fri (5) -->
        <dict>
            <key>Weekday</key>
            <integer>3</integer>
            <key>Hour</key>
            <integer>9</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>3</integer>
            <key>Hour</key>
            <integer>12</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>3</integer>
            <key>Hour</key>
            <integer>15</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>3</integer>
            <key>Hour</key>
            <integer>18</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>4</integer>
            <key>Hour</key>
            <integer>9</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>4</integer>
            <key>Hour</key>
            <integer>12</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>4</integer>
            <key>Hour</key>
            <integer>15</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>4</integer>
            <key>Hour</key>
            <integer>18</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>5</integer>
            <key>Hour</key>
            <integer>9</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>5</integer>
            <key>Hour</key>
            <integer>12</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>5</integer>
            <key>Hour</key>
            <integer>15</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>5</integer>
            <key>Hour</key>
            <integer>18</integer>
        </dict>
    </array>

    <key>StandardOutPath</key>
    <string>$HOME/.openclaw/logs/productivity-monitor.log</string>

    <key>StandardErrorPath</key>
    <string>$HOME/.openclaw/logs/productivity-monitor-error.log</string>
</dict>
</plist>
EOF

# Create logs directory
mkdir -p "$HOME/.openclaw/logs"

# Load the launchd job
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo ""
echo "✅ Productivity monitoring installed!"
echo ""
echo "What happens now:"
echo "  • Every hour (9am-6pm weekdays), your Mac will:"
echo "    1. Check git activity in ~/dev"
echo "    2. Write state to workspace/memory/productivity-state.json"
echo "    3. Google Drive syncs it to cloud"
echo "    4. Cloud bot reads it and can nudge you via Telegram"
echo ""
echo "Manual test:"
echo "  bash $SYNC_SCRIPT"
echo ""
echo "View logs:"
echo "  tail -f ~/.openclaw/logs/productivity-monitor.log"
echo ""
echo "Uninstall:"
echo "  launchctl unload $PLIST_FILE"
echo "  rm $PLIST_FILE"
echo ""
