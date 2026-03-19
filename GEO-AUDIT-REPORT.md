# GEO Audit Report: FrameCoach

**Audit Date:** 2026-03-19
**URL:** https://framecoach.io
**Blog:** https://theshumba.github.io/framecoach-blog/
**Business Type:** SaaS (Filmmaker Camera Coaching App)
**Pages Analyzed:** 50+ (blog) + 1 (main site SPA)

---

## Executive Summary

**Overall GEO Score: 23/100 (Critical)**

FrameCoach is effectively invisible to AI systems. The main site at framecoach.io is a JavaScript SPA that serves 796 bytes of empty HTML to AI crawlers — they see nothing but a `<title>` tag. There is no robots.txt, no sitemap.xml, no llms.txt, no meta tags, no structured data, and no server-rendered content on the primary domain. The separate blog (50+ posts on GitHub Pages) has decent technical foundations but is not indexed by Google, has broken image URLs in all schema markup, no author attribution, and lives on a completely separate domain that splits authority. FrameCoach has zero brand presence across YouTube, Reddit, Wikipedia, LinkedIn, Product Hunt, and app stores. No third-party source has ever mentioned the brand. AI models cannot recognize FrameCoach as an entity.

### Score Breakdown

| Category | Score | Weight | Weighted Score |
|---|---|---|---|
| AI Citability | 34/100 | 25% | 8.5 |
| Brand Authority | 6/100 | 20% | 1.2 |
| Content E-E-A-T | 28/100 | 20% | 5.6 |
| Technical GEO | 18/100 | 15% | 2.7 |
| Schema & Structured Data | 38/100 | 10% | 3.8 |
| Platform Optimization | 8/100 | 10% | 0.8 |
| **Overall GEO Score** | | | **22.6/100** |

---

## Critical Issues (Fix Immediately)

### 1. framecoach.io is a black hole for AI crawlers
The entire site is a React SPA on Vercel. AI crawlers (GPTBot, ClaudeBot, PerplexityBot) receive this and nothing more:
```html
<title>FrameCoach - The decision layer for your camera</title>
<div id="root"></div>
```
**Impact:** The primary domain has zero citability. No AI system can learn what FrameCoach is, what it does, or who it's for from the main site.

**Fix:** Add server-side rendering (Next.js migration), pre-rendering for bots (Vercel supports this), or at minimum a comprehensive `<noscript>` block with all key product info as plain HTML.

### 2. Neither domain is indexed by Google
`site:framecoach.io` and `site:theshumba.github.io/framecoach-blog` return zero results. Google has not indexed either domain.

**Fix:** Submit both sitemaps to Google Search Console immediately. The blog sitemap with 68 URLs is ready at `theshumba.github.io/framecoach-blog/sitemap.xml`.

### 3. Zero brand entity recognition
Searching "FrameCoach" returns Coach brand frames, Frame.io, and Google Camera Coach. No AI model can recognize FrameCoach as a distinct entity. Zero third-party mentions exist anywhere on the web.

**Fix:** Launch on Product Hunt, post on Reddit (r/filmmaking, r/videography), get listed on filmmaker app directories, create YouTube content.

### 4. No robots.txt on main domain
`framecoach.io/robots.txt` returns 404. Crawlers have no guidance and no sitemap reference.

**Fix:** Deploy `public/robots.txt` in the Vite project.

### 5. No llms.txt on either domain
The emerging standard for helping AI systems understand websites is completely absent.

**Fix:** Create llms.txt files for both domains (see Quick Wins below).

---

## High Priority Issues

### 6. Zero meta tags on main site
No `<meta name="description">`, no Open Graph tags, no Twitter Cards, no canonical URL, no structured data. The ONLY metadata is the `<title>` tag.

### 7. No author attribution anywhere
Every blog post is credited to "FrameCoach Team" with zero biographical detail. No headshots, no credentials, no social links. Google's E-E-A-T guidelines explicitly penalize anonymous content.

### 8. No About page on either domain
Google's Quality Rater Guidelines check "Who is responsible for this website?" — there is no answer anywhere.

### 9. No privacy policy, terms of service, or contact information
Basic trust signals expected by both search engines and users are completely absent.

### 10. All blog schema image URLs are 404
Every Article/BlogPosting schema references a broken image path (`/framecoach-blog/framecoach-blog/assets/images/default-og.png` — doubled path). This disqualifies all 50+ posts from image-based rich results.

