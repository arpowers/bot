---
name: leads
description: Lead management via Google Sheets
version: 1.0.0
triggers:
  - leads
  - lead
  - prospect
  - pipeline
  - crm
  - sales
---

# Leads Skill

Manage leads and sales pipeline in Google Sheets. Add, update, and track prospects.

## Setup

### Prerequisites
1. Google Service Account configured (see google-workspace skill)
2. Google Sheet shared with `ari-375@fiction2025.iam.gserviceaccount.com`
3. Sheet ID stored (get from URL: `docs.google.com/spreadsheets/d/[SHEET_ID]/edit`)

### Sheet Structure

Recommended columns:
| Column | Description |
|--------|-------------|
| A: Date Added | When lead was added |
| B: Name | Contact name |
| C: Company | Company name |
| D: Email | Contact email |
| E: Source | Where lead came from |
| F: Status | New/Contacted/Qualified/Won/Lost |
| G: Notes | Additional context |
| H: Next Action | What to do next |
| I: Last Contact | Date of last touch |

## API Reference

### Get Access Token
```bash
TOKEN=$(node /app/scripts/google-sa-token.js)
```

### Read Leads
```bash
SHEET_ID="your_sheet_id"
RANGE="Leads!A:I"

curl -s "https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values/${RANGE}" \
  -H "Authorization: Bearer ${TOKEN}"
```

### Add New Lead
```bash
SHEET_ID="your_sheet_id"

curl -s "https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values/Leads!A:I:append?valueInputOption=USER_ENTERED" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "values": [[
      "2026-02-01",
      "John Smith",
      "Acme Corp",
      "john@acme.com",
      "LinkedIn",
      "New",
      "Met at conference",
      "Send intro email",
      ""
    ]]
  }'
```

### Update Lead Status
```bash
SHEET_ID="your_sheet_id"
ROW=5
RANGE="Leads!F${ROW}"

curl -s "https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values/${RANGE}?valueInputOption=USER_ENTERED" \
  -X PUT \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"values": [["Contacted"]]}'
```

### Batch Update (Multiple Cells)
```bash
SHEET_ID="your_sheet_id"

curl -s "https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values:batchUpdate" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "valueInputOption": "USER_ENTERED",
    "data": [
      {"range": "Leads!F5", "values": [["Contacted"]]},
      {"range": "Leads!I5", "values": [["2026-02-01"]]}
    ]
  }'
```

## Common Operations

### Add Lead
```
/leads add [name] from [company] - [source]
Email: [email]
Notes: [context]
```

### Update Status
```
/leads update [name or row] status [New/Contacted/Qualified/Won/Lost]
```

### List Pipeline
```
/leads list [status filter]
```

### Daily Review
```
/leads review
```
Returns leads needing follow-up today.

### Search
```
/leads search [company or name]
```

## Lead Workflow

### New Lead
1. Add to sheet with status "New"
2. Set next action and date
3. Add source for tracking

### Follow-up Sequence
1. **Day 0**: Initial outreach
2. **Day 3**: Follow-up if no response
3. **Day 7**: Second follow-up
4. **Day 14**: Final follow-up
5. Move to "Lost" if no response

### Status Definitions
| Status | Meaning |
|--------|---------|
| New | Just added, not contacted |
| Contacted | Initial outreach sent |
| Replied | They responded |
| Qualified | Confirmed fit and interest |
| Meeting | Call/meeting scheduled |
| Proposal | Sent proposal/quote |
| Won | Closed deal |
| Lost | No longer pursuing |

## Integration

### With Email
```
/leads add [name] from [company]
Then: /email draft intro to [name] about [service]
```

### With Research
```
/research [company name] before outreach
/leads update [name] notes: [research findings]
```

### With Calendar
```
/leads update [name] status Meeting
/calendar schedule call with [name] [date/time]
```

## Reporting

### Pipeline Summary
Count leads by status:
```bash
# After fetching all leads, summarize
jq 'group_by(.[5]) | map({status: .[0][5], count: length})'
```

### Source Analysis
Which sources produce best leads:
```
/leads report sources
```

### Weekly Review
```
/leads weekly
```
Shows: new leads, status changes, follow-ups due.

## Sheet ID Reference

Store your sheet IDs in workspace for easy access:
- Main leads sheet: [add your sheet ID]
- Archive sheet: [add your sheet ID]

Get sheet ID from URL: `https://docs.google.com/spreadsheets/d/[THIS_PART]/edit`

## Error Handling

### Permission Denied
Sheet not shared with service account. Share with:
`ari-375@fiction2025.iam.gserviceaccount.com`

### Invalid Range
Check sheet name matches exactly (case-sensitive).

### Rate Limits
Google Sheets API: 300 requests per minute per project.
