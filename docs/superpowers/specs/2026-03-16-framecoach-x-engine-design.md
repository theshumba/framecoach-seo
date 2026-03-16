# FrameCoach X Engine — Design Spec

## Overview

GitHub Actions-powered auto-posting system for @framecoachapp on X (Twitter). Runs 5x daily, mixing evergreen filmmaking tips with AI-generated trending content tied to current film industry news. Built on Node.js + Google Gemini 2.5 Flash.

**Project repo:** `framecoach-x-engine/` (new GitHub repo)
**Target account:** @framecoachapp
**Posting schedule:** 5x daily (8am, 11am, 2pm, 5pm, 8pm UTC)
**Monthly cost:** ~$1.50 (X API) + free tiers (Gemini, GitHub Actions)

## Problem

FrameCoach has 50 pre-written evergreen tweets and a Python posting script that requires a laptop to be open. The content is static and doesn't engage with current film industry trends, limiting organic reach and engagement.

## Solution

A cloud-based tweet engine that:
1. Posts 5 tweets/day automatically via GitHub Actions (no laptop needed)
2. Mixes evergreen content (50 pre-written tweets) with AI-generated trending tweets
3. Trending tweets reference current film news but always tie back to filmmaking craft + FrameCoach
4. Runs autonomously with graceful fallbacks

## Architecture

```
GitHub Actions (cron: 5x daily)
    |
    v
[Decision: evergreen or trending?] (~65% evergreen, ~35% trending)
    |                          |
    v                          v
[Evergreen Bank]          [Trending Pipeline]
    |                          |
    v                          v
[Pick random              [RSS Ingest -> Gemini
 unposted tweet]           -> Generate tweet
                            -> Validate]
    |                          |
    v                          v
[Post to X via API v2 (OAuth 1.0a)]
    |
    v
[Log posted tweet -> git commit -> push]
```

## Daily Mix Strategy

- 3-4 evergreen tweets from the bank (proven content, always relevant)
- 1-2 trending tweets generated fresh from current film news
- Per-run decision: random weighted ~65% evergreen / ~35% trending
- Ensures feed stays relevant without becoming a news aggregator

## RSS Feeds

Film/filmmaking industry sources:

| Feed | Focus |
|------|-------|
| IndieWire | Film news, festival coverage, industry |
| No Film School | Filmmaking techniques, gear, industry |
| American Cinematographer | Cinematography deep dives |
| PetaPixel | Camera/lens news relevant to filmmakers |
| Filmmaker Magazine | Indie film industry |
| Google News: "filmmaking" | Catch-all trending topics |

- Articles filtered to last 48 hours for freshness
- Keyword filtering: filmmaking, cinematography, camera, lens, lighting, director, cinematographer, indie film, short film, production, post-production
- Exclude: celebrity gossip, box office, streaming wars, TV recaps

## Gemini Tweet Generation Pipeline

### Step 1: Topic Selection

Input: Array of fresh RSS articles
Output: Selected article + angle for filmmakers

- Gemini picks the most relevant story for filmmakers/videographers
- Must relate to filmmaking craft, gear, technique, or industry
- Filters out entertainment gossip, box office reports, celebrity news
- Returns: topic, angle, reasoning, relevant article index

### Step 2: Tweet Generation

Input: Selected topic + angle + source article
Output: Tweet text (max 280 chars)

- References the trending topic
- Ties it back to a filmmaking lesson, technique, or insight
- Includes subtle FrameCoach CTA when natural (not forced into every tweet)
- Uses 1-2 relevant hashtags
- Tone: educational + slightly opinionated (matches existing bank style)

### Step 3: Validation

Quality gates before posting:

1. **Length:** Under 280 characters
2. **AI filler check:** No banned phrases ("In today's rapidly evolving...", "Let's dive in...", "Game-changer", etc.)
3. **Hashtag check:** At least 1 hashtag present
4. **Duplicate check:** Dice coefficient similarity < 0.6 against last 20 posted tweets
5. **On failure:** Falls back to evergreen bank (never skips a post)

## Brand Voice (Gemini System Prompt)

```
You are the social voice of FrameCoach, a filmmaker coaching app.

AUDIENCE: Independent filmmakers, videographers, film students, content creators.

TONE: Practical, direct, slightly opinionated. Like a working cinematographer
sharing tips at a bar, not a corporate brand account.

DO:
- Tie trending news back to filmmaking CRAFT (technique, settings, composition)
- Reference specific technical details (focal lengths, frame rates, lighting setups)
- Be encouraging about gear-independent filmmaking
- Link to https://framecoach.io when natural (not every tweet)

DO NOT:
- Report movie box office numbers or celebrity gossip
- Sound like a news aggregator
- Use AI filler phrases
- Force a FrameCoach plug into every tweet
- Use more than 2 hashtags per tweet
- Use emojis excessively (1-2 max per tweet)
```

## State Management

### posted-log.json

Tracks all posted content to prevent duplicates and manage cycling:

