Hey — I ran a full GEO audit on framecoach.io (Generative Engine Optimization — how visible we are to ChatGPT, Claude, Perplexity, Google AI Overviews etc).

We scored 23 out of 100. Basically invisible.

The biggest problem: the React app serves an empty HTML shell to AI crawlers. They literally see nothing about what FrameCoach is. No description, no features, no structured data. Just `<div id="root"></div>`.

I've already fixed the blog side (schema, author bios, FAQ expansion, llms.txt, privacy policy, about page — all pushed and live).

For the main site, I need you to do one thing:

1. Open Claude Code on your computer (where the framecoach.io repo is)
2. Paste the contents of this file into it: https://github.com/theshumba/framecoach-seo/blob/main/main-site-geo-fixes/COFOUNDER-CLAUDE-PROMPT.md
3. Let Claude do its thing — it'll add robots.txt, llms.txt, sitemap.xml, meta tags, structured data, and a noscript fallback to the site
4. Push and let Vercel deploy

Should take 5 minutes. The file has everything Claude needs — it's step by step.

After that, we need to submit our sitemap to Google Search Console (2 min job — just go to search.google.com/search-console, add both domains, submit the sitemap URLs). I can walk you through that if needed.
