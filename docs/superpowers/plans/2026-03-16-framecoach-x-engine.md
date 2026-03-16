# FrameCoach X Engine Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a GitHub Actions-powered X auto-posting system that mixes 50 evergreen filmmaking tweets with AI-generated trending content from film industry RSS feeds.

**Architecture:** Node.js ESM pipeline running on GitHub Actions 5x daily. Each run decides evergreen vs trending (65/35 split), fetches RSS if trending, generates a tweet via Gemini 2.5 Flash, validates quality, posts to X via OAuth 1.0a, and commits state to git. Mirrors the proven sahem-content-engine architecture.

**Tech Stack:** Node.js 22, @google/genai, oauth-1.0a, rss-parser, pino, GitHub Actions

**Spec:** `docs/superpowers/specs/2026-03-16-framecoach-x-engine-design.md`

**Reference codebase:** `/Users/theshumba/Documents/GitHub/sahem-content-engine/` (same patterns)

---

## Chunk 1: Project Scaffold + Config + Evergreen Pipeline

### Task 1: Initialize project repository

**Files:**
- Create: `package.json`
- Create: `.gitignore`
- Create: `config/strategy.json`
- Create: `config/feeds.json`
- Create: `config/brand-voice.md`
- Create: `tweets/evergreen-bank.json`
- Create: `state/posted-log.json`
- Create: `state/trending-cache.json`

- [ ] **Step 1: Create GitHub repo and clone**

```bash
cd /Users/theshumba/Documents/GitHub
mkdir framecoach-x-engine && cd framecoach-x-engine
git init
```

- [ ] **Step 2: Create package.json**

```json
{
  "name": "framecoach-x-engine",
  "version": "1.0.0",
  "description": "Auto-posting engine for @framecoachapp on X — evergreen tips + trending film content",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "start:pretty": "node src/index.js | pino-pretty",
    "dry-run": "DRY_RUN=true node src/index.js"
  },
  "keywords": ["framecoach", "twitter", "x", "automation"],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "@google/genai": "^1.44.0",
    "oauth-1.0a": "^2.2.6",
    "rss-parser": "^3.13.0",
    "pino": "^9.0.0"
  },
  "devDependencies": {
    "pino-pretty": "^13.1.3"
  }
}
```

- [ ] **Step 3: Create .gitignore**

```
node_modules/
.env
*.log
```

- [ ] **Step 4: Create config/strategy.json**

```json
{
  "evergreenWeight": 0.65,
  "trendingWeight": 0.35,
  "trendingCacheTTLHours": 6,
  "maxArticleAgeHours": 48,
  "minArticlesRequired": 2,
  "evergreenCooldownCount": 10,
  "maxDuplicateRetries": 2,
  "rateLimitDelayMs": 7000,
  "postRetryAttempts": 3,
  "postRetryBaseDelayMs": 2000
}
```

- [ ] **Step 5: Create config/feeds.json**

```json
{
  "feeds": [
    {
      "id": "nofilmschool",
      "name": "No Film School",
      "url": "https://nofilmschool.com/rss.xml",
      "keywords": ["filmmaking", "cinematography", "camera", "lens", "lighting", "director"]
    },
    {
      "id": "petapixel",
      "name": "PetaPixel",
      "url": "https://petapixel.com/feed/",
      "keywords": ["camera", "lens", "filmmaking", "video", "cinema", "filmmaker"]
    },
    {
      "id": "indiewire",
      "name": "IndieWire",
      "url": "https://www.indiewire.com/feed/",
      "keywords": ["filmmaker", "cinematography", "director", "indie film", "short film", "production"]
    },
    {
      "id": "google-filmmaking",
      "name": "Google News: Filmmaking",
      "url": "https://news.google.com/rss/search?q=filmmaking+OR+cinematography+OR+%22indie+film%22&hl=en-US&gl=US&ceid=US:en",
      "keywords": []
    },
    {
      "id": "google-camera-gear",
      "name": "Google News: Camera Gear",
      "url": "https://news.google.com/rss/search?q=%22cinema+camera%22+OR+%22filmmaking+gear%22+OR+%22new+lens%22&hl=en-US&gl=US&ceid=US:en",
      "keywords": []
    }
  ],
  "globalKeywords": [
    "filmmaking", "cinematography", "camera", "lens", "lighting",
    "director", "cinematographer", "indie film", "short film",
    "production", "post-production", "videography", "filmmaker"
  ],
  "excludeKeywords": [
    "box office", "streaming wars", "celebrity", "red carpet",
    "gossip", "dating", "divorce", "fashion", "outfit"
  ]
}
```

