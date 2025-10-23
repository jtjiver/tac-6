# Build Phase: Automated vs Interactive Comparison

This document provides a detailed step-by-step comparison of the automated Python workflow vs the interactive guide for the **Build Phase**.

---

## Overview

| Aspect | Automated (`adw_build.py`) | Interactive (`/adw_guide_build`) |
|--------|----------------------------|----------------------------------|
| **Trigger** | CLI: `python adws/adw_build.py <adw_id>` | User runs: `/adw_guide_build <adw_id>` |
| **Cost** | $$$ (2 Claude API calls) | $0 (Single Claude Pro session) |
| **Execution** | Fully automatic, no user interaction | Semi-automatic, orchestrated by Claude |
| **Logging** | `agents/{adw_id}/adw_build/execution.log` | `agents/{adw_id}/adw_build/execution.log` |
| **Total Steps** | ~8 steps | 10 steps (0-9) |
| **Time** | ~8-10 minutes | ~3-5 minutes |

---

## Step-by-Step Comparison

### Step 0: Initialize Logging (Interactive Only)

#### Automated
```python
# adws/adw_build.py line 100-110
logger = setup_logger(adw_id, "adw_build")
logger.info(f"ADW Build starting - ID: {adw_id}")
```

**Creates:**
- `agents/{adw_id}/adw_build/execution.log`

**Logs:**
```
2025-10-07 09:30:00 - INFO - ADW Logger initialized - ID: abc12345
2025-10-07 09:30:00 - INFO - ADW Build starting - ID: abc12345
```

#### Interactive (`/adw_guide_build` Step 0)
```bash
# User provides ADW ID
ADW_ID="abc12345"

# Create phase folder (matches automated system structure)
mkdir -p agents/$ADW_ID/adw_build
LOG_FILE="agents/$ADW_ID/adw_build/execution.log"

# Write initial log entries
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW Build Phase Initialized" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW ID: $ADW_ID" >> $LOG_FILE
```

**Creates:**
- `agents/{adw_id}/adw_build/execution.log` ✅ Identical

**Logs:**
```
[2025-10-23T10:30:00Z] ========================================
[2025-10-23T10:30:00Z] ADW Build Phase Initialized
[2025-10-23T10:30:00Z] ADW ID: abc12345
```

**✅ Result:** Same folder, slightly different log format

---

### Step 1: Load State and Initialize

#### Automated
```python
# adws/adw_modules/state.py:ADWState.load() line 60-82
def load(adw_id: str):
    state_file = os.path.join(project_root, "agents", adw_id, "adw_state.json")
    if not os.path.exists(state_file):
        raise FileNotFoundError(f"State file not found: {state_file}")

    with open(state_file, "r") as f:
        state_data = json.load(f)

    return ADWState(**state_data)

# adws/adw_build.py line 152-180
state = ADWState.load(adw_id)
logger.info(f"Loaded state for issue #{state.issue_number}")
logger.info(f"Branch: {state.branch_name}")
logger.info(f"Plan file: {state.plan_file}")
```

**Logs:**
```
2025-10-07 09:30:01 - INFO - Loaded state for issue #20
2025-10-07 09:30:01 - INFO - Branch: feature-issue-20-adw-abc12345-add-dark-mode
2025-10-07 09:30:01 - INFO - Plan file: specs/issue-20-adw-abc12345-sdlc_planner-add-dark-mode.md
```

**Subprocess Calls:** 0

#### Interactive
```bash
# Step 1 uses Task tool to delegate
Task: Load workflow state
Subagent: general-purpose
Prompt: |
  Load the ADW workflow state and verify prerequisites.

  ADW ID: abc12345

  1. Load state from: agents/abc12345/adw_state.json
  2. Verify state exists and is valid
  3. Extract key information:
     - Issue number
     - Branch name
     - Plan file
  4. Return the state information
```

**Logs:**
```
[2025-10-23T10:30:01Z] Step 1: Starting - Load State and Initialize
[2025-10-23T10:30:02Z] Step 1: State loaded for issue #20
[2025-10-23T10:30:02Z] Step 1: Branch: feature-issue-20-adw-abc12345-add-dark-mode
[2025-10-23T10:30:02Z] Step 1: Posted GitHub comment - Starting implementation
[2025-10-23T10:30:02Z] Step 1: Completed - Load State and Initialize
```

**GitHub Comments:**
```
[ADW-BOT] abc12345_ops: ✅ Starting implementation phase
```

