# ADW Guide: Testing Phase (Intelligent Sub-Agent Automation)

Interactive guide with intelligent sub-agent delegation for maximum automation at $0 cost.

## Architecture Overview

This intelligent guide uses Claude Code's **SlashCommand tool** for critical testing operations that need artifact preservation, automating the entire testing workflow while staying at zero cost (covered by Claude Pro).

### Intelligent Architecture with Sub-Agents

```
Interactive Flow (this guide with sub-agents)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You (in Claude Code CLI)
├── /adw_guide_test
│   ├── Main orchestrator (this guide)
│   ├── Sub-agent: Load workflow state
│   ├── Sub-agent: Run backend tests (pytest)
│   ├── Sub-agent: Resolve failed backend tests (/resolve_failed_test)
│   ├── Sub-agent: Run frontend type checks (tsc)
│   ├── Sub-agent: Run frontend build (bun run build)
│   ├── Sub-agent: Run E2E tests (/test_e2e)
│   ├── Sub-agent: Resolve failed E2E tests
│   └── Sub-agent: Update state and commit results
│
All in ONE Claude Code session = $0 (Claude Pro)

Automated Flow (for reference - costs $$$)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trigger_webhook.py (FastAPI server)
├── subprocess.Popen → adw_test.py
    ├── subprocess.run → claude -p "/test"
    ├── subprocess.run → claude -p "/resolve_failed_test"
    ├── subprocess.run → claude -p "/test_e2e"
    ├── subprocess.run → claude -p "/resolve_failed_e2e_test"
    └── subprocess.run → claude -p "/commit"

Each subprocess = separate Claude API call = $$$
```

### Key Innovation: Task Tool for Sub-Agents

Instead of manually running each test command, we use the **Task tool** to delegate to specialized sub-agents:

```markdown
# Old approach (manual):
You run: pytest
You analyze failures manually
You run: /resolve_failed_test
You run: tsc --noEmit
You run: bun run build
...

# New approach (intelligent delegation):
Task tool spawns: "Run backend pytest suite"
Task tool spawns: "Resolve failed test {test_json}"
Task tool spawns: "Run frontend TypeScript checks"
Task tool spawns: "Run E2E test {test_file}"
...
```

**Benefits:**
- ✅ Fully automated - just provide ADW ID
- ✅ Sub-agents handle retries automatically
- ✅ Still $0 cost (same Claude Code session)
- ✅ More robust error handling
- ✅ Better progress tracking

## 🚨 CRITICAL: Logging and GitHub Comment Checklist 🚨

**FOR EVERY STEP, YOU MUST DO ALL OF THESE:**

### Before Starting a Step:
```bash
# 1. Log step start
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step {N}: Starting {step_name}" >> $LOG_FILE

# 2. Post GitHub comment (if appropriate)
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_{agent_name}: ⏳ {step_description}"

# 3. Update TodoWrite - mark step as "in_progress"
```

### While Doing the Step:
- Execute the actual work as described
- Log important events to `$LOG_FILE`

### After Completing a Step:
```bash
# 1. Log step completion
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step {N}: Completed {step_name}" >> $LOG_FILE

# 2. Post GitHub success comment
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_{agent_name}: ✅ {completion_message}"

# 3. Update TodoWrite - mark step {N} complete, step {N+1} in_progress
```

**IF YOU SKIP ANY OF THESE, THE WORKFLOW TRACKING WILL BE INCOMPLETE!**

## Instructions

**IMPORTANT:** This guide uses intelligent sub-agent delegation to automate the entire testing phase. Just provide an ADW ID and the guide orchestrates everything automatically.

**CRITICAL EXECUTION RULES:**
1. **Never stop until all 11 steps are complete** - Check your TodoWrite list after EVERY step
2. **Mark each step complete immediately** after finishing it using TodoWrite
3. **Automatically proceed to the next pending step** without waiting for user input
4. **Only ask the user questions** at Step 0 (ADW ID) - everything else runs automatically
5. **After ANY SlashCommand or tool execution completes**, immediately:
   - Log completion to `$LOG_FILE`
   - Post GitHub comment
   - Update your TodoWrite list (mark current step complete, next step in_progress)
   - Continue to the next pending step WITHOUT waiting for user input
   - Check your TodoWrite list to see what's next
   - DO NOT stop or pause - keep executing until all steps are complete
6. **Display final summary only** when Step 10 is marked "completed" in your TodoWrite list

**Why this matters:** The automated system (`adws/adw_test.py`) runs all steps sequentially without pausing. This interactive guide must match that behavior to provide the same experience. The slash commands now include auto-continuation instructions, so you MUST honor them and keep working.