### 11. Blog and main site are disconnected domains
The blog at `theshumba.github.io` builds zero authority for `framecoach.io`. No cross-linking exists. AI crawlers visiting framecoach.io have no indication the blog exists.

### 12. Duplicate Article schemas on blog posts
Each post has both a `BlogPosting` (jekyll-seo-tag) AND an `Article` (post.html layout) with conflicting author types (Person vs Organization).

---

## Medium Priority Issues

### 13. Blog posts use narrative style instead of answer-first blocks
Articles bury answers in flowing paragraphs. AI systems preferentially cite content formatted as: clear question heading → concise 1-3 sentence answer → deeper explanation.

### 14. No original data or statistics
Zero unique numbers, benchmarks, or research. AI systems disproportionately cite sources with original data ("73% of indie filmmakers...").

### 15. Many blog posts are too thin
Several articles are 400-500 words. Competing content (No Film School, StudioBinder) runs 1,500-3,000+ words.

### 16. 50 posts published in ~45 days with no named author
This pattern signals AI-generated content farm to Google's quality systems.

### 17. Missing BreadcrumbList schema on all pages
One of the easiest rich results to earn, completely absent.

### 18. Missing HowTo schema on tutorial posts
Posts like "How to Set Camera Settings for Film" could earn rich results with step-by-step display.

### 19. Self-promotional content without disclosure
"FrameCoach Review 2026" published by FrameCoach on FrameCoach's blog — no disclosure that it's self-published.

### 20. Organization logo in schema is a favicon
Google expects minimum 112x112px. Current logo reference is favicon.ico (16-32px).

---

## Low Priority Issues

### 21. 307 temporary redirect instead of 301
`framecoach.io` → `www.framecoach.io` uses 307 (temporary). Should be 301 (permanent) to consolidate SEO signals.

### 22. Non-functional SearchAction in blog schema
Blog WebSite schema includes SearchAction but Jekyll has no search functionality.

### 23. No @id cross-references in schema graph
Schema nodes don't reference each other, creating disconnected fragments instead of a unified entity graph.

### 24. Hub pages lack ItemList schema
The 3 hub pages (Camera Settings, Learn Filmmaking, Filmmaker Tools) have no structured data beyond globals.

### 25. Missing og:image and twitter:image on both sites
No social card images defined anywhere.

---

## Category Deep Dives

### AI Citability (34/100)

**What works:**
- FAQ page with FAQPage schema (14 Q&A pairs) — strongest citable asset
- Blog posts have strong quotable one-liners ("Bad audio feels amateur")
- Camera settings table in cinematic video post is highly citable
- 3 hub pages create topical hierarchy AI can parse

**What's broken:**
- Main site = zero extractable content for AI
- Blog posts bury answers in narrative instead of surfacing them
- No original data, benchmarks, or statistics
- Blog domain is disconnected from product domain

**Key fix:** Reformat blog post openings to lead with a bolded 1-2 sentence direct answer before any narrative. Expand FAQ from 14 to 50+ questions.

### Brand Authority (6/100)

