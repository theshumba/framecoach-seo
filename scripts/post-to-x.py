#!/usr/bin/env python3
"""
Auto-post to X (Twitter) for FrameCoach.
Posts 5 tweets per day from the pre-generated tweet bank.

SETUP:
1. Create a free X developer account: https://developer.twitter.com
2. Create a project/app and get your API keys
3. Set environment variables:
   export X_API_KEY="your-api-key"
   export X_API_SECRET="your-api-secret"
   export X_ACCESS_TOKEN="your-access-token"
   export X_ACCESS_SECRET="your-access-token-secret"
4. Install tweepy: pip3 install tweepy
5. Run: python3 post-to-x.py
   Or set up cron: python3 post-to-x.py --cron

CRON SETUP (5 posts/day at different times):
0 8 * * * cd /path/to/scripts && python3 post-to-x.py --single >> /tmp/framecoach-x.log 2>&1
0 11 * * * cd /path/to/scripts && python3 post-to-x.py --single >> /tmp/framecoach-x.log 2>&1
0 14 * * * cd /path/to/scripts && python3 post-to-x.py --single >> /tmp/framecoach-x.log 2>&1
0 17 * * * cd /path/to/scripts && python3 post-to-x.py --single >> /tmp/framecoach-x.log 2>&1
0 20 * * * cd /path/to/scripts && python3 post-to-x.py --single >> /tmp/framecoach-x.log 2>&1
"""

import json
import os
import sys
import random
from datetime import datetime
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
TWEETS_FILE = SCRIPT_DIR / "x-tweets-bank.json"
POSTED_LOG = SCRIPT_DIR / ".x-posted-log"

def load_tweets():
    with open(TWEETS_FILE) as f:
        return json.load(f)

def load_posted():
    if POSTED_LOG.exists():
        return set(POSTED_LOG.read_text().strip().split("\n"))
    return set()

def save_posted(index):
    with open(POSTED_LOG, "a") as f:
        f.write(f"{index}\n")

def get_next_tweet():
    tweets = load_tweets()
    posted = load_posted()

    # Find unposted tweets
    available = [(i, t) for i, t in enumerate(tweets) if str(i) not in posted]

    if not available:
        # All tweets posted — reset and start over with random order
        POSTED_LOG.unlink(missing_ok=True)
        available = list(enumerate(tweets))

    # Pick a random unposted tweet (not sequential to feel more natural)
    index, tweet = random.choice(available)
    return index, tweet["text"]

def post_tweet(text):
    """Post a tweet using tweepy (X API v2)."""
    try:
        import tweepy
    except ImportError:
        print("ERROR: tweepy not installed. Run: pip3 install tweepy")
        sys.exit(1)

    api_key = os.environ.get("X_API_KEY")
    api_secret = os.environ.get("X_API_SECRET")
    access_token = os.environ.get("X_ACCESS_TOKEN")
    access_secret = os.environ.get("X_ACCESS_SECRET")

    if not all([api_key, api_secret, access_token, access_secret]):
        print("ERROR: Missing X API credentials.")
        print("Set these environment variables:")
        print("  X_API_KEY, X_API_SECRET, X_ACCESS_TOKEN, X_ACCESS_SECRET")
        print("")
        print("Get them from: https://developer.twitter.com/en/portal/dashboard")
        sys.exit(1)

    client = tweepy.Client(
        consumer_key=api_key,
        consumer_secret=api_secret,
        access_token=access_token,
        access_token_secret=access_secret
    )

    response = client.create_tweet(text=text)
    return response

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "--single"

    if mode == "--preview":
        # Preview next tweet without posting
        index, text = get_next_tweet()
        print(f"Next tweet (#{index}):\n")
        print(text)
        print(f"\nCharacters: {len(text)}")
        return

    if mode == "--preview-all":
        # Preview all unposted tweets
        tweets = load_tweets()
        posted = load_posted()
        for i, t in enumerate(tweets):
            status = "POSTED" if str(i) in posted else "PENDING"
            print(f"[{status}] #{i}: {t['text'][:80]}...")
        return

    if mode == "--single":
        # Post one tweet
        index, text = get_next_tweet()
        print(f"[{datetime.now()}] Posting tweet #{index}...")
        try:
            response = post_tweet(text)
            save_posted(str(index))
            print(f"Posted successfully! Tweet ID: {response.data['id']}")
        except Exception as e:
            print(f"Error posting: {e}")
            sys.exit(1)

    elif mode == "--batch":
        # Post 5 tweets (for manual batch posting)
        for i in range(5):
            index, text = get_next_tweet()
            print(f"[{datetime.now()}] Posting tweet #{index}...")
            try:
                response = post_tweet(text)
                save_posted(str(index))
                print(f"Posted! Tweet ID: {response.data['id']}")
            except Exception as e:
                print(f"Error posting: {e}")
                break

            if i < 4:
                import time
                wait = random.randint(300, 900)  # 5-15 min between posts
                print(f"Waiting {wait//60} minutes before next post...")
                time.sleep(wait)

    elif mode == "--setup-cron":
        # Set up cron jobs for 5 posts per day
        script_path = os.path.abspath(__file__)
        cron_lines = [
            f"0 8 * * * cd {SCRIPT_DIR} && python3 {script_path} --single >> /tmp/framecoach-x.log 2>&1",
            f"0 11 * * * cd {SCRIPT_DIR} && python3 {script_path} --single >> /tmp/framecoach-x.log 2>&1",
            f"0 14 * * * cd {SCRIPT_DIR} && python3 {script_path} --single >> /tmp/framecoach-x.log 2>&1",
            f"0 17 * * * cd {SCRIPT_DIR} && python3 {script_path} --single >> /tmp/framecoach-x.log 2>&1",
            f"0 20 * * * cd {SCRIPT_DIR} && python3 {script_path} --single >> /tmp/framecoach-x.log 2>&1",
        ]

        import subprocess
        existing = subprocess.run(["crontab", "-l"], capture_output=True, text=True).stdout
        # Remove old framecoach-x entries
        cleaned = "\n".join(l for l in existing.strip().split("\n") if "framecoach-x" not in l and l.strip())
        new_cron = cleaned + "\n" + "\n".join(cron_lines) + "\n"

        proc = subprocess.run(["crontab", "-"], input=new_cron, capture_output=True, text=True)
        if proc.returncode == 0:
            print("Cron jobs installed! 5 tweets per day at 8am, 11am, 2pm, 5pm, 8pm.")
            print("Check logs at: /tmp/framecoach-x.log")
        else:
            print(f"Error: {proc.stderr}")

    else:
        print("Usage: python3 post-to-x.py [--single|--batch|--preview|--preview-all|--setup-cron]")

if __name__ == "__main__":
    main()