- [ ] **Step 6: Create config/brand-voice.md**

Copy the brand voice prompt from the spec verbatim:

```markdown
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
- Generate or reference any URLs other than https://framecoach.io or https://theshumba.github.io/framecoach-blog/
```

- [ ] **Step 7: Copy and clean evergreen tweet bank**

Copy the bank, then filter out any tweets over 280 characters:

```bash
cp /Users/theshumba/Documents/GitHub/framecoach-seo/scripts/x-tweets-bank.json tweets/evergreen-bank.json
```

Run this to verify and fix:

```bash
node -e "
import { readFileSync, writeFileSync } from 'fs';
const bank = JSON.parse(readFileSync('tweets/evergreen-bank.json', 'utf-8'));
const valid = bank.filter(t => t.text.length <= 280);
const removed = bank.length - valid.length;
if (removed > 0) console.log('Removed ' + removed + ' over-length tweets');
writeFileSync('tweets/evergreen-bank.json', JSON.stringify(valid, null, 2));
console.log('Bank: ' + valid.length + ' tweets, all <= 280 chars');
"
```

- [ ] **Step 8: Create initial state files**

`state/posted-log.json`:
```json
{
  "evergreen": {
    "posted_indices": [],
    "cycle": 1
  },
  "trending": {
    "recent_texts": []
  },
  "last_posted": null
}
```

`state/trending-cache.json`:
```json
{
  "fetched_at": null,
  "articles": []
}
```

- [ ] **Step 9: Install dependencies and commit**

```bash
npm install
git add -A
git commit -m "init: project scaffold with config, tweet bank, and state files"
```

---

### Task 2: Logger module

**Files:**
- Create: `src/logger.js`

- [ ] **Step 1: Create src/logger.js**

```javascript
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  timestamp: pino.stdTimeFunctions.isoTime,
});
```

- [ ] **Step 2: Commit**

```bash
git add src/logger.js
git commit -m "feat: add pino logger"
```

---

### Task 3: Evergreen tweet picker

**Files:**
- Create: `src/evergreen.js`

This module reads the tweet bank, picks a random unposted tweet, manages cycle resets with cooldown.

- [ ] **Step 1: Create src/evergreen.js**

```javascript
import { readFileSync } from 'fs';
import { logger } from './logger.js';

const log = logger.child({ module: 'evergreen' });

/**
 * Pick a random unposted evergreen tweet from the bank.
 * Manages cycle resets with cooldown to avoid quick repeats.
 *
 * @param {object} state - The posted-log state object (mutated in place)
 * @param {object} strategy - The strategy config
 * @returns {{ text: string, index: number }}
 */
export function pickEvergreen(state, strategy) {
  const bank = JSON.parse(readFileSync('tweets/evergreen-bank.json', 'utf-8'));
  const totalTweets = bank.length;
  const posted = new Set(state.evergreen.posted_indices);

  log.info({ total: totalTweets, posted: posted.size, cycle: state.evergreen.cycle }, 'Picking evergreen tweet');

  // Find available (unposted) indices
  let available = [];
  for (let i = 0; i < totalTweets; i++) {
    if (!posted.has(i)) available.push(i);
  }

  // Cycle reset if all posted
  if (available.length === 0) {
    log.info({ cycle: state.evergreen.cycle }, 'All tweets posted — resetting cycle');
    state.evergreen.cycle += 1;

    // Cooldown: exclude last N posted to avoid quick repeats
    const cooldown = strategy.evergreenCooldownCount || 10;
    const recentlyPosted = new Set(
      state.evergreen.posted_indices.slice(-cooldown)
    );

    state.evergreen.posted_indices = [];

    available = [];
    for (let i = 0; i < totalTweets; i++) {
      if (!recentlyPosted.has(i)) available.push(i);
    }

    // Fallback if cooldown is larger than bank
    if (available.length === 0) {
      available = Array.from({ length: totalTweets }, (_, i) => i);
    }
  }

  // Random pick
  const index = available[Math.floor(Math.random() * available.length)];
  const tweet = bank[index];

  // Update state
  state.evergreen.posted_indices.push(index);

  log.info({ index, chars: tweet.text.length }, 'Evergreen tweet selected');

  return { text: tweet.text, index, type: 'evergreen' };
}
```

