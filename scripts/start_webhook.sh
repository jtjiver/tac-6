#!/bin/bash

# Start Webhook Script - ADW System
#
# This script starts the webhook trigger with a clean environment to ensure
# Claude Code uses the authenticated session instead of API keys from .env
#
# Usage: ./scripts/start_webhook.sh
#
# This is the recommended way to start the webhook when you have Claude Code Pro subscription

# Unset API keys to force use of authenticated Claude Code session
# Belt and braces approach - ensure these are not in the environment
unset ANTHROPIC_API_KEY
unset GITHUB_PAT

# Load other environment variables from .env
if [ -f .env ]; then
    # Export only the non-sensitive variables we need
    export GITHUB_WEBHOOK_SECRET=$(grep GITHUB_WEBHOOK_SECRET .env | cut -d '=' -f2)
    export CLOUDFLARED_TUNNEL_TOKEN=$(grep CLOUDFLARED_TUNNEL_TOKEN .env | cut -d '=' -f2)
    export CLOUDFLARE_ACCOUNT_ID=$(grep CLOUDFLARE_ACCOUNT_ID .env | cut -d '=' -f2)
    export CLOUDFLARE_R2_ACCESS_KEY_ID=$(grep CLOUDFLARE_R2_ACCESS_KEY_ID .env | cut -d '=' -f2)
    export CLOUDFLARE_R2_SECRET_ACCESS_KEY=$(grep CLOUDFLARE_R2_SECRET_ACCESS_KEY .env | cut -d '=' -f2)
    export CLOUDFLARE_R2_BUCKET_NAME=$(grep CLOUDFLARE_R2_BUCKET_NAME .env | cut -d '=' -f2)
    export CLOUDFLARE_R2_PUBLIC_DOMAIN=$(grep CLOUDFLARE_R2_PUBLIC_DOMAIN .env | cut -d '=' -f2)
    export CLAUDE_CODE_PATH=$(grep CLAUDE_CODE_PATH .env | cut -d '=' -f2)
    export E2B_API_KEY=$(grep E2B_API_KEY .env | cut -d '=' -f2)
    export HELICONE_API_KEY=$(grep HELICONE_API_KEY .env | cut -d '=' -f2)
    export CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=$(grep CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR .env | cut -d '=' -f2)
    export CLAUDE_NO_AUTOUPDATE=$(grep CLAUDE_NO_AUTOUPDATE .env | cut -d '=' -f2)
    export PORT=$(grep PORT .env | cut -d '=' -f2)
fi

# Set default PORT if not set
export PORT=${PORT:-8001}

echo "🚀 Starting ADW Webhook Trigger on port ${PORT}"
echo "   Using authenticated Claude Code session (no API keys)"
echo ""
echo "   To stop: Press Ctrl+C or run: ./scripts/kill_trigger_webhook.sh"
echo ""

# Start the webhook trigger
uv run adws/adw_triggers/trigger_webhook.py
