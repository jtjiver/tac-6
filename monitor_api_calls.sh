#!/bin/bash
# Monitor for any Python ADW script execution that could use API

echo "=========================================="
echo "API Call Monitor"
echo "=========================================="
echo "Watching for Python ADW script execution..."
echo ""
echo "Safe commands (won't alert):"
echo "  - git commands"
echo "  - gh commands"
echo "  - pytest"
echo "  - ruff"
echo ""
echo "Will alert on:"
echo "  - python adws/adw_*.py"
echo "  - uv run adws/adw_*.py"
echo "  - claude -p (API mode)"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo "=========================================="
echo ""

# Monitor process table for suspicious commands
while true; do
    # Check for Python ADW scripts being run
    if ps aux | grep -E "python.*adws/adw_.*\.py|uv run.*adws/adw_.*\.py" | grep -v grep | grep -v "monitor_api" > /dev/null; then
        echo ""
        echo "🚨 ALERT: Python ADW script detected!"
        ps aux | grep -E "python.*adws/adw_.*\.py|uv run.*adws/adw_.*\.py" | grep -v grep | grep -v "monitor_api"
        echo ""
    fi

    # Check for claude -p (API mode)
    if ps aux | grep "claude -p" | grep -v grep > /dev/null; then
        echo ""
        echo "🚨 ALERT: claude -p detected (API mode)!"
        ps aux | grep "claude -p" | grep -v grep
        echo ""
    fi

    sleep 2
done
