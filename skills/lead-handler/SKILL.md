---
name: lead-handler
description: Process inbound leads with qualification, enrichment, and personalized response
user-invocable: false
---

# Lead Handler

Process inbound leads. Decide if CRM-worthy, enrich, draft response, confirm before sending.

## Context

**PageLines** - Revenue automation workflows, GTM bots. Offers consulting packages and club membership.

**Fiction** - Voice agents, digital self for bots and workflows.

## Workflow

1. **Qualify** - Does this lead belong in CRM? Use judgment based on signal quality.

2. **Enrich** - Look up the person/company. Use whatever enrichment tools are available.

3. **Add to CRM** - If qualified, add with relevant context. Note quality level.

4. **Draft Response** - Write a personalized, specific email based on:
   - Who they are (enriched data)
   - What they're interested in (source, message)
   - Best fit offering (PageLines vs Fiction)

   **CTA should match fit:**
   - High intent: Suggest 3 specific times for intro call
   - Exploratory: Ask a qualifying question
   - Low fit: Soft touch, share resource

   Keep it short. Sound human. No templates.

5. **Confirm via Telegram** - Post summary + draft:

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

Wait for response before any action.

## Notes

- Never send without explicit confirmation
- Adapt to whatever data is available
- If unsure about fit, ask me
