# ADW Guide: Planning Phase

Interactive guide to help you through the ADW planning phase without API costs.

## Instructions

**IMPORTANT:** This is an interactive guide that runs commands automatically where there's only one logical next step. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

Follow these steps to complete the planning phase:

### Step 1: Gather Information

Ask the user: "What is the GitHub issue number you want to work on?"

Once provided, automatically fetch the issue:
- Run `gh issue view <issue-number> --json number,title,body`
- Parse the issue JSON
- Store issue details for next steps

### Step 2: Classify the Issue

Analyze the issue and determine if this is:
- **Feature**: New functionality or enhancement
- **Bug**: Something broken that needs fixing
- **Chore**: Maintenance, refactoring, documentation, or cleanup

Display your classification to the user and ask for confirmation.

### Step 3: Generate ADW ID

Create a unique 8-character ID for this workflow (e.g., using first 8 chars of a UUID or timestamp-based).

Display: "ADW ID: `{adw_id}`"

### Step 4: Generate Branch Name

Based on the issue classification and details, generate a semantic branch name:
- Format: `{type}-issue-{number}-adw-{adw_id}-{slug}`
- Examples:
  - `feature-issue-1-adw-abc12345-table-exports`
  - `bug-issue-42-adw-xyz98765-fix-sql-injection`
  - `chore-issue-7-adw-def45678-update-dependencies`

### Step 5: Create Branch and Initialize Logging

Automatically create the branch and set up logging:

```bash
# Create branch
git checkout -b {branch-name}

# Initialize logging directory
mkdir -p agents/{adw_id}/logs
LOG_FILE="agents/{adw_id}/logs/adw_guide_plan_$(date +%s).log"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Planning phase started for issue #{issue_number}" >> $LOG_FILE
```

Post status update to GitHub issue:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting planning phase"
```

### Step 6: Create State File

Automatically create the state file to track progress:

```bash
mkdir -p agents/{adw_id}
cat > agents/{adw_id}/adw_state.json << EOF
{
  "adw_id": "{adw_id}",
  "issue_number": "{issue_number}",
  "issue_class": "/{classification}",
  "branch_name": "{branch_name}",
  "current_phase": "planning",
  "mode": "interactive"
}
EOF
```

Confirm to user: "✅ State file created: `agents/{adw_id}/adw_state.json`"

Post status update:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Working on branch: \`{branch_name}\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] State file created" >> $LOG_FILE
```

### Step 7: Create Implementation Plan

Automatically run the appropriate planning slash command based on classification:

Post status update:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Issue classified as: {classification}"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running {classification} planning command" >> $LOG_FILE
```

Run the planning command (auto-executed):
- For Features: `/feature {issue_number} {adw_id} '{issue_json}'`
- For Bugs: `/bug {issue_number} {adw_id} '{issue_json}'`
- For Chores: `/chore {issue_number} {adw_id} '{issue_json}'`

This will automatically create the implementation plan file.

### Step 8: Complete Planning Phase

After the plan is created, post completion status and finalize logging:

```bash
# Find the created plan file
PLAN_FILE=$(find specs -name "issue-{issue_number}-adw-{adw_id}-*.md" | head -1)

# Post completion status to GitHub
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_planner: ✅ Plan file created: \`$PLAN_FILE\`"
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Planning phase completed"

# Log completion
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Planning phase completed - Plan file: $PLAN_FILE" >> $LOG_FILE
```

Tell the user:

"✅ Planning phase complete!

**What was created:**
- Branch: `{branch_name}`
- State file: `agents/{adw_id}/adw_state.json`
- Plan file: `$PLAN_FILE`
- Log file: `agents/{adw_id}/logs/adw_guide_plan_*.log`

**GitHub issue updated:** Issue #{issue_number} has been updated with progress

**Next steps:**
1. Review the plan file in `specs/`
2. When ready to implement, run: `/adw_guide_build {adw_id}`

**Cost so far:** $0 (covered by Claude Pro) ✨"

## Logging and Issue Updates

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in planning phase:
- `ops` - Operational messages (starting, branch creation, completion)
- `sdlc_planner` - Planning-specific messages

Common emojis:
- ✅ Success/completion
- ❌ Error
- ⚠️ Warning
- 🔍 Information

### Logging Pattern
Logs are created in `agents/{adw_id}/logs/adw_guide_plan_{timestamp}.log` with entries like:
```
[2025-10-07T16:30:00Z] Planning phase started for issue #4
[2025-10-07T16:30:15Z] State file created
[2025-10-07T16:31:45Z] Planning phase completed - Plan file: specs/issue-4-adw-abc12345-feature.md
```

## What to Do

- **DO** automatically run commands when there's only one logical next step
- **DO** post status updates to GitHub issues
- **DO** create logs in `agents/{adw_id}/logs/`
- **DO** keep the user informed with clear progress messages
- **DO** explain what's happening at each stage

## Variables

If the user provides an ADW ID as an argument, try to resume from existing state:
- `$1` = ADW ID (optional - if provided, resume existing workflow)