### Step 0: Initialize and Load State (Automated with Sub-Agent)

Ask the user: "What is the ADW ID you want to test?" (or auto-detect from argument)

**As soon as user provides ADW ID, initialize TodoWrite tracking:**
Create todo list with all 11 steps:
0. Initialize and Load State
1. Run Backend Tests
2. Handle Backend Test Failures (if needed)
3. Run Frontend Type Checks
4. Run Frontend Build
5. Run E2E Tests
6. Handle E2E Test Failures (if needed)
7. Update State and Commit
8. Post Comprehensive Test Summary
9. Push Changes
10. Verify Logging and Comments

Mark Step 0 as "in_progress" immediately.

**BEFORE starting Step 0:**
Store ADW ID and initialize logging FIRST:

```bash
# CRITICAL: Create log file and store path in variable
ADW_ID="{user_provided_adw_id}"
# Create phase folder (matches automated system structure)
mkdir -p agents/$ADW_ID/adw_test
LOG_FILE="agents/$ADW_ID/adw_test/execution.log"

# Write initial log entry
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW Testing Phase Initialized" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW ID: $ADW_ID" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Log file: $LOG_FILE" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 0: Starting - Initialize and Load State" >> $LOG_FILE

# Display log file path for confirmation
echo "📝 Log file initialized: $LOG_FILE"
```

**CRITICAL:** Store `$LOG_FILE` path and use it in ALL subsequent steps.

Spawn a sub-agent to load state:

```markdown
# Use Task tool to delegate state loading
Task: Load workflow state
Subagent: general-purpose
Prompt: |
  Load the ADW workflow state and verify prerequisites.

  ADW ID: {adw_id}

  1. Load state from: agents/{adw_id}/adw_state.json
  2. Verify state exists and is valid
  3. Extract key information:
     - Issue number
     - Branch name
     - Current phase
     - Issue classification
  4. Verify we're on the correct git branch
  5. Return the state information

  File Reference: This mimics adws/adw_modules/state.py:ADWState.load()
```

**File Reference:**
- Automated: `adws/adw_modules/state.py:ADWState.load()` line 60-82
- Used by: `adws/adw_test.py` line 859
- Logging: `adws/adw_modules/utils.py:setup_logger()` line 56-80

**AFTER state loads:**
```bash
# Extract issue number from state
ISSUE_NUMBER="{issue_number_from_state}"
BRANCH_NAME="{branch_name_from_state}"

# Log state loaded
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 0: State loaded for issue #$ISSUE_NUMBER" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 0: Branch: $BRANCH_NAME" >> $LOG_FILE

# Post initial GitHub comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_ops: ✅ Starting testing phase"

# Log GitHub comment posted
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 0: Posted GitHub comment - Starting testing" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 0: Completed - Initialize and Load State" >> $LOG_FILE
```

Display workflow info to user:
```
✅ Testing workflow loaded
- ADW ID: {adw_id}
- Issue: #{issue_number}
- Branch: {branch_name}
- Phase: {current_phase}
```

**Update TodoWrite:** Mark Step 0 complete, Step 1 in_progress. Then immediately continue to Step 1.

### Step 1: Run Backend Tests (Automated with Sub-Agent)

**BEFORE starting Step 1:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Starting - Run Backend Tests" >> $LOG_FILE

# Post pre-test status
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ⏳ Running backend tests"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Posted GitHub comment - Backend tests starting" >> $LOG_FILE
```

**What This Step Does:**
- Spawns a sub-agent to run pytest
- Mimics `adws/adw_test.py:run_tests()`
- Handles test execution and result parsing

Delegate backend test execution to sub-agent:

```markdown
# Use Task tool to delegate backend testing
Task: Run backend test suite
Subagent: general-purpose
Prompt: |
  Run the backend test suite using pytest.

  1. Navigate to app/server directory
  2. Run: uv run pytest
  3. Capture the test output and results
  4. Parse the results to identify:
     - Total tests run
     - Tests passed
     - Tests failed
     - Failure details (test name, error message, execution command)
  5. Return results in JSON format

  File Reference: This mimics adws/adw_test.py:run_tests() line 219-238
```

**File Reference:**
- Automated: `adws/adw_test.py:run_tests()` line 219-238
- Calls: `adws/adw_modules/agent.py:execute_template("/test")` line 262-299
- Executes: `.claude/commands/test.md`

Store the test results.

**AFTER tests complete:**
```bash
# Log test results
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Backend tests completed - Passed: $PASSED_COUNT, Failed: $FAILED_COUNT" >> $LOG_FILE

