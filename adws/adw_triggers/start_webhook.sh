#!/bin/bash
# ADW Webhook Startup Script
# This script starts the webhook server using Pro subscription (no API charges)

echo "🚀 Starting ADW Webhook Server..."
echo "📋 Using:"
echo "   - GitHub: keyring authentication (gh auth login)"
echo "   - Claude Code: Pro subscription (no API charges)"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Unset any API keys to force use of keyring/Pro subscription
env -u GITHUB_PAT -u ANTHROPIC_API_KEY uv run "$SCRIPT_DIR/trigger_webhook.py"
