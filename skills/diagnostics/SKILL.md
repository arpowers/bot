---
name: diagnostics
description: Run system diagnostics on all integrations
version: 1.0.0
triggers:
  - diagnostics
  - diagnose
  - system check
  - health check
  - test integrations
---

# Diagnostics Skill

Run comprehensive diagnostics on all bot integrations.

## Full Diagnostic Checklist

Test each service and report status using this format:
```
✅ Service - Working (proof)
❌ Service - Failed: [error]
⚠️ Service - Partial: [details]
```

## 1. Google Calendar (Service Account)

```bash
# Get token using service account (NOT OAuth)
TOKEN=$(node /app/scripts/google-sa-token.js 2>&1)

if [[ $TOKEN == ya29.* ]]; then
  # Test calendar access
  RESULT=$(curl -s "https://www.googleapis.com/calendar/v3/calendars/arpowers@gmail.com/events?maxResults=1" \
    -H "Authorization: Bearer $TOKEN")

  if echo "$RESULT" | grep -q "items"; then
    echo "✅ Google Calendar - Working via service account"
  else
    echo "❌ Google Calendar - Token works but calendar not accessible"
    echo "$RESULT"
  fi
else
  echo "❌ Google Calendar - Service account token failed: $TOKEN"
fi
```

**Required env:** `GOOGLE_SERVICE_ACCOUNT`

## 2. PostHog Analytics

```bash
RESULT=$(curl -s "https://us.posthog.com/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":{"kind":"HogQLQuery","query":"SELECT count() FROM events WHERE timestamp > now() - interval 1 day"}}')

if echo "$RESULT" | grep -q "results"; then
  COUNT=$(echo "$RESULT" | jq -r '.results[0][0]')
  echo "✅ PostHog - Working ($COUNT events in last 24h)"
else
  echo "❌ PostHog - Failed: $RESULT"
fi
```

**Required env:** `POSTHOG_API_KEY`, `POSTHOG_PROJECT_ID`

## 3. Perplexity Research

```bash
RESULT=$(curl -s "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"model":"sonar","messages":[{"role":"user","content":"What is 2+2?"}]}')

if echo "$RESULT" | grep -q "choices"; then
  MODEL=$(echo "$RESULT" | jq -r '.model')
  echo "✅ Perplexity - Working (model: $MODEL)"
else
  echo "❌ Perplexity - Failed: $RESULT"
fi
```

**Required env:** `PERPLEXITY_API_KEY`

## 4. Email (Himalaya)

```bash
RESULT=$(himalaya envelope list -a arpowers@gmail.com 2>&1 | head -5)

if echo "$RESULT" | grep -q "@"; then
  echo "✅ Email - Working (Himalaya connected)"
else
  echo "❌ Email - Failed: $RESULT"
fi
```

**Required env:** `GMAIL_APP_PASSWORD` (configured in himalaya)

## 5. Apify MCP

Test via MCP tool call or direct API:

```bash
RESULT=$(curl -s "https://api.apify.com/v2/acts" \
  -H "Authorization: Bearer ${APIFY_API_TOKEN}" \
  | head -c 200)

if echo "$RESULT" | grep -q "data"; then
  echo "✅ Apify - API accessible"
else
  echo "❌ Apify - Failed: $RESULT"
fi
```

**Required env:** `APIFY_API_TOKEN`

## 6. DataForSEO MCP

```bash
RESULT=$(curl -s "https://api.dataforseo.com/v3/serp/google/organic/live/advanced" \
  -u "${DATAFORSEO_USERNAME}:${DATAFORSEO_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d '[{"keyword":"test","location_code":2840,"language_code":"en"}]' 2>&1 | head -c 300)

if echo "$RESULT" | grep -q "status_code"; then
  echo "✅ DataForSEO - API accessible"
else
  echo "⚠️ DataForSEO - Check credentials"
fi
```

**Required env:** `DATAFORSEO_USERNAME`, `DATAFORSEO_PASSWORD`

## 7. GitHub

```bash
RESULT=$(gh api user 2>&1)

if echo "$RESULT" | grep -q "login"; then
  USER=$(echo "$RESULT" | jq -r '.login')
  echo "✅ GitHub - Working (user: $USER)"
else
  echo "❌ GitHub - Failed: $RESULT"
fi
```

**Required env:** `GITHUB_TOKEN`

## Environment Variable Checklist

| Variable | Purpose | Check |
|----------|---------|-------|
| `GOOGLE_SERVICE_ACCOUNT` | Calendar/Sheets | `echo $GOOGLE_SERVICE_ACCOUNT \| head -c 20` |
| `POSTHOG_API_KEY` | Analytics | `echo $POSTHOG_API_KEY \| head -c 10` |
| `POSTHOG_PROJECT_ID` | Analytics | Should be `2226` |
| `PERPLEXITY_API_KEY` | Research | `echo $PERPLEXITY_API_KEY \| head -c 10` |
| `APIFY_API_TOKEN` | Web scraping | `echo $APIFY_API_TOKEN \| head -c 10` |
| `DATAFORSEO_USERNAME` | SEO data | Set? |
| `DATAFORSEO_PASSWORD` | SEO data | Set? |
| `GITHUB_TOKEN` | GitHub API | Set? |
| `GMAIL_APP_PASSWORD` | Email | Configured in Himalaya |

## Quick Full Test

Run all diagnostics and summarize:

```bash
echo "=== Bot Diagnostics ==="
echo ""

# Google Calendar
TOKEN=$(node /app/scripts/google-sa-token.js 2>/dev/null)
if [[ $TOKEN == ya29.* ]]; then
  echo "✅ Google Calendar (service account)"
else
  echo "❌ Google Calendar"
fi

# PostHog
if curl -sf "https://us.posthog.com/api/projects/${POSTHOG_PROJECT_ID}/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" > /dev/null 2>&1; then
  echo "✅ PostHog"
else
  echo "❌ PostHog"
fi

# Perplexity
if curl -sf "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"model":"sonar","messages":[{"role":"user","content":"hi"}]}' > /dev/null 2>&1; then
  echo "✅ Perplexity"
else
  echo "❌ Perplexity"
fi

# Apify
if curl -sf "https://api.apify.com/v2/acts" \
  -H "Authorization: Bearer ${APIFY_API_TOKEN}" > /dev/null 2>&1; then
  echo "✅ Apify"
else
  echo "❌ Apify"
fi

# GitHub
if gh api user > /dev/null 2>&1; then
  echo "✅ GitHub"
else
  echo "❌ GitHub"
fi

echo ""
echo "=== Done ==="
```
