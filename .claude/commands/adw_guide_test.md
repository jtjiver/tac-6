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

## Instructions

**IMPORTANT:** This guide uses intelligent sub-agent delegation to automate the entire testing phase. Just provide an ADW ID and the guide orchestrates everything automatically.

**CRITICAL EXECUTION RULES:**
1. **Never stop until all 9 steps are complete** - Check your TodoWrite list after EVERY step
2. **Mark each step complete immediately** after finishing it using TodoWrite
3. **Automatically proceed to the next pending step** without waiting for user input
4. **Only ask the user questions** at Step 1 (ADW ID) - everything else runs automatically
5. **After ANY SlashCommand or tool execution completes**, immediately:
   - Update your TodoWrite list (mark current step complete, next step in_progress)
   - Continue to the next pending step WITHOUT waiting for user input
   - Check your TodoWrite list to see what's next
   - DO NOT stop or pause - keep executing until all steps are complete
6. **Display final summary only** when Step 9 is marked "completed" in your TodoWrite list

**Why this matters:** The automated system (`adws/adw_test.py`) runs all steps sequentially without pausing. This interactive guide must match that behavior to provide the same experience. The slash commands now include auto-continuation instructions, so you MUST honor them and keep working.

### Step 1: Load State and Initialize (Automated with Sub-Agent)

Ask the user: "What is the ADW ID you want to test?" (or auto-detect from argument)

**Initialize TodoWrite tracking:**
Create todo list with all 9 steps:
1. Load State and Initialize
2. Run Backend Tests
3. Handle Backend Test Failures
4. Run Frontend Type Checks
5. Run Frontend Build
6. Run E2E Tests
7. Handle E2E Test Failures
8. Update State and Commit
9. Post Comprehensive Test Summary

Mark Step 1 as "in_progress" immediately.

Once provided, spawn a sub-agent to load state:

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
  5. Return the state information in JSON format

  File Reference: This mimics adws/adw_modules/state.py:ADWState.load()
```

**File Reference:**
- Automated: `adws/adw_modules/state.py:ADWState.load()` line 60-82
- Used by: `adws/adw_test.py` line 859

Initialize logging:

```bash
# This mimics: adws/adw_modules/utils.py:setup_logger()
mkdir -p agents/{adw_id}/logs
LOG_FILE="agents/{adw_id}/logs/adw_guide_test_$(date +%s).log"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Testing phase started for issue #{issue_number}" >> $LOG_FILE

# Post to GitHub
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting testing phase"
```

**File Reference:**
- Logging: `adws/adw_modules/utils.py:setup_logger()` line 56-80

Display workflow info to user:
```
✅ Testing workflow loaded
- ADW ID: {adw_id}
- Issue: #{issue_number}
- Branch: {branch_name}
- Phase: {current_phase}
```

### Step 2: Run Backend Tests (Automated with Sub-Agent)

**What This Step Does:**
- Spawns a sub-agent to run pytest
- Mimics `adws/adw_test.py:run_tests()`
- Handles test execution and result parsing

Post pre-test status:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Running backend tests"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running backend tests" >> $LOG_FILE
```

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
  5. Return results in JSON format:
  ```json
  [
    {
      "test_name": "test_example",
      "passed": false,
      "error": "AssertionError: ...",
      "test_path": "tests/test_example.py",
      "execution_command": "cd app/server && uv run pytest tests/test_example.py::test_example"
    }
  ]
  ```

  File Reference: This mimics adws/adw_test.py:run_tests() line 219-238
```

**File Reference:**
- Automated: `adws/adw_test.py:run_tests()` line 219-238
- Calls: `adws/adw_modules/agent.py:execute_template("/test")` line 262-299
- Executes: `.claude/commands/test.md`

Store the test results.

**IMPORTANT:** Mark Step 2 as completed in TodoWrite and immediately proceed to Step 3. DO NOT wait for user input.

### Step 3: Handle Backend Test Failures (Automated with Sub-Agent)

**What This Step Does:**
- If tests fail, automatically attempt to resolve them
- Mimics `adws/adw_test.py:resolve_failed_tests()`
- Retries up to MAX_TEST_RETRY_ATTEMPTS (4 attempts)

If failed_count > 0, iterate through each failed test:

```bash
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

