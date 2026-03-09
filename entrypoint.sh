#!/bin/sh
set -e

# ── Error notification (fires before exit on fatal errors) ──
notify_error() {
    local msg="$1"
    echo "[FATAL] $msg"
    # Send to Discord webhook if configured
    if [ -n "$DISCORD_ERROR_WEBHOOK" ]; then
        curl -sf -X POST "$DISCORD_ERROR_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "$(cat <<PAYLOAD
{
  "content": "🚨 **Bot crashed** — \`${FLY_APP_NAME:-local}\`",
  "embeds": [{
    "color": 15548997,
    "title": "Fatal startup error",
    "description": "$(echo "$msg" | sed 's/"/\\"/g')",
    "fields": [
      {"name": "App", "value": "\`${FLY_APP_NAME:-local}\`", "inline": true},
      {"name": "Region", "value": "\`${FLY_REGION:-n/a}\`", "inline": true},
      {"name": "Build", "value": "\`${BUILD_ID:-0}\`", "inline": true},
      {"name": "Commit", "value": "\`${GIT_SHA:-unknown}\`", "inline": false},
      {"name": "Machine", "value": "\`${FLY_MACHINE_ID:-n/a}\`", "inline": true}
    ]
  }]
}
PAYLOAD
)" 2>/dev/null || echo "[notify] Discord webhook failed"
    fi
}

# Wrapper: run a command, notify + exit on failure
fatal_on_fail() {
    local label="$1"
    shift
    if ! "$@"; then
        notify_error "$label"
        exit 1
    fi
}

on_exit() {
    code=$?
    if [ "$code" -ne 0 ] && [ -z "$NOTIFIED" ]; then
        notify_error "Unexpected exit with code $code"
    fi
    fusermount -u /app/workspace 2>/dev/null || true
    pkill -f "rclone" 2>/dev/null || true
}
cleanup() {
    echo "[entrypoint] SIGTERM received, shutting down..."
    NOTIFIED=1
    on_exit
    exit 0
}
trap cleanup 15 2 3
trap on_exit EXIT

# ── Version info (for diagnosing deploy issues) ──
echo "=== Versions ==="
BOT_VERSION=$(node -p "require('/app/package.json').version" 2>/dev/null || echo "unknown")
echo "[versions] ap-bot: ${BOT_VERSION}"
echo "[versions] git-sha: ${GIT_SHA:-unknown}"
echo "[versions] build-id: ${BUILD_ID:-0}"
echo "[versions] openclaw: $(openclaw --version 2>/dev/null || echo 'not found')"
echo "[versions] mcporter: $(mcporter --version 2>/dev/null || echo 'not found')"
echo "[versions] node: $(node --version 2>/dev/null || echo 'not found')"
echo "[versions] himalaya: $(himalaya --version 2>/dev/null || echo 'not found')"
echo "[versions] rclone: $(rclone version --check 2>/dev/null | head -1 || rclone --version 2>/dev/null | head -1 || echo 'not found')"
echo "[versions] yt-dlp: $(yt-dlp --version 2>/dev/null || echo 'not found')"
echo "[versions] gh: $(gh --version 2>/dev/null | head -1 || echo 'not found')"

# ── Environment info ──
echo "=== Environment ==="
echo "[env] FLY_APP_NAME=${FLY_APP_NAME:-unset}"
echo "[env] FLY_REGION=${FLY_REGION:-unset}"
echo "[env] FLY_MACHINE_ID=${FLY_MACHINE_ID:-unset}"
echo "[env] FLY_IMAGE_REF=${FLY_IMAGE_REF:-unset}"
echo "[env] OPENCLAW_STATE_DIR=${OPENCLAW_STATE_DIR:-unset}"
echo "[env] ANTHROPIC_API_KEY=$([ -n "$ANTHROPIC_API_KEY" ] && echo 'set' || echo 'MISSING')"
echo "[env] TELEGRAM_BOT_TOKEN=$([ -n "$TELEGRAM_BOT_TOKEN" ] && echo 'set' || echo 'MISSING')"
echo "[env] GATEWAY_TOKEN=$([ -n "$GATEWAY_TOKEN" ] && echo 'set' || echo 'unset')"
echo "[env] RCLONE_CONFIG_GDRIVE_TOKEN=$([ -n "$RCLONE_CONFIG_GDRIVE_TOKEN" ] && echo 'set' || echo 'MISSING')"

echo "=== Auto-healing ==="

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

  // Ensure hooks.token differs from gateway auth token (openclaw requirement)
  // Resolve env var templates to compare actual values
  const resolve = (s) => (s || '').replace(/\\$\\{(\\w+)\\}/g, (_, k) => process.env[k] || '');
  if (config.hooks && config.gateway && config.gateway.auth) {
    const gwVal = resolve(config.gateway.auth.token);
    const hookVal = resolve(config.hooks.token);
    if (gwVal && hookVal && gwVal === hookVal) {
      config.hooks.token = (config.hooks.token || 'hook') + '-hooks';
      console.log('Fixed hooks.token to differ from gateway token');
    }
  }

  fs.writeFileSync('/app/.openclaw/openclaw.json', JSON.stringify(config, null, 2));
  console.log('Config updated for production');
" || { notify_error "Config patching failed"; NOTIFIED=1; exit 1; }

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
  if ! ls /app/workspace/ >/dev/null 2>&1; then
    notify_error "Google Drive mount failed — /app/workspace is empty or inaccessible"
    NOTIFIED=1; exit 1
  fi
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
  notify_error "RCLONE_CONFIG_GDRIVE_TOKEN not set — workspace won't persist"
  # Continue anyway, non-fatal
fi

# Run gateway
echo "Starting openclaw gateway..."
exec openclaw gateway run --port 3000 --bind lan --allow-unconfigured