- [ ] **Step 2: Verify module loads**

```bash
node -e "import('./src/evergreen.js').then(() => console.log('OK'))"
```

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add src/evergreen.js
git commit -m "feat: evergreen tweet picker with cycle reset and cooldown"
```

---

### Task 4: Decision module

**Files:**
- Create: `src/decide.js`

- [ ] **Step 1: Create src/decide.js**

```javascript
import { logger } from './logger.js';

const log = logger.child({ module: 'decide' });

/**
 * Decide whether this run should post an evergreen or trending tweet.
 *
 * @param {object} strategy - config/strategy.json contents
 * @returns {'evergreen' | 'trending'}
 */
export function decideType(strategy) {
  const roll = Math.random();
  const type = roll < strategy.evergreenWeight ? 'evergreen' : 'trending';
  log.info({ roll: roll.toFixed(3), threshold: strategy.evergreenWeight, decision: type }, 'Content type decided');
  return type;
}
```

- [ ] **Step 2: Commit**

```bash
git add src/decide.js
git commit -m "feat: weighted random decision module (evergreen vs trending)"
```

---

### Task 5: X API posting module

**Files:**
- Create: `src/post.js`

Uses oauth-1.0a + native fetch for X API v2 tweet creation with exponential backoff retry.

- [ ] **Step 1: Create src/post.js**

```javascript
import OAuth from 'oauth-1.0a';
import { createHmac } from 'crypto';
import { logger } from './logger.js';

const log = logger.child({ module: 'post' });

/**
 * Post a tweet to X using OAuth 1.0a + API v2.
 *
 * @param {string} text - Tweet text (max 280 chars)
 * @param {object} retryConfig - { attempts, baseDelayMs }
 * @returns {Promise<object>} X API response data
 */
export async function postTweet(text, retryConfig = {}) {
  const { attempts = 3, baseDelayMs = 2000 } = retryConfig;

  if (process.env.DRY_RUN === 'true') {
    log.info({ text, chars: text.length }, 'DRY RUN — tweet not posted');
    return { data: { id: 'dry-run-id', text } };
  }

  const oauth = new OAuth({
    consumer: {
      key: process.env.X_API_KEY,
      secret: process.env.X_API_SECRET,
    },
    signature_method: 'HMAC-SHA1',
    hash_function: (baseString, key) =>
      createHmac('sha1', key).update(baseString).digest('base64'),
  });

  const token = {
    key: process.env.X_ACCESS_TOKEN,
    secret: process.env.X_ACCESS_SECRET,
  };

  const url = 'https://api.x.com/2/tweets';
  const body = JSON.stringify({ text });

  for (let attempt = 1; attempt <= attempts; attempt++) {
    const requestData = { url, method: 'POST' };
    const authHeader = oauth.toHeader(oauth.authorize(requestData, token));

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          ...authHeader,
          'Content-Type': 'application/json',
        },
        body,
      });

      if (response.ok) {
        const data = await response.json();
        log.info({ tweetId: data.data?.id }, 'Tweet posted successfully');
        return data;
      }

      const errorBody = await response.text();
      const status = response.status;

      // Don't retry on auth errors (4xx except 429)
      if (status >= 400 && status < 500 && status !== 429) {
        throw new Error(`X API error ${status}: ${errorBody}`);
      }

      log.warn({ status, attempt, errorBody }, 'Retryable X API error');
    } catch (err) {
      if (attempt >= attempts || (err.message && err.message.startsWith('X API error 4'))) {
        throw err;
      }
      log.warn({ error: err.message, attempt }, 'Request failed, retrying');
    }

    // Exponential backoff
    const delay = baseDelayMs * Math.pow(2, attempt - 1);
    log.info({ delayMs: delay, attempt }, 'Backing off before retry');
    await new Promise(resolve => setTimeout(resolve, delay));
  }

  throw new Error('All retry attempts exhausted — tweet not posted');
}
```

- [ ] **Step 2: Verify module loads**

```bash
node -e "import('./src/post.js').then(() => console.log('OK'))"
```

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add src/post.js
git commit -m "feat: X API posting with OAuth 1.0a and exponential backoff retry"
```

