# Unified Config: Sync Everything via Google Drive

Make local and cloud bots share the **exact same** config and skills via Google Drive.

---

## Goal

**One source of truth:** All config, skills, and memory in `workspace/` (Google Drive synced).

```
workspace/
├── .openclaw/              # ← Move config here
│   ├── openclaw.json       # ← Single config for local + cloud
│   ├── credentials/        # ← Shared auth tokens
│   └── telegram/           # ← Shared pairing state
├── skills/                 # ← All skills here (core + custom)
├── TASKS.md                # ← Already here
├── MEMORY.md               # ← Already here
└── memory/                 # ← Already here
```

Both local and cloud point to `workspace/` → Everything syncs automatically!

---

## Benefits

### ✅ Single Source of Truth
- Edit config once → Both bots see it instantly
- Add/modify skills → No redeploy needed
- One OPENCLAW_STATE_DIR for everything

### ✅ Zero Deploy Lag
- Change MCP servers? Instant sync
- Add new skill? Instant sync
- Update model? Instant sync

### ✅ Simpler Mental Model
- All bot files in one place (`workspace/`)
- Google Drive is the source of truth
- No git push/deploy cycle for config changes

---

## Migration Steps

### 1. Move OpenClaw Config to Workspace

```bash
cd /Users/arpowers/dev/bot

# Move .openclaw to workspace
mv .openclaw workspace/.openclaw

# Create symlink for backward compatibility
ln -s workspace/.openclaw .openclaw
```

### 2. Move Core Skills to Workspace

```bash
# Option A: Move everything
mv skills workspace/skills-core
ln -s workspace/skills-core skills

# Option B: Keep git-tracked skills separate, only sync dynamic ones
# (workspace/skills/ already exists for dynamic skills)
```

### 3. Update Local .env

Edit `.env`:
```bash
# Point to workspace/.openclaw instead of ./.openclaw
OPENCLAW_STATE_DIR="./workspace/.openclaw"
```

### 4. Update Cloud (entrypoint.sh)

Edit `entrypoint.sh` to use workspace:
```bash
# Change from:
ENV OPENCLAW_STATE_DIR=/app/.openclaw

# To:
ENV OPENCLAW_STATE_DIR=/app/workspace/.openclaw
```

### 5. Update Dockerfile

Edit `Dockerfile`:
```dockerfile
# Remove these lines (no longer needed):
# COPY .openclaw/ /app/.openclaw/
# COPY skills/ /app/skills/

# Keep only:
COPY entrypoint.sh /app/entrypoint.sh
COPY package.json /app/package.json  # if exists

# Everything else comes from Google Drive mount
```

### 6. Update openclaw.json Paths

Since `openclaw.json` is now in `workspace/.openclaw/`, paths are relative to that:

```json
{
  "skills": [
    {
      "path": "../skills-core/github"  // or "../skills/skill-name"
    }
  ],
  "workspace": {
    "path": ".."  // Points to workspace/ parent
  }
}
```

### 7. Git Cleanup

Update `.gitignore`:
```gitignore
# OLD: Ignore .openclaw runtime state
# .openclaw/agents/
# .openclaw/credentials/
# .openclaw/telegram/

# NEW: Ignore entire .openclaw (now a symlink)
.openclaw
# Actual config is in workspace/.openclaw/ (Google Drive)

# OLD: skills/ is in git
# NEW: skills/ is symlink to workspace/skills-core/
skills
```

Update `.dockerignore`:
```dockerignore
# Don't copy these (come from Google Drive)
workspace/
.openclaw/
skills/
```

---

## Final Structure

### Local (Mac)

```
/Users/arpowers/dev/bot/
├── .openclaw/           → symlink to workspace/.openclaw/
├── skills/              → symlink to workspace/skills-core/
├── workspace/           → symlink to Google Drive
│   ├── .openclaw/       ← REAL config here
│   │   ├── openclaw.json
│   │   ├── credentials/
│   │   └── telegram/
│   ├── skills-core/     ← Core skills
│   ├── skills/          ← Dynamic skills
│   ├── TASKS.md
│   ├── MEMORY.md
│   └── memory/
├── entrypoint.sh
├── Dockerfile
└── .env (OPENCLAW_STATE_DIR=./workspace/.openclaw)
```

