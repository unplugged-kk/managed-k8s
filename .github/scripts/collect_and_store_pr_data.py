import os
import json
import requests

def send_to_slack(pr_title, pr_author, pr_merged_at, pr_url, pr_commit_hash, pr_description, webhook_url):
    message = {
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*PR Title:* {pr_title}\n*Author:* {pr_author}\n*Merged at:* {pr_merged_at}\n*URL:* {pr_url}\n*Commit Hash:* {pr_commit_hash}\n*Description:* {pr_description}"
                },
            },
        ]
    }

    response = requests.post(webhook_url, json=message)
    response.raise_for_status()

# Get the PR data from the environment variables
pr_title = os.environ['GITHUB_PR_TITLE']
pr_url = os.environ['GITHUB_PR_LINK']
pr_merged_at = os.environ['GITHUB_PR_MERGED_AT']
pr_author = os.environ['GITHUB_ACTOR']
pr_commit_hash = os.environ['GITHUB_PR_COMMIT_HASH']
pr_description = os.environ['GITHUB_PR_DESCRIPTION']

# Send PR data to Slack
slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']
send_to_slack(pr_title, pr_author, pr_merged_at, pr_url, pr_commit_hash, pr_description, slack_webhook_url)