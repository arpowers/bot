#!/bin/sh
set -e

cleanup() {
    fusermount -u /app/workspace 2>/dev/null || true
    pkill -f "rclone" 2>/dev/null || true
    exit 0
}
trap cleanup 15 2 3

echo "=== Pre-deploy auto-healing ==="

# Clear stale locks that can cause startup failures
echo "Clearing stale locks..."
find /app -name "*.lock" -delete 2>/dev/null || true
find /data -name "*.lock" -delete 2>/dev/null || true

# Kill orphaned MCP processes from previous runs
echo "Killing orphaned MCP processes..."
pkill -f "npx.*-mcp" 2>/dev/null || true

# Skip doctor - it strips valid discord config
# openclaw doctor --fix 2>/dev/null || echo "Doctor not available or failed (non-fatal)"
echo "Skipping doctor (was stripping discord config)"

echo "=== Auto-healing complete ==="

# Apply prod path overrides to config
echo "Applying production config..."
node -e "
  const fs = require('fs');
  const config = JSON.parse(fs.readFileSync('/app/.openclaw/openclaw.json'));

  // Override paths for production
  config.agents.defaults.workspace = '/app/workspace';
  config.skills.load.extraDirs = ['/app/skills', '/app/workspace/skills'];

  // Remove signal channel in prod (signal-cli not installed, openclaw auto-enables it)
  if (config.channels && config.channels.signal) {
    delete config.channels.signal;
    console.log('Removed signal channel (not available in prod)');
  }

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

  # Install npm deps for workspace skills
  echo "Installing workspace skill dependencies..."
  for pkg in /app/workspace/skills/*/package.json; do
    if [ -f "$pkg" ]; then
      dir=$(dirname "$pkg")
      echo "Installing deps in $dir"
      (cd "$dir" && npm install --omit=dev 2>/dev/null) || echo "Failed to install deps in $dir"
    fi
  done
else
  echo "WARNING: No Google Drive - workspace won't persist!"
fi

# Run gateway
echo "Starting openclaw gateway..."
exec openclaw gateway run --port 3000 --bind lan --allow-unconfigured
