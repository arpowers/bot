# Deployment Specification

Procedures for deploying AP Bot to Fly.io.

## Quick Commands

```bash
npm run deploy           # Push to main (triggers CI)
npm run deploy:force     # Force rebuild without cache
npm run deploy:check     # Check deploy health
npm run deploy:logs      # View cloud logs
npm run deploy:restart   # Restart machine
npm run deploy:ssh       # SSH into container
npm run deploy:status    # Check machine status
```

## Pre-Deploy Checklist

1. **Test locally first**
   ```bash
   openclaw gateway run
   ```

2. **Check for config issues**
   ```bash
   openclaw doctor
   ```

3. **Verify secrets are set** (if adding new ones)
   ```bash
   fly secrets list --app ap-assist-agent
   ```

4. **Commit and push**
   ```bash
   git add -A && git commit -m "description" && git push
   ```

## What Happens on Deploy

1. **GitHub Actions** triggers on push to main
2. **Fly.io builds** from Dockerfile
3. **entrypoint.sh runs:**
   - Clears stale locks
   - Kills orphaned MCP processes
   - Runs `openclaw doctor --fix`
   - Patches config for prod paths
   - Mounts Google Drive via rclone
   - Starts `openclaw gateway run`

## Auto-Healing Mechanisms

The entrypoint.sh includes automatic fixes:

| Issue | Auto-Fix |
|-------|----------|
| Stale lock files | `find /app -name "*.lock" -delete` |
| Orphaned MCP processes | `pkill -f "npx.*-mcp"` |
| Config validation errors | `openclaw doctor --fix` |

## Common Failures

### 1. Config Validation Error

**Symptoms:** Bot crashes immediately after deploy
**Cause:** Invalid key in openclaw.json (like `mcp` instead of `mcpServers`)
**Fix:**
```bash
# Check logs for specific error
fly logs --app ap-assist-agent

# Fix config locally, commit, and redeploy
```

### 2. MCP Server Startup Failure

**Symptoms:** Bot starts but MCP tools don't work
**Cause:** Missing env var, bad MCP server config, or npm package issue
**Fix:**
```bash
# SSH and check manually
fly ssh console --app ap-assist-agent
npx -y @pegasusheavy/google-mcp --help
```

### 3. Google Drive Mount Failure

**Symptoms:** Workspace is empty, memories don't persist
**Cause:** Expired rclone token
**Fix:**
```bash
# Refresh the rclone token locally
rclone config reconnect gdrive:

# Get the new token
cat ~/.config/rclone/rclone.conf | grep token

# Update Fly secret
fly secrets set RCLONE_CONFIG_GDRIVE_TOKEN='...'
```

### 4. Health Check Timeout

**Symptoms:** Deploy succeeds but machine keeps restarting
**Cause:** Health check fails because bot takes too long to start
**Fix:** Increase health check grace period in fly.toml:
```toml
[[services.http_checks]]
  grace_period = "60s"
```

### 5. OAuth Token Expired

**Symptoms:** Bot starts but Claude API calls fail
**Cause:** Claude Max OAuth token expired
**Fix:**
```bash
# Get new token locally
claude setup-token

# Update on Fly
fly secrets set ANTHROPIC_API_KEY="sk-ant-oat01-..."
```

## Post-Deploy Verification

```bash
# Quick check
npm run deploy:check

# Or with wait
npm run deploy:check:wait

# Manual verification
fly status --app ap-assist-agent
fly logs --app ap-assist-agent
```

## CI Failure Webhook

When deploy fails, GitHub Actions posts to a webhook (configured in `.github/workflows/deploy.yml`). The bot can then:
1. Receive the failure notification
2. Check logs
3. Attempt auto-fix if possible
4. Notify user

## Rolling Back

```bash
# List recent deployments
fly releases --app ap-assist-agent

# Rollback to previous version
fly deploy --image <previous-image-ref>
```

## Secrets Management

```bash
# List all secrets
fly secrets list --app ap-assist-agent

# Set a secret
fly secrets set KEY="value" --app ap-assist-agent

# Unset a secret
fly secrets unset KEY --app ap-assist-agent
```

### Required Secrets

| Secret | Purpose |
|--------|---------|
| `ANTHROPIC_API_KEY` | Claude Max OAuth token |
| `TELEGRAM_BOT_TOKEN` | Production bot (@ari_task_bot) |
| `RCLONE_CONFIG_GDRIVE_TOKEN` | Google Drive mount |
| `PERPLEXITY_API_KEY` | Research skill |
| `POSTHOG_API_KEY` | Analytics |
| `ELEVENLABS_API_KEY` | Voice synthesis |

## Monitoring

```bash
# Live logs
fly logs --app ap-assist-agent

# Machine metrics
fly status --app ap-assist-agent

# SSH for debugging
fly ssh console --app ap-assist-agent
```