# Post test results
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ✅ Backend tests: $PASSED_COUNT passed, $FAILED_COUNT failed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Posted GitHub comment - Test results" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Completed - Run Backend Tests" >> $LOG_FILE
```

**Update TodoWrite:** Mark Step 1 complete, Step 2 in_progress. Then immediately continue to Step 2.

### Step 2: Handle Backend Test Failures (Automated with SlashCommand)

**BEFORE starting Step 2:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Starting - Handle Backend Test Failures" >> $LOG_FILE
```

**What This Step Does:**
- If tests fail, automatically attempt to resolve them
- Mimics `adws/adw_test.py:resolve_failed_tests()`
- Retries up to MAX_TEST_RETRY_ATTEMPTS (4 attempts)

If failed_count > 0, iterate through each failed test:

```bash
# Log resolution attempt
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Attempting to resolve $FAILED_COUNT failed tests" >> $LOG_FILE

# Post resolution starting
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_resolver: ⏳ Resolving $FAILED_COUNT failed tests"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Posted GitHub comment - Resolution starting" >> $LOG_FILE

# Use SlashCommand tool to create agent artifacts
/resolve_failed_test '{test_json}'
```

This will automatically:
1. Create: `agents/{adw_id}/test_resolver/prompts/resolve_failed_test.txt`
2. Create: `agents/{adw_id}/test_resolver/raw_output.jsonl`
3. Create: `agents/{adw_id}/test_resolver/raw_output.json`
4. Analyze the test failure details
5. Review recent changes that might have caused the failure
6. Make targeted fixes to resolve the issue
7. Re-run the specific test to verify the fix
8. Return success/failure status

**IMPORTANT:** Only fix this specific test. Do not modify other tests.

**File Reference:**
- Automated: `adws/adw_test.py:resolve_failed_tests()` line 308-377
- Calls: `adws/adw_modules/agent.py:execute_template("/resolve_failed_test")` line 262-299
- Executes: `.claude/commands/resolve_failed_test.md`

**AFTER resolution attempts:**
```bash
# Log resolution results
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Resolution complete - Resolved: $RESOLVED_COUNT" >> $LOG_FILE

if [ $RESOLVED_COUNT -gt 0 ]; then
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_resolver: ✅ Resolved $RESOLVED_COUNT/$FAILED_COUNT failed tests"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Posted GitHub comment - Tests resolved, re-running" >> $LOG_FILE

  # Re-run tests (go back to Step 1)
else
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_resolver: ❌ Could not resolve failed tests"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Posted GitHub comment - Resolution failed" >> $LOG_FILE
fi

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Completed - Handle Backend Test Failures" >> $LOG_FILE
```

**Retry Logic:**
- If tests resolved, go back to Step 1 (max 4 total attempts)
- If no tests resolved or max attempts reached, continue to next step

**Update TodoWrite:** Mark Step 2 complete, Step 3 in_progress. Then immediately continue to Step 3.

### Step 3: Run Frontend Type Checks (Automated with Sub-Agent)

**BEFORE starting Step 3:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Starting - Run Frontend Type Checks" >> $LOG_FILE

# Post pre-check status
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ⏳ Running frontend type checks"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Posted GitHub comment - Type checks starting" >> $LOG_FILE
```

**What This Step Does:**
- Spawns a sub-agent to run TypeScript type checking
- Validates frontend code correctness

Delegate TypeScript checks to sub-agent:

```markdown
# Use Task tool to delegate TypeScript checking
Task: Run frontend TypeScript type checks
Subagent: general-purpose
Prompt: |
  Run TypeScript type checking for the frontend.

  1. Navigate to app/client directory
  2. Run: bun tsc --noEmit
  3. Capture the output
  4. Determine if type checking passed or failed
  5. If failed, capture the error details
  6. Return status: "passed" or "failed"

  File Reference: This mimics the TypeScript check portion of adws/adw_test.py
```

**AFTER type checks complete:**
```bash
# Log type check results
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: TypeScript checks: $TS_STATUS" >> $LOG_FILE

if [ "$TS_STATUS" == "passed" ]; then
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ✅ Frontend type checks: PASSED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Posted GitHub comment - Type checks passed" >> $LOG_FILE
else
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ❌ Frontend type checks: FAILED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Posted GitHub comment - Type checks failed" >> $LOG_FILE
  # Note: In automated system, TS failures don't stop the workflow
fi

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Completed - Run Frontend Type Checks" >> $LOG_FILE
```

**Update TodoWrite:** Mark Step 3 complete, Step 4 in_progress. Then immediately continue to Step 4.

### Step 4: Run Frontend Build (Automated with Sub-Agent)

**BEFORE starting Step 4:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Starting - Run Frontend Build" >> $LOG_FILE

# Post pre-build status
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ⏳ Running frontend build"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Posted GitHub comment - Build starting" >> $LOG_FILE
```

