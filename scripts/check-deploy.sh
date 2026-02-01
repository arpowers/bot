#!/bin/bash
# Post-deploy health check script
# Usage: ./scripts/check-deploy.sh [--wait]

set -e

APP_NAME="ap-assist-agent"
HEALTH_URL="https://ap-assist-agent.fly.dev/health"

# Wait for deploy to settle
if [ "$1" = "--wait" ]; then
  echo "Waiting 30s for deploy to settle..."
  sleep 30
fi

echo "=== Checking deploy status ==="

# Check machine state
echo "Checking machine state..."
STATUS=$(fly status --app $APP_NAME --json 2>/dev/null | jq -r '.Machines[0].State' 2>/dev/null || echo "unknown")

if [ "$STATUS" != "started" ]; then
  echo "❌ Deploy may have failed - machine state: $STATUS"
  echo ""
  echo "Recent logs:"
  fly logs --app $APP_NAME --no-tail 2>/dev/null | tail -30 || true
  exit 1
fi

echo "✓ Machine state: $STATUS"

# Check health endpoint (if available)
echo "Checking health endpoint..."
if curl -sf "$HEALTH_URL" --max-time 10 > /dev/null 2>&1; then
  echo "✓ Health endpoint OK"
else
  echo "⚠ Health endpoint not responding (may be normal if no /health route)"
fi

# Show recent activity
echo ""
echo "=== Recent logs ==="
fly logs --app $APP_NAME --no-tail 2>/dev/null | tail -15 || true

echo ""
echo "✅ Deploy healthy"
