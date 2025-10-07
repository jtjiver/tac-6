# ADW Guide: Build/Implementation Phase

Interactive guide to help you through the ADW implementation phase without API costs.

## Variables

- `$1` = ADW ID (optional - will search for latest if not provided)

## Instructions

**IMPORTANT:** This is a guide command that helps you run the workflow manually. It does NOT make subprocess calls or programmatic API calls. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

### Step 1: Load State

If ADW ID is provided in `$1`, load state from `agents/$1/adw_state.json`.

Otherwise, find the most recent interactive state file:
```bash
find agents/*/adw_state.json -type f -exec grep -l '"mode": "interactive"' {} \; | xargs ls -t | head -1
```

Display the state to the user:
```
Found workflow:
- Issue: #{issue_number}
- Branch: {branch_name}
- Current phase: {current_phase}
```

### Step 2: Verify Branch

Check current branch with `git branch --show-current`.

If not on the correct branch, tell the user:
```bash
git checkout {branch_name}
```

### Step 3: Find Plan File

Look for the plan file in `specs/` directory matching the pattern:
```
specs/issue-{issue_number}-adw-{adw_id}-*.md
```

Display: "Found plan file: `{plan_file}`"

### Step 4: Guide User to Implement

Tell the user:

"Now let's implement the plan. Run the following command:
```
/implement {plan_file}
```

This will:
1. Read the plan file
2. Research the codebase
3. Implement all changes according to the plan
4. Report what was changed

**Note:** This runs inside Claude Code interactively, so it's covered by your Claude Pro subscription at zero additional cost."

Wait for the user to confirm implementation is complete.

### Step 5: Review Changes

After implementation, tell the user:

"Let's review what was changed:
```bash
git status
git diff --stat
```

Review the changes to ensure they look correct."

### Step 6: Commit Changes

If changes look good, guide the user to create a commit:

"Now let's create a semantic commit message. Run:
```
/commit
```

This will:
1. Analyze the changes
2. Generate a semantic commit message
3. Create the commit with proper attribution"

Alternatively, tell the user they can commit manually:
```bash
git add .
git commit -m "feat: implement {feature-name}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 7: Update State

Tell the user to update the state file:
```bash
# Update state to mark build complete
jq '.current_phase = "build_complete" | .plan_file = "{plan_file}"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp
mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json
```

Or provide a simpler version:
```bash
echo "Build phase complete! State updated."
```

### Step 8: Report Next Steps

Tell the user:

"✅ Implementation phase complete!

**What was done:**
- Implemented all changes from the plan
- Changes committed to branch: `{branch_name}`

**Next steps:**
1. Run tests: `/adw_guide_test {adw_id}`
2. Or skip to review: `/adw_guide_review {adw_id}`
3. Or skip to PR: `/adw_guide_pr {adw_id}`

**Cost so far:** $0 (covered by Claude Pro) ✨"

## What NOT to Do

- **DO NOT** call subprocess.run()
- **DO NOT** call execute_template() or prompt_claude_code()
- **DO NOT** make programmatic API calls
- **DO** guide the user on what commands to run
- **DO** wait for user confirmation at each step
- **DO** explain what's happening and why

## Error Handling

If no state file is found, tell the user:
"No workflow state found. Please run `/adw_guide_plan` first to start a new workflow."

If plan file is not found, tell the user:
"Plan file not found. Please ensure the planning phase completed successfully."