Post resolution status:

```bash
if [ $resolved_count -gt 0 ]; then
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_resolver: ✅ Resolved {resolved_count}/{failed_count} failed tests"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Resolved {resolved_count} tests, re-running" >> $LOG_FILE

  # Re-run tests (go back to Step 2)
else
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_resolver: ❌ Could not resolve failed tests"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Test resolution failed" >> $LOG_FILE
fi
```

**Retry Logic:**
- If tests resolved, go back to Step 2 (max 4 total attempts)
- If no tests resolved or max attempts reached, continue to next step

**IMPORTANT:** Mark Step 3 as completed in TodoWrite and immediately proceed to Step 4. DO NOT wait for user input.

### Step 4: Run Frontend Type Checks (Automated with Sub-Agent)

**What This Step Does:**
- Spawns a sub-agent to run TypeScript type checking
- Validates frontend code correctness

Post pre-check status:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Running frontend type checks"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running TypeScript checks" >> $LOG_FILE
```

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

Post result:

```bash
if [ $TS_RESULT -eq 0 ]; then
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Frontend type checks: PASSED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] TypeScript checks PASSED" >> $LOG_FILE
else
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ❌ Frontend type checks: FAILED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] TypeScript checks FAILED" >> $LOG_FILE
  # Note: In automated system, TS failures don't stop the workflow
fi
```

**IMPORTANT:** Mark Step 4 as completed in TodoWrite and immediately proceed to Step 5. DO NOT wait for user input.

### Step 5: Run Frontend Build (Automated with Sub-Agent)

**What This Step Does:**
- Spawns a sub-agent to run frontend build
- Validates that frontend compiles successfully

Post pre-build status:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Running frontend build"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running frontend build" >> $LOG_FILE
```

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

Post result:

```bash
if [ $BUILD_RESULT -eq 0 ]; then
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Frontend build: SUCCESS"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Frontend build SUCCESS" >> $LOG_FILE
else
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ❌ Frontend build: FAILED"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Frontend build FAILED" >> $LOG_FILE
fi
```

**IMPORTANT:** Mark Step 5 as completed in TodoWrite and immediately proceed to Step 6. DO NOT wait for user input.

### Step 6: Run E2E Tests (Automated with Sub-Agent)

**What This Step Does:**
- If unit tests passed, run E2E browser tests
- Mimics `adws/adw_test.py:run_e2e_tests()`
- Uses Playwright for browser automation

Skip E2E tests if unit tests failed:

```bash
if [ $failed_count -gt 0 ]; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Skipping E2E tests due to unit test failures" >> $LOG_FILE
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ⚠️ Skipping E2E tests due to unit test failures"
  # Skip to Step 8
fi
```

Otherwise, run E2E tests:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_e2e_test_runner: ✅ Starting E2E tests"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running E2E tests" >> $LOG_FILE
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
9. Return results in JSON format:
```json
{
  "test_name": "test_name",
  "status": "passed|failed",
  "test_path": "{test_file}",
  "screenshots": ["path1.png", "path2.png"],
  "error": null
}
```

**IMPORTANT:** Stop on first E2E test failure.

**File Reference:**
- Automated: `adws/adw_test.py:run_e2e_tests()` line 489-521
- Executes: `adws/adw_test.py:execute_single_e2e_test()` line 524-610
- Calls: `adws/adw_modules/agent.py:execute_template("/test_e2e")` line 262-299
- Executes: `.claude/commands/test_e2e.md`

Store E2E test results.

**IMPORTANT:** Mark Step 6 as completed in TodoWrite and immediately proceed to Step 7. DO NOT wait for user input.

### Step 7: Handle E2E Test Failures (Automated with Sub-Agent)

**What This Step Does:**
- If E2E tests fail, automatically attempt to resolve them
- Mimics `adws/adw_test.py:resolve_failed_e2e_tests()`
- Retries up to MAX_E2E_TEST_RETRY_ATTEMPTS (2 attempts)

If E2E tests failed, iterate through each failed test:

```bash
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

Post resolution status:

```bash
if [ $resolved_count -gt 0 ]; then
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_e2e_test_resolver: ✅ Resolved {resolved_count}/{e2e_failed_count} failed E2E tests"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Resolved {resolved_count} E2E tests, re-running" >> $LOG_FILE

  # Re-run E2E tests (go back to Step 6)
