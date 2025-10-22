#!/bin/bash

# ASW Help Banner - Display available commands and usage information

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║     🚀 ASW Development Environment - AI Developer Workflow System           ║
║                                                                              ║
║     Your automated development workflow commands and usage guide            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔧 Available ASW Commands in Claude Code CLI:
══════════════════════════════════════════════════════════════════════════════

📋 Planning & Status:
   /adw_guide_plan                    - Start new workflow (creates plan & initializes state)
   /adw_guide_status [adw_id]         - Check workflow progress & next steps

🛠️  Implementation Phases:
   /adw_guide_build {adw_id}          - Implementation phase (code changes)
   /adw_guide_test {adw_id}           - Testing phase (run tests & validation)
   /adw_guide_review {adw_id}         - Review phase (compare against spec)

🚀 Deployment:
   /adw_guide_pr {adw_id}             - Create pull request (final step)

📝 Development Commands:
   /bug                               - Create bug fix implementation
   /chore                             - Create maintenance/chore implementation  
   /feature                           - Create new feature implementation
   /review                            - Review code changes
   /test                              - Run test suite

💰 Cost Information:
   All interactive workflow phases: $0 (covered by Claude Pro)
   Saves ~$2-9 per workflow compared to automated mode ✨

🔧 Development Scripts:
   ./scripts/asw_tmux.sh              - Start tmux development environment
   ./scripts/asw_help.sh              - Show this help (you are here)
   ./scripts/start.sh                 - Start app servers (backend + frontend)

⚡ Quick Start Guide:
══════════════════════════════════════════════════════════════════════════════

1️⃣  Start Development Environment:
   ./scripts/asw_tmux.sh              - Creates 4-pane tmux session

2️⃣  Start a New Workflow:
   /adw_guide_plan                    - In Claude Code CLI (pane 0)

3️⃣  Check Your Progress:
   /adw_guide_status                  - See all workflows and next steps

4️⃣  Continue Your Workflow:
   /adw_guide_build {adw_id}          - Implement the plan
   /adw_guide_test {adw_id}           - Run tests and validation
   /adw_guide_review {adw_id}         - Review against specifications
   /adw_guide_pr {adw_id}             - Create pull request

🎯 Typical Workflow Examples:
══════════════════════════════════════════════════════════════════════════════

📝 Issue-Based Workflow:
   1. Create GitHub issue
   2. /adw_guide_plan                 - Creates plan from issue
   3. /adw_guide_build {adw_id}       - Implements solution
   4. /adw_guide_test {adw_id}        - Validates implementation
   5. /adw_guide_review {adw_id}      - Reviews against requirements
   6. /adw_guide_pr {adw_id}          - Creates pull request

🛠️  Direct Development:
   1. /feature                        - Create new feature
   2. /bug                           - Fix a bug
   3. /chore                         - Maintenance task

📊 Automated Monitoring (Optional):
   cd adws/
   uv run trigger_webhook.py         - Real-time GitHub webhook processing
   uv run trigger_cron.py            - Poll GitHub for new issues

🔍 Environment Information:
══════════════════════════════════════════════════════════════════════════════
EOF

echo -e "${CYAN}Project Root:${NC} $(pwd)"
echo -e "${CYAN}Git Branch:${NC} $(git branch --show-current 2>/dev/null || echo 'Not a git repository')"

# Check if in tmux
if [ -n "$TMUX" ]; then
    echo -e "${GREEN}✅ Currently in tmux session: $(tmux display-message -p '#S')${NC}"
else
    echo -e "${YELLOW}💡 Run './scripts/asw_tmux.sh' to start the development environment${NC}"
fi

# Check for active workflows
if [ -d "agents" ] && [ "$(find agents -name "adw_state.json" 2>/dev/null | wc -l)" -gt 0 ]; then
    echo ""
    echo -e "${PURPLE}🔍 Active Workflows Found:${NC}"
    find agents -name "adw_state.json" 2>/dev/null | while read state_file; do
        if [ -f "$state_file" ]; then
            adw_id=$(basename "$(dirname "$state_file")")
            issue_num=$(jq -r '.issue_number // "unknown"' "$state_file" 2>/dev/null)
            phase=$(jq -r '.current_phase // "unknown"' "$state_file" 2>/dev/null)
            echo -e "   ${CYAN}ADW ID:${NC} $adw_id ${CYAN}Issue:${NC} #$issue_num ${CYAN}Phase:${NC} $phase"
        fi
    done
    echo ""
    echo -e "${BLUE}💡 Use '/adw_guide_status' to see detailed progress${NC}"
fi

echo ""
echo -e "${GREEN}🚀 Ready to develop! Use the commands above to get started.${NC}"