---
name: google-workspace
description: Google Calendar and Sheets via Service Account
version: 1.0.0
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

## Setup Required

### 1. Create Service Account (One-time)

1. Go to [GCP Console](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Create or select a project
3. Enable APIs: Calendar API, Sheets API
4. Create service account (e.g., `ari-bot`)
5. Create JSON key → Download

### 2. Share Resources

Share with the service account email (e.g., `ari-bot@project.iam.gserviceaccount.com`):

- **Calendar:** Settings → Share → Add email → "Make changes to events"
- **Sheets:** Share button → Add email → "Editor"

### 3. Set Secret

```bash
# Base64 encode the JSON key and set as secret
fly secrets set GOOGLE_SERVICE_ACCOUNT="$(cat google-service-account.json | base64)"
```

## Authentication

Service account credentials are in `GOOGLE_SERVICE_ACCOUNT` (base64-encoded JSON).

```bash
# Decode credentials
echo "$GOOGLE_SERVICE_ACCOUNT" | base64 -d > /tmp/sa.json

# Use with gcloud or API calls
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/sa.json
```

## Calendar API

### Get Access Token

```bash
# Using the service account
TOKEN=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$(create_jwt)")
```

For simplicity, use a library that handles JWT signing (googleapis npm, google-auth-library, etc.)

### List Events (Today)

```bash
curl -s "https://www.googleapis.com/calendar/v3/calendars/primary/events" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -G \
  --data-urlencode "timeMin=$(date -u +%Y-%m-%dT00:00:00Z)" \
  --data-urlencode "timeMax=$(date -u +%Y-%m-%dT23:59:59Z)" \
  --data-urlencode "singleEvents=true" \
  --data-urlencode "orderBy=startTime"
```

### Create Event

```bash
curl -s "https://www.googleapis.com/calendar/v3/calendars/primary/events" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "summary": "Meeting Title",
    "start": {"dateTime": "2024-01-15T10:00:00-08:00"},
    "end": {"dateTime": "2024-01-15T11:00:00-08:00"}
  }'
```

## Sheets API

### Read Sheet

```bash
curl -s "https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values/${RANGE}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}"
```

### Write to Sheet

```bash
curl -s "https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values/${RANGE}:append" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{
    "values": [["Column1", "Column2", "Column3"]]
  }' \
  -G --data-urlencode "valueInputOption=USER_ENTERED"
```

## Common Calendar IDs

| Calendar | ID |
|----------|-----|
| Primary | `primary` or email address |
| Shared | The calendar's email/ID from settings |

## Notes

- Service account auth never expires (unlike OAuth tokens)
- Calendar/sheets must be explicitly shared with service account
- The service account has its OWN calendar - use shared calendars
- For email, use Himalaya + app password (separate skill)

## Migration from OAuth

Old OAuth secrets to remove after service account is working:
- `GOOGLE_ACCESS_TOKEN`
- `GOOGLE_REFRESH_TOKEN`
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_OAUTH_CLIENT_ID`
- `GOOGLE_OAUTH_CLIENT_SECRET`
- `GOOGLE_CALENDAR_CLIENT_ID`
- `GOOGLE_CALENDAR_CLIENT_SECRET`