else
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_e2e_test_resolver: ❌ Could not resolve E2E test failures"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] E2E test resolution failed" >> $LOG_FILE
fi
```

**Retry Logic:**
- If E2E tests resolved, go back to Step 6 (max 2 total attempts)
- If no tests resolved or max attempts reached, continue to next step

**IMPORTANT:** Mark Step 7 as completed in TodoWrite and immediately proceed to Step 8. DO NOT wait for user input.

### Step 8: Update State and Commit (Automated with Sub-Agent)

**What This Step Does:**
- Updates state file with test results
- Creates commit with test results
- Pushes changes and updates PR

Post pre-commit status:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_runner: ✅ Committing test results"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Committing test results" >> $LOG_FILE
```

Delegate commit creation using SlashCommand:

```bash
# Use SlashCommand tool to create agent artifacts
/commit test_runner {type} '{issue_json}'
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

Update state:

```bash
# This mimics: adws/adw_modules/state.py:ADWState.save()
jq '.current_phase = "testing_complete"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] State updated" >> $LOG_FILE
```

Push and update PR:

```bash
# This mimics: adws/adw_modules/git_ops.py:finalize_git_operations()
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Pushing changes" >> $LOG_FILE
git push

# Update PR if it exists
gh pr view &>/dev/null && gh pr comment --body "[ADW-BOT] {adw_id}_ops: ✅ Test results committed and pushed"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Testing phase completed" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_modules/git_ops.py:finalize_git_operations()` line 80-139

**IMPORTANT:** Mark Step 8 as completed in TodoWrite and immediately proceed to Step 9. DO NOT wait for user input.

### Step 9: Post Comprehensive Test Summary (Automated)

**What This Step Does:**
- Posts detailed test summary to GitHub issue
- Mimics `adws/adw_test.py:log_test_results()`

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_test_summary: 📊 Test Run Summary

## Unit Tests
**Total Tests:** {total_tests}
**Passed:** {passed_count} ✅
**Failed:** {failed_count} ❌

## E2E Tests
**Total Tests:** {total_e2e_tests}
**Passed:** {e2e_passed_count} ✅
**Failed:** {e2e_failed_count} ❌

## Overall Status
{overall_status_emoji} All tests passed!"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Posted test summary to issue" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_test.py:log_test_results()` line 149-217

**FINAL STEP:** Mark Step 9 as completed in TodoWrite. Verify ALL 9 steps show "completed" status. You are now done with the testing phase.

Display comprehensive summary to user:

```markdown
✅ Testing phase complete!

**Test Results:**
- Backend tests: {passed_count} passed, {failed_count} failed
- Frontend type checks: {ts_status}
- Frontend build: {build_status}
- E2E tests: {e2e_passed_count} passed, {e2e_failed_count} failed

**Artifacts created:**
```
agents/{adw_id}/
├── adw_state.json                           # Updated state
├── logs/
│   └── adw_guide_test_{timestamp}.log       # Execution log
├── test_runner/                             # From test sub-agent
│   └── output/
├── test_resolver_iter1_0/                   # From test resolution sub-agent
│   └── output/
└── e2e_test_runner_0_0/                     # From E2E test sub-agent
    ├── output/
    └── img/                                 # E2E screenshots
        └── {test_name}/
            ├── 01_screenshot.png
            └── 02_screenshot.png
```

**Sub-agents spawned (all in same session = $0):**
1. ✅ State loader
2. ✅ Backend test runner
3. ✅ Test failure resolver (x{resolution_attempts})
4. ✅ TypeScript checker
5. ✅ Frontend builder
6. ✅ E2E test runner
7. ✅ E2E test resolver (x{e2e_resolution_attempts})
8. ✅ Commit creator

**GitHub issue updated:** Issue #{issue_number} has been updated with test results

**Next steps:**
1. Review test results: Check the issue for details
2. If all tests passed: Continue to next phase
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
```

### New Intelligent Mode (Sub-Agent Delegation)
```
Claude Code CLI Session
├── You run: /adw_guide_test {adw_id}
├── Task spawns: Backend test runner (runs automatically)
├── Task spawns: Test failure resolver (runs automatically, retries)
├── Task spawns: TypeScript checker (runs automatically)
├── Task spawns: Frontend builder (runs automatically)
├── Task spawns: E2E test runner (runs automatically)
├── Task spawns: E2E test resolver (runs automatically, retries)
└── Task spawns: Commit creator (runs automatically)