**What This Step Does:**
- Spawns a sub-agent to run frontend build
- Validates that frontend compiles successfully

Delegate frontend build to sub-agent:

```markdown
# Use Task tool to delegate frontend build
Task: Run frontend build
Subagent: general-purpose
Prompt: |
  Build the frontend application.

  1. Navigate to app/client directory
  2. Run: bun run build
  3. Capture the output
  4. Determine if build succeeded or failed
  5. If failed, capture the error details
  6. Return status: "success" or "failed"

  File Reference: This mimics the build check portion of adws/adw_test.py
```

**AFTER build completes:**
```bash
# Log build results
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Frontend build: $BUILD_STATUS" >> $LOG_FILE

if [ "$BUILD_STATUS" == "success" ]; then
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ✅ Frontend build: SUCCESS"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Posted GitHub comment - Build success" >> $LOG_FILE
else
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ❌ Frontend build: FAILED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Posted GitHub comment - Build failed" >> $LOG_FILE
fi

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Completed - Run Frontend Build" >> $LOG_FILE
```

**Update TodoWrite:** Mark Step 4 complete, Step 5 in_progress. Then immediately continue to Step 5.

### Step 5: Run E2E Tests (Automated with SlashCommand)

**BEFORE starting Step 5:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Starting - Run E2E Tests" >> $LOG_FILE
```

**What This Step Does:**
- If unit tests passed, run E2E browser tests
- Mimics `adws/adw_test.py:run_e2e_tests()`
- Uses Playwright for browser automation

Skip E2E tests if unit tests failed:

```bash
if [ $FAILED_COUNT -gt 0 ]; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Skipping E2E tests due to unit test failures" >> $LOG_FILE
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_ops: ⚠️ Skipping E2E tests due to unit test failures"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Posted GitHub comment - E2E tests skipped" >> $LOG_FILE
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Completed - Run E2E Tests (skipped)" >> $LOG_FILE
  # Skip to Step 7
fi
```

Otherwise, run E2E tests:

```bash
# Post E2E starting
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_e2e_test_runner: ⏳ Starting E2E tests"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Posted GitHub comment - E2E tests starting" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Running E2E tests" >> $LOG_FILE
```

Find and run each E2E test file sequentially:

```bash
# Use SlashCommand tool to create agent artifacts
/test_e2e {adw_id} e2e_test_runner_0_{idx} {test_file}
```

This will automatically:
1. Create: `agents/{adw_id}/e2e_test_runner_0_{idx}/prompts/test_e2e.txt`
2. Create: `agents/{adw_id}/e2e_test_runner_0_{idx}/raw_output.jsonl`
3. Create: `agents/{adw_id}/e2e_test_runner_0_{idx}/raw_output.json`
4. Read the E2E test file
5. Start Playwright browser in headed mode
6. Execute the test steps
7. Capture screenshots at specified points
8. Save screenshots to: `agents/{adw_id}/e2e_test_runner_0_{idx}/img/`
9. Return results in JSON format

**IMPORTANT:** Stop on first E2E test failure.

**File Reference:**
- Automated: `adws/adw_test.py:run_e2e_tests()` line 489-521
- Executes: `adws/adw_test.py:execute_single_e2e_test()` line 524-610
- Calls: `adws/adw_modules/agent.py:execute_template("/test_e2e")` line 262-299
- Executes: `.claude/commands/test_e2e.md`

**AFTER E2E tests complete:**
```bash
# Log E2E results
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: E2E tests completed - Passed: $E2E_PASSED_COUNT, Failed: $E2E_FAILED_COUNT" >> $LOG_FILE

# Post E2E results
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_e2e_test_runner: ✅ E2E tests: $E2E_PASSED_COUNT passed, $E2E_FAILED_COUNT failed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Posted GitHub comment - E2E results" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Completed - Run E2E Tests" >> $LOG_FILE
```

**Update TodoWrite:** Mark Step 5 complete, Step 6 in_progress. Then immediately continue to Step 6.

### Step 6: Handle E2E Test Failures (Automated with SlashCommand)

**BEFORE starting Step 6:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Starting - Handle E2E Test Failures" >> $LOG_FILE
```

**What This Step Does:**
- If E2E tests fail, automatically attempt to resolve them
- Mimics `adws/adw_test.py:resolve_failed_e2e_tests()`
- Retries up to MAX_E2E_TEST_RETRY_ATTEMPTS (2 attempts)

If E2E tests failed, iterate through each failed test:

