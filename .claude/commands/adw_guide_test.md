# ADW Guide: Testing Phase

Interactive guide to help you through the ADW testing phase without API costs.

## Variables

- `$1` = ADW ID (optional - will search for latest if not provided)

## Instructions

**IMPORTANT:** This is a guide command that helps you run the workflow manually. It does NOT make subprocess calls or programmatic API calls. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

### Step 1: Load State

Load state from `agents/{adw_id}/adw_state.json` or find the latest interactive state.

Display current workflow info to the user.

### Step 2: Verify Branch

Ensure user is on the correct branch with `git branch --show-current`.

### Step 3: Run Backend Tests

Tell the user:

"Let's run the backend tests:
```bash
cd app/server
uv run pytest
```

This will run all Python tests to ensure your changes don't break existing functionality."

Wait for the user to report results.

### Step 4: Handle Test Failures (If Any)

If tests fail, tell the user:

"Some tests failed. You have two options:

**Option 1: Let Claude fix them**
Run: `/resolve_failed_test`

This will:
1. Analyze the test failures
2. Fix the issues
3. Re-run the tests
4. Repeat up to 3 times if needed

**Option 2: Fix manually**
Review the test failures and fix them yourself.

Which would you like to do?"

### Step 5: Run Frontend Tests

Tell the user:

"Now let's validate the frontend code:
```bash
cd app/client
bun tsc --noEmit
```

This checks for TypeScript type errors."

Wait for confirmation.

### Step 6: Run Frontend Build

Tell the user:

"Let's ensure the frontend builds successfully:
```bash
cd app/client
bun run build
```

This validates that all code compiles correctly."

Wait for confirmation.

### Step 7: Run E2E Tests (If Applicable)

Check if the plan file mentions E2E tests. If yes, tell the user:

"The plan includes E2E tests. Let's run them:

First, read the E2E test guide:
```
/test_e2e
```

This will:
1. Show you how to run E2E tests
2. Guide you through the browser-based testing
3. Help you validate the feature works end-to-end"

### Step 8: Update State

After all tests pass, tell the user:

"✅ All tests passing!

Let's update the workflow state:
```bash
jq '.current_phase = "testing_complete"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp
mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json
```"

### Step 9: Report Next Steps

Tell the user:

"✅ Testing phase complete!

**What was validated:**
- ✅ Backend tests passing
- ✅ Frontend TypeScript checks passing
- ✅ Frontend build successful
- ✅ E2E tests passing (if applicable)

**Next steps:**
1. Review implementation: `/adw_guide_review {adw_id}`
2. Or skip to PR: `/adw_guide_pr {adw_id}`

**Cost so far:** $0 (covered by Claude Pro) ✨"

## Alternative: Quick Test Command

If the user wants to run the `/test` slash command directly, tell them:

"You can also run the automated test workflow:
```
/test
```

This will automatically:
1. Run the test suite
2. Attempt to fix failures (up to 3 times)
3. Report results

This is still covered by your Claude Pro subscription at zero cost since you're running it interactively."

## What NOT to Do

- **DO NOT** call subprocess.run()
- **DO NOT** call execute_template() or prompt_claude_code()
- **DO NOT** make programmatic API calls
- **DO** guide the user on what commands to run
- **DO** wait for user confirmation at each step
- **DO** explain what's happening and why

## Error Handling

If no state file is found:
"No workflow state found. Please run `/adw_guide_plan` first."

If user is not on correct branch:
"You're not on the correct branch. Please checkout: `{branch_name}`"
