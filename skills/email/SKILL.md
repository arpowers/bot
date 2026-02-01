---
name: email
description: Read, search, and send email via Himalaya CLI
version: 1.0.0
triggers:
  - email
  - inbox
  - gmail
  - mail
---

# Email Skill

Manage email using Himalaya CLI with Gmail app password authentication.

## Identity

When responding to emails on Andrew's behalf, sign as:
**Ari, Executive Assistant to Andrew Powers**

## Commands

### List recent emails
```bash
himalaya list -s 20
```

### Read a specific email
```bash
himalaya read <email-id>
```

### Search emails
```bash
himalaya search "from:someone@example.com"
himalaya search "subject:meeting"
himalaya search "is:unread"
```

### Send email
```bash
himalaya send --to "recipient@example.com" --subject "Subject" <<< "Body text"
```

### Reply to email
```bash
himalaya reply <email-id> <<< "Reply text"
```

### Forward email
```bash
himalaya forward <email-id> --to "recipient@example.com"
```

### Move to folder
```bash
himalaya move <email-id> "Archive"
```

### Delete email
```bash
himalaya delete <email-id>
```

## Workflow

1. **Triage**: List unread, categorize by urgency
2. **Respond**: Draft replies for Andrew's approval or handle routine items directly
3. **Archive**: Move handled emails out of inbox

## Notes

- Account: arpowers@gmail.com
- Auth: Gmail app password via `GMAIL_APP_PASSWORD` env var
- No OAuth refresh issues - app passwords don't expire
