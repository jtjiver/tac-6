#!/bin/bash
# Extract ADW Framework from tac-6 project
# Creates a clean starter framework in a new directory

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default target directory
TARGET_DIR="${1:-adw-framework-starter}"

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   ADW Framework Extraction Tool               ║${NC}"
echo -e "${BLUE}║   AI Developer Workflow Starter Framework     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Check if target directory exists
if [ -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}⚠️  Target directory '$TARGET_DIR' already exists.${NC}"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}✗ Extraction cancelled${NC}"
        exit 1
    fi
    rm -rf "$TARGET_DIR"
fi

echo -e "${GREEN}✓ Creating target directory: $TARGET_DIR${NC}"
mkdir -p "$TARGET_DIR"

# Function to copy files with progress
copy_with_progress() {
    local source=$1
    local dest=$2
    local description=$3

    if [ -e "$source" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -r "$source" "$dest"
        echo -e "${GREEN}  ✓${NC} $description"
    else
        echo -e "${YELLOW}  ⚠${NC} Skipped: $description (not found)"
    fi
}

# Function to copy directory contents
copy_directory() {
    local source=$1
    local dest=$2
    local description=$3
    local exclude_pattern=$4

    if [ -d "$source" ]; then
        mkdir -p "$dest"
        if [ -n "$exclude_pattern" ]; then
            rsync -av --exclude="$exclude_pattern" "$source/" "$dest/" > /dev/null 2>&1
        else
            cp -r "$source"/* "$dest/" 2>/dev/null || true
        fi
        echo -e "${GREEN}  ✓${NC} $description"
    else
        echo -e "${YELLOW}  ⚠${NC} Skipped: $description (not found)"
    fi
}

echo ""
echo -e "${BLUE}📦 Extracting ADW System...${NC}"

# ADW Core Modules
copy_directory "adws/adw_modules" "$TARGET_DIR/adws/adw_modules" "ADW core modules" "__pycache__"

# ADW Workflow Scripts
for script in adw_plan.py adw_build.py adw_test.py adw_review.py adw_document.py adw_patch.py \
              adw_plan_build.py adw_plan_build_test.py adw_plan_build_test_review.py \
              adw_plan_build_review.py adw_plan_build_document.py adw_sdlc.py; do
    copy_with_progress "adws/$script" "$TARGET_DIR/adws/$script" "Workflow: $script"
done

# ADW Triggers
copy_directory "adws/adw_triggers" "$TARGET_DIR/adws/adw_triggers" "Automation triggers" "__pycache__"

# ADW README
copy_with_progress "adws/README.md" "$TARGET_DIR/adws/README.md" "ADW documentation"

# Create __init__.py files
touch "$TARGET_DIR/adws/__init__.py"
touch "$TARGET_DIR/adws/adw_modules/__init__.py"
touch "$TARGET_DIR/adws/adw_triggers/__init__.py"

echo ""
echo -e "${BLUE}⚙️  Extracting Claude Code Configuration...${NC}"

# Claude settings
copy_with_progress ".claude/settings.json" "$TARGET_DIR/.claude/settings.json" "Claude Code settings"

# Claude hooks
copy_directory ".claude/hooks" "$TARGET_DIR/.claude/hooks" "Claude Code hooks" "__pycache__"

# Claude slash commands (generic ones)
echo -e "${GREEN}  ✓${NC} Copying slash commands..."
mkdir -p "$TARGET_DIR/.claude/commands"

# Core workflow commands
for cmd in classify_issue.md classify_adw.md feature.md bug.md chore.md \
           implement.md patch.md test.md test_e2e.md resolve_failed_test.md \
           resolve_failed_e2e_test.md review.md document.md generate_branch_name.md \
           commit.md pull_request.md tools.md conditional_docs.md prepare_app.md; do
    copy_with_progress ".claude/commands/$cmd" "$TARGET_DIR/.claude/commands/$cmd" "  - $cmd"
done

# Interactive guides
for guide in adw_guide_plan.md adw_guide_build.md adw_guide_test.md \
             adw_guide_pr.md adw_guide_review.md adw_guide_status.md; do
    copy_with_progress ".claude/commands/$guide" "$TARGET_DIR/.claude/commands/$guide" "  - $guide"
done

# Create e2e directory with README
mkdir -p "$TARGET_DIR/.claude/commands/e2e"
cat > "$TARGET_DIR/.claude/commands/e2e/README.md" << 'EOF'
# E2E Test Templates

This directory contains your project-specific E2E tests.

## Creating E2E Tests

Each E2E test should follow this structure:

```markdown
# Test: [Test Name]

## User Story
As a [role], I want to [action] so that [benefit]

## Prerequisites
- Application running on http://localhost:PORT
- Test data setup (if needed)

## Test Steps

### Step 1: [Action]
1. Navigate to [URL]
2. Verify [condition]
3. Take screenshot: `01_[description].png`

### Step 2: [Action]
1. Click [element]
2. Verify [condition]
3. Take screenshot: `02_[description].png`

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] All screenshots captured

## Output Format
{
  "test_name": "test_name",
  "status": "passed|failed",
  "screenshots": ["01_description.png", "02_description.png"],
  "error": null
}
```

## Running E2E Tests

```bash
# Run specific test
claude -p "/test_e2e test_name"

# Run all E2E tests
claude -p "/test_e2e all"
```
EOF
echo -e "${GREEN}  ✓${NC} E2E test template directory created"

echo ""
echo -e "${BLUE}📚 Extracting Documentation...${NC}"

# Framework documentation
for doc in README.md ADW_AGENTS_GUIDE.md COEXISTENCE_GUIDE.md \
           COMPARISON_SUMMARY.md COMPARISON_PLANNING_PHASE.md COMPARISON_BUILD_PHASE.md; do
    copy_with_progress "docs/$doc" "$TARGET_DIR/docs/$doc" "$doc"
done

echo ""
echo -e "${BLUE}🧪 Extracting Testing Infrastructure...${NC}"

# MCP and Playwright configuration
copy_with_progress "playwright-mcp-config.json" "$TARGET_DIR/playwright-mcp-config.json" "Playwright MCP config"
copy_with_progress ".mcp.json.sample" "$TARGET_DIR/.mcp.json.sample" "MCP server config template"

# Package.json for Playwright
cat > "$TARGET_DIR/package.json" << 'EOF'
{
  "name": "adw-framework-starter",
  "version": "1.0.0",
  "description": "ADW Framework - AI Developer Workflow Starter",
  "scripts": {
    "setup": "node setup.js"
  },
  "dependencies": {
    "playwright": "^1.48.2"
  },
  "devDependencies": {}
}
EOF
echo -e "${GREEN}  ✓${NC} package.json created"

echo ""
echo -e "${BLUE}📝 Extracting Configuration Templates...${NC}"

# Environment template
copy_with_progress ".env.sample" "$TARGET_DIR/.env.sample" "Environment template"

# Gitignore
copy_with_progress ".gitignore" "$TARGET_DIR/.gitignore" "Git ignore patterns"

echo ""
echo -e "${BLUE}🔧 Extracting Utility Scripts...${NC}"

# Generic scripts
mkdir -p "$TARGET_DIR/scripts"
copy_with_progress "scripts/start.sh" "$TARGET_DIR/scripts/start.sh" "Multi-service startup script"
copy_with_progress "scripts/stop_apps.sh" "$TARGET_DIR/scripts/stop_apps.sh" "Service shutdown script"

# Make scripts executable
chmod +x "$TARGET_DIR/scripts"/*.sh 2>/dev/null || true

# Copy setup.js
copy_with_progress "setup.js" "$TARGET_DIR/setup.js" "Interactive setup wizard"
chmod +x "$TARGET_DIR/setup.js" 2>/dev/null || true

echo ""
echo -e "${BLUE}📖 Creating Framework README...${NC}"

# Create main README
cat > "$TARGET_DIR/README.md" << 'EOF'
# ADW Framework Starter

AI Developer Workflow (ADW) Framework - A production-ready system for AI-assisted software development.

## 🚀 Quick Start

Run the interactive setup to configure this framework for your project:

```bash
npm run setup
```

Or manually:

```bash
node setup.js
```

## 📦 What's Included

### 1. ADW System (Complete AI Automation)
- **Core Modules**: GitHub, Git, State, Workflow operations
- **Workflow Scripts**: Plan, Build, Test, Review, Document, Patch
- **Automation Triggers**: Webhook server + Cron monitor

### 2. Claude Code Configuration
- **Settings**: Permissions, hooks, MCP servers
- **Hooks**: Safety checks, logging, notifications
- **Slash Commands**: 25+ commands for complete SDLC
- **Interactive Guides**: Zero-cost alternative to API automation

### 3. Testing Infrastructure
- **Playwright MCP**: AI-driven browser automation
- **E2E Templates**: Standardized test format
- **Test Patterns**: Pytest fixtures and patterns

### 4. Documentation
- Agent catalog (14 AI agents)
- Cost analysis ($792-$2,976/year savings)
- Speed comparison (2-4x faster interactive mode)
- Migration guides

## 💡 Two Execution Modes

### Interactive Mode (Zero Cost)
- Uses Claude Code CLI ($0, covered by Claude Pro)
- 2-4x faster than subprocess automation
- Real-time visibility and error recovery
- Same artifacts as automated mode

```bash
# Run interactive planning guide
claude -p "/adw_guide_plan 123"
```

### Automated Mode (CI/CD)
- Webhook-driven automation ($7-25 per workflow)
- Hands-free issue processing
- Complete audit trail
- GitHub integration

```bash
# Start webhook server
cd adws
uv run adw_triggers/trigger_webhook.py
```

## 🛠️ Setup Requirements

### Prerequisites
- Python 3.10+
- `uv` package manager: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Claude Code CLI: [Installation guide](https://docs.anthropic.com/claude/docs/claude-code)
- GitHub CLI: `brew install gh` (or equivalent)
- Node.js 18+ (for Playwright)

### Environment Variables

Copy `.env.sample` to `.env` and configure:

```bash
# Required for API mode
ANTHROPIC_API_KEY=sk-ant-...

# Required for GitHub integration
GITHUB_REPO_URL=https://github.com/owner/repo

# Optional: Different GitHub account
GITHUB_PAT=ghp_...

# Optional: Screenshot upload to R2
CLOUDFLARE_R2_ACCOUNT_ID=...
CLOUDFLARE_R2_ACCESS_KEY_ID=...
CLOUDFLARE_R2_SECRET_ACCESS_KEY=...
CLOUDFLARE_R2_BUCKET_NAME=...
```

## 📚 Usage

### Interactive Workflow (Recommended for Development)

```bash
# Plan a feature
claude -p "/adw_guide_plan 123"

# Build the implementation
claude -p "/adw_guide_build {adw_id}"

# Run tests
claude -p "/adw_guide_test {adw_id}"

# Create PR
claude -p "/adw_guide_pr {adw_id}"

# Review implementation
claude -p "/adw_guide_review {adw_id}"
```

### Automated Workflow (For CI/CD)

```bash
# Complete SDLC for an issue
cd adws
uv run adw_plan_build_test_review.py 123
```

### Individual Slash Commands

```bash
# Classify an issue
claude -p "/classify_issue '{issue_json}'"

# Generate implementation plan
claude -p "/feature 123 abc12345 '{issue_json}'"

# Run E2E tests
claude -p "/test_e2e test_name"
```

## 📖 Documentation

- `docs/README.md` - Documentation index
- `docs/ADW_AGENTS_GUIDE.md` - Complete agent catalog
- `docs/COEXISTENCE_GUIDE.md` - Automated vs Interactive
- `docs/COMPARISON_SUMMARY.md` - Cost and speed analysis

## 🎯 Key Features

- ✅ Zero-cost interactive mode ($0/workflow)
- ✅ 2-4x faster than subprocess automation
- ✅ Complete SDLC automation (plan → build → test → review → document)
- ✅ GitHub webhook integration
- ✅ E2E testing with Playwright MCP
- ✅ State management for workflow chaining
- ✅ Comprehensive safety hooks
- ✅ 14 specialized AI agents

## 🔒 Security Features

- Pre-execution safety checks
- Dangerous command blocking (rm -rf, etc.)
- Environment variable protection
- Session logging for audit
- Granular permission system

## 📁 Project Structure

```
adw-framework-starter/
├── .claude/              # Claude Code configuration
│   ├── settings.json     # Permissions, hooks, MCP
│   ├── hooks/            # Safety and logging hooks
│   └── commands/         # Slash commands and guides
├── adws/                 # ADW automation system
│   ├── adw_modules/      # Core modules
│   ├── adw_triggers/     # Webhook and cron triggers
│   └── *.py              # Workflow scripts
├── docs/                 # Framework documentation
├── scripts/              # Utility scripts
└── setup.js              # Interactive setup wizard
```

## 🚢 Deployment

### Local Development
1. Run `npm run setup` to configure
2. Use interactive guides (`/adw_guide_*`) for zero-cost development
3. Commit and push using `/commit` and `/pull_request` commands

### Production (Webhook)
1. Configure webhook in GitHub repository settings
2. Point to your webhook server URL
3. Start webhook server: `uv run adw_triggers/trigger_webhook.py`
4. Issues will be processed automatically

## 💰 Cost Analysis

### Interactive Mode
- **Cost**: $0 (Claude Pro covers CLI usage)
- **Speed**: 2-4x faster than automated
- **Use case**: Active development, debugging, learning

### Automated Mode
- **Cost**: $7-25 per workflow (depends on complexity)
- **Speed**: Fully automated, hands-free
- **Use case**: CI/CD, production deployments

**Annual Savings**: $792-$2,976 using interactive mode vs automated

## 🤝 Contributing

This framework is extracted from a production system. Improvements welcome!

## 📄 License

MIT License - See LICENSE file for details

## 🔗 Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
- [ADW System Overview](docs/README.md)
- [Agent Catalog](docs/ADW_AGENTS_GUIDE.md)
- [Cost Comparison](docs/COMPARISON_SUMMARY.md)
EOF

echo -e "${GREEN}  ✓${NC} README.md created"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Framework Extraction Complete!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📊 Extraction Summary:${NC}"
echo -e "  ${GREEN}✓${NC} ADW System (core modules, workflows, triggers)"
echo -e "  ${GREEN}✓${NC} Claude Code Configuration (settings, hooks, commands)"
echo -e "  ${GREEN}✓${NC} Testing Infrastructure (Playwright MCP, E2E templates)"
echo -e "  ${GREEN}✓${NC} Documentation (guides, comparisons, agent catalog)"
echo -e "  ${GREEN}✓${NC} Configuration Templates (.env, .gitignore, etc.)"
echo -e "  ${GREEN}✓${NC} Utility Scripts (start.sh, stop_apps.sh)"
echo ""

echo -e "${YELLOW}📍 Next Steps:${NC}"
echo -e "  1. cd $TARGET_DIR"
echo -e "  2. npm install          # Install Playwright"
echo -e "  3. npm run setup        # Run interactive setup wizard"
echo -e "  4. Review docs/README.md for usage guide"
echo ""

echo -e "${BLUE}🚀 Quick Start:${NC}"
echo -e "  ${GREEN}cd $TARGET_DIR && npm run setup${NC}"
echo ""
