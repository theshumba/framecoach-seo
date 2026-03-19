# FrameCoach GEO Fix — Automated Task for Claude Code

> **INSTRUCTIONS:** Paste this entire file into Claude Code on the computer that has the framecoach.io source code. Claude will find the project, apply all changes, and push.

---

## Context

We ran a GEO (Generative Engine Optimization) audit on framecoach.io. The site scored **23/100** — critically low. The main problem: the React SPA serves 796 bytes of empty HTML to AI crawlers. GPTBot, ClaudeBot, PerplexityBot, and Googlebot see nothing but `<div id="root"></div>`.

The blog fixes are already live. This task handles the **main framecoach.io site** only.

## Your Task

Find the framecoach.io Vite/React project on this computer and do the following:

### 1. Add these files to the `public/` directory

**public/robots.txt:**
```
# FrameCoach - framecoach.io
# Allow all crawlers including AI systems

User-agent: *
Allow: /

# Explicitly allow AI crawlers
User-agent: GPTBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: Amazonbot
Allow: /

User-agent: CCBot
Allow: /

Sitemap: https://www.framecoach.io/sitemap.xml
Sitemap: https://theshumba.github.io/framecoach-blog/sitemap.xml
```

**public/llms.txt:**
```
# FrameCoach
> The decision layer for your camera

FrameCoach is a free, real-time camera coaching app for indie filmmakers and content creators. It guides users through ISO, aperture, shutter speed, white balance, and composition decisions while on set — so filmmakers can focus on telling their story instead of second-guessing settings.

## What FrameCoach Does
- Real-time camera settings coaching on set
- Shot composition and framing guidance
- Scene-aware decision support for lighting and exposure
- Plain-language explanations of cinematography concepts
- Camera settings memory across shooting scenarios

## Who It's For
Solo filmmakers, indie crews, content creators, and film students who don't have a dedicated camera department.

## Key Differentiator
Most filmmaking apps are tools (calculators, monitors, shot list managers). FrameCoach is a coach — it tells you what your settings should be for the look you want, and explains why in plain language.

## Pricing
Free. No subscription, no paywall, no hidden fees.

## Links
- Website: https://framecoach.io
- Blog: https://theshumba.github.io/framecoach-blog/
- FAQ: https://theshumba.github.io/framecoach-blog/filmmaking-faq/
- Camera Settings Guide: https://theshumba.github.io/framecoach-blog/camera-settings-guide/
- Twitter/X: https://x.com/framecoachapp

## Founded By
Melusi — building tools to make camera knowledge accessible to every filmmaker.
```

**public/sitemap.xml:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://www.framecoach.io/</loc>
    <lastmod>2026-03-19</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

### 2. Update `index.html`