```bash
# Log E2E resolution attempt
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Attempting to resolve $E2E_FAILED_COUNT failed E2E tests" >> $LOG_FILE

# Post resolution starting
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_e2e_test_resolver: ⏳ Resolving $E2E_FAILED_COUNT failed E2E tests"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Posted GitHub comment - E2E resolution starting" >> $LOG_FILE

# Use SlashCommand tool to create agent artifacts
/resolve_failed_e2e_test '{e2e_test_json}'
```

This will automatically:
1. Create: `agents/{adw_id}/e2e_test_resolver/prompts/resolve_failed_e2e_test.txt`
2. Create: `agents/{adw_id}/e2e_test_resolver/raw_output.jsonl`
3. Create: `agents/{adw_id}/e2e_test_resolver/raw_output.json`
4. Analyze the E2E test failure details
5. Review the test steps and screenshots
6. Identify what went wrong in the UI/functionality
7. Make targeted fixes to resolve the issue
8. Return success/failure status

**IMPORTANT:** Only fix issues related to this specific E2E test.

**File Reference:**
- Automated: `adws/adw_test.py:resolve_failed_e2e_tests()` line 662-731
- Calls: `adws/adw_modules/agent.py:execute_template("/resolve_failed_e2e_test")` line 262-299
- Executes: `.claude/commands/resolve_failed_e2e_test.md`

**AFTER E2E resolution attempts:**
```bash
# Log E2E resolution results
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: E2E resolution complete - Resolved: $E2E_RESOLVED_COUNT" >> $LOG_FILE

if [ $E2E_RESOLVED_COUNT -gt 0 ]; then
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_e2e_test_resolver: ✅ Resolved $E2E_RESOLVED_COUNT/$E2E_FAILED_COUNT failed E2E tests"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Posted GitHub comment - E2E tests resolved, re-running" >> $LOG_FILE

  # Re-run E2E tests (go back to Step 5)
else
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_e2e_test_resolver: ❌ Could not resolve E2E test failures"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Posted GitHub comment - E2E resolution failed" >> $LOG_FILE
fi

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Completed - Handle E2E Test Failures" >> $LOG_FILE
```

**Retry Logic:**
- If E2E tests resolved, go back to Step 5 (max 2 total attempts)
- If no tests resolved or max attempts reached, continue to next step

**Update TodoWrite:** Mark Step 6 complete, Step 7 in_progress. Then immediately continue to Step 7.

### Step 7: Update State and Commit (Automated with SlashCommand)

**BEFORE starting Step 7:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Starting - Update State and Commit" >> $LOG_FILE

# Post pre-commit status
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ⏳ Committing test results"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Posted GitHub comment - Committing results" >> $LOG_FILE
```

**What This Step Does:**
- Updates state file with test results
- Creates commit with test results
- Prepares for push

Delegate commit creation using SlashCommand:

```bash
# Extract type from state (should be "feature", "bug", or "chore" WITHOUT slash)
ISSUE_CLASS="{issue_class_from_state_without_slash}"

# Get issue JSON for commit context
ISSUE_JSON=$(gh issue view $ISSUE_NUMBER --json number,title,body)

# Use SlashCommand tool to create agent artifacts
/commit test_runner $ISSUE_CLASS "$ISSUE_JSON"
```

This will automatically:
1. Create: `agents/{adw_id}/test_runner/prompts/commit.txt`
2. Create: `agents/{adw_id}/test_runner/raw_output.jsonl`
3. Create: `agents/{adw_id}/test_runner/raw_output.json`
4. Stage all changes (git add .)
5. Analyze the test-related changes
6. Generate semantic commit message following project conventions
7. Create commit with proper attribution
8. Return the commit SHA

**File Reference:**
- Automated: `adws/adw_test.py:create_commit()` line 1033
- Calls: `adws/adw_modules/workflow_ops.py:create_commit()` line 238-272
- Executes: `.claude/commands/commit.md`

**AFTER commit completes:**
```bash
# Log commit created
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Commit created" >> $LOG_FILE

# Update state
jq '.current_phase = "testing_complete"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: State updated to testing_complete" >> $LOG_FILE

# Post commit success
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_test_runner: ✅ Test results committed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Posted GitHub comment - Committed" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Completed - Update State and Commit" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_modules/state.py:ADWState.save()` line 38-58

**Update TodoWrite:** Mark Step 7 complete, Step 8 in_progress. Then immediately continue to Step 8.

### Step 8: Post Comprehensive Test Summary (Automated)

**BEFORE starting Step 8:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Starting - Post Comprehensive Test Summary" >> $LOG_FILE
```

