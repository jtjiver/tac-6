# ADW Guide: Review Phase

Interactive guide to help you through the ADW review phase without API costs.

## Variables

- `$1` = ADW ID (optional - will search for latest if not provided)

## Instructions

**IMPORTANT:** This is a guide command that helps you run the workflow manually. It does NOT make subprocess calls or programmatic API calls. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

### Step 1: Load State

Load state from `agents/{adw_id}/adw_state.json` or find the latest interactive state.

Display current workflow info including the plan file path.

### Step 2: Verify Prerequisites

Check that:
1. User is on correct branch
2. Implementation is complete
3. Tests are passing (ask user to confirm)

If tests haven't been run, suggest: "Would you like to run tests first? Use `/adw_guide_test {adw_id}`"

### Step 3: Find Specification File

Locate the spec file from the planning phase:
```
specs/issue-{issue_number}-adw-{adw_id}-*.md
```

Display: "Found specification: `{spec_file}`"

### Step 4: Guide User to Review

Tell the user:

"Now let's review the implementation against the specification:
```
/review {spec_file}
```

This will:
1. Compare your implementation to the specification
2. Check if all requirements are met
3. Identify any issues (blockers, tech debt, nice-to-haves)
4. Take screenshots if the feature has UI components
5. Create a review report

**Note:** This runs inside Claude Code interactively, so it's covered by your Claude Pro subscription at zero additional cost."

Wait for the review to complete.

### Step 5: Analyze Review Results

After review completes, tell the user:

"Let's analyze the review results.

The review checked:
- ✅ All requirements implemented
- ✅ Code follows best practices
- ✅ Tests are comprehensive
- ✅ Documentation is clear
- ✅ UI works as expected (if applicable)

Did the review identify any blockers or issues?"

### Step 6: Handle Review Issues (If Any)

If the review found blockers, tell the user:

"The review identified some blockers that need to be fixed:

[List the blockers from review]

You have two options:

**Option 1: Fix automatically**
Claude can attempt to fix these issues. Would you like me to implement the fixes?

**Option 2: Fix manually**
You can fix the issues yourself and then re-run the review.

Which would you like to do?"

If user chooses automatic fixes, implement them and then suggest re-running review.

### Step 7: Commit Review Artifacts

After review is complete and satisfactory, tell the user:

"Let's commit the review artifacts:
```bash
git add agents/{adw_id}/reviewer/
git commit -m \"review: complete implementation review for issue #{issue_number}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>\"
```"

### Step 8: Update State

Tell the user:

"Update the workflow state:
```bash
jq '.current_phase = "review_complete"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp
mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json
```"

### Step 9: Report Next Steps

Tell the user:

"✅ Review phase complete!

**What was done:**
- Implementation reviewed against specification
- All requirements verified
- Issues identified and resolved
- Review artifacts committed

**Next steps:**
1. Generate documentation (optional): `/adw_guide_document {adw_id}`
2. Create pull request: `/adw_guide_pr {adw_id}`

**Cost so far:** $0 (covered by Claude Pro) ✨"

## Alternative: Manual Review

If the user prefers to review manually, tell them:

"You can also review the implementation yourself:

1. Open the specification: `specs/issue-{issue_number}-adw-{adw_id}-*.md`
2. Check each requirement is implemented
3. Test the functionality manually
4. Verify edge cases are handled
5. Ensure code quality is maintained

Then proceed to: `/adw_guide_pr {adw_id}`"

## What NOT to Do

- **DO NOT** call subprocess.run()
- **DO NOT** call execute_template() or prompt_claude_code()
- **DO NOT** make programmatic API calls
- **DO** guide the user on what commands to run
- **DO** wait for user confirmation at each step
- **DO** explain what's happening and why

## Error Handling

If spec file not found:
"Specification file not found. Ensure planning phase completed successfully."

If implementation not complete:
"Implementation doesn't appear to be complete. Run `/adw_guide_build {adw_id}` first."
