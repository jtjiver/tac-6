# ADW Guide: Review Phase

Interactive guide to help you through the ADW review phase without API costs.

## Variables

- `$1` = ADW ID (optional - will search for latest if not provided)

## Instructions

**IMPORTANT:** This is an interactive guide that runs commands automatically where there's only one logical next step. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

### Step 1: Load State and Initialize Logging

Load state from `agents/{adw_id}/adw_state.json` or find the latest interactive state.

Initialize logging:
```bash
mkdir -p agents/{adw_id}/logs
LOG_FILE="agents/{adw_id}/logs/adw_guide_review_$(date +%s).log"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Review phase started for issue #{issue_number}" >> $LOG_FILE
```

Post status to GitHub:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting review phase"
```

Display current workflow info including the plan file path.

### Step 2: Verify Prerequisites

Check that:
1. User is on correct branch
2. Implementation is complete
3. Tests are passing (read from state or logs)

Display status to user.

### Step 3: Find Specification File

Automatically locate the spec file from the planning phase:
```bash
SPEC_FILE=$(find specs -name "issue-{issue_number}-adw-{adw_id}-*.md" | head -1)
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Using spec file: $SPEC_FILE" >> $LOG_FILE
```

Display: "Found specification: `$SPEC_FILE`"

### Step 4: Run Implementation Review

Automatically run the review command:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_reviewer: ✅ Reviewing implementation against specification"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running /review command" >> $LOG_FILE
```

Run `/review $SPEC_FILE` (auto-executed)

This will:
1. Compare your implementation to the specification
2. Check if all requirements are met
3. Identify any issues (blockers, tech debt, nice-to-haves)
4. Take screenshots if the feature has UI components
5. Create a review report

### Step 5: Analyze Review Results

After review completes, automatically parse results:

```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Review completed" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_reviewer: ✅ Implementation reviewed"
```

Display review summary to user:
- Requirements met
- Code quality
- Test coverage
- Documentation status
- Any blockers or issues found

### Step 6: Handle Review Issues (If Any)

If the review found blockers, automatically attempt to resolve them:

```bash
if [ "$BLOCKERS_FOUND" = "true" ]; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Blockers found - attempting resolution" >> $LOG_FILE
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_reviewer: ⚠️ Review identified issues - resolving"

  # Auto-implement fixes for blockers
  # This runs inside Claude Code interactively
fi
```

After resolution:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_reviewer: ✅ Review issues resolved"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Issues resolved" >> $LOG_FILE
```

### Step 7: Commit Review Artifacts

Automatically commit the review artifacts:

```bash
# Add review artifacts
git add agents/{adw_id}/reviewer/

# Create commit
git commit -m "review: complete implementation review for issue #{issue_number}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Review artifacts committed" >> $LOG_FILE
```

### Step 8: Update State and Complete

Automatically update state and finalize:

```bash
jq '.current_phase = "review_complete"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Review phase completed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Review phase completed" >> $LOG_FILE
```

Tell the user:

"✅ Review phase complete!

**What was done:**
- Implementation reviewed against specification
- All requirements verified
- Issues identified and resolved (if any)
- Review artifacts committed

**Review report:** `agents/{adw_id}/reviewer/`

**Log file:** `agents/{adw_id}/logs/adw_guide_review_*.log`

**GitHub issue updated:** Issue #{issue_number} has been updated with review results

**Next steps:**
1. Create pull request: `/adw_guide_pr {adw_id}`

**Cost so far:** $0 (covered by Claude Pro) ✨"

## Logging and Issue Updates

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in review phase:
- `ops` - Operational messages (starting, completion)
- `reviewer` - Review-specific messages

Common emojis:
- ✅ Success/completion
- ❌ Error
- ⚠️ Warning/issues found

### Logging Pattern
Logs are created in `agents/{adw_id}/logs/adw_guide_review_{timestamp}.log` with entries like:
```
[2025-10-07T16:45:00Z] Review phase started for issue #4
[2025-10-07T16:45:15Z] Using spec file: specs/issue-4-adw-abc12345-feature.md
[2025-10-07T16:46:30Z] Review completed
[2025-10-07T16:47:00Z] Review artifacts committed
[2025-10-07T16:47:05Z] Review phase completed
```

## What to Do

- **DO** automatically run the review command
- **DO** post review results to GitHub issues
- **DO** automatically resolve identified blockers
- **DO** create comprehensive review logs
- **DO** commit review artifacts automatically

## Alternative: Manual Review

If the user prefers to review manually:

"You can also review the implementation yourself:

1. Open the specification: `$SPEC_FILE`
2. Check each requirement is implemented
3. Test the functionality manually
4. Verify edge cases are handled
5. Ensure code quality is maintained

Then proceed to: `/adw_guide_pr {adw_id}`"

## Error Handling

If spec file not found:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Spec file not found" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ❌ Specification file not found - ensure planning completed"
```

If implementation not complete:
"Implementation doesn't appear to be complete. Run `/adw_guide_build {adw_id}` first."

If blockers cannot be resolved:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Blockers require manual intervention" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_reviewer: ❌ Review blockers require manual intervention"
```