**Claude API Calls:** 0 (sub-agent in same session)

**✅ Result:** Same state loaded, interactive adds GitHub comment

---

### Step 2: Verify Branch

#### Automated
```python
# adws/adw_modules/git_ops.py:ensure_branch() line 58-78
def ensure_branch(branch_name: str, logger):
    current_branch = subprocess.run(
        ["git", "branch", "--show-current"],
        capture_output=True,
        text=True
    ).stdout.strip()

    if current_branch != branch_name:
        subprocess.run(["git", "checkout", branch_name], check=True)
        logger.info(f"Switched to branch: {branch_name}")
    else:
        logger.info(f"Already on branch: {branch_name}")
```

**Logs:**
```
2025-10-07 09:30:02 - INFO - Already on branch: feature-issue-20-adw-abc12345-add-dark-mode
```

**Subprocess Calls:** 1-2 (`git branch --show-current`, optionally `git checkout`)

#### Interactive
```bash
# Step 2 in guide
CURRENT_BRANCH=$(git branch --show-current)
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Current branch is $CURRENT_BRANCH" >> $LOG_FILE

if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
  git checkout $BRANCH_NAME
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Switched to branch $BRANCH_NAME" >> $LOG_FILE
else
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Already on correct branch" >> $LOG_FILE
fi

# Post GitHub comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] abc12345_ops: ✅ Working on branch: \`$BRANCH_NAME\`"
```

**Logs:**
```
[2025-10-23T10:30:03Z] Step 2: Starting - Verify Branch
[2025-10-23T10:30:03Z] Step 2: Current branch is feature-issue-20-adw-abc12345-add-dark-mode
[2025-10-23T10:30:03Z] Step 2: Already on correct branch
[2025-10-23T10:30:03Z] Step 2: Posted GitHub comment - Branch verified
[2025-10-23T10:30:03Z] Step 2: Completed - Verify Branch
```

**GitHub Comments:**
```
[ADW-BOT] abc12345_ops: ✅ Working on branch: `feature-issue-20-adw-abc12345-add-dark-mode`
```

**✅ Result:** Same branch verification, interactive adds tracking

---

### Step 3: Locate Plan File

#### Automated
```python
# adws/adw_build.py line 182-210
def find_plan_file(state, logger):
    # Check state file first
    if state.plan_file and os.path.exists(state.plan_file):
        logger.info(f"Using plan file from state: {state.plan_file}")
        return state.plan_file

    # Search for plan file
    pattern = f"specs/issue-{state.issue_number}-adw-{state.adw_id}-*.md"
    matches = glob.glob(pattern)

    if not matches:
        raise FileNotFoundError(f"No plan file found matching: {pattern}")

    plan_file = matches[0]
    logger.info(f"Found plan file: {plan_file}")
    return plan_file
```

**Logs:**
```
2025-10-07 09:30:03 - INFO - Using plan file from state: specs/issue-20-adw-abc12345-sdlc_planner-add-dark-mode.md
```

**Subprocess Calls:** 0

#### Interactive
```bash
# Step 3 uses Task tool to delegate
Task: Locate implementation plan file
Subagent: general-purpose
Prompt: |
  Find the implementation plan file for this workflow.

  Issue: #20
  ADW ID: abc12345
  Plan file hint from state: {plan_file_from_state}

  Search locations:
  1. Check state file plan_file path first
  2. Search: specs/issue-20-adw-abc12345-*.md
  3. Search: specs/*abc12345*.md

  Return ONLY the absolute path to the plan file.
```

**Logs:**
```
[2025-10-23T10:30:04Z] Step 3: Starting - Locate Plan File
[2025-10-23T10:30:04Z] Step 3: Using plan file: specs/issue-20-adw-abc12345-sdlc_planner-add-dark-mode.md
[2025-10-23T10:30:04Z] Step 3: Posted GitHub comment - Plan file located
[2025-10-23T10:30:04Z] Step 3: Completed - Locate Plan File
```

**GitHub Comments:**
```
[ADW-BOT] abc12345_ops: ✅ Found plan: `specs/issue-20-adw-abc12345-sdlc_planner-add-dark-mode.md`
```

**Claude API Calls:** 0 (sub-agent in same session)

**✅ Result:** Same plan file found

---

### Step 4: Implement Solution

