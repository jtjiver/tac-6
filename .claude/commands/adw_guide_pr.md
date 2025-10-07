# ADW Guide: Pull Request Phase

Interactive guide to help you create a pull request without API costs.

## Variables

- `$1` = ADW ID (optional - will search for latest if not provided)

## Instructions

**IMPORTANT:** This is an interactive guide that runs commands automatically where there's only one logical next step. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

### Step 1: Load State and Initialize Logging

Load state from `agents/{adw_id}/adw_state.json` or find the latest interactive state.

Initialize logging:
```bash
mkdir -p agents/{adw_id}/logs
LOG_FILE="agents/{adw_id}/logs/adw_guide_pr_$(date +%s).log"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] PR phase started for issue #{issue_number}" >> $LOG_FILE
```

Post status to GitHub:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting PR phase"
```

Display current workflow info.

### Step 2: Verify Prerequisites

Automatically check that:
1. User is on correct branch
2. Implementation is complete
3. All changes are committed

```bash
# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] WARNING: Uncommitted changes detected" >> $LOG_FILE
  # Show user what needs to be committed
  git status
fi
```

### Step 3: Check Remote Branch Status

Automatically check if branch needs to be pushed:
```bash
BRANCH_NAME=$(git branch --show-current)
REMOTE_STATUS=$(git status | grep -c "Your branch is ahead\|Your branch and")

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Checking remote branch status" >> $LOG_FILE
```

### Step 4: Push Branch

Automatically push branch to remote if needed:

```bash
if [ "$REMOTE_STATUS" -gt 0 ] || ! git rev-parse --verify origin/$BRANCH_NAME 2>/dev/null; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Pushing branch to remote" >> $LOG_FILE

  git push -u origin $BRANCH_NAME

  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Branch pushed to remote"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Branch pushed successfully" >> $LOG_FILE
else
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Branch already up to date with remote" >> $LOG_FILE
fi
```

### Step 5: Create Pull Request

Automatically run the pull request command:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_pr_creator: ✅ Creating pull request"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running /pull_request command" >> $LOG_FILE
```

Run `/pull_request` (auto-executed)

This will:
1. Analyze your commits and changes
2. Generate a comprehensive PR description
3. Create the PR with proper formatting
4. Link to the original issue
5. Return the PR URL

### Step 6: Capture PR URL

After PR is created:
```bash
# PR URL will be returned by /pull_request command
PR_URL="<captured from command output>"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] PR created: $PR_URL" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_pr_creator: ✅ Pull request created: $PR_URL"
```

### Step 7: Update State and Create Completion Comment

Automatically update state and post completion message:

```bash
# Update state
jq '.current_phase = "complete" | .pr_created = true | .pr_url = "'"$PR_URL"'"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] State updated to complete" >> $LOG_FILE

# Post completion comment to issue
gh issue comment {issue_number} --body "✅ Implementation complete!

**Pull Request:** $PR_URL
**Branch:** \`$BRANCH_NAME\`
**ADW ID:** \`{adw_id}\`

Completed using ADW interactive workflow at zero API cost.

**Phases completed:**
- ✅ Planning
- ✅ Implementation
- ✅ Testing
- ✅ Review
- ✅ Pull Request

Ready for review!"

gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Workflow complete - Ready for review"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] PR phase completed" >> $LOG_FILE
```

### Step 8: Report Completion

Tell the user:

"🎉 Workflow complete!

**Summary:**
- Issue: #{issue_number}
- Branch: `$BRANCH_NAME`
- Pull Request: $PR_URL
- ADW ID: `{adw_id}`

**What was accomplished:**
1. ✅ Created implementation plan
2. ✅ Implemented all changes
3. ✅ Tests passing
4. ✅ Implementation reviewed
5. ✅ Pull request created

**Log file:** `agents/{adw_id}/logs/adw_guide_pr_*.log`

**GitHub issue updated:** Issue #{issue_number} has been notified of completion

**Total cost:** $0 (covered by Claude Pro subscription) ✨

**Next steps:**
1. Review the PR on GitHub: $PR_URL
2. Address any reviewer feedback
3. Merge when approved!

You can resume this workflow anytime with the appropriate `/adw_guide_*` command.

Great work! 🚀"

## Logging and Issue Updates

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in PR phase:
- `ops` - Operational messages (starting, completion)
- `pr_creator` - PR creation messages

Common emojis:
- ✅ Success/completion
- ❌ Error
- 🔍 Information

### Logging Pattern
Logs are created in `agents/{adw_id}/logs/adw_guide_pr_{timestamp}.log` with entries like:
```
[2025-10-07T16:50:00Z] PR phase started for issue #4
[2025-10-07T16:50:15Z] Checking remote branch status
[2025-10-07T16:50:30Z] Pushing branch to remote
[2025-10-07T16:51:00Z] Running /pull_request command
[2025-10-07T16:51:45Z] PR created: https://github.com/owner/repo/pull/123
[2025-10-07T16:51:50Z] State updated to complete
[2025-10-07T16:51:55Z] PR phase completed
```

## What to Do

- **DO** automatically push the branch to remote
- **DO** automatically create the pull request
- **DO** post PR URL and completion message to GitHub issue
- **DO** update state to mark workflow complete
- **DO** create detailed PR creation logs

## Alternative: Manual PR Creation

If the user prefers to create the PR manually:

"You can also create the PR manually:

**Option 1: Using GitHub CLI**
```bash
gh pr create --title \"<type>: <description>\" --body \"<PR description>\"
```

**Option 2: Using GitHub Web UI**
1. Go to: https://github.com/{owner}/{repo}/pull/new/$BRANCH_NAME
2. Fill in title and description
3. Link to issue #{issue_number}
4. Create pull request

**PR Description Template:**
```markdown
## Summary
[Describe what this PR does]

## Related Issue
Closes #{issue_number}

## Changes
- [List key changes]

## Testing
- [x] Unit tests passing
- [x] E2E tests passing (if applicable)
- [x] Manual testing completed

## Screenshots (if applicable)
[Add screenshots]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```"

## Error Handling

If branch is not pushed:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Failed to push branch" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ❌ Failed to push branch to remote"
```

If there are uncommitted changes:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Uncommitted changes detected" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ⚠️ Uncommitted changes detected - please commit first"
```

If PR already exists for branch:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] WARNING: PR already exists" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ⚠️ A pull request already exists for this branch"
```

If PR creation fails:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: PR creation failed" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_pr_creator: ❌ Failed to create pull request - check logs"
```
