#!/bin/sh
set -e

cleanup() {
    echo "Received shutdown signal, cleaning up..."
    pkill -f "npx.*-mcp" 2>/dev/null || true
    find /data -name "*.lock" -delete 2>/dev/null || true
    echo "Cleanup complete"
    exit 0
}

trap cleanup 15 2 3

# Volume setup
chown -R node:node /data

# Set paths - use /data for persistent state, /app for code
export OPENCLAW_STATE_DIR="/data"
export BOT_WORKSPACE="/data/workspace"
export BOT_SKILLS="/app/skills"

# Merge base config with volume config (preserve channels from cloud setup)
echo "Merging config..."
node -e "
  const fs = require('fs');
  const base = JSON.parse(fs.readFileSync('/app/openclaw.json'));
  let existing = {};
  if (fs.existsSync('/data/openclaw.json')) {
    try {
      existing = JSON.parse(fs.readFileSync('/data/openclaw.json'));
      console.log('Read existing config');
    } catch(e) {
      console.log('Failed to parse existing config:', e.message);
    }
  }
  const safeFields = ['channels', 'plugins', 'messages'];
  for (const field of safeFields) {
    if (existing[field]) base[field] = existing[field];
  }
  fs.writeFileSync('/data/openclaw.json', JSON.stringify(base, null, 2));
  console.log('Config written to /data/openclaw.json');
"

# Mount Google Drive for shared workspace (if configured)
if [ -n "$RCLONE_CONFIG_GDRIVE_TOKEN" ]; then
  echo "Mounting Google Drive workspace..."
  mkdir -p /data/workspace

  # Create rclone config from env vars
  mkdir -p /root/.config/rclone
  cat > /root/.config/rclone/rclone.conf << EOF
[gdrive]
type = drive
client_id = ${GOOGLE_OAUTH_CLIENT_ID}
client_secret = ${GOOGLE_OAUTH_CLIENT_SECRET}
token = ${RCLONE_CONFIG_GDRIVE_TOKEN}
root_folder_id =
EOF

  # Mount Google Drive folder
  rclone mount gdrive:ari-bot/workspace /data/workspace \
    --vfs-cache-mode full \
    --vfs-cache-max-age 1m \
    --allow-other \
    --daemon

  sleep 2
  echo "Google Drive mounted at /data/workspace"
else
  echo "No Google Drive config, using local workspace..."
  # Fallback: sync from repo
  rsync -av --update /app/workspace/ /data/workspace/ 2>/dev/null || \
    cp -r /app/workspace/* /data/workspace/ 2>/dev/null || true
fi

# Clear stale locks
find /data -name "*.lock" -delete 2>/dev/null || true

# Run as node user
exec su node -c 'openclaw gateway run --port 3000 --bind lan --allow-unconfigured'
