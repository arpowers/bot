#!/bin/sh
set -e

# ── Error notification (fires before exit on fatal errors) ──
notify_error() {
    local msg="$1"
    echo "[FATAL] $msg"
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

# ── Version info ──
echo "=== Versions ==="
BOT_VERSION=$(python3 -c "import json; print(json.load(open('/app/package.json'))['version'])" 2>/dev/null || echo "unknown")
echo "[versions] ap-bot: ${BOT_VERSION}"
echo "[versions] git-sha: ${GIT_SHA:-unknown}"
echo "[versions] build-id: ${BUILD_ID:-0}"
echo "[versions] hermes: $(hermes version 2>/dev/null || echo 'not found')"
echo "[versions] node: $(node --version 2>/dev/null || echo 'not found')"
echo "[versions] python: $(python3 --version 2>/dev/null || echo 'not found')"
echo "[versions] himalaya: $(himalaya --version 2>/dev/null || echo 'not found')"
echo "[versions] rclone: $(rclone version --check 2>/dev/null | head -1 || rclone --version 2>/dev/null | head -1 || echo 'not found')"
echo "[versions] yt-dlp: $(yt-dlp --version 2>/dev/null || echo 'not found')"
echo "[versions] gh: $(gh --version 2>/dev/null | head -1 || echo 'not found')"

# ── Environment info ──
echo "=== Environment ==="
echo "[env] FLY_APP_NAME=${FLY_APP_NAME:-unset}"
echo "[env] FLY_REGION=${FLY_REGION:-unset}"
echo "[env] FLY_MACHINE_ID=${FLY_MACHINE_ID:-unset}"
echo "[env] OPENROUTER_API_KEY=$([ -n "$OPENROUTER_API_KEY" ] && echo 'set' || echo 'MISSING')"
echo "[env] TELEGRAM_BOT_TOKEN=$([ -n "$TELEGRAM_BOT_TOKEN" ] && echo 'set' || echo 'MISSING')"
echo "[env] RCLONE_CONFIG_GDRIVE_TOKEN=$([ -n "$RCLONE_CONFIG_GDRIVE_TOKEN" ] && echo 'set' || echo 'MISSING')"

echo "=== Auto-healing ==="

# Clear stale locks
echo "Clearing stale locks..."
find /app -name "*.lock" -delete 2>/dev/null || true
find /root/.hermes -name "*.lock" -delete 2>/dev/null || true

# Kill orphaned MCP processes
echo "Killing orphaned MCP processes..."
pkill -f "npx.*-mcp" 2>/dev/null || true

echo "=== Auto-healing complete ==="

# ── Apply production overrides to Hermes config ──
echo "Applying production config..."
python3 -c "
import yaml, os

config_path = os.path.expanduser('~/.hermes/config.yaml')
with open(config_path) as f:
    config = yaml.safe_load(f)

# Override skill dirs for production paths
config.setdefault('skills', {})
config['skills']['external_dirs'] = ['/app/skills', '/app/workspace/skills']

# Write back
with open(config_path, 'w') as f:
    yaml.dump(config, f, default_flow_style=False, sort_keys=False)

print('Config updated for production')
"

# ── Write .env from Fly.io secrets ──
echo "Writing Hermes .env from environment..."
cat > /root/.hermes/.env << ENVEOF
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS:-5810543997}
DISCORD_BOT_TOKEN=${DISCORD_BOT_TOKEN}
ELEVENLABS_API_KEY=${ELEVENLABS_API_KEY}
VOYAGE_API_KEY=${VOYAGE_API_KEY}
GITHUB_TOKEN=${GITHUB_TOKEN}
APIFY_API_TOKEN=${APIFY_API_TOKEN}
ENRICHLAYER_API_KEY=${ENRICHLAYER_API_KEY}
TICKTICK_ACCESS_TOKEN=${TICKTICK_ACCESS_TOKEN}
ENVEOF

# ── Ensure Hermes dirs exist ──
mkdir -p /root/.hermes/{cron,sessions,logs,memories,skills,pairing,hooks,image_cache,audio_cache}

# ── Mount Google Drive for shared workspace ──
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

  # Symlink SOUL.md from workspace to Hermes config dir
  if [ -f /app/workspace/SOUL.md ]; then
    ln -sf /app/workspace/SOUL.md /root/.hermes/SOUL.md
    echo "Linked SOUL.md from workspace"
  fi

  # Symlink memories from workspace
  if [ -d /app/workspace/memory ]; then
    ln -sf /app/workspace/memory/* /root/.hermes/memories/ 2>/dev/null || true
    echo "Linked workspace memories"
  fi
  if [ -f /app/workspace/MEMORY.md ]; then
    ln -sf /app/workspace/MEMORY.md /root/.hermes/memories/MEMORY.md
    echo "Linked MEMORY.md from workspace"
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
fi

# ── Health check server (Fly.io needs HTTP on port 3000) ──
echo "Starting health check server on port 3000..."
python3 -c "
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading, os

class Health(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(b'{\"status\":\"ok\",\"agent\":\"hermes\",\"version\":\"' + os.environ.get('GIT_SHA','unknown').encode()[:8] + b'\"}')
    def log_message(self, *args):
        pass  # suppress access logs

server = HTTPServer(('0.0.0.0', 3000), Health)
threading.Thread(target=server.serve_forever, daemon=True).start()

# Block — the gateway runs via exec below
import time
while True:
    time.sleep(86400)
" &
HEALTH_PID=$!
sleep 1

# ── Start Hermes gateway ──
echo "Starting Hermes gateway..."
hermes gateway &
GATEWAY_PID=$!

# Wait for either process to exit
wait -n $HEALTH_PID $GATEWAY_PID 2>/dev/null || wait $GATEWAY_PID
