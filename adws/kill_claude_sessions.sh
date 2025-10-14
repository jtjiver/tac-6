#!/bin/bash
# Kill Claude Code sessions spawned by orchestrator
# Usage: ./kill_claude_sessions.sh [adw_id]

ADW_ID="${1:-}"
PID_FILE="agents/${ADW_ID}/pids/claude_sessions.txt"

if [ -n "$ADW_ID" ] && [ -f "$PID_FILE" ]; then
    echo "🔍 Killing Claude sessions tracked for ADW ID: $ADW_ID"
    while IFS= read -r pid; do
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "  Killing PID $pid..."
            kill "$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null
        else
            echo "  PID $pid already terminated"
        fi
    done < "$PID_FILE"
    rm -f "$PID_FILE"
else
    # Kill all claude processes that match pattern
    echo "🔍 Finding all Claude Code sessions..."
    pids=$(ps aux | grep -E "claude /adw_guide" | grep -v grep | awk '{print $2}')

    if [ -z "$pids" ]; then
        echo "✅ No Claude Code sessions found"
        exit 0
    fi

    echo "Found PIDs: $pids"
    for pid in $pids; do
        echo "  Killing PID $pid..."
        kill "$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null
    done
fi

echo "✅ Cleanup complete"
