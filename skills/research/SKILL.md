---
name: research
description: Web search and research via Perplexity API
version: 1.1.0
triggers:
  - research
  - search
  - perplexity
  - look up
  - find out
---

# Research Skill

Use Perplexity API directly for web search and research. Avoids expensive MCP auto-selection.

## ⚠️ COST WARNING

| Model | Cost/Query | Monthly ($10 budget) |
|-------|------------|---------------------|
| sonar | $0.006 | ~1,666 queries |
| sonar-pro | $0.02 | ~500 queries |
| sonar-deep-research | $0.40-1.30 | **8-25 queries!** |

**$10 only buys 8-25 deep research queries.** Use `sonar` by default.

## Model Selection (CRITICAL)

**Default: `sonar`** - Use for 95% of all queries

### Decision Tree

```
User query → Is it a simple lookup/search?
              ├─ YES → sonar (always)
              └─ NO → Did user explicitly request deep research?
                       ├─ NO → sonar (still!)
                       └─ YES → Check exact wording:
                                ├─ "deep research" → sonar-deep-research
                                ├─ "comprehensive analysis" → sonar-deep-research
                                ├─ "thoroughly investigate" → sonar-deep-research
                                └─ Other → sonar-pro at most
```

### Model Reference

| Model | Cost | When to Use |
|-------|------|-------------|
| `sonar` | $0.006 | **DEFAULT** - web search, facts, news, lookups |
| `sonar-pro` | $0.02 | Complex multi-part queries (rare) |
| `sonar-reasoning-pro` | $$$$ | NEVER use unless explicitly requested |
| `sonar-deep-research` | $$$$ | ONLY if user says "deep research" verbatim |

### Examples: Which Model?

| User Says | Model | Why |
|-----------|-------|-----|
| "What's the news on AI agents?" | sonar | Simple search |
| "Look up Anthropic's latest funding" | sonar | Factual lookup |
| "Research competitor pricing" | sonar | Normal research |
| "Find out about their CEO" | sonar | Quick lookup |
| "Do deep research on market trends" | sonar-deep-research | Explicit request |
| "Comprehensive analysis of the industry" | sonar-deep-research | Explicit request |

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

## Examples

**Standard search (use this pattern):**
```bash
curl -s "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"model": "sonar", "messages": [{"role": "user", "content": "What is the latest news about AI agents?"}]}'
```

**With system prompt for concise answers:**
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

**Deep research (ONLY when explicitly requested):**
```bash
curl -s "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-deep-research",
    "messages": [{"role": "user", "content": "Comprehensive market analysis of AI agent startups"}]
  }'
```

## Response Parsing

- Content: `.choices[0].message.content`
- Citations: `.citations[]`

## Notes

- **Always default to `sonar`** - it handles 95%+ of queries well
- Only upgrade models when explicitly requested
- The word "research" alone does NOT mean deep-research
- Perplexity MCP defaults to expensive models - avoid it, use direct API
