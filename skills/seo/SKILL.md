---
name: seo
description: SEO research via DataForSEO API
version: 1.0.0
triggers:
  - seo
  - keywords
  - serp
  - ranking
  - backlinks
  - domain analysis
---

# SEO Skill

Direct DataForSEO API for keyword research, SERP analysis, and domain insights.

## Authentication

```bash
AUTH=$(echo -n "${DATAFORSEO_USERNAME}:${DATAFORSEO_PASSWORD}" | base64)
```

**Base URL:** `https://api.dataforseo.com/v3`

## Common Queries

### Keyword Difficulty (Bulk)

Check difficulty for up to 1000 keywords:

```bash
AUTH=$(echo -n "${DATAFORSEO_USERNAME}:${DATAFORSEO_PASSWORD}" | base64)

curl -s "https://api.dataforseo.com/v3/dataforseo_labs/google/bulk_keyword_difficulty/live" \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -d '[{
    "keywords": ["ai agents", "automation tools"],
    "language_code": "en",
    "location_name": "United States"
  }]'
```

### Ranked Keywords for Domain

See what keywords a domain ranks for:

```bash
AUTH=$(echo -n "${DATAFORSEO_USERNAME}:${DATAFORSEO_PASSWORD}" | base64)

curl -s "https://api.dataforseo.com/v3/dataforseo_labs/google/ranked_keywords/live" \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -d '[{
    "target": "fiction.com",
    "language_code": "en",
    "location_name": "United States",
    "limit": 20
  }]'
```

### Related Keywords

Find related keywords for content ideas:

```bash
AUTH=$(echo -n "${DATAFORSEO_USERNAME}:${DATAFORSEO_PASSWORD}" | base64)

curl -s "https://api.dataforseo.com/v3/dataforseo_labs/google/related_keywords/live" \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -d '[{
    "keyword": "ai automation",
    "language_code": "en",
    "location_name": "United States",
    "limit": 20
  }]'
```

### Domain Overview

Get domain authority and backlink summary:

```bash
AUTH=$(echo -n "${DATAFORSEO_USERNAME}:${DATAFORSEO_PASSWORD}" | base64)

curl -s "https://api.dataforseo.com/v3/dataforseo_labs/google/domain_rank_overview/live" \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -d '[{
    "target": "fiction.com",
    "language_code": "en",
    "location_name": "United States"
  }]'
```

### SERP Analysis (Live)

Check current SERP for a keyword:

```bash
AUTH=$(echo -n "${DATAFORSEO_USERNAME}:${DATAFORSEO_PASSWORD}" | base64)

curl -s "https://api.dataforseo.com/v3/serp/google/organic/live/advanced" \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -d '[{
    "keyword": "ai agents for business",
    "location_name": "United States",
    "language_code": "en"
  }]'
```

### Backlinks Summary

Get backlink profile for a domain:

```bash
AUTH=$(echo -n "${DATAFORSEO_USERNAME}:${DATAFORSEO_PASSWORD}" | base64)

curl -s "https://api.dataforseo.com/v3/backlinks/summary/live" \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -d '[{
    "target": "fiction.com"
  }]'
```

## Response Format

All responses have this structure:
```json
{
  "status_code": 20000,
  "status_message": "Ok.",
  "tasks": [{
    "result": [...]
  }]
}
```

- `status_code: 20000` = success
- `status_code: 40100` = auth error
- Results in `tasks[0].result`

## Cost Notes

DataForSEO charges per request. Common costs:
- Keyword difficulty: ~$0.01 per keyword
- SERP analysis: ~$0.01-0.02 per query
- Backlinks: ~$0.01-0.05 per query

Use sparingly. Batch keywords when possible.

## Troubleshooting

### Auth Error (40100)
Check credentials at [app.dataforseo.com/api-access](https://app.dataforseo.com/api-access)

### No Results
- Check spelling of location_name (must be exact: "United States" not "US")
- Verify language_code is valid ("en", not "english")

---

*Use direct API instead of MCP for reliability.*
