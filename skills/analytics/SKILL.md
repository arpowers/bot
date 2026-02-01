---
name: analytics
description: Query website analytics via PostHog API
version: 1.0.0
triggers:
  - analytics
  - posthog
  - visitors
  - traffic
  - pageviews
  - how many
---

# Analytics Skill

Query PostHog analytics directly via API. No MCP overhead.

## Configuration

| Variable | Value |
|----------|-------|
| Region | US (`us.posthog.com`) |
| Auth | Bearer `${POSTHOG_API_KEY}` |

## Projects

| Site | Project ID | Use for |
|------|------------|---------|
| fiction.com | `2226` | Default - personal site |
| pagelines.com | `296599` | PageLines product |

**Default:** Use `2226` (fiction.com) unless user specifies PageLines/pagelines.

## API Endpoints

**Base URL:** `https://us.posthog.com`

| Endpoint | Purpose |
|----------|---------|
| `/api/projects/{id}/query/` | Run HogQL queries |
| `/api/projects/{id}/insights/` | Get saved insights |
| `/api/projects/{id}/events/` | List events |

## HogQL Queries

PostHog uses HogQL (SQL-like) for queries.

### Query Template

```bash
curl -s "https://us.posthog.com/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "YOUR HOGQL QUERY HERE"
    }
  }'
```

## Common Queries

### Daily Traffic (Today)

```bash
curl -s "https://us.posthog.com/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT count() as pageviews, count(distinct distinct_id) as unique_visitors FROM events WHERE event = '"'"'$pageview'"'"' AND timestamp > now() - interval 1 day"
    }
  }'
```

### Weekly Traffic

```bash
curl -s "https://us.posthog.com/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT count() as pageviews, count(distinct distinct_id) as unique_visitors FROM events WHERE event = '"'"'$pageview'"'"' AND timestamp > now() - interval 7 day"
    }
  }'
```

### Traffic by Day (Last 7 Days)

```bash
curl -s "https://us.posthog.com/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT toDate(timestamp) as day, count() as pageviews, count(distinct distinct_id) as visitors FROM events WHERE event = '"'"'$pageview'"'"' AND timestamp > now() - interval 7 day GROUP BY day ORDER BY day"
    }
  }'
```

### Top Pages (Last 7 Days)

```bash
curl -s "https://us.posthog.com/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT properties.$current_url as url, count() as views FROM events WHERE event = '"'"'$pageview'"'"' AND timestamp > now() - interval 7 day GROUP BY url ORDER BY views DESC LIMIT 10"
    }
  }'
```

### Traffic Sources (Referrers)

```bash
curl -s "https://us.posthog.com/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT properties.$referrer as source, count() as visits FROM events WHERE event = '"'"'$pageview'"'"' AND timestamp > now() - interval 7 day AND properties.$referrer IS NOT NULL GROUP BY source ORDER BY visits DESC LIMIT 10"
    }
  }'
```

### Custom Events

```bash
curl -s "https://us.posthog.com/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT event, count() as count FROM events WHERE timestamp > now() - interval 7 day AND event NOT LIKE '"'"'$%'"'"' GROUP BY event ORDER BY count DESC LIMIT 20"
    }
  }'
```

## Response Format

```json
{
  "results": [
    [value1, value2, ...],
    [value1, value2, ...]
  ],
  "columns": ["column1", "column2", ...],
  "types": ["UInt64", "String", ...]
}
```

## HogQL Tips

- Use `$pageview` for page view events
- Use `distinct_id` for unique users
- Properties are accessed via `properties.key`
- Standard properties: `$current_url`, `$referrer`, `$browser`, `$os`
- Time intervals: `interval 1 day`, `interval 7 day`, `interval 30 day`

## Notes

- Always use direct API, not MCP (simpler, faster)
- Default to 7-day window unless user specifies otherwise
- Parse results by matching `results` array to `columns` array
