#!/bin/bash
# Sync workspace (memory, etc.) from cloud to local repo

set -e

APP="ap-assist-agent"
LOCAL_DIR="./workspace"

echo "Syncing workspace from $APP..."

mkdir -p "$LOCAL_DIR"

# Pull workspace files from cloud volume
fly ssh console -a "$APP" -C "tar czf - -C /data/workspace . 2>/dev/null" | \
  tar xzf - -C "$LOCAL_DIR" 2>/dev/null || {
    echo "No workspace files found or error syncing"
    exit 0
  }

echo "Workspace synced to $LOCAL_DIR"
ls -la "$LOCAL_DIR/" 2>/dev/null || echo "Empty workspace"