**What This Step Does:**
- Posts detailed test summary to GitHub issue
- Mimics `adws/adw_test.py:log_test_results()`

```bash
# Create comprehensive summary
SUMMARY="[ADW-BOT] {adw_id}_test_summary: 📊 Test Run Summary

## Unit Tests
**Total Tests:** $TOTAL_TESTS
**Passed:** $PASSED_COUNT ✅
**Failed:** $FAILED_COUNT ❌

## E2E Tests
**Total Tests:** $TOTAL_E2E_TESTS
**Passed:** $E2E_PASSED_COUNT ✅
**Failed:** $E2E_FAILED_COUNT ❌

## Frontend Checks
**TypeScript:** $TS_STATUS
**Build:** $BUILD_STATUS

## Overall Status
$OVERALL_STATUS_EMOJI $OVERALL_MESSAGE"

gh issue comment $ISSUE_NUMBER --body "$SUMMARY"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Posted comprehensive test summary" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Completed - Post Comprehensive Test Summary" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_test.py:log_test_results()` line 149-217

**Update TodoWrite:** Mark Step 8 complete, Step 9 in_progress. Then immediately continue to Step 9.

### Step 9: Push Changes (Automated)

**BEFORE starting Step 9:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Starting - Push Changes" >> $LOG_FILE
```

**What This Step Does:**
- Pushes changes to remote
- Updates PR if it exists

```bash
# Push changes
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Pushing changes" >> $LOG_FILE
git push

# Update PR if it exists
gh pr view &>/dev/null && gh pr comment --body "[ADW-BOT] {adw_id}_ops: ✅ Test results committed and pushed"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Changes pushed" >> $LOG_FILE

# Post push success
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_ops: ✅ Changes pushed to branch"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Posted GitHub comment - Pushed" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Completed - Push Changes" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_modules/git_ops.py:finalize_git_operations()` line 80-139

**Update TodoWrite:** Mark Step 9 complete, Step 10 in_progress. Then immediately continue to Step 10.

### Step 10: Verify Logging and Comments (FINAL CHECK) ✅

**BEFORE starting Step 10:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 10: Starting - Verify Logging and Comments" >> $LOG_FILE
```

**What This Step Does:**
- Verifies all logging was captured
- Verifies GitHub comments were posted
- Final validation before completion

Verify logging and comments:
```bash
# Verify log file exists and has entries
if [ ! -f "$LOG_FILE" ]; then
  echo "❌ ERROR: Log file not found at $LOG_FILE"
  exit 1
fi

# Count log entries
LOG_ENTRIES=$(wc -l < "$LOG_FILE")
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 10: Log file has $LOG_ENTRIES entries" >> $LOG_FILE

# Show log summary to user
echo "=== Testing Log Summary ==="
echo "Log file: $LOG_FILE"
echo "Total entries: $LOG_ENTRIES"
echo ""
echo "Recent entries:"
tail -10 "$LOG_FILE"

# Verify GitHub comments were posted
echo ""
echo "=== GitHub Comments Verification ==="
echo "Checking issue #$ISSUE_NUMBER for ADW-BOT comments..."
gh issue view $ISSUE_NUMBER --comments | grep "ADW-BOT.*{adw_id}" | tail -10

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 10: Completed - Verify Logging and Comments" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ALL STEPS COMPLETE - Testing phase successful" >> $LOG_FILE
```

**Update TodoWrite:** Mark Step 10 complete. Verify ALL 11 steps (0-10) show "completed" status.

**FINAL STEP:** You are now DONE with the testing phase. All 11 steps are complete.

Display comprehensive summary to user:

```markdown
✅ Testing phase complete!

**Test Results:**
- Backend tests: {passed_count} passed, {failed_count} failed
- Frontend type checks: {ts_status}
- Frontend build: {build_status}
- E2E tests: {e2e_passed_count} passed, {e2e_failed_count} failed

**Artifacts created (identical to automated system):**
```
agents/{adw_id}/
├── adw_state.json                           # Updated state
├── adw_test/                                # PHASE folder for testing
│   └── execution.log                        # Phase-level log (matches automated)
├── test_runner/                             # AGENT folder (test runner artifacts)
│   ├── prompts/
│   │   └── commit.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
├── test_resolver_iter1_0/                   # AGENT folder (test resolution artifacts)
│   ├── prompts/
│   │   └── resolve_failed_test.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
└── e2e_test_runner_0_0/                     # AGENT folder (E2E test artifacts)
    ├── prompts/
    │   └── test_e2e.txt
    ├── raw_output.jsonl
    ├── raw_output.json
    └── img/                                 # E2E screenshots
        └── {test_name}/
            ├── 01_screenshot.png
            └── 02_screenshot.png
```

