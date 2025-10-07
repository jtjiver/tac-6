# ADW Guide: Testing Phase

Interactive guide to help you through the ADW testing phase without API costs.

## Variables

- `$1` = ADW ID (optional - will search for latest if not provided)

## Instructions

**IMPORTANT:** This is an interactive guide that runs commands automatically where there's only one logical next step. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

### Step 1: Load State and Initialize Logging

Load state from `agents/{adw_id}/adw_state.json` or find the latest interactive state.

Initialize logging:
```bash
mkdir -p agents/{adw_id}/logs
LOG_FILE="agents/{adw_id}/logs/adw_guide_test_$(date +%s).log"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Testing phase started for issue #{issue_number}" >> $LOG_FILE
```

Post status to GitHub:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting testing phase"
```

Display current workflow info to the user.

### Step 2: Verify Branch

Automatically verify correct branch:
```bash
CURRENT_BRANCH=$(git branch --show-current)
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] On branch: $CURRENT_BRANCH" >> $LOG_FILE
```

### Step 3: Run Backend Tests

Automatically run backend tests:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Running backend tests"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running backend tests" >> $LOG_FILE

cd app/server && uv run pytest
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Backend tests: PASSED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Backend tests PASSED" >> $LOG_FILE
else
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ❌ Backend tests: FAILED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Backend tests FAILED" >> $LOG_FILE
fi
```

### Step 4: Handle Test Failures (If Any)

If tests fail, automatically attempt to fix (up to 3 attempts):

```bash
if [ $TEST_RESULT -ne 0 ]; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Attempting to resolve test failures" >> $LOG_FILE
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ⚠️ Attempting to resolve test failures"

  # Run /test command which handles retries automatically
  # This is covered by your Claude Pro subscription
fi
```

Run `/test` if failures detected (auto-executed) - this will:
1. Analyze the test failures
2. Fix the issues
3. Re-run the tests
4. Repeat up to 3 times if needed

### Step 5: Run Frontend Type Checks

Automatically run TypeScript type checking:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Running frontend type checks"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running TypeScript checks" >> $LOG_FILE

cd app/client && bun tsc --noEmit
TS_RESULT=$?

if [ $TS_RESULT -eq 0 ]; then
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Frontend type checks: PASSED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] TypeScript checks PASSED" >> $LOG_FILE
else
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ❌ Frontend type checks: FAILED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] TypeScript checks FAILED" >> $LOG_FILE
fi
```

### Step 6: Run Frontend Build

Automatically validate frontend builds:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running frontend build" >> $LOG_FILE

cd app/client && bun run build
BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Frontend build: SUCCESS"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Frontend build SUCCESS" >> $LOG_FILE
else
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ❌ Frontend build: FAILED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Frontend build FAILED" >> $LOG_FILE
fi
```

### Step 7: Run E2E Tests (If Applicable)

Check if the plan file mentions E2E tests. If yes:

```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Checking for E2E test requirements" >> $LOG_FILE
```

Ask user: "The plan includes E2E tests. Would you like to run them now?"

If yes, run `/test_e2e` which will:
1. Start the application services
2. Run browser-based tests
3. Capture screenshots
4. Stop services
5. Report results

### Step 8: Update State and Complete

After all tests pass, automatically update state:

```bash
jq '.current_phase = "testing_complete"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Testing phase completed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Testing phase completed" >> $LOG_FILE
```

Tell the user:

"✅ Testing phase complete!

**What was validated:**
- ✅ Backend tests passing
- ✅ Frontend TypeScript checks passing
- ✅ Frontend build successful
- ✅ E2E tests passing (if applicable)

**Log file:** `agents/{adw_id}/logs/adw_guide_test_*.log`

**GitHub issue updated:** Issue #{issue_number} has been updated with test results

**Next steps:**
1. Review implementation: `/adw_guide_review {adw_id}`
2. Or skip to PR: `/adw_guide_pr {adw_id}`

**Cost so far:** $0 (covered by Claude Pro) ✨"

## Logging and Issue Updates

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in testing phase:
- `ops` - Operational messages (starting, completion)
- `test_runner` - Test execution messages

Common emojis:
- ✅ Success/passing
- ❌ Failure
- ⚠️ Warning/retrying

### Logging Pattern
Logs are created in `agents/{adw_id}/logs/adw_guide_test_{timestamp}.log` with entries like:
```
[2025-10-07T16:40:00Z] Testing phase started for issue #4
[2025-10-07T16:40:15Z] Running backend tests
[2025-10-07T16:41:00Z] Backend tests PASSED
[2025-10-07T16:41:05Z] Running TypeScript checks
[2025-10-07T16:41:30Z] TypeScript checks PASSED
[2025-10-07T16:41:35Z] Testing phase completed
```

## What to Do

- **DO** automatically run all test commands
- **DO** post test results to GitHub issues
- **DO** attempt automatic fixes for test failures
- **DO** create detailed test logs
- **DO** wait for user confirmation on E2E tests (may require visual validation)

## Error Handling

If no state file is found:
"No workflow state found. Please run `/adw_guide_plan` first."

If user is not on correct branch:
"You're not on the correct branch. Please checkout: `{branch_name}`"

If tests fail after retry attempts:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Tests failed after retries" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ❌ Tests failed after multiple attempts - manual intervention needed"
```