**Platform presence:**
- Google Search: ABSENT (zero organic results)
- YouTube: ABSENT (no channel, no videos)
- Reddit: ABSENT (zero mentions)
- Wikipedia: ABSENT
- LinkedIn: ABSENT (no company page)
- Product Hunt: ABSENT
- GitHub: EXISTS but not surfacing in search
- Twitter/X: @framecoachapp active but isolated (doesn't surface in web search)
- App Stores: ABSENT
- Third-party mentions: ZERO

**Name collision problem:** "FrameCoach" competes with Coach ($6B luxury brand), Frame.io (Adobe), and Google Camera Coach in search results. Always use "FrameCoach app" or "FrameCoach for filmmakers" to differentiate.

### Content E-E-A-T (28/100)

| Signal | Score | Notes |
|---|---|---|
| Experience | 30/100 | Tips show on-set awareness but no portfolio, reel, or production credits |
| Expertise | 45/100 | Technical content is accurate but thin; no external citations |
| Authoritativeness | 15/100 | Anonymous "FrameCoach Team", no founder visibility, no external validation |
| Trustworthiness | 18/100 | No privacy policy, no contact info, no about page, self-review without disclosure |

### Technical GEO (18/100)

| Check | Main Site | Blog |
|---|---|---|
| Server-rendered HTML | NO (796 bytes shell) | YES (33KB per page) |
| robots.txt | 404 | Present, allows all |
| sitemap.xml | 404 | Present, 68 URLs |
| llms.txt | 404 | 404 |
| Meta description | Missing | Present |
| Open Graph tags | Missing | Present |
| Canonical URL | Missing | Present |
| HTTPS | Yes | Yes |
| JSON-LD schema | None | 4-6 types |

### Schema & Structured Data (38/100)

**Found on blog:**
- Organization, SoftwareApplication, WebSite, BlogPosting, Article, FAQPage

**Missing everywhere:**
- BreadcrumbList, HowTo, Person (real author), ItemList, VideoObject

**Critical bugs:**
- All image URLs in schema are 404 (doubled `/framecoach-blog/` path)
- Duplicate Article + BlogPosting schemas with conflicting author types
- Organization logo uses favicon instead of proper image
- No structured data whatsoever on framecoach.io

### Platform Optimization (8/100)

FrameCoach exists on exactly 2 platforms: its own website and X/Twitter. Both are effectively invisible to search and AI systems. Zero presence on the 6 major platforms AI models rely on (YouTube, Reddit, Wikipedia, LinkedIn, Product Hunt, app directories).

---

## Quick Wins (Implement This Week)

### 1. Create robots.txt for framecoach.io
Deploy as `public/robots.txt` in the Vite project:
```
User-agent: *
Allow: /

User-agent: GPTBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

Sitemap: https://www.framecoach.io/sitemap.xml
Sitemap: https://theshumba.github.io/framecoach-blog/sitemap.xml
```

### 2. Create llms.txt for framecoach.io
Deploy as `public/llms.txt`:
```
# FrameCoach
> The decision layer for your camera

FrameCoach is a free camera coaching app for indie filmmakers and content creators. It provides real-time guidance on ISO, aperture, shutter speed, white balance, and composition decisions while on set.

## Key Features
- Real-time camera settings coaching
- Shot composition guidance
- Scene-aware decision support
- Plain-language cinematography explanations

## Who It's For
Solo filmmakers, indie crews, content creators, and film students who don't have a dedicated camera department.

## Links
- Website: https://framecoach.io
- Blog: https://theshumba.github.io/framecoach-blog/
- Twitter: https://x.com/framecoachapp
```

### 3. Add meta tags + JSON-LD to main site index.html
Add to `<head>` of the Vite project's `index.html`:
```html
<meta name="description" content="FrameCoach is a free camera coaching app for filmmakers. Get real-time guidance on ISO, aperture, shutter speed, white balance, and composition on set.">
<meta name="robots" content="index, follow">
<link rel="canonical" href="https://www.framecoach.io/">

<!-- Open Graph -->
<meta property="og:title" content="FrameCoach - The decision layer for your camera">
<meta property="og:description" content="Free real-time camera coaching for filmmakers. Master ISO, aperture, shutter speed, and composition on set.">
<meta property="og:url" content="https://www.framecoach.io/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="FrameCoach">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:site" content="@framecoachapp">
<meta name="twitter:title" content="FrameCoach - The decision layer for your camera">
<meta name="twitter:description" content="Free real-time camera coaching for filmmakers.">

<!-- JSON-LD Structured Data -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Organization",
      "@id": "https://framecoach.io/#organization",
      "name": "FrameCoach",
      "url": "https://framecoach.io",
      "logo": {
        "@type": "ImageObject",
        "url": "https://framecoach.io/logo.png",
        "width": 512,
        "height": 512
      },
      "sameAs": [
        "https://x.com/framecoachapp",
        "https://theshumba.github.io/framecoach-blog/"
      ],
      "founder": {
        "@type": "Person",
        "name": "Melusi"
      },
      "description": "FrameCoach is a free camera coaching app for indie filmmakers and content creators."
    },
    {
      "@type": "SoftwareApplication",
      "@id": "https://framecoach.io/#app",
      "name": "FrameCoach",
      "description": "Real-time camera coaching app for filmmakers. Guides you through ISO, aperture, shutter speed, white balance, and composition decisions on set.",
      "url": "https://framecoach.io",
      "applicationCategory": "MultimediaApplication",
      "operatingSystem": "Web",
      "offers": {
        "@type": "Offer",
        "price": "0",
        "priceCurrency": "USD"
      },
      "author": { "@id": "https://framecoach.io/#organization" }
    },
    {
      "@type": "WebSite",
      "@id": "https://framecoach.io/#website",
      "name": "FrameCoach",
      "url": "https://framecoach.io",
      "publisher": { "@id": "https://framecoach.io/#organization" }
    }
  ]
}
</script>
```

### 4. Fix broken blog image URLs
In `_config.yml`, change the default image path to remove the doubled directory. Then create an actual `default-og.png` (1200x630px) at `/assets/images/default-og.png`.

### 5. Submit both sitemaps to Google Search Console
- `https://theshumba.github.io/framecoach-blog/sitemap.xml` (68 URLs ready)
- `https://www.framecoach.io/sitemap.xml` (create a minimal one first)

---

## 30-Day Action Plan

### Week 1: Foundation (Make FrameCoach Visible)
- [ ] Add robots.txt, llms.txt, sitemap.xml to framecoach.io
- [ ] Add meta tags + JSON-LD structured data to main site index.html
- [ ] Fix broken image URLs in blog schema (_config.yml doubled path)
- [ ] Submit both domains to Google Search Console + request indexing
- [ ] Add cross-links: main site → blog, blog → main site
- [ ] Create a `<noscript>` block on main site with full product description

### Week 2: Trust & Authority (E-E-A-T Fixes)
- [ ] Create About page on framecoach.io (founder name, photo, story, credentials)
- [ ] Add author bios to all blog posts (replace "FrameCoach Team" with Melusi)
- [ ] Add privacy policy and terms of service to both domains
- [ ] Add contact email to footer/about page
- [ ] Add disclosure to self-promotional blog posts
- [ ] Consolidate duplicate Article/BlogPosting schemas on blog

### Week 3: Citability (Content Optimization)
- [ ] Reformat top 10 blog posts with answer-first opening blocks
- [ ] Expand FAQ page from 14 to 50+ questions (add "What is FrameCoach?", comparisons, camera settings Q&A)
- [ ] Add FAQ schema to 10 highest-traffic blog posts (3-5 Q&A each)
- [ ] Add BreadcrumbList schema to all blog pages
- [ ] Add HowTo schema to tutorial posts
- [ ] Create "What is FrameCoach?" dedicated page on blog

### Week 4: Brand Signals (External Presence)
- [ ] Launch on Product Hunt
- [ ] Post genuine content on r/filmmaking, r/videography, r/cinematography
- [ ] Create LinkedIn company page
- [ ] Submit to filmmaker app directories (Pro Filmmaker Apps, etc.)
- [ ] Create 3-5 short YouTube demo videos
- [ ] Add FrameCoach to relevant GitHub awesome-lists

---

## Longer-Term Recommendations (Month 2-3)

1. **Migrate to Next.js** for server-side rendering (biggest single GEO impact for main site)
2. **Move blog to blog.framecoach.io** subdomain to consolidate domain authority
3. **Add original data/statistics** to blog posts (survey filmmakers, analyze camera settings trends)
4. **Create comparison pages** (FrameCoach vs Filmic Pro, vs Shot Designer)
5. **Build a filmmaking glossary** (100+ terms = massive AI citation magnet)
6. **Guest post on No Film School, PetaPixel, IndieWire** for authoritative backlinks
7. **Add speakable schema** to most citable content blocks
8. **Create a proper logo** (512x512px minimum) and social card image (1200x630px)

---

## Appendix: AI Crawler Access Map

| Crawler | framecoach.io | Blog (GitHub Pages) |
|---|---|---|
| GPTBot (OpenAI) | Accesses 796 bytes empty shell | Full access, 33KB HTML |
| ClaudeBot (Anthropic) | Accesses 796 bytes empty shell | Full access |
| PerplexityBot | Accesses 796 bytes empty shell | Full access |
| Googlebot | Must execute JS to render | Full access |
| Google-Extended | Same as above | Full access |
| Bingbot | Same as above | Full access |

## Appendix: Key Files to Modify

| File | Location | Action |
|---|---|---|
| `index.html` | framecoach.io Vite project | Add meta tags, JSON-LD, noscript block |
| `public/robots.txt` | framecoach.io Vite project | Create new |
| `public/llms.txt` | framecoach.io Vite project | Create new |
| `public/sitemap.xml` | framecoach.io Vite project | Create new |
| `_config.yml` | framecoach-blog | Fix doubled image path |
| `_layouts/post.html` | framecoach-blog | Add author bio, BreadcrumbList, fix duplicate schema |
| `_layouts/default.html` | framecoach-blog | Update Organization logo, add cross-links |
| `_pages/faq.md` | framecoach-blog | Expand from 14 to 50+ questions |

---

*Generated by geo-seo-claude | Audit methodology based on Georgia Tech/Princeton/IIT Delhi 2024 GEO research*