Time: ~5-7 minutes (mostly automated)
Cost: $0 (all sub-agents in same Claude Pro session)
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
```

## Sub-Agent Best Practices

### When to Use Task Tool vs Direct Commands

**Use Task Tool (Sub-Agent) When:**
- ✅ Running test suites (pytest, tsc, build)
- ✅ Resolving test failures (needs analysis)
- ✅ Running E2E tests (complex browser automation)
- ✅ Creating commits (needs semantic message)
- ✅ Task needs error handling/retries

**Use Direct Command When:**
- ✅ Simple git operations (git add, git push)
- ✅ Creating directories (mkdir -p)
- ✅ Writing to log files (echo >> $LOG_FILE)
- ✅ Updating JSON state (jq commands)

### Parallel vs Sequential Sub-Agent Execution

**Sequential Execution (Required):**
- Backend tests → Test resolution → Re-run tests
- TypeScript checks → Frontend build
- E2E tests → E2E resolution → Re-run E2E tests

**Why Sequential:**
- Tests must complete before analyzing failures
- Fixes must be applied before re-running tests
- Each step depends on previous step's results

### Retry Logic with Sub-Agents

Sub-agents handle automatic retries intelligently:

```markdown
# Backend test retry logic
Attempt 1: Run tests → Find failures → Resolve → Re-run
Attempt 2: Run tests → Find failures → Resolve → Re-run
Attempt 3: Run tests → Find failures → Resolve → Re-run
Attempt 4: Run tests → Report final results

# E2E test retry logic
Attempt 1: Run E2E tests → Find failures → Resolve → Re-run
Attempt 2: Run E2E tests → Report final results

Max attempts configurable in automated system:
- MAX_TEST_RETRY_ATTEMPTS = 4
- MAX_E2E_TEST_RETRY_ATTEMPTS = 2
```

**File Reference:**
- Automated: `adws/adw_test.py:run_tests_with_resolution()` line 380-486
- E2E: `adws/adw_test.py:run_e2e_tests_with_resolution()` line 734-835
- Constants: line 64-66

## Error Handling with Sub-Agents

Sub-agents provide better error handling:

```markdown
# Sub-agent automatically handles test failures
Task: Resolve failed test
If resolution succeeds: Re-run tests automatically
If resolution fails: Try another test or stop after max attempts
If test execution errors: Report immediately and stop

# Sub-agent handles E2E test failures
Task: Run E2E test
If test fails: Capture screenshots and error details
If browser crashes: Report error and stop
If timeout: Report timeout and continue
```

**Benefits:**
- Automatic retry logic
- Better error messages
- Graceful degradation
- User stays informed

## Variables

- `$1` = ADW ID (required)

## Key Advantages of Sub-Agent Approach

1. **Fully Automated**: Just provide ADW ID, everything else is handled
2. **Intelligent Delegation**: Sub-agents handle complex testing tasks independently
3. **Automatic Retries**: Failed tests are resolved and re-run automatically
4. **Better Error Handling**: Sub-agents can analyze and fix test failures
5. **Zero Cost**: All sub-agents run in same Claude Pro session
6. **Identical Artifacts**: Produces same output as expensive automated system
7. **Time Savings**: ~20 minutes of manual work → ~5 minutes automated

## What to Do

- **DO** use Task tool for test execution and resolution
- **DO** let sub-agents handle test failures and retries
- **DO** run tests sequentially (backend → frontend → E2E)
- **DO** keep user informed of test progress
- **DO** create same artifacts as automated system
- **DO** post comprehensive test summaries to GitHub

## What NOT to Do

- **DON'T** spawn external processes (costs money)
- **DON'T** manually analyze test failures when sub-agent can do it
- **DON'T** skip E2E tests if unit tests pass
- **DON'T** continue E2E tests if unit tests fail
- **DON'T** call Anthropic API directly (Claude Code handles it)

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

All in one Claude Code session! 🚀
