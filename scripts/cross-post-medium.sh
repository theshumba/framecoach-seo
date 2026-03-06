#!/bin/bash
# Cross-post blog articles to Medium via their API
# Usage: ./cross-post-medium.sh <markdown-file>
# Requires: MEDIUM_TOKEN environment variable (get from medium.com/me/settings)
#
# HOW TO GET YOUR MEDIUM TOKEN:
# 1. Go to https://medium.com/me/settings
# 2. Scroll to "Integration tokens"
# 3. Generate a new token
# 4. export MEDIUM_TOKEN="your-token-here"

set -e

if [ -z "$MEDIUM_TOKEN" ]; then
  echo "Error: Set MEDIUM_TOKEN environment variable"
  echo "Get your token from https://medium.com/me/settings → Integration tokens"
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
TAGS=$(grep '^tags:' "$FILE" | sed 's/tags: *\[//;s/\]//;s/"//g')

# Extract content (everything after second ---)
CONTENT=$(sed -n '/^---$/,/^---$/!p' "$FILE" | tail -n +1)

# Add canonical URL to prevent duplicate content penalty
SLUG=$(basename "$FILE" .md | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')
CANONICAL="https://theshumba.github.io/framecoach-blog/${SLUG}/"

# Get Medium user ID
USER_ID=$(curl -s -H "Authorization: Bearer $MEDIUM_TOKEN" \
  https://api.medium.com/v1/me | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")

echo "Publishing '$TITLE' to Medium..."

# Format tags as JSON array (max 5 for Medium)
TAG_ARRAY=$(echo "$TAGS" | tr ',' '\n' | head -5 | awk '{printf "\"%s\",", $0}' | sed 's/,$//')

# Post to Medium
curl -s -X POST "https://api.medium.com/v1/users/${USER_ID}/posts" \
  -H "Authorization: Bearer $MEDIUM_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"${TITLE}\",
    \"contentFormat\": \"markdown\",
    \"content\": $(python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))" <<< "$CONTENT"),
    \"canonicalUrl\": \"${CANONICAL}\",
    \"tags\": [${TAG_ARRAY}],
    \"publishStatus\": \"public\"
  }"

echo ""
echo "Done! Published with canonical URL: $CANONICAL"
