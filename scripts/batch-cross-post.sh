#!/bin/bash
# Batch cross-post all blog posts to Medium and Dev.to
# Usage: ./batch-cross-post.sh [medium|devto|both]
#
# This script posts one article per day to avoid being flagged as spam.
# Run it daily or use cron: 0 10 * * * /path/to/batch-cross-post.sh both
#
# Set these environment variables first:
# export MEDIUM_TOKEN="your-token"
# export DEVTO_API_KEY="your-key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POSTS_DIR="/Users/theshumba/Documents/GitHub/framecoach-blog/_posts"
POSTED_LOG="$SCRIPT_DIR/.posted-log"

PLATFORM="${1:-both}"

# Create log file if it doesn't exist
touch "$POSTED_LOG"

# Find the next unposted article
NEXT_POST=""
for post in "$POSTS_DIR"/*.md; do
  [ -f "$post" ] || continue
  BASENAME=$(basename "$post")
  if ! grep -q "$BASENAME:$PLATFORM" "$POSTED_LOG" 2>/dev/null; then
    NEXT_POST="$post"
    break
  fi
done

if [ -z "$NEXT_POST" ]; then
  echo "All posts have been cross-posted to $PLATFORM!"
  exit 0
fi

echo "Cross-posting: $(basename "$NEXT_POST")"

if [ "$PLATFORM" = "medium" ] || [ "$PLATFORM" = "both" ]; then
  if [ -n "$MEDIUM_TOKEN" ]; then
    bash "$SCRIPT_DIR/cross-post-medium.sh" "$NEXT_POST"
    echo "$(basename "$NEXT_POST"):medium" >> "$POSTED_LOG"
  else
    echo "Skipping Medium (MEDIUM_TOKEN not set)"
  fi
fi

if [ "$PLATFORM" = "devto" ] || [ "$PLATFORM" = "both" ]; then
  if [ -n "$DEVTO_API_KEY" ]; then
    bash "$SCRIPT_DIR/cross-post-devto.sh" "$NEXT_POST"
    echo "$(basename "$NEXT_POST"):devto" >> "$POSTED_LOG"
  else
    echo "Skipping Dev.to (DEVTO_API_KEY not set)"
  fi
fi

echo ""
echo "Next run will post the following article in the queue."
echo "Run daily to drip-publish one post per day across platforms."