---

### Task 6: Validation module

**Files:**
- Create: `src/validate.js`

- [ ] **Step 1: Create src/validate.js**

```javascript
import { logger } from './logger.js';

const log = logger.child({ module: 'validate' });

const BANNED_PHRASES = [
  "in today's rapidly evolving",
  "let's dive in",
  "game-changer",
  "game changer",
  "unlock the power",
  "in the ever-changing landscape",
  "revolutionize",
  "it's no secret that",
  "at the end of the day",
  "leverage synergies",
  "paradigm shift",
  "move the needle",
  "deep dive",
  "circle back",
  "low-hanging fruit",
  "thought leader",
  "disruptive innovation",
  "synergistic approach",
  "cutting-edge solution",
  "best-in-class",
  "next-level",
];

/**
 * Validate a tweet before posting.
 *
 * @param {string} text - Tweet text
 * @param {string[]} recentTexts - Last 20 posted tweet texts for duplicate check
 * @returns {{ pass: boolean, failures: string[] }}
 */
export function validateTweet(text, recentTexts = []) {
  const failures = [];

  // Gate 1: Length
  if (text.length > 280) {
    failures.push(`Too long: ${text.length} chars (max 280)`);
  }

  // Gate 2: AI filler phrases
  const lower = text.toLowerCase();
  for (const phrase of BANNED_PHRASES) {
    if (lower.includes(phrase)) {
      failures.push(`Banned phrase: "${phrase}"`);
    }
  }

  // Gate 3: Hashtag check
  if (!/#\w+/.test(text)) {
    failures.push('Missing hashtag');
  }

  // Gate 4: Duplicate check (dice coefficient)
  for (const recent of recentTexts) {
    const similarity = diceCoefficient(text, recent);
    if (similarity >= 0.6) {
      failures.push(`Too similar to recent tweet (similarity: ${similarity.toFixed(3)})`);
      break;
    }
  }

  const result = { pass: failures.length === 0, failures };

  if (!result.pass) {
    log.warn({ failures }, 'Tweet failed validation');
  } else {
    log.info({ chars: text.length }, 'Tweet passed validation');
  }

  return result;
}

/**
 * Dice coefficient similarity between two strings.
 * Returns 0.0 (completely different) to 1.0 (identical).
 */
function diceCoefficient(a, b) {
  const bigramsA = bigrams(a.toLowerCase());
  const bigramsB = bigrams(b.toLowerCase());

  if (bigramsA.size === 0 && bigramsB.size === 0) return 1.0;
  if (bigramsA.size === 0 || bigramsB.size === 0) return 0.0;

  let intersection = 0;
  for (const bg of bigramsA) {
    if (bigramsB.has(bg)) intersection++;
  }

  return (2.0 * intersection) / (bigramsA.size + bigramsB.size);
}

function bigrams(str) {
  const set = new Set();
  for (let i = 0; i < str.length - 1; i++) {
    set.add(str.slice(i, i + 2));
  }
  return set;
}
```

- [ ] **Step 2: Quick smoke test**

```bash
node -e "
import { validateTweet } from './src/validate.js';
const r = validateTweet('Test tweet about filmmaking #filmmaking', []);
console.log(r);
"
```

Expected: `{ pass: true, failures: [] }`

- [ ] **Step 3: Commit**

```bash
git add src/validate.js
git commit -m "feat: tweet validation with length, filler, hashtag, and duplicate checks"
```

---

## Chunk 2: RSS Ingestion + Gemini Trending Pipeline

### Task 8: RSS ingestion module