### Cloud (Fly.io)

```
/app/
├── workspace/           ← rclone mount from Google Drive
│   ├── .openclaw/       ← Same config as local!
│   │   ├── openclaw.json
│   │   ├── credentials/
│   │   └── telegram/
│   ├── skills-core/     ← Same skills as local!
│   ├── skills/
│   ├── TASKS.md
│   ├── MEMORY.md
│   └── memory/
├── entrypoint.sh
└── (nothing else needed!)
```

**Both point to same Google Drive folder → Perfect sync!**

---

## Pros vs Cons

### ✅ Pros
- **Zero deploy lag** - Edit config, instant sync
- **Single source of truth** - No confusion
- **Simpler** - Everything in workspace/
- **Dynamic skills** - Add/modify without redeploy
- **Shared credentials** - Same auth tokens

### ⚠️ Cons
- **Requires Google Drive** - If Drive fails, both bots offline
- **No version control** - Config changes not in git
- **Less safe** - Mistake in config affects both bots instantly

---

## Hybrid Approach (Recommended)

Keep some things in git, sync only what makes sense:

```
Git (version controlled):
├── Dockerfile
├── entrypoint.sh
├── skills/             ← Core stable skills (committed)
└── .env.example

Google Drive (synced):
├── workspace/.openclaw/
│   └── openclaw.json   ← Gateway config
├── workspace/skills/   ← Dynamic/experimental skills
├── workspace/TASKS.md
└── workspace/memory/
```

**Best of both worlds:**
- Core skills in git (stable, versioned)
- Config in Google Drive (flexible, instant sync)
- Dynamic skills in Google Drive (no deploy needed)

---

## Migration Command Summary

```bash
cd /Users/arpowers/dev/bot

# 1. Move config to workspace
mv .openclaw workspace/.openclaw
ln -s workspace/.openclaw .openclaw

# 2. Update .env
echo 'OPENCLAW_STATE_DIR="./workspace/.openclaw"' >> .env

# 3. Test locally
openclaw gateway run

# 4. If works, update cloud:
#    - Edit entrypoint.sh (OPENCLAW_STATE_DIR)
#    - Edit Dockerfile (remove COPY .openclaw)
#    - git push (auto-deploy)

# 5. Verify cloud reads from workspace
fly ssh console -a ap-assist-agent
ls -la /app/workspace/.openclaw/
cat /app/workspace/.openclaw/openclaw.json
```

---

## Is This Worth It?

### Do This If:
- ✅ You frequently modify config/skills
- ✅ You want instant changes (no redeploy)
- ✅ You want one config for both bots
- ✅ You trust Google Drive reliability

### Skip This If:
- ❌ Current setup works fine
- ❌ You rarely change config
- ❌ You prefer git-based version control
- ❌ You want more safety (separate configs)

**For productivity monitoring, you don't need this.** The current hybrid works great:
- Config/skills in git (stable)
- Memory/TASKS in workspace (synced)

---

## Testing the Migration

### Before:
```bash
# Local uses: ./.openclaw/openclaw.json
# Cloud uses: /app/.openclaw/openclaw.json
# (Two separate files)
```

### After:
```bash
# Local uses: ./workspace/.openclaw/openclaw.json
# Cloud uses: /app/workspace/.openclaw/openclaw.json
# (Same file, synced via Google Drive!)

# Test it:
echo "test" >> workspace/.openclaw/test.txt
# Wait 5 seconds for Drive sync
fly ssh console -a ap-assist-agent -C "cat /app/workspace/.openclaw/test.txt"
# Should see "test"
```

---

## Recommendation

**For your use case, current setup is fine:**
- Core config in git (stable, versioned)
- Workspace synced (TASKS.md, memory, dynamic skills)
- Productivity monitoring works perfectly

**Only migrate to full sync if:**
- You're tired of redeploys
- You want to experiment with config a lot
- You want truly unified setup

Current hybrid is simpler and safer for most people.
