# FrameCoach SEO Audit — framecoach.io

## Critical Issues (Fix ASAP — Send to Co-founder)

### 1. No Meta Description
- **Current:** None
- **Fix:** Add `<meta name="description" content="FrameCoach is the filmmaker app that coaches you through camera settings, shot composition, and visual storytelling — so every frame looks intentional.">`

### 2. Weak Title Tag
- **Current:** "FrameCoach - The decision layer for your camera"
- **Problem:** "Decision layer" means nothing to Google or users searching for filmmaker tools
- **Fix:** "FrameCoach — Filmmaker App for Camera Settings, Shot Coaching & Visual Storytelling"

### 3. Zero Structured Data
- **Missing:** Organization schema, SoftwareApplication schema, BreadcrumbList
- **Fix:** Add JSON-LD for SoftwareApplication with name, description, applicationCategory ("MultimediaApplication"), operatingSystem, offers

### 4. No Open Graph / Twitter Card Tags
- **Missing:** og:title, og:description, og:image, og:url, twitter:card
- **Fix:** Add all OG tags so links shared on social media show a rich preview

### 5. No H1/H2/H3 Content Structure
- **Current:** One tagline, no heading hierarchy
- **Fix:** Add proper heading structure: H1 (main value prop), H2s (features, how it works, who it's for), H3s (specific benefits)

### 6. Virtually Zero Indexable Content
- **Current:** ~10 words of content. Google has nothing to rank.
- **Fix:** Add at minimum 300-500 words of keyword-rich content on the homepage
- **Recommended sections:**
  - Hero with clear value prop mentioning "filmmaker app" and "camera coaching"
  - "How It Works" (3-step process)
  - "Who It's For" (indie filmmakers, film students, content creators)
  - "Features" with descriptive copy
  - FAQ section (great for featured snippets)

### 7. No Blog / Content Section
- **Current:** No blog, no articles, no content marketing
- **Fix:** Add a blog OR use an external blog (what we're building now)

### 8. No Internal Linking
- **Current:** No links at all
- **Fix:** Add navigation, footer links, in-content links

### 9. No Sitemap or Robots.txt (likely)
- **Fix:** Add sitemap.xml and robots.txt

### 10. No Canonical URL
- **Fix:** Add `<link rel="canonical" href="https://framecoach.io/">`

---

## What Your Co-founder Needs to Do (5-minute fixes)

Copy-paste these to him:

### Title Tag
```html
<title>FrameCoach — Filmmaker App for Camera Settings & Shot Coaching</title>
```

### Meta Description
```html
<meta name="description" content="FrameCoach is the filmmaker app that coaches you through camera settings, shot composition, and visual storytelling. Built for indie filmmakers, film students, and content creators.">
```

### Open Graph Tags
```html
<meta property="og:title" content="FrameCoach — Filmmaker App for Camera Settings & Shot Coaching">
<meta property="og:description" content="The filmmaker app that coaches you through camera settings, shot composition, and visual storytelling.">
<meta property="og:type" content="website">
<meta property="og:url" content="https://framecoach.io">
<meta property="og:image" content="https://framecoach.io/og-image.jpg">
<meta name="twitter:card" content="summary_large_image">
```

### Structured Data (JSON-LD)
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "FrameCoach",
  "description": "The filmmaker app that coaches you through camera settings, shot composition, and visual storytelling.",
  "applicationCategory": "MultimediaApplication",
  "url": "https://framecoach.io",
  "author": {
    "@type": "Organization",
    "name": "FrameCoach"
  },
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  }
}
</script>
```
