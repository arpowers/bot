#!/bin/sh
set -e

cleanup() {
    fusermount -u /app/workspace 2>/dev/null || true
    pkill -f "rclone" 2>/dev/null || true
    exit 0
}
trap cleanup 15 2 3

# Apply prod path overrides to config
echo "Applying production config..."
node -e "
  const fs = require('fs');
  const config = JSON.parse(fs.readFileSync('/app/.openclaw/openclaw.json'));

  // Override paths for production
  config.agents.defaults.workspace = '/app/workspace';
  config.skills.load.extraDirs = ['/app/skills', '/app/workspace/skills'];

  fs.writeFileSync('/app/.openclaw/openclaw.json', JSON.stringify(config, null, 2));
  console.log('Config updated for production');
"

# Mount Google Drive for shared workspace
if [ -n "$RCLONE_CONFIG_GDRIVE_TOKEN" ]; then
  echo "Mounting Google Drive..."
  mkdir -p /root/.config/rclone
  cat > /root/.config/rclone/rclone.conf << EOF
[gdrive]
type = drive
token = ${RCLONE_CONFIG_GDRIVE_TOKEN}
EOF

  rclone mount gdrive:ari-bot/workspace /app/workspace \
    --vfs-cache-mode full \
    --vfs-cache-max-age 1m \
    --allow-other \
    --daemon

  sleep 2
  echo "Google Drive mounted"
  ls -la /app/workspace/ 2>/dev/null || echo "Workspace empty"

  # Copy bot-editable configs from workspace
  if [ -f /app/workspace/mcporter.json ]; then
    mkdir -p /app/config
    cp /app/workspace/mcporter.json /app/config/mcporter.json
    echo "Loaded mcporter.json from workspace"
  fi
else
  echo "WARNING: No Google Drive - workspace won't persist!"
fi

# Run gateway
exec openclaw gateway run --port 3000 --bind lan --allow-unconfigured
