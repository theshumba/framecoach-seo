# FrameCoach SEO — Quick Start Guide

Everything is built. Here's what to do, in order.

---

## Step 1: Deploy the Blog (5 minutes)
The blog is at `/Users/theshumba/Documents/GitHub/framecoach-blog/`

```bash
cd ~/Documents/GitHub/framecoach-blog
git add -A
git commit -m "Initial blog with 50 SEO-optimized filmmaking articles"
git push origin main
```

Then enable GitHub Pages:
1. Go to https://github.com/theshumba/framecoach-blog/settings/pages
2. Source: "GitHub Actions"
3. Wait 2-3 minutes for first deploy
4. Blog is live at: **https://theshumba.github.io/framecoach-blog/**

## Step 2: Google Search Console (10 minutes)
1. Go to https://search.google.com/search-console
2. Add https://theshumba.github.io/framecoach-blog as a URL prefix property
3. Verify (download HTML file, add to repo root, push)
4. Submit sitemap: https://theshumba.github.io/framecoach-blog/sitemap.xml
5. Request indexing for the 3 hub pages and the home page

## Step 3: Send Fix List to Co-founder (5 minutes)
Open `/Users/theshumba/Documents/GitHub/framecoach-seo/site-audit/AUDIT.md`
Copy the "What Your Co-founder Needs to Do" section and send it.

## Step 4: Create Platform Accounts (30 minutes)
Open `/Users/theshumba/Documents/GitHub/framecoach-seo/PLATFORM-SUBMISSIONS.md`
Create accounts on:
- [ ] Medium (@framecoach)
- [ ] Dev.to (framecoach)
- [ ] Product Hunt
- [ ] AlternativeTo
- [ ] Twitter/X (@framecoachapp)
- [ ] Substack (framecoach.substack.com)

## Step 5: Set Up Cross-Posting Automation (10 minutes)
```bash
# Get your API tokens (links in the scripts)
export MEDIUM_TOKEN="your-token"
export DEVTO_API_KEY="your-key"

# Add to your ~/.zshrc so they persist
echo 'export MEDIUM_TOKEN="your-token"' >> ~/.zshrc
echo 'export DEVTO_API_KEY="your-key"' >> ~/.zshrc

# Test with first post
cd ~/Documents/GitHub/framecoach-seo/scripts
./cross-post-medium.sh ~/Documents/GitHub/framecoach-blog/_posts/2026-02-01-how-to-set-camera-settings-for-film.md

# Set up daily cron (posts 1 article/day automatically)
./setup-cron.sh
```

## Step 6: Follow the Content Calendar
Open `/Users/theshumba/Documents/GitHub/framecoach-seo/CONTENT-CALENDAR.md`
Follow the 10-week plan. The automation handles Medium + Dev.to.
You manually share to Reddit + Twitter (takes 5 min/day).

---

## What You Get

| Asset | Location |
|-------|----------|
| SEO Audit | `framecoach-seo/site-audit/AUDIT.md` |
| 100 Target Keywords | `framecoach-seo/keyword-research/KEYWORDS.md` |
| 50 Blog Posts | `framecoach-blog/_posts/` |
| 3 Hub Pages | Camera Settings, Learn Filmmaking, Filmmaker Tools |
| FAQ Page (Schema) | Filmmaking FAQ with Google FAQ rich results |
| GitHub Pages Blog | Auto-deploys on push |
| Scheduled Publishing | GitHub Actions moves drafts → posts daily |
| Cross-Post Scripts | Medium + Dev.to with canonical URLs |
| Cron Automation | 1 article/day auto-posted |
| Platform Guide | 20+ free platform submissions |
| Social Bios | Copy-paste bios for every platform |
| Content Calendar | 10-week publishing plan |
| Google Search Console Guide | Setup instructions |

## Expected Timeline
- **Week 1-2:** Blog indexed, first impressions in Search Console
- **Week 3-4:** Long-tail keywords start showing in search results
- **Month 2-3:** Medium/Dev.to cross-posts driving referral traffic
- **Month 3-6:** Hub pages climbing for "filmmaker app," "filmmaking tools"
- **Month 6+:** Compound effect — 50+ indexed pages all linking to framecoach.io

## Monthly Maintenance (30 min/month)
1. Check Google Search Console for new queries getting impressions
2. Write 2-3 new posts targeting those queries
3. Update old posts if they're ranking page 2 (add more content, refresh)
4. Submit to 1-2 new directories from the platform list
