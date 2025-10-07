# ADW Guide: Pull Request Phase

Interactive guide to help you create a pull request without API costs.

## Variables

- `$1` = ADW ID (optional - will search for latest if not provided)

## Instructions

**IMPORTANT:** This is a guide command that helps you run the workflow manually. It does NOT make subprocess calls or programmatic API calls. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

### Step 1: Load State

Load state from `agents/{adw_id}/adw_state.json` or find the latest interactive state.

Display current workflow info.

### Step 2: Verify Prerequisites

Check that:
1. User is on correct branch
2. Implementation is complete
3. All changes are committed
4. Tests are passing

Ask user to confirm: "Are all your changes committed and ready to push?"

### Step 3: Check Remote Branch Status

Tell the user to check if branch is already pushed:
```bash
git status
```

Look for messages like:
- "Your branch is ahead of 'origin/{branch_name}'"
- "Your branch is up to date with 'origin/{branch_name}'"
- "Your branch and 'origin/{branch_name}' have diverged"

### Step 4: Push Branch (If Needed)

If branch is not pushed or is ahead, tell the user:

"Let's push your branch to the remote repository:
```bash
git push -u origin {branch_name}
```

This will:
1. Push your commits to GitHub
2. Set up tracking between local and remote branch"

Wait for confirmation that push succeeded.

### Step 5: Guide User to Create PR

Tell the user:

"Now let's create a pull request using the `/pull_request` command:
```
/pull_request
```

This will:
1. Analyze your commits and changes
2. Generate a comprehensive PR description
3. Create the PR with proper formatting
4. Link to the original issue

**Note:** This runs inside Claude Code interactively, so it's covered by your Claude Pro subscription at zero additional cost."

Wait for PR creation to complete.

### Step 6: Get PR URL

After PR is created, the `/pull_request` command should output the PR URL.

Display to user:
"✅ Pull request created!"

### Step 7: Update State and Create GitHub Comment

Tell the user to update state and notify the issue:

"Let's update the workflow state and notify the issue:

**Update state:**
```bash
jq '.current_phase = "complete" | .pr_created = true' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp
mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json
```

**Add comment to issue:**
```bash
gh issue comment {issue_number} --body \"✅ Implementation complete!

**Pull Request:** #{pr_number}
**Branch:** \`{branch_name}\`
**ADW ID:** \`{adw_id}\`

Completed using ADW interactive workflow at zero API cost.

**Phases completed:**
- ✅ Planning
- ✅ Implementation
- ✅ Testing
- ✅ Review
- ✅ Pull Request

Ready for review!\"
```"

### Step 8: Report Completion

Tell the user:

"🎉 Workflow complete!

**Summary:**
- Issue: #{issue_number}
- Branch: `{branch_name}`
- Pull Request: [View PR]({pr_url})
- ADW ID: `{adw_id}`

**What was accomplished:**
1. ✅ Created implementation plan
2. ✅ Implemented all changes
3. ✅ Tests passing
4. ✅ Implementation reviewed
5. ✅ Pull request created

**Total cost:** $0 (covered by Claude Pro subscription) ✨

**Next steps:**
1. Review the PR on GitHub
2. Address any reviewer feedback
3. Merge when approved!

You can resume this workflow anytime with: `/adw_guide_build {adw_id}` (or any other phase)

Great work! 🚀"

## Alternative: Manual PR Creation

If the user prefers to create the PR manually, provide guidance:

"You can also create the PR manually:

**Option 1: Using GitHub CLI**
```bash
gh pr create --title \"feat: {short-description}\" --body \"[PR description]\"
```

**Option 2: Using GitHub Web UI**
1. Go to: https://github.com/{owner}/{repo}/pull/new/{branch_name}
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

## What NOT to Do

- **DO NOT** call subprocess.run()
- **DO NOT** call execute_template() or prompt_claude_code()
- **DO NOT** make programmatic API calls
- **DO** guide the user on what commands to run
- **DO** wait for user confirmation at each step
- **DO** explain what's happening and why

## Error Handling

If branch is not pushed:
"Branch not pushed to remote. Please push first with: `git push -u origin {branch_name}`"

If there are uncommitted changes:
"You have uncommitted changes. Please commit them first with: `/commit` or `git commit`"

If PR already exists for branch:
"A pull request already exists for this branch: [PR URL]"
