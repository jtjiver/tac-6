# ADW Framework Extraction Guide

This guide explains how to extract the ADW (AI Developer Workflow) Framework from this project to use as a starter for new projects.

## 🎯 Overview

The ADW Framework is a production-ready system for AI-assisted software development with:
- **Zero-cost interactive mode** ($0/workflow with Claude Pro)
- **Automated webhook mode** ($7-25/workflow for CI/CD)
- **Complete SDLC coverage** (Plan → Build → Test → Review → Document)
- **94 framework files** ready for reuse

## 🚀 Quick Start

### Extract the Framework

```bash
# From this project directory
./scripts/extract_framework.sh /path/to/new-project-framework

# Or use default directory name
./scripts/extract_framework.sh
# Creates: ./adw-framework-starter/
```

### Set Up for Your Project

```bash
cd /path/to/new-project-framework
npm install
npm run setup  # Interactive configuration wizard
```

That's it! The framework is ready to use.

## 📦 What Gets Extracted

### 1. ADW System (Complete Automation)
- **Core Modules** (7 files): `adws/adw_modules/`
  - `agent.py` - Claude Code CLI integration
  - `data_types.py` - Pydantic models
  - `github.py` - GitHub API wrapper
  - `git_ops.py` - Git operations
  - `state.py` - Workflow state management
  - `workflow_ops.py` - Core workflow operations
  - `utils.py` - Utilities and logging

- **Workflow Scripts** (13 files): `adws/`
  - Planning: `adw_plan.py`
  - Build: `adw_build.py`
  - Testing: `adw_test.py`
  - Review: `adw_review.py`
  - Documentation: `adw_document.py`
  - Patch: `adw_patch.py`
  - Orchestrators: `adw_plan_build.py`, `adw_plan_build_test.py`, etc.
  - Complete SDLC: `adw_sdlc.py`

- **Automation Triggers** (2 files): `adws/adw_triggers/`
  - `trigger_webhook.py` - FastAPI webhook server
  - `trigger_cron.py` - Polling monitor

### 2. Claude Code Configuration
- **Settings**: `.claude/settings.json`
  - Comprehensive permission system
  - Hook configurations
  - MCP server integration

- **Hooks** (7 files + utilities): `.claude/hooks/`
  - Safety checks (pre-execution)
  - Logging (post-execution)
  - Notifications
  - Session tracking

- **Slash Commands** (25 files): `.claude/commands/`
  - Issue classification: `classify_issue.md`, `classify_adw.md`
  - Planning: `feature.md`, `bug.md`, `chore.md`
  - Implementation: `implement.md`, `patch.md`
  - Testing: `test.md`, `test_e2e.md`, resolvers
  - Review: `review.md`, `document.md`
  - Git ops: `generate_branch_name.md`, `commit.md`, `pull_request.md`
  - Utilities: `tools.md`, `conditional_docs.md`, `prepare_app.md`

- **Interactive Guides** (6 files): `.claude/commands/`
  - `adw_guide_plan.md` - Zero-cost planning
  - `adw_guide_build.md` - Zero-cost build
  - `adw_guide_test.md` - Zero-cost testing
  - `adw_guide_pr.md` - Zero-cost PR creation
  - `adw_guide_review.md` - Zero-cost review
  - `adw_guide_status.md` - Status checker

- **E2E Test Template**: `.claude/commands/e2e/README.md`
  - Template for creating project-specific E2E tests

### 3. Testing Infrastructure
- **MCP Configuration**: `playwright-mcp-config.json`
- **MCP Template**: `.mcp.json.sample`
- **Dependencies**: `package.json` (Playwright)

### 4. Documentation (6 files)
- `docs/README.md` - Documentation index
- `docs/ADW_AGENTS_GUIDE.md` - Complete agent catalog (14 agents)
- `docs/COEXISTENCE_GUIDE.md` - Interactive vs Automated modes
- `docs/COMPARISON_SUMMARY.md` - Cost and speed analysis
- `docs/COMPARISON_PLANNING_PHASE.md` - Detailed planning comparison
- `docs/COMPARISON_BUILD_PHASE.md` - Detailed build comparison

### 5. Configuration Templates
- `.env.sample` - Environment variable template
- `.gitignore` - Comprehensive ignore patterns

### 6. Utility Scripts
- `scripts/start.sh` - Multi-service startup
- `scripts/stop_apps.sh` - Service shutdown

### 7. Interactive Setup
- `setup.js` - NPX-style configuration wizard
- `package.json` - Includes `npm run setup` command

## 🚫 What Gets Excluded (Project-Specific)

- `app/` - Your application code
- `specs/` - Project-specific specifications
- `agents/` - Runtime execution logs
- `logs/` - Session logs
- `.claude/commands/e2e/*.md` - Project-specific E2E tests (template provided)
- Project-specific utility scripts

