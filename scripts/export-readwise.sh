#!/bin/bash
# Export all Readwise highlights to individual markdown files
# Usage: ./scripts/export-readwise.sh

TOKEN="${READWISE_ACCESS_TOKEN:-l9n1XScla4ZiIiAqJ7BqUBUabgZ8I8buQ7WTnfyhSzba3SfP1j}"
OUTPUT_DIR="workspace/book-notes"
TEMP_FILE="/tmp/readwise-export.json"

mkdir -p "$OUTPUT_DIR"

echo "Fetching all highlights from Readwise..."

# Get all highlights using export endpoint
> "$TEMP_FILE"
page_cursor=""

while true; do
  if [ -z "$page_cursor" ]; then
    response=$(curl -s "https://readwise.io/api/v2/export/" \
      -H "Authorization: Token $TOKEN")
  else
    response=$(curl -s "https://readwise.io/api/v2/export/?pageCursor=$page_cursor" \
      -H "Authorization: Token $TOKEN")
  fi

  echo "$response" | jq '.results' >> "$TEMP_FILE"

  page_cursor=$(echo "$response" | jq -r '.nextPageCursor // empty')
  if [ -z "$page_cursor" ]; then
    break
  fi
  echo "  Fetched page..."
done

echo "Processing highlights..."

# Combine all pages into single array
all_books=$(cat "$TEMP_FILE" | jq -s 'add')
book_count=$(echo "$all_books" | jq 'length')

echo "Found $book_count books"

# Process each book using array indices (avoids subshell issue)
for i in $(seq 0 $((book_count - 1))); do
  book=$(echo "$all_books" | jq ".[$i]")

  title=$(echo "$book" | jq -r '.title')
  author=$(echo "$book" | jq -r '.author // "Unknown"')
  category=$(echo "$book" | jq -r '.category // "book"')
  highlights=$(echo "$book" | jq '.highlights // []')
  count=$(echo "$highlights" | jq 'length')

  # Skip books with no highlights
  if [ "$count" -eq 0 ]; then
    continue
  fi

  # Create snake_case filename
  filename=$(echo "$title" | \
    tr '[:upper:]' '[:lower:]' | \
    sed 's/[^a-z0-9 ]//g' | \
    tr ' ' '_' | \
    sed 's/__*/_/g' | \
    sed 's/^_//;s/_$//' | \
    head -c 60)

  filepath="$OUTPUT_DIR/${filename}.md"

  echo "Exporting: $title → ${filename}.md"

  {
    echo "---"
    echo "title: \"$(echo "$title" | sed 's/"/\\"/g')\""
    echo "author: \"$(echo "$author" | sed 's/"/\\"/g')\""
    echo "category: $category"
    echo "highlights: $count"
    echo "exported: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "---"
    echo ""
    echo "# $title"
    echo ""
    echo "**Author:** $author"
    echo ""
    echo "---"
    echo ""
    echo "$highlights" | jq -r '.[] | "> " + (.text // "") + "\n\n— Location " + ((.location // 0) | tostring) + (if .note and .note != "" then "\n\n*Note: " + .note + "*" else "" end) + "\n\n---\n"'
  } > "$filepath"
done

rm -f "$TEMP_FILE"

file_count=$(ls -1 "$OUTPUT_DIR"/*.md 2>/dev/null | wc -l)
echo ""
echo "Export complete! $file_count books saved to $OUTPUT_DIR"
