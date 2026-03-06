#!/bin/bash
# Set up daily cron jobs for automated cross-posting
# Run this once to install the cron schedule

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "This will add a daily cron job to cross-post one article per day."
echo "You need to set these environment variables in your shell profile first:"
echo ""
echo "  export MEDIUM_TOKEN='your-medium-integration-token'"
echo "  export DEVTO_API_KEY='your-devto-api-key'"
echo ""
echo "Get Medium token: https://medium.com/me/settings → Integration tokens"
echo "Get Dev.to key: https://dev.to/settings/extensions → Generate API key"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Add cron job - runs at 10am local time daily
  CRON_CMD="0 10 * * * cd $SCRIPT_DIR && bash batch-cross-post.sh both >> /tmp/framecoach-crosspost.log 2>&1"

  # Check if cron job already exists
  if crontab -l 2>/dev/null | grep -q "framecoach"; then
    echo "Cron job already exists. Updating..."
    crontab -l 2>/dev/null | grep -v "framecoach" | { cat; echo "$CRON_CMD"; } | crontab -
  else
    (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
  fi

  echo "Cron job installed! One article will be cross-posted daily at 10am."
  echo "Check logs at: /tmp/framecoach-crosspost.log"
else
  echo "Cancelled."
fi