**Folder Structure Notes:**
- **PHASE folders** (`adw_test/`): Created by us, contain phase execution logs
- **AGENT folders** (`test_runner/`, `e2e_test_runner_0_0/`): Created automatically by SlashCommand tool
- **Iteration naming**: Test resolvers increment (iter1, iter2, etc.) for multiple retry attempts
```

**Logging verification:**
- Log file: `{log_file}`
- Total log entries: {log_entry_count}
- All steps logged ✅

**GitHub issue tracking:**
- Issue #{issue_number} updated with {comment_count} ADW-BOT comments
- All major milestones tracked ✅

**Sub-agents spawned (all in same session = $0):**
1. ✅ State loader
2. ✅ Backend test runner
3. ✅ Test failure resolver (x{resolution_attempts})
4. ✅ TypeScript checker
5. ✅ Frontend builder
6. ✅ E2E test runner
7. ✅ E2E test resolver (x{e2e_resolution_attempts})
8. ✅ Commit creator

**Next steps:**
1. Review test results: Check the issue for details
2. If all tests passed: `/adw_guide_review {adw_id}`
3. If tests failed: Review failures and decide on next steps

**Cost so far:** $0 (all sub-agents in Claude Pro session) ✨

**Time saved:** ~15-20 minutes of manual test execution and debugging!
```

## Intelligent Architecture Comparison

### Old Interactive Mode (Manual Test Execution)
```
Claude Code CLI Session
├── You manually run: pytest
├── Check for failures
├── You manually fix each test
├── Re-run pytest
├── You manually run: tsc --noEmit
├── You manually run: bun run build
├── You manually run E2E tests
└── You manually commit results

Time: ~20-30 minutes of manual work
Cost: $0 (Claude Pro)
Logging: Manual (often forgotten)
GitHub comments: Manual (often forgotten)
```

### New Intelligent Mode (Sub-Agent Delegation with Tracking)
```
Claude Code CLI Session
├── You run: /adw_guide_test {adw_id}
├── Auto-initialize: Logging and GitHub tracking
├── Task spawns: Backend test runner (runs automatically + logs)
├── Task spawns: Test failure resolver (runs automatically, retries + logs)
├── Task spawns: TypeScript checker (runs automatically + logs)
├── Task spawns: Frontend builder (runs automatically + logs)
├── Task spawns: E2E test runner (runs automatically + logs)
├── Task spawns: E2E test resolver (runs automatically, retries + logs)
├── Task spawns: Commit creator (runs automatically + logs)
└── Auto-verify: All logs and comments created

Time: ~5-7 minutes (mostly automated)
Cost: $0 (all sub-agents in same Claude Pro session)
Logging: Automatic, complete, timestamped
GitHub comments: Automatic at every step
```

### Automated Mode (External Processes - For Reference)
```
trigger_webhook.py (FastAPI server)
├── subprocess.Popen → adw_test.py
    ├── subprocess.run → claude -p "/test"                      $$
    ├── subprocess.run → claude -p "/resolve_failed_test"       $$
    ├── subprocess.run → claude -p "/test_e2e"                  $$
    ├── subprocess.run → claude -p "/resolve_failed_e2e_test"   $$
    └── subprocess.run → claude -p "/commit"                    $$

Time: ~10-15 minutes (fully automated)
Cost: $$$ (5+ separate Claude API calls)
Logging: Automatic
GitHub comments: Automatic
```

## Variables

- `$1` = ADW ID (required)

## Logging and Issue Updates

### Log File Format
All logs are created in `agents/{adw_id}/adw_test/execution.log` (matches automated system) with timestamped entries:
```
[2025-10-22T17:19:24Z] ========================================
[2025-10-22T17:19:24Z] ADW Testing Phase Initialized
[2025-10-22T17:19:24Z] ADW ID: 61d49d73
[2025-10-22T17:19:24Z] ========================================
[2025-10-22T17:19:25Z] Step 0: Starting - Initialize and Load State
[2025-10-22T17:19:26Z] Step 0: State loaded for issue #20
[2025-10-22T17:19:26Z] Step 0: Completed - Initialize and Load State
...
[2025-10-22T17:35:00Z] ALL STEPS COMPLETE - Testing phase successful
```

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in testing phase:
- `ops` - Operational messages (starting, completion, state)
- `test_runner` - Backend/frontend test messages
- `test_resolver` - Backend test resolution messages
- `e2e_test_runner` - E2E test messages
- `e2e_test_resolver` - E2E test resolution messages
- `test_summary` - Final test summary