```json
{
  "evergreen": {
    "posted_indices": [4, 12, 31, 7],
    "cycle": 1
  },
  "trending": {
    "recent_hashes": ["abc123", "def456"],
    "recent_texts": ["Last 20 trending tweets stored here..."]
  },
  "last_posted": "2026-03-16T14:00:00Z"
}
```

### trending-cache.json

Caches recent RSS articles to avoid re-fetching within same day:

```json
{
  "fetched_at": "2026-03-16T08:00:00Z",
  "articles": [...]
}
```

Both files committed to git after each successful post.

## File Structure

```
framecoach-x-engine/
├── .github/
│   └── workflows/
│       └── post-tweet.yml        # 5x daily cron + manual trigger
├── src/
│   ├── index.js                  # Pipeline orchestrator
│   ├── decide.js                 # Evergreen vs trending decision
│   ├── evergreen.js              # Pick from tweet bank + cycle management
│   ├── ingest.js                 # RSS feed ingestion + filtering
│   ├── generate.js               # Gemini tweet generation (topic + write + validate)
│   ├── validate.js               # Tweet quality gates
│   ├── duplicate.js              # Dice coefficient duplicate detection
│   ├── post.js                   # X API v2 posting via oauth-1.0a
│   └── logger.js                 # pino logging
├── config/
│   ├── feeds.json                # RSS feed URLs + keywords
│   └── brand-voice.md            # Gemini system prompt
├── state/
│   ├── posted-log.json           # Posted history + cycle tracking
│   └── trending-cache.json       # RSS article cache
├── tweets/
│   └── evergreen-bank.json       # 50 pre-written tweets
├── package.json
└── README.md
```

## GitHub Actions Workflow

```yaml
name: Post Tweet
on:
  schedule:
    - cron: '0 8 * * *'
    - cron: '0 11 * * *'
    - cron: '0 14 * * *'
    - cron: '0 17 * * *'
    - cron: '0 20 * * *'
  workflow_dispatch: {}

permissions:
  contents: write

jobs:
  post:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm ci
      - name: Configure git
        run: |
          git config user.name "framecoach-bot"
          git config user.email "bot@framecoach.io"
      - name: Post tweet
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
          X_API_KEY: ${{ secrets.X_API_KEY }}
          X_API_SECRET: ${{ secrets.X_API_SECRET }}
          X_ACCESS_TOKEN: ${{ secrets.X_ACCESS_TOKEN }}
          X_ACCESS_SECRET: ${{ secrets.X_ACCESS_SECRET }}
        run: node src/index.js
      - name: Push state updates
        run: |
          git add state/
          git diff --staged --quiet || git commit -m "state: update posted log"
          git pull --rebase origin main
          git push
```

## Secrets (GitHub Repository Settings)

| Secret | Purpose |
|--------|---------|
| `GEMINI_API_KEY` | Google Gemini 2.5 Flash API |
| `X_API_KEY` | X Consumer Key (OAuth 1.0a) |
| `X_API_SECRET` | X Consumer Secret |
| `X_ACCESS_TOKEN` | X Access Token for @framecoachapp |
| `X_ACCESS_SECRET` | X Access Token Secret |

## Dependencies

```json
{
  "dependencies": {
    "@google/generative-ai": "^0.24.0",
    "oauth-1.0a": "^2.2.6",
    "rss-parser": "^3.13.0",
    "pino": "^9.0.0",
    "crypto": "built-in"
  }
}
```

Note: Using `oauth-1.0a` + native `fetch` instead of `tweepy` (Python) since the project is Node.js.

## Failure Handling

| Scenario | Handling |
|----------|----------|
| All RSS feeds fail | Falls back to evergreen tweet |
| Gemini API fails/timeout | Falls back to evergreen tweet |
| Generated tweet fails validation | Falls back to evergreen tweet |
| X API post fails | Logs error, exits with code 1 (GitHub shows failed run) |
| All evergreen tweets posted | Resets cycle counter, starts over in random order |
| Duplicate tweet detected | Regenerates (max 2 attempts), then falls back to evergreen |
| Git push conflict | `git pull --rebase` resolves (state files are append-only) |
| GitHub Actions disabled (60d inactivity) | Not possible — runs 5x daily |

## Cost Analysis

| Service | Usage | Cost |
|---------|-------|------|
| X API (Pay Per Use) | ~150 tweets/month | ~$1.50/month |
| Google Gemini 2.5 Flash | ~50-60 calls/month | Free tier (15 RPM) |
| GitHub Actions | ~5 min/day = ~150 min/month | Free tier (2,000 min/month) |
| **Total** | | **~$1.50/month** |

## Migration from Existing System

1. Copy `x-tweets-bank.json` → `tweets/evergreen-bank.json`
2. No `.x-posted-log` exists yet (fresh start)
3. Old `post-to-x.py` remains in `framecoach-seo/` but is superseded
4. Same X API credentials used (already generated)

## Success Criteria

- Posts 5 tweets/day reliably without manual intervention
- Trending tweets are relevant to filmmakers (not entertainment gossip)
- Feed feels like a real filmmaker's account, not a bot
- Falls back gracefully — never misses a scheduled post
- Runs entirely in the cloud (no laptop dependency)