**Files:**
- Create: `src/ingest.js`

Follows the same 5-stage pattern as sahem-content-engine's ingest.js but with 48-hour freshness and film-specific exclude keywords.

- [ ] **Step 1: Create src/ingest.js**

```javascript
import Parser from 'rss-parser';
import { createHash } from 'crypto';
import { readFileSync, writeFileSync } from 'fs';
import { logger } from './logger.js';

const log = logger.child({ module: 'ingest' });

/**
 * Ingest film industry news from RSS feeds.
 * Uses trending-cache.json with configurable TTL to avoid re-fetching.
 *
 * @param {object} strategy - config/strategy.json contents
 * @returns {Promise<Array>} Filtered, deduplicated articles
 */
export async function ingestNews(strategy) {
  // --- Check cache TTL ---
  const cachePath = 'state/trending-cache.json';
  let cache;
  try {
    cache = JSON.parse(readFileSync(cachePath, 'utf-8'));
  } catch {
    cache = { fetched_at: null, articles: [] };
  }

  const ttlMs = (strategy.trendingCacheTTLHours || 6) * 60 * 60 * 1000;
  const cacheAge = cache.fetched_at ? Date.now() - new Date(cache.fetched_at).getTime() : Infinity;

  if (cacheAge < ttlMs && cache.articles.length > 0) {
    log.info({ cached: cache.articles.length, ageHours: (cacheAge / 3600000).toFixed(1) }, 'Using cached articles');
    return cache.articles;
  }

  // --- Fresh fetch ---
  const feedConfig = JSON.parse(readFileSync('config/feeds.json', 'utf-8'));
  const { feeds, globalKeywords = [], excludeKeywords = [] } = feedConfig;

  log.info({ feedCount: feeds.length }, 'Starting RSS ingestion');

  const parser = new Parser({
    timeout: 10000,
    maxRedirects: 5,
    headers: { 'User-Agent': 'FrameCoachXEngine/1.0' },
  });

  // Stage 1: Fetch all feeds in parallel
  const results = await Promise.allSettled(
    feeds.map(feed => parser.parseURL(feed.url))
  );

  const allArticles = [];
  let succeeded = 0;
  let failed = 0;

  for (const [i, result] of results.entries()) {
    const feed = feeds[i];
    if (result.status === 'fulfilled') {
      const items = result.value.items.map(item => ({
        title: item.title || '',
        link: item.link || '',
        pubDate: item.isoDate || item.pubDate,
        contentSnippet: (item.contentSnippet || '').slice(0, 500),
        source: feed.id,
        sourceName: feed.name,
      }));
      log.info({ feed: feed.id, items: items.length }, 'Feed fetched');
      allArticles.push(...items);
      succeeded++;
    } else {
      log.warn({ feed: feed.id, error: result.reason?.message }, 'Feed failed');
      failed++;
    }
  }

  log.info({ total: allArticles.length, succeeded, failed }, 'Fetch complete');

  // Stage 2: Freshness filter (48 hours)
  const cutoffMs = (strategy.maxArticleAgeHours || 48) * 60 * 60 * 1000;
  const cutoff = new Date(Date.now() - cutoffMs);

  const fresh = allArticles.filter(article => {
    if (!article.pubDate) return false;
    const parsed = new Date(article.pubDate);
    if (isNaN(parsed.getTime())) return false;
    return parsed >= cutoff;
  });

  log.info({ before: allArticles.length, after: fresh.length }, 'Freshness filter applied');

  // Stage 3: Keyword relevance + exclude filter
  const feedMap = Object.fromEntries(feeds.map(f => [f.id, f]));

  const relevant = fresh.filter(article => {
    const text = `${article.title} ${article.contentSnippet}`.toLowerCase();

    // Exclude articles matching exclude keywords
    if (excludeKeywords.some(kw => text.includes(kw.toLowerCase()))) {
      return false;
    }

    const feedCfg = feedMap[article.source];
    const feedKeywords = feedCfg?.keywords || [];

    // Google News feeds (empty keywords) are pre-filtered
    if (feedKeywords.length === 0) return true;

    const allKeywords = [...feedKeywords, ...globalKeywords];
    return allKeywords.some(kw => text.includes(kw.toLowerCase()));
  });

  log.info({ before: fresh.length, after: relevant.length }, 'Keyword filter applied');

  // Stage 4: Deduplication
  const seen = new Set();
  const unique = relevant.filter(article => {
    const normalized = `${article.title.toLowerCase().trim()}|${article.link}`;
    const hash = createHash('sha256').update(normalized).digest('hex').slice(0, 16);
    if (seen.has(hash)) return false;
    seen.add(hash);
    return true;
  });

  log.info({ before: relevant.length, after: unique.length }, 'Deduplication applied');

  // Update cache
  const cacheData = {
    fetched_at: new Date().toISOString(),
    articles: unique,
  };
  writeFileSync(cachePath, JSON.stringify(cacheData, null, 2));

  // Stage 5: Minimum threshold
  if (unique.length < (strategy.minArticlesRequired || 2)) {
    log.warn({ found: unique.length }, 'Too few articles for trending — will fall back to evergreen');
    return [];
  }

  log.info({ total: unique.length }, 'Ingestion complete');
  return unique;
}
```

