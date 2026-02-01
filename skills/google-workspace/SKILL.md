---
name: google-workspace
description: Google Calendar and Sheets via Service Account
version: 1.1.0
triggers:
  - calendar
  - schedule
  - meeting
  - sheets
  - spreadsheet
  - google
---

# Google Workspace Skill

Access Google Calendar and Sheets via Service Account authentication.

## ⚠️ IMPORTANT: Use Service Account, NOT OAuth

**DO NOT use these env vars** (they're deprecated/expired):
- `GOOGLE_ACCESS_TOKEN` ❌
- `GOOGLE_REFRESH_TOKEN` ❌
- `GOOGLE_CLIENT_ID` ❌

**USE this instead:**
- `GOOGLE_SERVICE_ACCOUNT` ✅ (base64-encoded JSON)

## Getting an Access Token

Use the helper script to get a token from the service account:

```bash
TOKEN=$(node /app/scripts/google-sa-token.js)
# or locally:
TOKEN=$(node scripts/google-sa-token.js)
```

This handles JWT signing automatically. Token is valid for 1 hour.

## Calendar API

### List Today's Events

```bash
TOKEN=$(node scripts/google-sa-token.js)

curl -s "https://www.googleapis.com/calendar/v3/calendars/arpowers@gmail.com/events" \
  -H "Authorization: Bearer $TOKEN" \
  -G \
  --data-urlencode "timeMin=$(date -u +%Y-%m-%dT00:00:00Z)" \
  --data-urlencode "timeMax=$(date -u +%Y-%m-%dT23:59:59Z)" \
  --data-urlencode "singleEvents=true" \
  --data-urlencode "orderBy=startTime"
```

**Note:** Use the actual calendar email (`arpowers@gmail.com`), not `primary`. Service accounts have their own "primary" calendar.

### Create Event

```bash
TOKEN=$(node scripts/google-sa-token.js)

curl -s "https://www.googleapis.com/calendar/v3/calendars/arpowers@gmail.com/events" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "summary": "Meeting Title",
    "start": {"dateTime": "2024-01-15T10:00:00-08:00"},
    "end": {"dateTime": "2024-01-15T11:00:00-08:00"}
  }'
```

### List Calendars (find calendar IDs)

```bash
TOKEN=$(node scripts/google-sa-token.js)
curl -s "https://www.googleapis.com/calendar/v3/users/me/calendarList" \
  -H "Authorization: Bearer $TOKEN"
```

## Sheets API

### Read Sheet

```bash
TOKEN=$(node scripts/google-sa-token.js)
curl -s "https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values/Sheet1!A1:Z100" \
  -H "Authorization: Bearer $TOKEN"
```

### Append Row

```bash
TOKEN=$(node scripts/google-sa-token.js)
curl -s "https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values/Sheet1:append?valueInputOption=USER_ENTERED" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"values": [["Col1", "Col2", "Col3"]]}'
```

## Service Account Info

| Field | Value |
|-------|-------|
| Email | `ari-375@fiction2025.iam.gserviceaccount.com` |
| Project | fiction2025 |

Calendar must be shared with this email to access it.

## Troubleshooting

### "Not Found" error
Calendar not shared with service account. Share it in Google Calendar settings.

### "GOOGLE_SERVICE_ACCOUNT env var not set"
The base64-encoded JSON isn't in the environment. Check Fly secrets.

### Token errors
Check that the service account JSON is valid and base64-encoded correctly.

## Verify Setup

```bash
# 1. Check env var exists
echo $GOOGLE_SERVICE_ACCOUNT | head -c 50

# 2. Get token (should output a long string starting with ya29.)
node scripts/google-sa-token.js

# 3. List calendars accessible to service account
TOKEN=$(node scripts/google-sa-token.js)
curl -s "https://www.googleapis.com/calendar/v3/users/me/calendarList" \
  -H "Authorization: Bearer $TOKEN" | jq '.items[].id'
```