Find the `index.html` in the project root (the one Vite uses). Add these inside `<head>`, before any existing `<script>` or `<link>` tags:

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
<meta property="og:image" content="https://www.framecoach.io/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:site" content="@framecoachapp">
<meta name="twitter:title" content="FrameCoach - The decision layer for your camera">
<meta name="twitter:description" content="Free real-time camera coaching for filmmakers.">
<meta name="twitter:image" content="https://www.framecoach.io/og-image.png">

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
      "author": { "@id": "https://framecoach.io/#organization" },
      "featureList": "Camera settings coaching, Shot composition guidance, Real-time decision support, Visual storytelling tools"
    },
    {
      "@type": "WebSite",
      "@id": "https://framecoach.io/#website",
      "name": "FrameCoach",
      "url": "https://framecoach.io",
      "publisher": { "@id": "https://framecoach.io/#organization" }
    },
    {
      "@type": "WebPage",
      "@id": "https://framecoach.io/#webpage",
      "name": "FrameCoach - The decision layer for your camera",
      "url": "https://framecoach.io",
      "isPartOf": { "@id": "https://framecoach.io/#website" },
      "about": { "@id": "https://framecoach.io/#app" },
      "description": "FrameCoach is a free camera coaching app for filmmakers. Real-time guidance on ISO, aperture, shutter speed, white balance, and composition."
    }
  ]
}
</script>
```

### 3. Add noscript fallback inside `<div id="root">`

Find `<div id="root"></div>` and replace it with:

```html
<div id="root">
  <noscript>
    <div style="max-width:800px;margin:0 auto;padding:40px 20px;font-family:system-ui,sans-serif;color:#fff;background:#0a0a0a;">
      <h1>FrameCoach — The Decision Layer for Your Camera</h1>
      <p><strong>FrameCoach is a free, real-time camera coaching app for indie filmmakers and content creators.</strong></p>
      <p>It guides you through ISO, aperture, shutter speed, white balance, and composition decisions while you're on set — so you can focus on telling your story instead of second-guessing settings.</p>
      <h2>Key Features</h2>
      <ul>
        <li><strong>Real-time camera settings coaching</strong> — Get guided through ISO, aperture, shutter speed, and white balance for any shooting scenario</li>
        <li><strong>Shot composition guidance</strong> — Rule of thirds, leading lines, depth, and framing suggestions as you shoot</li>
        <li><strong>Scene-aware decisions</strong> — Lighting-aware exposure recommendations that adapt to your environment</li>
        <li><strong>Plain-language explanations</strong> — No jargon. Understand why each setting matters for the look you want</li>
      </ul>
      <h2>Who It's For</h2>
      <p>Solo filmmakers, indie crews, content creators, and film students who don't have a dedicated camera department.</p>
      <h2>Free to Use</h2>
      <p>No subscription, no paywall, no hidden fees. Camera knowledge should be accessible to every filmmaker.</p>
      <h2>Learn More</h2>
      <ul>
        <li><a href="https://theshumba.github.io/framecoach-blog/">FrameCoach Blog</a></li>
        <li><a href="https://theshumba.github.io/framecoach-blog/camera-settings-guide/">Camera Settings Guide</a></li>
        <li><a href="https://theshumba.github.io/framecoach-blog/filmmaking-faq/">Filmmaking FAQ</a></li>
        <li><a href="https://x.com/framecoachapp">@framecoachapp on X</a></li>
      </ul>
    </div>
  </noscript>
</div>
```

### 4. Copy image assets to `public/`

Download these two images from the framecoach-seo repo and place them in `public/`:
- `og-image.png` — from https://github.com/theshumba/framecoach-seo/raw/main/main-site-geo-fixes/og-image.png
- `logo.png` — from https://github.com/theshumba/framecoach-seo/raw/main/main-site-geo-fixes/logo.png

You can download them with:
```bash
curl -L -o public/og-image.png "https://github.com/theshumba/framecoach-seo/raw/main/main-site-geo-fixes/og-image.png"
curl -L -o public/logo.png "https://github.com/theshumba/framecoach-seo/raw/main/main-site-geo-fixes/logo.png"
```

### 5. Fix the redirect (if using vercel.json)

If there's a `vercel.json` file, check if there's a redirect from the naked domain to www. If it uses a 307 (temporary), change it to 308 or 301 (permanent).

### 6. Commit and push

Commit all changes with the message:
```
GEO fixes: robots.txt, llms.txt, sitemap, meta tags, structured data, noscript fallback
```

Then push to trigger a Vercel deployment.

### 7. Verify after deployment

After the Vercel deploy completes, verify these URLs all return 200:
- https://www.framecoach.io/robots.txt
- https://www.framecoach.io/llms.txt
- https://www.framecoach.io/sitemap.xml

And verify the homepage now has meta tags by checking the page source.

---

**Why this matters:** Right now, every AI crawler (ChatGPT, Claude, Perplexity, Google AI) that visits framecoach.io sees literally nothing — just an empty `<div>`. These changes make the site visible to AI systems, which is critical for showing up in AI-generated search results.