- [ ] **Step 2: Verify module loads**

```bash
node -e "import('./src/ingest.js').then(() => console.log('OK'))"
```

- [ ] **Step 3: Commit**

```bash
git add src/ingest.js
git commit -m "feat: RSS ingestion with caching, freshness, keyword, and exclude filters"
```

---

### Task 9: Gemini tweet generation module

**Files:**
- Create: `src/generate.js`

Two-step Gemini pipeline: topic selection → tweet writing. Returns validated tweet text.

- [ ] **Step 1: Create src/generate.js**

```javascript
import { GoogleGenAI } from '@google/genai';
import { readFileSync } from 'fs';
import { logger } from './logger.js';
import { validateTweet } from './validate.js';

const log = logger.child({ module: 'generate' });

const MODEL = process.env.GEMINI_MODEL || 'gemini-2.5-flash';

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

async function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Generate a trending tweet from RSS articles using Gemini.
 *
 * @param {Array} articles - Filtered RSS articles
 * @param {string[]} recentTexts - Recent tweet texts for duplicate check
 * @param {object} strategy - config/strategy.json contents
 * @returns {Promise<{ text: string, topic: string, type: 'trending' } | null>}
 */
export async function generateTrendingTweet(articles, recentTexts, strategy) {
  const brandVoice = readFileSync('config/brand-voice.md', 'utf-8');
  const rateLimitDelay = strategy.rateLimitDelayMs || 7000;
  const maxRetries = strategy.maxDuplicateRetries || 2;

  // Format articles for prompt
  const articleList = articles.slice(0, 15).map((a, i) =>
    `[${i}] "${a.title}" — ${a.sourceName} (${a.pubDate?.slice(0, 10) || 'unknown'})\n    ${a.contentSnippet.slice(0, 200)}`
  ).join('\n\n');

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    // Step 1: Topic selection + tweet generation in one call
    const prompt = `${brandVoice}

---

TASK: You are writing a tweet for @framecoachapp on X (Twitter).

Below are recent film/filmmaking news articles. Pick the ONE most relevant to independent filmmakers, videographers, or film students. Then write a single tweet that:

