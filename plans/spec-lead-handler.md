# Lead Handler

Process inbound leads. Qualify, enrich, draft response, confirm before sending.

---

## Problem

Leads come from multiple sources (forms, RB2B, Discord). Need consistent qualification and personalized response without manual effort.

## Solution

Skill that handles the full lead workflow with human-in-loop confirmation.

---

## Workflow

```
Webhook trigger → Qualify → Enrich → Draft response → Telegram confirm → Send/Skip
```

### 1. Qualify

Determine if lead belongs in CRM based on:
- Signal quality (explicit request vs passive visit)
- Company fit (size, industry, tech stack)
- Role fit (decision maker vs researcher)

**Output:** Hot / Warm / Cold / Skip

### 2. Enrich

Look up person/company using available tools:
- Apollo (email → company data)
- LinkedIn scrapers (profile details)
- Perplexity (company research)

### 3. Add to CRM

If qualified, add with:
- Source (form, rb2b, discord, etc.)
- Quality score
- Enriched context
- Original message/trigger

### 4. Draft Response

Write personalized email based on:
- Who they are (enriched data)
- What they want (source, message)
- Best offering (PageLines vs Fiction)

**CTA matching:**
| Fit | CTA |
|-----|-----|
| High intent | 3 specific meeting times |
| Exploratory | Qualifying question |
| Low fit | Soft touch, share resource |

### 5. Confirm via Telegram

```
📥 [Name] from [Company]
[1-line enriched context]
[Quality: Hot/Warm/Cold]

Draft:
---
[email draft]
---

y to send / n to skip / or reply with edits
```

**Wait for explicit confirmation before any action.**

---

## Skill File

`skills/lead-handler/SKILL.md`:

```markdown
---
name: lead-handler
description: Process inbound leads with qualification and personalized response
user-invocable: false
---

# Lead Handler

Process inbound leads. Decide if CRM-worthy, enrich, draft response, confirm before sending.

## Context

**PageLines** - Revenue automation workflows, GTM bots
**Fiction** - Voice agents, digital self

## Workflow

1. Qualify - Does this lead belong in CRM?
2. Enrich - Look up person/company
3. Add to CRM - If qualified
4. Draft Response - Personalized, specific
5. Confirm via Telegram - Wait for y/n/edits

## Rules

- Never send without explicit confirmation
- Adapt to available data
- If unsure about fit, ask
```

---

## Webhook Payload

```json
{
  "message": "New lead: John Smith from Acme Corp, requested demo via website",
  "name": "Lead",
  "deliver": true,
  "channel": "telegram",
  "metadata": {
    "source": "website_form",
    "email": "john@acme.com",
    "company": "Acme Corp"
  }
}
```

---

## Success Criteria

- [ ] Webhook triggers skill correctly
- [ ] Enrichment runs for qualified leads
- [ ] Draft appears in Telegram with confirm prompt
- [ ] Only sends on explicit "y" response