## 📖 Using the Framework

### For New Projects

1. **Extract framework**:
   ```bash
   ./scripts/extract_framework.sh /path/to/new-project
   ```

2. **Install dependencies**:
   ```bash
   cd /path/to/new-project
   npm install
   ```

3. **Run interactive setup**:
   ```bash
   npm run setup
   ```

   The wizard will ask:
   - Project name
   - GitHub repository URL
   - Execution mode (interactive/automated/both)
   - API keys (if using automated mode)
   - Optional integrations (R2, custom GitHub PAT)

4. **Start using**:
   ```bash
   # Interactive mode (zero cost)
   claude -p "/adw_guide_plan <issue-number>"

   # Automated mode (API-based)
   cd adws && uv run adw_plan.py <issue-number>
   ```

### Customization Points

#### 1. Planning Templates
Edit these to match your project structure:
- `.claude/commands/feature.md`
- `.claude/commands/bug.md`
- `.claude/commands/chore.md`

#### 2. E2E Tests
Create project-specific tests:
- Add files to `.claude/commands/e2e/`
- Follow template in `.claude/commands/e2e/README.md`

#### 3. Test Commands
Update test execution:
- `.claude/commands/test.md` - Backend tests
- `.claude/commands/test_e2e.md` - E2E test runner

#### 4. Hooks
Add custom behaviors:
- `.claude/hooks/pre_tool_use.py` - Pre-execution checks
- `.claude/hooks/post_tool_use.py` - Post-execution logging
- `.claude/hooks/notification.py` - Custom notifications

#### 5. Conditional Documentation
Update documentation requirements:
- `.claude/commands/conditional_docs.md`

## 💡 Execution Modes

### Interactive Mode (Recommended for Development)

**Cost**: $0 (Claude Pro covers CLI usage)
**Speed**: 2-4x faster than automated mode
**Benefits**:
- Real-time visibility
- Better error recovery
- No API costs
- Same artifacts as automated mode

**Usage**:
```bash
# Complete planning phase
claude -p "/adw_guide_plan 123"

# Build implementation
claude -p "/adw_guide_build abc12345"

# Run tests
claude -p "/adw_guide_test abc12345"

# Create PR
claude -p "/adw_guide_pr abc12345"
```

### Automated Mode (For CI/CD)

**Cost**: $7-25 per workflow
**Speed**: Fully automated, hands-free
**Benefits**:
- Webhook integration
- Zero human intervention
- Complete audit trail
- Production-ready

**Usage**:
```bash
# Complete SDLC for an issue
cd adws
uv run adw_plan_build_test_review.py 123

# Individual phases
uv run adw_plan.py 123
uv run adw_build.py 123
uv run adw_test.py 123

# Start webhook server
uv run adw_triggers/trigger_webhook.py
```

### Both Modes (Best of Both Worlds)

Use interactive for development, automated for production:
- Develop features with zero-cost interactive mode
- Deploy with automated webhook integration
- Save $792-$2,976 per year

## 📊 Value Propositions

### Cost Savings

**Interactive vs Automated (Annual)**:
- Planning: $0 vs $2,976 (24 workflows × $2-8 × 12 months)
- Build: $0 vs $4,320 (24 workflows × $3-10 × 12 months)
- Test: $0 vs $2,016 (24 workflows × $2-7 × 12 months)
- **Total Savings**: $792-$2,976/year

### Speed Improvement

- **Interactive mode**: 2-4x faster than subprocess automation
- **Sub-agent delegation**: Parallel task execution
- **Zero context switching**: All in one session

### Safety Features

- Pre-execution safety hooks
- Dangerous command blocking
- Environment variable protection
- Session logging for audit
- Granular permission system

### Comprehensive SDLC

- Plan → Build → Test → Review → Document
- 14 specialized AI agents
- State management for workflow chaining
- GitHub integration
- Playwright E2E testing

## 🔧 Prerequisites

### Required
- Python 3.10+
- `uv` package manager: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Node.js 18+ (for Playwright)
- Git
- GitHub CLI: `brew install gh`