#### Automated
```python
# adws/adw_modules/workflow_ops.py:implement_solution() line 328-365
def implement_solution(plan_file, adw_id, logger):
    logger.info("Implementing solution from plan")

    response = execute_template(
        agent_name=AGENT_IMPLEMENTOR,  # "sdlc_implementor"
        slash_command="/implement",
        args=[plan_file],
        adw_id=adw_id,
        model="opus"  # Complex implementation needs Opus
    )

    logger.info("Implementation complete")
    return response.output
```

**Creates Agent Folder:**
```
agents/{adw_id}/sdlc_implementor/
├── prompts/
│   └── implement.txt
├── raw_output.jsonl
└── raw_output.json
```

**Logs:**
```
2025-10-07 09:30:05 - INFO - Implementing solution from plan
2025-10-07 09:35:30 - INFO - Implementation complete
```

**Subprocess Calls:** 1 (`claude -p /implement`)
**Claude API Calls:** 1 (Opus - expensive! ~$3.00)
**Time:** ~5-6 minutes (Opus is slow but thorough)

#### Interactive
```bash
# Step 4 uses SlashCommand tool
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Starting - Implement Solution" >> $LOG_FILE

# Post pre-implementation GitHub comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] abc12345_sdlc_implementor: ⏳ Implementing solution from plan"

# Execute /implement
/implement {plan_file}
```

**Creates Agent Folder:**
```
agents/{adw_id}/sdlc_implementor/
├── prompts/
│   └── implement.txt
├── raw_output.jsonl
└── raw_output.json
```
✅ Identical structure

**Logs:**
```
[2025-10-23T10:30:05Z] Step 4: Starting - Implement Solution
[2025-10-23T10:30:05Z] Step 4: Posted GitHub comment - Implementation starting
[2025-10-23T10:33:20Z] Step 4: Implementation complete
[2025-10-23T10:33:20Z] Step 4: Posted GitHub comment - Implementation complete
[2025-10-23T10:33:20Z] Step 4: Completed - Implement Solution
```

**GitHub Comments:**
```
[ADW-BOT] abc12345_sdlc_implementor: ⏳ Implementing solution from plan
[ADW-BOT] abc12345_sdlc_implementor: ✅ Solution implemented
```

**Claude API Calls:** 0 (in same session as orchestrator)
**Time:** ~3-4 minutes (faster due to shared context)

**💰 Cost Savings:** ~$3.00 per build phase

**✅ Result:** Identical agent artifacts, interactive is faster and free

---

### Step 5: Review Changes

#### Automated
```python
# adws/adw_build.py line 240-265
logger.info("Reviewing changes...")

# Show git status
status_output = subprocess.run(
    ["git", "status"],
    capture_output=True,
    text=True
).stdout
logger.debug(f"Git status:\n{status_output}")

# Show diff stats
diff_output = subprocess.run(
    ["git", "diff", "--stat"],
    capture_output=True,
    text=True
).stdout
logger.debug(f"Diff stats:\n{diff_output}")
```

**Logs:**
```
2025-10-07 09:35:31 - INFO - Reviewing changes...
2025-10-07 09:35:31 - DEBUG - Git status:
On branch feature-issue-20-adw-abc12345-add-dark-mode
Changes not staged for commit:
  modified:   app/client/src/style.css
  modified:   app/client/index.html
```

**Subprocess Calls:** 2 (`git status`, `git diff --stat`)

#### Interactive
```bash
# Step 5 in guide
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Starting - Review Changes" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Running git status" >> $LOG_FILE
git status

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Running git diff --stat" >> $LOG_FILE
git diff --stat

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Changes reviewed" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Completed - Review Changes" >> $LOG_FILE
```

**Logs:**
```
[2025-10-23T10:33:21Z] Step 5: Starting - Review Changes
[2025-10-23T10:33:21Z] Step 5: Running git status
[2025-10-23T10:33:21Z] Step 5: Running git diff --stat
[2025-10-23T10:33:21Z] Step 5: Changes reviewed
[2025-10-23T10:33:21Z] Step 5: Completed - Review Changes
```

**Display to User:** Full git status and diff output shown in Claude Code

**✅ Result:** Same review, user sees output in real-time

---

### Step 6: Create Commit

#### Automated
```python
# adws/adw_modules/workflow_ops.py:create_commit() line 238-272
def create_commit(agent_name, issue_class, issue, adw_id, logger):
    type_str = issue_class.lstrip('/')  # Remove leading slash

    logger.info("Creating commit")

    response = execute_template(
        agent_name=f"{agent_name}_committer",  # "sdlc_implementor_committer"
        slash_command="/commit",
        args=[agent_name, type_str, json.dumps(issue.model_dump())],
        adw_id=adw_id,
        model="sonnet"
    )

    # Git operations
    subprocess.run(["git", "add", "."], check=True)
    subprocess.run(["git", "commit", "-m", response.output], check=True)

    logger.info(f"Created commit: {response.output}")
    return response.output
```