Common emojis:
- ✅ Success/completion
- ⏳ In progress
- ❌ Error/failure
- ⚠️ Warning
- 📊 Summary/statistics

Example sequence of comments for a successful test run:
```
[ADW-BOT] 61d49d73_ops: ✅ Starting testing phase
[ADW-BOT] 61d49d73_test_runner: ⏳ Running backend tests
[ADW-BOT] 61d49d73_test_runner: ✅ Backend tests: 67 passed, 0 failed
[ADW-BOT] 61d49d73_test_runner: ⏳ Running frontend type checks
[ADW-BOT] 61d49d73_test_runner: ✅ Frontend type checks: PASSED
[ADW-BOT] 61d49d73_test_runner: ⏳ Running frontend build
[ADW-BOT] 61d49d73_test_runner: ✅ Frontend build: SUCCESS
[ADW-BOT] 61d49d73_e2e_test_runner: ⏳ Starting E2E tests
[ADW-BOT] 61d49d73_e2e_test_runner: ✅ E2E tests: 1 passed, 0 failed
[ADW-BOT] 61d49d73_test_runner: ⏳ Committing test results
[ADW-BOT] 61d49d73_test_runner: ✅ Test results committed
[ADW-BOT] 61d49d73_ops: ✅ Changes pushed to branch
[ADW-BOT] 61d49d73_test_summary: 📊 Test Run Summary ...
```

## Key Advantages of Sub-Agent Approach

1. **Fully Automated**: Just provide ADW ID, everything else is handled
2. **Intelligent Delegation**: Sub-agents handle complex testing tasks independently
3. **Automatic Retries**: Failed tests are resolved and re-run automatically
4. **Better Error Handling**: Sub-agents can analyze and fix test failures
5. **Zero Cost**: All sub-agents run in same Claude Pro session
6. **Identical Artifacts**: Produces same output as expensive automated system
7. **Complete Tracking**: Full logging and GitHub comments
8. **Time Savings**: ~20 minutes of manual work → ~5 minutes automated

## What to Do

- **DO** initialize logging FIRST (Step 0)
- **DO** log every step start and completion to `$LOG_FILE`
- **DO** post GitHub comments at major milestones
- **DO** use Task tool for test execution and resolution
- **DO** let sub-agents handle test failures and retries
- **DO** run tests sequentially (backend → frontend → E2E)
- **DO** keep user informed of test progress
- **DO** create same artifacts as automated system
- **DO** post comprehensive test summaries to GitHub
- **DO** verify logging and comments at the end

## What NOT to Do

- **DON'T** skip Step 0 (logging initialization)
- **DON'T** forget to log step start/completion
- **DON'T** forget to post GitHub comments
- **DON'T** spawn external processes (costs money)
- **DON'T** manually analyze test failures when sub-agent can do it
- **DON'T** skip E2E tests if unit tests pass
- **DON'T** continue E2E tests if unit tests fail
- **DON'T** call Anthropic API directly (Claude Code handles it)
- **DON'T** forget to update TodoWrite after each step

## File References Summary

All file references point to the actual automated system implementation:

- **Test Orchestrator**: `adws/adw_test.py`
- **Test Execution**: `adws/adw_test.py:run_tests()` line 219-238
- **Test Resolution**: `adws/adw_test.py:resolve_failed_tests()` line 308-377
- **E2E Test Execution**: `adws/adw_test.py:run_e2e_tests()` line 489-521
- **E2E Test Resolution**: `adws/adw_test.py:resolve_failed_e2e_tests()` line 662-731
- **Workflow Operations**: `adws/adw_modules/workflow_ops.py`
- **Agent Execution**: `adws/adw_modules/agent.py`
- **State Management**: `adws/adw_modules/state.py`
- **Git Operations**: `adws/adw_modules/git_ops.py`
- **GitHub API**: `adws/adw_modules/github.py`
- **Utilities**: `adws/adw_modules/utils.py` (logging setup line 56-80)
- **Slash Commands**:
  - `.claude/commands/test.md`
  - `.claude/commands/resolve_failed_test.md`
  - `.claude/commands/test_e2e.md`
  - `.claude/commands/resolve_failed_e2e_test.md`
  - `.claude/commands/commit.md`

## The Bottom Line

This intelligent guide with sub-agent delegation gives you:

✨ **The automation of the $$ webhook system**
✨ **The zero cost of interactive Claude Pro**
✨ **The reliability of automatic test retry logic**
✨ **The intelligence of sub-agent error resolution**
✨ **Complete logging and GitHub tracking**
✨ **Verification that nothing was missed**

All in one Claude Code session! 🚀