### Recommended
- Claude Code CLI: [Installation guide](https://docs.anthropic.com/claude/docs/claude-code)
- Claude Pro subscription (for zero-cost interactive mode)

### For Automated Mode
- Anthropic API key
- Webhook server (for GitHub integration)

## 📁 Directory Structure

```
adw-framework-starter/
├── .claude/                    # Claude Code configuration
│   ├── settings.json           # Permissions, hooks, MCP
│   ├── hooks/                  # Safety and logging hooks
│   └── commands/               # Slash commands and guides
│       ├── *.md                # 25+ workflow commands
│       ├── adw_guide_*.md      # 6 interactive guides
│       └── e2e/                # E2E test templates
│
├── adws/                       # ADW automation system
│   ├── adw_modules/            # Core modules (7 files)
│   ├── adw_triggers/           # Webhook and cron (2 files)
│   ├── adw_plan.py             # Planning phase
│   ├── adw_build.py            # Build phase
│   ├── adw_test.py             # Test phase
│   ├── adw_review.py           # Review phase
│   ├── adw_document.py         # Documentation phase
│   ├── adw_patch.py            # Quick patch workflow
│   ├── adw_plan_build.py       # Combined: plan + build
│   ├── adw_plan_build_test.py  # Combined: plan + build + test
│   └── adw_sdlc.py             # Complete SDLC
│
├── docs/                       # Framework documentation
│   ├── README.md               # Documentation index
│   ├── ADW_AGENTS_GUIDE.md     # 14 AI agents catalog
│   ├── COEXISTENCE_GUIDE.md    # Mode comparison
│   ├── COMPARISON_SUMMARY.md   # Cost/speed analysis
│   └── COMPARISON_*.md         # Phase-specific comparisons
│
├── scripts/                    # Utility scripts
│   ├── start.sh                # Multi-service startup
│   └── stop_apps.sh            # Service shutdown
│
├── setup.js                    # Interactive configuration wizard
├── package.json                # Playwright dependencies
├── .env.sample                 # Environment template
├── .gitignore                  # Ignore patterns
├── .mcp.json.sample            # MCP server config
├── playwright-mcp-config.json  # Playwright config
└── README.md                   # Framework overview
```

## 🎓 Learning Resources

### Start Here
1. `README.md` - Framework overview and quick start
2. `QUICKSTART.md` - Generated by `npm run setup`
3. `docs/README.md` - Documentation index

### Understanding the System
1. `docs/ADW_AGENTS_GUIDE.md` - All 14 AI agents explained
2. `docs/COEXISTENCE_GUIDE.md` - When to use each mode
3. `docs/COMPARISON_SUMMARY.md` - Cost and speed analysis

### Using Interactive Mode
1. `.claude/commands/adw_guide_plan.md` - Planning walkthrough
2. `.claude/commands/adw_guide_build.md` - Build walkthrough
3. `.claude/commands/adw_guide_test.md` - Test walkthrough

### Using Automated Mode
1. `adws/README.md` - ADW system documentation
2. `docs/COMPARISON_PLANNING_PHASE.md` - Detailed workflow
3. `docs/COMPARISON_BUILD_PHASE.md` - Implementation details

## 🐛 Troubleshooting

### Extraction Issues

**Problem**: Files not found during extraction
**Solution**: Run from project root: `./scripts/extract_framework.sh`

**Problem**: Permission denied
**Solution**: `chmod +x scripts/extract_framework.sh`

### Setup Issues

**Problem**: npm run setup fails
**Solution**: Ensure Node.js 18+ is installed: `node --version`

**Problem**: Interactive wizard not starting
**Solution**: Make setup.js executable: `chmod +x setup.js`

### Interactive Mode Issues

**Problem**: Claude Code commands not working
**Solution**:
- Verify Claude Code CLI installed: `claude --version`
- Check Claude Pro subscription is active
- Ensure you're in project directory with `.claude/` folder

**Problem**: Slash commands not found
**Solution**: Verify `.claude/commands/` directory exists and contains .md files

### Automated Mode Issues

**Problem**: API calls failing
**Solution**:
- Check API key in `.env`: `ANTHROPIC_API_KEY`
- Verify API key is valid and not expired
- Review logs in `agents/<adw-id>/logs/`

**Problem**: Webhook not receiving events
**Solution**:
- Check webhook URL in GitHub settings
- Verify webhook server is running
- Check firewall/port forwarding

### E2E Test Issues

**Problem**: Playwright not found
**Solution**: `npm install` to install Playwright

**Problem**: Tests failing to connect
**Solution**: Ensure application is running on expected port

**Problem**: Screenshots not saving
**Solution**: Check R2 configuration in `.env` (if using uploads)

## 🤝 Contributing Improvements

If you improve the framework, consider:
1. Documenting changes in your QUICKSTART.md
2. Updating slash command templates
3. Adding new E2E test examples
4. Improving hook safety checks
5. Enhancing documentation

## 📄 License

This framework is extracted from a production system and provided as-is.
Check LICENSE file for specific terms.

## 🔗 Additional Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
- [Anthropic API Docs](https://docs.anthropic.com/)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Playwright Documentation](https://playwright.dev/)
- [uv Package Manager](https://github.com/astral-sh/uv)

---

**Generated from**: tac-6 Natural Language SQL Interface project
**Framework Version**: 1.0.0
**Last Updated**: 2025-10-23