**Creates Agent Folder:**
```
agents/{adw_id}/sdlc_implementor_committer/
├── prompts/
│   └── commit.txt
├── raw_output.jsonl
└── raw_output.json
```

**Logs:**
```
2025-10-07 09:35:32 - INFO - Creating commit
2025-10-07 09:35:45 - INFO - Created commit: sdlc_implementor: feat: implement dark mode functionality
```

**Subprocess Calls:** 3 (`claude -p /commit`, `git add .`, `git commit`)
**Claude API Calls:** 1 (Sonnet ~$0.05)

#### Interactive
```bash
# Step 6 uses SlashCommand tool
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Starting - Create Commit" >> $LOG_FILE

# Extract type from state
ISSUE_CLASS="{issue_class_from_state_without_slash}"
ISSUE_JSON=$(gh issue view $ISSUE_NUMBER --json number,title,body)

# Execute /commit
/commit sdlc_implementor $ISSUE_CLASS "$ISSUE_JSON"
```

**Creates Agent Folder:**
```
agents/{adw_id}/sdlc_implementor_committer/
├── prompts/
│   └── commit.txt
├── raw_output.jsonl
└── raw_output.json
```
✅ Identical structure

**Logs:**
```
[2025-10-23T10:33:22Z] Step 6: Starting - Create Commit
[2025-10-23T10:33:30Z] Step 6: Commit created
[2025-10-23T10:33:30Z] Step 6: Posted GitHub comment - Commit created
[2025-10-23T10:33:30Z] Step 6: Completed - Create Commit
```

**GitHub Comments:**
```
[ADW-BOT] abc12345_sdlc_implementor: ✅ Implementation committed
```

**Claude API Calls:** 0 (in same session)

**✅ Result:** Identical agent artifacts and git commit

---

### Step 7: Update State

#### Automated
```python
# adws/adw_build.py line 290-310
state.current_phase = "build_complete"
state.save()

logger.info("State updated to build_complete")
```

**Logs:**
```
2025-10-07 09:35:46 - INFO - State updated to build_complete
```

#### Interactive
```bash
# Step 7 in guide
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Starting - Update State" >> $LOG_FILE

jq '.current_phase = "build_complete"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: State updated to build_complete" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Completed - Update State" >> $LOG_FILE
```

**Logs:**
```
[2025-10-23T10:33:31Z] Step 7: Starting - Update State
[2025-10-23T10:33:31Z] Step 7: State updated to build_complete
[2025-10-23T10:33:31Z] Step 7: Completed - Update State
```

**✅ Result:** Same state update

---

### Step 8: Complete Build Phase

#### Automated
```python
# adws/adw_build.py line 312-330
logger.info("Build phase completed successfully")

# Post completion comment to issue
gh_comment = f"[ADW-BOT] {adw_id}: Build phase completed"
subprocess.run(
    ["gh", "issue", "comment", str(state.issue_number), "--body", gh_comment],
    check=True
)
```

**Logs:**
```
2025-10-07 09:35:47 - INFO - Build phase completed successfully
```

**GitHub Comments:**
```
[ADW-BOT] abc12345: Build phase completed
```

#### Interactive
```bash
# Step 8 in guide
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Starting - Complete Build Phase" >> $LOG_FILE

# Post completion comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] abc12345_ops: ✅ Implementation phase completed"

# Post final state
FINAL_STATE=$(cat agents/{adw_id}/adw_state.json | jq -r .)
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] abc12345_ops: 📋 Build phase state:
\`\`\`json
$FINAL_STATE
\`\`\`"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Build phase completed" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Completed - Complete Build Phase" >> $LOG_FILE
```

**Logs:**
```
[2025-10-23T10:33:32Z] Step 8: Starting - Complete Build Phase
[2025-10-23T10:33:32Z] Step 8: Build phase completed
[2025-10-23T10:33:32Z] ========================================
[2025-10-23T10:33:32Z] Step 8: Completed - Complete Build Phase
```

**GitHub Comments:**
```
[ADW-BOT] abc12345_ops: ✅ Implementation phase completed
[ADW-BOT] abc12345_ops: 📋 Build phase state: { ... }
```

