#!/bin/bash
# Cross-post blog articles to Dev.to via their API
# Usage: ./cross-post-devto.sh <markdown-file>
# Requires: DEVTO_API_KEY environment variable
#
# HOW TO GET YOUR DEV.TO API KEY:
# 1. Go to https://dev.to/settings/extensions
# 2. Generate a new API key
# 3. export DEVTO_API_KEY="your-key-here"

set -e

if [ -z "$DEVTO_API_KEY" ]; then
  echo "Error: Set DEVTO_API_KEY environment variable"
  echo "Get your key from https://dev.to/settings/extensions"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 <markdown-file>"
  exit 1
fi

FILE="$1"

# Extract front matter
TITLE=$(grep '^title:' "$FILE" | sed 's/title: *"*//;s/"*$//')
DESCRIPTION=$(grep '^description:' "$FILE" | sed 's/description: *"*//;s/"*$//')
TAGS=$(grep '^tags:' "$FILE" | sed 's/tags: *\[//;s/\]//;s/"//g;s/ //g' | tr ',' '\n' | head -4 | tr '\n' ',' | sed 's/,$//')

# Extract content (everything after second ---)
CONTENT=$(sed -n '/^---$/,/^---$/!p' "$FILE" | tail -n +1)

# Canonical URL
SLUG=$(basename "$FILE" .md | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')
CANONICAL="https://theshumba.github.io/framecoach-blog/${SLUG}/"

echo "Publishing '$TITLE' to Dev.to..."

# Create article
curl -s -X POST "https://dev.to/api/articles" \
  -H "api-key: $DEVTO_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"article\": {
      \"title\": \"${TITLE}\",
      \"body_markdown\": $(python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))" <<< "$CONTENT"),
      \"published\": true,
      \"canonical_url\": \"${CANONICAL}\",
      \"tags\": [$(echo "$TAGS" | awk -F',' '{for(i=1;i<=NF;i++) printf "\"%s\"%s", $i, (i<NF?",":"")}')] ,
      \"description\": \"${DESCRIPTION}\"
    }
  }"

echo ""
echo "Done! Published with canonical URL: $CANONICAL"
