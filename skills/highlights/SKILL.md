---
name: highlights
description: Access Kindle highlights and book notes via Readwise API
version: 1.0.0
triggers:
  - highlights
  - kindle
  - books
  - quotes
  - readwise
  - reading
---

# Highlights Skill

Access your Kindle highlights and book notes via Readwise. Get quotes, insights, and reading history.

## Authentication

Requires `READWISE_ACCESS_TOKEN` environment variable.

Get your token at: https://readwise.io/access_token

## API Reference

**Base URL:** `https://readwise.io/api/v2`
**Auth:** `Authorization: Token ${READWISE_ACCESS_TOKEN}`

## Common Queries

### List All Books
```bash
curl -s "https://readwise.io/api/v2/books/" \
  -H "Authorization: Token ${READWISE_ACCESS_TOKEN}" | jq '.results[] | {id, title, author, num_highlights}'
```

### Get Highlights for a Book
```bash
BOOK_ID="your_book_id"
curl -s "https://readwise.io/api/v2/highlights/?book_id=${BOOK_ID}" \
  -H "Authorization: Token ${READWISE_ACCESS_TOKEN}" | jq '.results[] | {text, note, location}'
```

### Search Highlights
```bash
curl -s "https://readwise.io/api/v2/highlights/?page_size=100" \
  -H "Authorization: Token ${READWISE_ACCESS_TOKEN}" | jq '.results[] | select(.text | test("keyword"; "i")) | {text, book_id}'
```

### Get Recent Highlights
```bash
curl -s "https://readwise.io/api/v2/highlights/?page_size=20" \
  -H "Authorization: Token ${READWISE_ACCESS_TOKEN}" | jq '.results | sort_by(.highlighted_at) | reverse | .[:10]'
```

### Export All Highlights (Paginated)
```bash
# Get first page
curl -s "https://readwise.io/api/v2/export/" \
  -H "Authorization: Token ${READWISE_ACCESS_TOKEN}" | jq '.results'

# With updated_after filter (ISO date)
curl -s "https://readwise.io/api/v2/export/?updatedAfter=2025-01-01T00:00:00Z" \
  -H "Authorization: Token ${READWISE_ACCESS_TOKEN}"
```

## Use Cases

### Daily Inspiration
Get a random highlight for daily review:
```bash
curl -s "https://readwise.io/api/v2/highlights/?page_size=100" \
  -H "Authorization: Token ${READWISE_ACCESS_TOKEN}" | \
  jq -r '.results | .[range(0; length)] | "\(.text)\n— from book ID \(.book_id)"' | \
  shuf -n 1
```

### Content Ideas
Find highlights related to a topic for social media content:
```
/highlights search [topic]
```

### Book Summary
Get all highlights from a specific book:
```
/highlights book [title or author]
```

### Quote for Post
Get a quotable highlight:
```
/highlights quote about [topic]
```

## Response Structure

### Book Object
```json
{
  "id": 12345,
  "title": "Book Title",
  "author": "Author Name",
  "category": "books",
  "source": "kindle",
  "num_highlights": 42,
  "cover_image_url": "https://..."
}
```

### Highlight Object
```json
{
  "id": 67890,
  "text": "The actual highlighted text...",
  "note": "Your note on this highlight",
  "location": 1234,
  "location_type": "location",
  "highlighted_at": "2025-01-15T10:30:00Z",
  "book_id": 12345,
  "tags": [{"name": "favorite"}]
}
```

## Integration with Social Media

Combine with `/social` for content creation:

```
1. /highlights search "leadership"
2. Pick a powerful quote
3. /social post for LinkedIn using that quote as hook
```

Example workflow:
```
Find a highlight about perseverance, then create a LinkedIn post that:
- Opens with the quote
- Adds personal story
- Connects to business lesson
- Asks engagement question
```

## Sync Sources

Readwise syncs from:
- Kindle (automatic)
- Apple Books
- Pocket
- Instapaper
- Web highlights (browser extension)
- Manual imports

## Pagination

API returns 100 results per page. For full export:
```bash
# Check if more pages exist
curl -s "https://readwise.io/api/v2/highlights/" \
  -H "Authorization: Token ${READWISE_ACCESS_TOKEN}" | jq '.next'

# If next is not null, fetch that URL
```

## Rate Limits

- 20 requests per minute
- Batch operations when possible
- Cache results for repeated queries

## Tags

Readwise supports tags on highlights. Filter by tag:
```bash
curl -s "https://readwise.io/api/v2/highlights/" \
  -H "Authorization: Token ${READWISE_ACCESS_TOKEN}" | \
  jq '.results[] | select(.tags[]?.name == "favorite")'
```

## Notes

- Highlights sync automatically from Kindle (usually within hours)
- You can add notes to highlights in the Readwise app
- Tags help organize highlights by topic
- The export endpoint is best for bulk operations
