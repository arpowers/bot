#!/bin/sh
set -e

cleanup() {
    echo "Received shutdown signal, cleaning up..."
    fusermount -u /app/workspace 2>/dev/null || true
    pkill -f "rclone" 2>/dev/null || true
    echo "Cleanup complete"
    exit 0
}

trap cleanup 15 2 3

# Mount Google Drive for shared workspace
if [ -n "$RCLONE_CONFIG_GDRIVE_TOKEN" ]; then
  echo "Mounting Google Drive workspace..."

  # Create rclone config
  mkdir -p /root/.config/rclone
  cat > /root/.config/rclone/rclone.conf << EOF
[gdrive]
type = drive
token = ${RCLONE_CONFIG_GDRIVE_TOKEN}
EOF

  # Mount Google Drive folder as workspace
  rclone mount gdrive:ari-bot/workspace /app/workspace \
    --vfs-cache-mode full \
    --vfs-cache-max-age 1m \
    --allow-other \
    --daemon

  sleep 2
  echo "Google Drive mounted at /app/workspace"
  ls -la /app/workspace/
else
  echo "WARNING: No Google Drive config, workspace will not persist!"
fi

# Merge base config with production overrides
echo "Merging configs..."
node -e "
  const fs = require('fs');
  const base = JSON.parse(fs.readFileSync('/app/openclaw.json'));
  const prod = JSON.parse(fs.readFileSync('/app/openclaw-prod.json'));

  // Deep merge function
  const merge = (target, source) => {
    for (const key of Object.keys(source)) {
      if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
        target[key] = target[key] || {};
        merge(target[key], source[key]);
      } else {
        target[key] = source[key];
      }
    }
    return target;
  };

  const merged = merge(base, prod);
  fs.writeFileSync('/app/openclaw-merged.json', JSON.stringify(merged, null, 2));
  console.log('Config merged to /app/openclaw-merged.json');
"

# Use merged config
export OPENCLAW_CONFIG="/app/openclaw-merged.json"

# Run gateway
exec openclaw gateway run --config /app/openclaw-merged.json --port 3000 --bind lan --allow-unconfigured