1. References the news topic (what happened, who's involved)
2. Ties it back to a filmmaking TECHNIQUE, SKILL, or LESSON that the audience can learn from
3. Optionally mentions FrameCoach (https://framecoach.io) if it fits naturally — DO NOT force it
4. Includes 1-2 relevant hashtags
5. Is under 280 characters
6. Sounds like a working filmmaker sharing insights, NOT a news bot

RECENT ARTICLES:
${articleList}

${attempt > 1 ? `IMPORTANT: Your previous tweet was too similar to a recent post. Write something DIFFERENT this time.` : ''}

Respond with ONLY a JSON object:
{
  "topic": "brief topic description",
  "tweet": "the actual tweet text"
}`;

    try {
      const response = await ai.models.generateContent({
        model: MODEL,
        contents: prompt,
        config: {
          responseMimeType: 'application/json',
          thinkingConfig: { thinkingBudget: 0 },
        },
      });

      let result;
      try {
        result = JSON.parse(response.text);
      } catch (err) {
        log.error({ error: err.message, raw: response.text?.slice(0, 500) }, 'Failed to parse Gemini JSON');
        return null;
      }

      const { tweet, topic } = result;

      if (!tweet || !topic) {
        log.warn('Gemini returned empty tweet or topic');
        return null;
      }

      log.info({ topic, chars: tweet.length, attempt }, 'Gemini generated tweet');

      // Validate
      const validation = validateTweet(tweet, recentTexts);

      if (validation.pass) {
        return { text: tweet, topic, type: 'trending' };
      }

      log.warn({ failures: validation.failures, attempt }, 'Generated tweet failed validation');

      if (attempt < maxRetries) {
        await delay(rateLimitDelay);
      }
    } catch (err) {
      log.error({ error: err.message, attempt }, 'Gemini API call failed');
      return null;
    }
  }

  log.warn('All trending generation attempts failed — returning null');
  return null;
}
```

- [ ] **Step 2: Verify module loads**

```bash
node -e "import('./src/generate.js').then(() => console.log('OK'))"
```

- [ ] **Step 3: Commit**

```bash
git add src/generate.js
git commit -m "feat: Gemini trending tweet generation with validation and retry"
```

---

## Chunk 3: Pipeline Orchestrator + GitHub Actions + Deploy

### Task 10: State management helpers

**Files:**
- Create: `src/state.js`

Centralized state read/write for posted-log.json.

- [ ] **Step 1: Create src/state.js**

```javascript
import { readFileSync, writeFileSync } from 'fs';

const STATE_PATH = 'state/posted-log.json';

/**
 * Load the posted-log state.
 * @returns {object}
 */
export function loadState() {
  try {
    return JSON.parse(readFileSync(STATE_PATH, 'utf-8'));
  } catch {
    return {
      evergreen: { posted_indices: [], cycle: 1 },
      trending: { recent_hashes: [], recent_texts: [] },
      last_posted: null,
    };
  }
}

/**
 * Save the posted-log state.
 * @param {object} state
 */
export function saveState(state) {
  writeFileSync(STATE_PATH, JSON.stringify(state, null, 2));
}

/**
 * Record a posted tweet in state.
 * @param {object} state - State object (mutated)
 * @param {object} tweet - { text, type, index?, topic? }
 */
export function recordPosted(state, tweet) {
  state.last_posted = new Date().toISOString();

  if (tweet.type === 'trending') {
    state.trending.recent_texts.push(tweet.text);
    // Keep only last 20
    if (state.trending.recent_texts.length > 20) {
      state.trending.recent_texts = state.trending.recent_texts.slice(-20);
    }
  }
  // Evergreen state is updated in pickEvergreen()
}
```

- [ ] **Step 2: Commit**

```bash
git add src/state.js
git commit -m "feat: state management helpers for posted-log.json"
```

---

### Task 11: Pipeline orchestrator

**Files:**
- Create: `src/index.js`

Main entry point. Reads config, decides type, gets tweet, posts, saves state.

- [ ] **Step 1: Create src/index.js**

```javascript
import { readFileSync } from 'fs';
import { logger } from './logger.js';
import { decideType } from './decide.js';
import { pickEvergreen } from './evergreen.js';
import { ingestNews } from './ingest.js';
import { generateTrendingTweet } from './generate.js';
import { postTweet } from './post.js';
import { loadState, saveState, recordPosted } from './state.js';
const log = logger.child({ stage: 'pipeline' });

async function main() {
  // Validate required env vars
  const required = ['X_API_KEY', 'X_API_SECRET', 'X_ACCESS_TOKEN', 'X_ACCESS_SECRET'];
  if (process.env.DRY_RUN !== 'true') {
    const missing = required.filter(k => !process.env[k]);
    if (missing.length > 0) {
      log.error({ missing }, 'Missing required environment variables');
      process.exit(1);
    }
  }

  log.info({ timestamp: new Date().toISOString() }, 'Pipeline started');

  const strategy = JSON.parse(readFileSync('config/strategy.json', 'utf-8'));
  const state = loadState();

  let tweet;
  const contentType = decideType(strategy);

  if (contentType === 'trending') {
    log.info('Trending path selected — ingesting RSS feeds');

    try {
      const articles = await ingestNews(strategy);

      if (articles.length > 0) {
        const recentTexts = state.trending.recent_texts || [];
        tweet = await generateTrendingTweet(articles, recentTexts, strategy);
      }
    } catch (err) {
      log.warn({ error: err.message }, 'Trending pipeline failed');
    }

    // Fallback to evergreen if trending fails
    if (!tweet) {
      log.info('Trending failed — falling back to evergreen');
      tweet = pickEvergreen(state, strategy);
    }
  } else {
    tweet = pickEvergreen(state, strategy);
  }

  log.info({ type: tweet.type, chars: tweet.text.length }, 'Tweet ready to post');

  // Post to X
  const retryConfig = {
    attempts: strategy.postRetryAttempts || 3,
    baseDelayMs: strategy.postRetryBaseDelayMs || 2000,
  };

  const response = await postTweet(tweet.text, retryConfig);

  log.info({ tweetId: response.data?.id, type: tweet.type }, 'Tweet posted');

  // Record in state
  recordPosted(state, tweet);
  saveState(state);

  log.info('State saved — pipeline complete');
}

main().catch((err) => {
  log.error({ error: err.message }, 'Pipeline failed');
  process.exit(1);
});
```

- [ ] **Step 2: Test with dry run**

```bash
DRY_RUN=true node src/index.js
```

Expected: Pipeline runs, picks an evergreen or trending tweet, logs `DRY RUN — tweet not posted`, saves state.

- [ ] **Step 3: Commit**

```bash
git add src/index.js
git commit -m "feat: pipeline orchestrator with trending/evergreen mix and fallback"
```

---

### Task 12: GitHub Actions workflow

**Files:**
- Create: `.github/workflows/post-tweet.yml`

- [ ] **Step 1: Create .github/workflows/post-tweet.yml**

```yaml
name: Post Tweet

on:
  schedule:
    - cron: '0 8 * * *'
    - cron: '0 11 * * *'
    - cron: '0 14 * * *'
    - cron: '0 17 * * *'
    - cron: '0 20 * * *'
  workflow_dispatch:
    inputs:
      dry_run:
        description: 'Run without posting to X'
        type: boolean
        default: false

concurrency:
  group: post-tweet
  cancel-in-progress: false

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
          DRY_RUN: ${{ inputs.dry_run || 'false' }}
        run: node src/index.js

      - name: Push state updates
        run: |
          git add state/
          git diff --staged --quiet || git commit -m "state: update posted log"
          git pull --rebase origin main
          git push
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/post-tweet.yml
git commit -m "feat: GitHub Actions workflow — 5x daily cron with dry-run support"
```

---

### Task 13: Create GitHub repo and push

- [ ] **Step 1: Create remote repo**

```bash
gh repo create theshumba/framecoach-x-engine --public --source=. --push
```

- [ ] **Step 2: Add GitHub secrets**

```bash
gh secret set GEMINI_API_KEY
gh secret set X_API_KEY
gh secret set X_API_SECRET
gh secret set X_ACCESS_TOKEN
gh secret set X_ACCESS_SECRET
```

Enter each key when prompted. Get the X keys from your X Developer Portal app settings. For `GEMINI_API_KEY`, use the same key from sahem-content-engine (check `gh secret list` in that repo or your Google AI Studio dashboard).

- [ ] **Step 3: Trigger a dry-run test from GitHub Actions**

```bash
gh workflow run post-tweet.yml -f dry_run=true
```

Then watch:

```bash
gh run watch
```

Expected: Workflow completes successfully, logs show a tweet was selected but not posted (DRY_RUN).

- [ ] **Step 4: Trigger a real post**

```bash
gh workflow run post-tweet.yml
```

Watch for success, then check @framecoachapp on X to verify the tweet appeared.

- [ ] **Step 5: Final commit with any state changes**

```bash
git pull
git status
```

Verify state/posted-log.json was updated by the workflow.
