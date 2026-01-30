#!/bin/bash
# Run the bot locally - everything stays in this repo

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

# Load environment variables
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

# Point OpenClaw at this repo (no ~/.openclaw needed)
export OPENCLAW_STATE_DIR="$REPO_DIR"
export BOT_WORKSPACE="$REPO_DIR/workspace"
export BOT_SKILLS="$REPO_DIR/skills"

# Himalaya config (only thing that needs ~/.config)
mkdir -p ~/.config/himalaya
cp config/himalaya.toml ~/.config/himalaya/config.toml 2>/dev/null || true

# Run gateway
exec openclaw gateway run --port 3000
