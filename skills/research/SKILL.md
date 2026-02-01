---
name: research
description: Web search and research via Perplexity API
version: 1.0.0
triggers:
  - research
  - search
  - perplexity
  - look up
  - find out
---

# Research Skill

Use Perplexity API directly for web search and research. Avoids expensive MCP auto-selection.

## API Call

```bash
curl -s "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar",
    "messages": [{"role": "user", "content": "YOUR QUERY"}]
  }'
```

## Models (use sonar by default)

| Model | Cost | Use Case |
|-------|------|----------|
| sonar | $0.006/query | Default - web search |
| sonar-pro | $0.01-0.02 | Complex queries |
| sonar-reasoning-pro | $$$$ | NEVER use unless asked |
| sonar-deep-research | $$$$ | NEVER use unless asked |

## Examples

**Simple search:**
```bash
curl -s "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"model": "sonar", "messages": [{"role": "user", "content": "What is the latest news about AI agents?"}]}'
```

**With system prompt:**
```bash
curl -s "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar",
    "messages": [
      {"role": "system", "content": "Be concise. Return key facts only."},
      {"role": "user", "content": "Who is the CEO of Anthropic?"}
    ]
  }'
```

## Notes

- Always use `sonar` model unless user explicitly requests deep research
- Parse response: `.choices[0].message.content`
- Citations in: `.citations[]`
