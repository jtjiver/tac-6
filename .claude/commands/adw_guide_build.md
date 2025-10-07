# ADW Guide: Build/Implementation Phase

Interactive guide to help you through the ADW implementation phase without API costs.

## Variables

- `$1` = ADW ID (optional - will search for latest if not provided)

## Instructions

**IMPORTANT:** This is an interactive guide that runs commands automatically where there's only one logical next step. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

### Step 1: Load State and Initialize Logging

If ADW ID is provided in `$1`, load state from `agents/$1/adw_state.json`.

Otherwise, find the most recent interactive state file:
```bash
find agents/*/adw_state.json -type f -exec grep -l '"mode": "interactive"' {} \; | xargs ls -t | head -1
```

Initialize logging:
```bash
mkdir -p agents/{adw_id}/logs
LOG_FILE="agents/{adw_id}/logs/adw_guide_build_$(date +%s).log"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Build phase started for issue #{issue_number}" >> $LOG_FILE
```

Post status to GitHub:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting implementation phase"
```

Display the state to the user:
```
Found workflow:
- Issue: #{issue_number}
- Branch: {branch_name}
- Current phase: {current_phase}
```

### Step 2: Verify Branch

Automatically check and switch to the correct branch if needed:
```bash
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "{branch_name}" ]; then
  git checkout {branch_name}
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Switched to branch {branch_name}" >> $LOG_FILE
fi
```

### Step 3: Find Plan File

Automatically locate the plan file:
```bash
PLAN_FILE=$(find specs -name "issue-{issue_number}-adw-{adw_id}-*.md" | head -1)
```

Display: "Found plan file: `$PLAN_FILE`"

Log the plan file:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Using plan file: $PLAN_FILE" >> $LOG_FILE
```

### Step 4: Implement the Plan

Automatically run the implementation:
```bash
# Post status
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_implementor: ✅ Implementing solution"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running /implement command" >> $LOG_FILE
```

Run `/implement $PLAN_FILE` (auto-executed)

This will:
1. Read the plan file
2. Research the codebase
3. Implement all changes according to the plan
4. Report what was changed

### Step 5: Review and Commit Changes

After implementation completes, automatically review and commit:

```bash
# Log implementation complete
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Implementation complete" >> $LOG_FILE

# Post status
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_implementor: ✅ Solution implemented"

# Show changes to user
git status
git diff --stat
```

Display brief summary of changes to user.

### Step 6: Create Commit

Automatically generate and create commit:

```bash
# Run /commit to create semantic commit message (auto-executed)
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Creating commit" >> $LOG_FILE
```

Run `/commit` (auto-executed) - this will:
1. Analyze the changes
2. Generate a semantic commit message
3. Create the commit with proper attribution

After commit:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_implementor: ✅ Implementation committed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Changes committed" >> $LOG_FILE
```

### Step 7: Update State

Automatically update the state file:
```bash
jq '.current_phase = "build_complete" | .plan_file = "'"$PLAN_FILE"'"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] State updated to build_complete" >> $LOG_FILE
```

### Step 8: Complete Build Phase

Post completion status and report next steps:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Implementation phase completed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Build phase completed" >> $LOG_FILE
```

Tell the user:

"✅ Implementation phase complete!

**What was done:**
- Implemented all changes from the plan
- Changes committed to branch: `{branch_name}`
- State file updated
- Log file: `agents/{adw_id}/logs/adw_guide_build_*.log`

**GitHub issue updated:** Issue #{issue_number} has been updated with progress

**Next steps:**
1. Run tests: `/adw_guide_test {adw_id}`
2. Or skip to review: `/adw_guide_review {adw_id}`
3. Or skip to PR: `/adw_guide_pr {adw_id}`

**Cost so far:** $0 (covered by Claude Pro) ✨"

## Logging and Issue Updates

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in build phase:
- `ops` - Operational messages (starting, completion)
- `sdlc_implementor` - Implementation-specific messages

Common emojis:
- ✅ Success/completion
- ❌ Error
- ⚠️ Warning

### Logging Pattern
Logs are created in `agents/{adw_id}/logs/adw_guide_build_{timestamp}.log` with entries like:
```
[2025-10-07T16:35:00Z] Build phase started for issue #4
[2025-10-07T16:35:15Z] Using plan file: specs/issue-4-adw-abc12345-feature.md
[2025-10-07T16:36:45Z] Implementation complete
[2025-10-07T16:37:00Z] Changes committed
[2025-10-07T16:37:05Z] Build phase completed
```

## What to Do

- **DO** automatically run commands when there's only one logical next step
- **DO** post status updates to GitHub issues at key milestones
- **DO** create detailed logs in `agents/{adw_id}/logs/`
- **DO** keep the user informed with clear progress messages
- **DO** automatically commit changes after implementation

## Error Handling

If no state file is found:
"No workflow state found. Please run `/adw_guide_plan` first to start a new workflow."

If plan file is not found:
"Plan file not found. Please ensure the planning phase completed successfully."

If implementation fails, log the error and post to GitHub:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Implementation failed" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_implementor: ❌ Implementation failed - check logs"
```
