#!/bin/bash
# Sync memory from cloud to local repo

set -e

APP="ap-assist-agent"
LOCAL_DIR="./workspace/memory"

echo "Syncing memory from $APP..."

mkdir -p "$LOCAL_DIR"

# Pull session files from cloud
fly ssh console -a "$APP" -C "tar czf - /data/agents/default/sessions/ 2>/dev/null" | \
  tar xzf - -C "$LOCAL_DIR" --strip-components=4 2>/dev/null || {
    echo "No sessions found or error syncing"
    exit 0
  }

echo "Memory synced to $LOCAL_DIR"
ls -la "$LOCAL_DIR/" 2>/dev/null || echo "No sessions yet"