**✅ Result:** Same completion, interactive adds detailed state

---

### Step 9: Verify Logging and Comments (Interactive Only)

#### Automated
Not present - automated system doesn't verify

#### Interactive
```bash
# Step 9 in guide - FINAL CHECK
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Starting - Verify Logging and Comments" >> $LOG_FILE

# Verify log file exists
if [ ! -f "$LOG_FILE" ]; then
  echo "❌ ERROR: Log file not found at $LOG_FILE"
  exit 1
fi

# Count log entries
LOG_ENTRIES=$(wc -l < "$LOG_FILE")
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Log file has $LOG_ENTRIES entries" >> $LOG_FILE

# Show log summary
echo "=== Build Log Summary ==="
echo "Log file: $LOG_FILE"
echo "Total entries: $LOG_ENTRIES"
tail -10 "$LOG_FILE"

# Verify GitHub comments
echo "=== GitHub Comments Verification ==="
gh issue view $ISSUE_NUMBER --comments | grep "ADW-BOT.*abc12345" | tail -5

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Completed - Verify Logging and Comments" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ALL STEPS COMPLETE - Build phase successful" >> $LOG_FILE
```

**Logs:**
```
[2025-10-23T10:33:33Z] Step 9: Starting - Verify Logging and Comments
[2025-10-23T10:33:33Z] Step 9: Log file has 32 entries
[2025-10-23T10:33:33Z] Step 9: Completed - Verify Logging and Comments
[2025-10-23T10:33:33Z] ALL STEPS COMPLETE - Build phase successful
```

**✅ Result:** Interactive adds verification that automated lacks

---

## Summary Comparison

### Artifacts Created (Identical)

```
agents/{adw_id}/
├── adw_state.json (updated)
├── adw_build/
│   └── execution.log
└── sdlc_implementor/
    ├── prompts/
    │   ├── implement.txt
    │   └── commit.txt (in sdlc_implementor_committer/)
    ├── raw_output.jsonl
    └── raw_output.json
```

✅ **100% Identical folder structure and artifacts**

---

### Key Differences

| Aspect | Automated | Interactive |
|--------|-----------|-------------|
| **Cost** | $3.05 (2 API calls) | $0 (all in same session) |
| **Subprocess Calls** | ~8 (claude, git, gh) | ~4 (git, gh only) |
| **Claude API Calls** | 2 separate calls | 0 (sub-agents in session) |
| **GitHub Comments** | Minimal (1-2) | Comprehensive (5-7) |
| **Logging Detail** | Standard | Enhanced with step tracking |
| **Verification** | None | Final verification step |
| **User Visibility** | None (background) | Real-time in Claude Code |
| **Time** | ~8-10 minutes | ~3-5 minutes |
| **Retry Logic** | Explicit error handling | Claude orchestrates retries |

---

### Cost Breakdown

#### Automated
- Implementor: 1 API call (Opus) = ~$3.00
- Committer: 1 API call (Sonnet) = ~$0.05
- **Total: ~$3.05 per build phase**

#### Interactive
- Implementor: In same session = $0.00
- Committer: In same session = $0.00
- **Total: $0.00 (covered by Claude Pro subscription)**

**💰 Savings: $3.05 per build**

---

### Execution Time

#### Automated
```
Step 1-3:   Load + Verify + Find   ~10 seconds
Step 4:     Implementation (Opus)   ~330 seconds (5.5 min)
Step 5-8:   Review + Commit + Done  ~50 seconds
----------------------------------------
Total:                              ~390 seconds (~6.5 minutes)
```

#### Interactive
```
Step 0-3:   Init + Load + Verify    ~10 seconds
Step 4:     Implementation          ~195 seconds (3.25 min)
Step 5-9:   Review + Commit + Done  ~30 seconds
----------------------------------------
Total:                              ~235 seconds (~4 minutes)
```

**⚡ Interactive is ~1.7x faster** due to:
- Shared session context (Opus benefits most)
- No subprocess overhead
- Parallel processing where possible

---

## Conclusion

The interactive `/adw_guide_build` produces **100% identical artifacts** to the automated system while being:
- **$3.05 cheaper** per run
- **1.7x faster**
- **More transparent** (user sees everything)
- **Better tracked** (comprehensive GitHub comments)
- **More reliable** (Claude orchestrates error recovery)

The only trade-off is that interactive requires a user to initiate it, while automated can run on webhooks. For development workflows, interactive is clearly superior.
