# ADW Guide: Build/Implementation Phase (Intelligent Sub-Agent Automation)

Interactive guide with intelligent sub-agent delegation for maximum automation at $0 cost.

## Architecture Overview

This intelligent guide uses Claude Code's **Task tool** to spawn sub-agents within the same session, automating the entire implementation workflow while staying at zero cost (covered by Claude Pro).

### Intelligent Architecture with Sub-Agents

```
Interactive Flow (this guide with sub-agents)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You (in Claude Code CLI)
├── /adw_guide_build [adw_id]
│   ├── Main orchestrator (this guide)
│   ├── Task → Sub-agent: Load and analyze state
│   ├── Task → Sub-agent: Implement solution from plan
│   ├── Task → Sub-agent: Create commit
│   └── Task → Sub-agent: Push changes (optional)
│
All in ONE Claude Code session = $0 (Claude Pro)

Automated Flow (for reference - costs $$$)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trigger_webhook.py → adw_plan_build.py
    ├── subprocess.run → adw_build.py
        ├── subprocess.run → claude -p "/implement"
        └── subprocess.run → claude -p "/commit"

Each subprocess = separate Claude API call = $$$
```

### Key Innovation: Task Tool for Sub-Agents

Instead of manually running each slash command, we use the **Task tool** to delegate to specialized sub-agents:

```markdown
# Old approach (manual):
You run: /implement
You run: /commit
...

# New approach (intelligent delegation):
Task tool spawns: "Implement this plan: {plan_file}"
Task tool spawns: "Create semantic commit for implementation"
...
```

**Benefits:**
- ✅ Fully automated - just provide ADW ID
- ✅ Sub-agents run in parallel when possible
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

**IMPORTANT:** This guide uses intelligent sub-agent delegation to automate the entire implementation phase. Just provide an ADW ID and the guide orchestrates everything automatically.

**CRITICAL EXECUTION RULES:**
1. **Never stop until all 9 steps are complete** - Check your TodoWrite list after EVERY step
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
6. **Display final summary only** when Step 9 is marked "completed" in your TodoWrite list

**Why this matters:** The automated system (`adws/adw_build.py`) runs all steps sequentially without pausing. This interactive guide must match that behavior to provide the same experience. The slash commands now include auto-continuation instructions, so you MUST honor them and keep working.

### Step 0: Initialize Logging (MUST DO FIRST) ⚠️

**This step happens BEFORE you ask for ADW ID!**

Ask the user: "What is the ADW ID you want to continue working on?"

**As soon as user provides ADW ID, initialize TodoWrite tracking:**
Create todo list with all 9 steps:
0. Initialize Logging
1. Load State and Initialize
2. Verify Branch
3. Locate Plan File
4. Implement Solution
5. Review Changes
6. Create Commit
7. Update State
8. Complete Build Phase
9. Verify Logging and Comments

Mark Step 0 as "in_progress" immediately.

**Initialize logging FIRST (before doing anything else):**

```bash
# CRITICAL: Create log file and store path in variable
ADW_ID="{user_provided_adw_id}"
# Create phase folder (matches automated system structure)
mkdir -p agents/$ADW_ID/adw_build
LOG_FILE="agents/$ADW_ID/adw_build/execution.log"

# Write initial log entry
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW Build Phase Initialized" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW ID: $ADW_ID" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Log file: $LOG_FILE" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE

# Display log file path for confirmation
echo "📝 Log file initialized: $LOG_FILE"
```

**CRITICAL:** Store `$LOG_FILE` path and use it in ALL subsequent steps. Every bash command block should append to `$LOG_FILE`.

**File Reference:**
- Automated: `adws/adw_modules/utils.py:setup_logger()` ANCHOR: `setup_logger`

Display: "✅ Logging initialized: `{log_file}`"

**Before continuing:** Mark Step 0 complete, mark Step 1 as in_progress.

### Step 1: Load State and Initialize (Automated)

**BEFORE starting Step 1:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Starting - Load State and Initialize" >> $LOG_FILE
```

Spawn a sub-agent to load and verify the state:

```markdown
# Use Task tool to delegate state loading
Task: Load and analyze workflow state
Subagent: general-purpose
Prompt: |
  Load the ADW workflow state for ADW ID: {adw_id}

  1. Read state file: agents/{adw_id}/adw_state.json
  2. Verify the workflow exists and is in a valid state for building
  3. Extract key information:
     - Issue number
     - Branch name
     - Plan file path
     - Current phase
  4. Display state summary to me
  5. Return the complete state object

  File Reference: This mimics adws/adw_modules/state.py:ADWState.load()
```

**File Reference:**
- Automated: `adws/adw_modules/state.py:ADWState.load()` (function ~lines 78-100)
- Build: `adws/adw_build.py` (section ~lines 100-150)

**AFTER sub-agent returns state:**
```bash
# Extract issue number from state
ISSUE_NUMBER="{issue_number_from_state}"
BRANCH_NAME="{branch_name_from_state}"

# Log state loaded
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: State loaded for issue #$ISSUE_NUMBER" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Branch: $BRANCH_NAME" >> $LOG_FILE

# Post initial GitHub comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_ops: ✅ Starting implementation phase"

# Log GitHub comment posted
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Posted GitHub comment - Starting implementation" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Completed - Load State and Initialize" >> $LOG_FILE
```

Display: "Found workflow for issue #{issue_number} on branch `{branch_name}`"

**Update TodoWrite:** Mark Step 1 complete, Step 2 in_progress. Then immediately continue to Step 2.

### Step 2: Verify Branch (Automated)

**BEFORE starting Step 2:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Starting - Verify Branch" >> $LOG_FILE
```

Automatically check and switch to correct branch:

```bash
# This mimics: adws/adw_modules/git_ops.py:ensure_branch()
CURRENT_BRANCH=$(git branch --show-current)
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Current branch is $CURRENT_BRANCH" >> $LOG_FILE

if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
  git checkout $BRANCH_NAME
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Switched to branch $BRANCH_NAME" >> $LOG_FILE
else
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Already on correct branch" >> $LOG_FILE
fi

# Post GitHub comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_ops: ✅ Working on branch: \`$BRANCH_NAME\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Posted GitHub comment - Branch verified" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Completed - Verify Branch" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_build.py` (section ~lines 152-180)

Display: "✅ On branch: `{branch_name}`"

**Update TodoWrite:** Mark Step 2 complete, Step 3 in_progress. Then immediately continue to Step 3.

### Step 3: Locate Plan File (Automated with Sub-Agent)

**BEFORE starting Step 3:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Starting - Locate Plan File" >> $LOG_FILE
```

**What This Step Does:**
- Spawns sub-agent to locate the implementation plan
- Mimics `adws/adw_build.py:find_plan_file()`

Delegate plan file location to sub-agent:

```markdown
# Use Task tool to delegate plan file search
Task: Locate implementation plan file
Subagent: general-purpose
Prompt: |
  Find the implementation plan file for this workflow.

  Issue: #{issue_number}
  ADW ID: {adw_id}
  Plan file hint from state: {plan_file_from_state}

  Search locations:
  1. Check state file plan_file path first
  2. Search: specs/issue-{issue_number}-adw-{adw_id}-*.md
  3. Search: specs/*{adw_id}*.md

  Verify the file exists and is readable.

  Return ONLY the absolute path to the plan file.

  File Reference: This mimics adws/adw_build.py find_plan_file logic
```

**File Reference:**
- Automated: `adws/adw_build.py` (section ~lines 182-210)

**AFTER sub-agent returns plan file:**
```bash
PLAN_FILE="{plan_file_from_subagent}"

# Log plan file found
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Using plan file: $PLAN_FILE" >> $LOG_FILE

# Post GitHub comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_ops: ✅ Found plan: \`$PLAN_FILE\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Posted GitHub comment - Plan file located" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Completed - Locate Plan File" >> $LOG_FILE
```

Display: "✅ Plan file located: `{plan_file}`"

**Update TodoWrite:** Mark Step 3 complete, Step 4 in_progress. Then immediately continue to Step 4.

### Step 4: Implement Solution (Automated with SlashCommand)

**BEFORE starting Step 4:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Starting - Implement Solution" >> $LOG_FILE

# Post pre-implementation GitHub comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_sdlc_implementor: ⏳ Implementing solution from plan"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Posted GitHub comment - Implementation starting" >> $LOG_FILE
```

**What This Step Does:**
- Uses SlashCommand to implement all changes from the plan (creates agent artifacts)
- Mimics `adws/adw_modules/workflow_ops.py:implement_solution()`

Execute the implement slash command:

```bash
# Use SlashCommand tool to create agent artifacts
/implement {plan_file}
```

This will automatically:
1. Create: `agents/{adw_id}/sdlc_implementor/prompts/implement.txt`
2. Create: `agents/{adw_id}/sdlc_implementor/raw_output.jsonl`
3. Create: `agents/{adw_id}/sdlc_implementor/raw_output.json`
4. Read and analyze the implementation plan thoroughly
5. Research the codebase to understand existing patterns
6. Implement all required changes following the plan:
   - Create new files as specified
   - Modify existing files as detailed
   - Follow project conventions and patterns
7. Ensure all acceptance criteria are addressed
8. Report what was implemented

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py:implement_plan()` (function ~lines 182-220)
- Calls: `adws/adw_modules/agent.py:execute_template("/implement")` ANCHOR: `execute_template`
- Executes: `.claude/commands/implement.md`
- Model: `opus` for complex implementation
- Agent folder: `agents/{adw_id}/sdlc_implementor/`

**AFTER /implement completes:**
```bash
# Log implementation complete
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Implementation complete" >> $LOG_FILE

# Post GitHub success comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_sdlc_implementor: ✅ Solution implemented"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Posted GitHub comment - Implementation complete" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Completed - Implement Solution" >> $LOG_FILE
```

Display: "✅ Implementation complete"

**Update TodoWrite:** Mark Step 4 complete, Step 5 in_progress. Then immediately continue to Step 5.

### Step 5: Review Changes (Automated)

**BEFORE starting Step 5:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Starting - Review Changes" >> $LOG_FILE
```

**What This Step Does:**
- Shows user what was changed
- Prepares for commit

Automatically show changes:
```bash
# This mimics: adws/adw_build.py review changes section
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Running git status" >> $LOG_FILE
git status

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Running git diff --stat" >> $LOG_FILE
git diff --stat

# Log changes reviewed
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Changes reviewed" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Completed - Review Changes" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_build.py` (section ~lines 240-265)

Display summary of changes to user.

**Update TodoWrite:** Mark Step 5 complete, Step 6 in_progress. Then immediately continue to Step 6.

### Step 6: Create Commit (Automated with SlashCommand)

**BEFORE starting Step 6:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Starting - Create Commit" >> $LOG_FILE
```

**What This Step Does:**
- Uses SlashCommand to create semantic commit (creates agent artifacts)
- Mimics `adws/adw_modules/workflow_ops.py:create_commit()`

Execute the commit slash command:

```bash
# Extract issue class from state (should be "feature", "bug", or "chore" WITHOUT slash)
ISSUE_CLASS="{issue_class_from_state_without_slash}"

# Get issue JSON for commit context
ISSUE_JSON=$(gh issue view $ISSUE_NUMBER --json number,title,body)

# Use SlashCommand tool to create agent artifacts
/commit sdlc_implementor $ISSUE_CLASS "$ISSUE_JSON"
```

Where `{type}` is `feature`, `bug`, or `chore` (without the slash).

This will automatically:
1. Stage all changes (git add .)
2. Create: `agents/{adw_id}/sdlc_implementor/prompts/commit.txt` (appends if exists)
3. Analyze the implementation changes
4. Generate semantic commit message following project conventions
5. Create commit with proper attribution
6. Return the commit SHA

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py:create_commit()` ANCHOR: `create_commit`
- Calls: `adws/adw_modules/agent.py:execute_template("/commit")` ANCHOR: `execute_template`
- Executes: `.claude/commands/commit.md`
- Git ops: `adws/adw_modules/git_ops.py:commit_changes()` (function ~lines 37-56)
- Model: `sonnet` (fast commit generation)
- Agent folder: `agents/{adw_id}/sdlc_implementor/` (reuses implementor folder)

**AFTER /commit completes:**
```bash
# Log commit created
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Changes committed" >> $LOG_FILE

# Post GitHub success comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_sdlc_implementor: ✅ Implementation committed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Posted GitHub comment - Commit created" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Completed - Create Commit" >> $LOG_FILE
```

Display: "✅ Changes committed successfully"

**Update TodoWrite:** Mark Step 6 complete, Step 7 in_progress. Then immediately continue to Step 7.

### Step 7: Update State (Automated)

**BEFORE starting Step 7:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Starting - Update State" >> $LOG_FILE
```

**What This Step Does:**
- Updates workflow state to indicate build completion
- Mimics `adws/adw_modules/state.py:ADWState.save()`

Automatically update state:
```bash
# This mimics: adws/adw_modules/state.py:ADWState.save()
jq '.current_phase = "build_complete" | .plan_file = "'"$PLAN_FILE"'"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: State updated to build_complete" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Completed - Update State" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_modules/state.py:ADWState.save()` ANCHOR: `save`
- Build: `adws/adw_build.py` (section ~lines 290-310)

Display: "✅ State updated: build_complete"

**Update TodoWrite:** Mark Step 7 complete, Step 8 in_progress. Then immediately continue to Step 8.

### Step 8: Complete Build Phase (Automated)

**BEFORE starting Step 8:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Starting - Complete Build Phase" >> $LOG_FILE
```

**What This Step Does:**
- Posts completion messages
- Provides comprehensive summary
- Posts final state to GitHub

Post completion:
```bash
# Post completion comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_ops: ✅ Implementation phase completed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Posted GitHub comment - Build phase completed" >> $LOG_FILE

# Post final state to GitHub
FINAL_STATE=$(cat agents/{adw_id}/adw_state.json | jq -r .)
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_ops: 📋 Build phase state:
\`\`\`json
$FINAL_STATE
\`\`\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Posted GitHub comment - Final state" >> $LOG_FILE

# Log build phase complete
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Build phase completed" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Completed - Complete Build Phase" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_build.py` (section ~lines 312-330)

**Update TodoWrite:** Mark Step 8 complete, Step 9 in_progress. Then immediately continue to Step 9.

### Step 9: Verify Logging and Comments (FINAL CHECK) ✅

**BEFORE starting Step 9:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Starting - Verify Logging and Comments" >> $LOG_FILE
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
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Log file has $LOG_ENTRIES entries" >> $LOG_FILE

# Show log summary to user
echo "=== Build Log Summary ==="
echo "Log file: $LOG_FILE"
echo "Total entries: $LOG_ENTRIES"
echo ""
echo "Recent entries:"
tail -10 "$LOG_FILE"

# Verify GitHub comments were posted
echo ""
echo "=== GitHub Comments Verification ==="
echo "Checking issue #$ISSUE_NUMBER for ADW-BOT comments..."
gh issue view $ISSUE_NUMBER --comments | grep "ADW-BOT.*{adw_id}" | tail -5

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Completed - Verify Logging and Comments" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ALL STEPS COMPLETE - Build phase successful" >> $LOG_FILE
```

**Update TodoWrite:** Mark Step 9 complete. Verify ALL 10 steps (0-9) show "completed" status.

Display comprehensive summary to user:

```markdown
✅ Implementation phase complete!

**What was done:**
- Loaded workflow state for ADW ID: {adw_id}
- Switched to branch: `{branch_name}`
- Located plan file: `{plan_file}`
- Implemented all changes from plan
- Changes committed to branch
- State updated to: build_complete

**Artifacts created (identical to automated system):**
```
agents/{adw_id}/
├── adw_state.json                           # Updated state
├── adw_build/                               # PHASE folder for build
│   └── execution.log                        # Phase-level log (matches automated)
└── sdlc_implementor/                        # AGENT folder (SDLC implementor artifacts)
    ├── prompts/
    │   ├── implement.txt
    │   └── commit.txt
    ├── raw_output.jsonl
    └── raw_output.json
```

**Folder Structure Notes:**
- **PHASE folders** (`adw_build/`): Created by us, contain phase execution logs
- **AGENT folders** (`sdlc_implementor/`): Created automatically by SlashCommand tool
- **SDLC naming**: "Software Development Life Cycle" agents for planning and implementation
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
2. ✅ Plan file locator
3. ✅ Solution implementor (via /implement)
4. ✅ Commit creator (via /commit)

**Next steps:**
1. Run tests: `/adw_guide_test {adw_id}`
2. Or skip to review: `/adw_guide_review {adw_id}`
3. Or skip to PR: `/adw_guide_pr {adw_id}`

**Cost so far:** $0 (all sub-agents in Claude Pro session) ✨

**Time saved:** ~5-8 minutes of manual implementation and commits!
```

**FINAL STEP:** You are now DONE with the build phase. All 10 steps are complete.

## Intelligent Architecture Comparison

### Old Interactive Mode (Manual Commands)
```
Claude Code CLI Session
├── You manually run: /implement
├── Wait for implementation
├── You manually run: /commit
└── Wait for commit

Time: ~15-20 minutes of hands-on work
Cost: $0 (Claude Pro)
Logging: Manual (often forgotten)
GitHub comments: Manual (often forgotten)
```

### New Intelligent Mode (Sub-Agent Delegation with Tracking)
```
Claude Code CLI Session
├── You run: /adw_guide_build {adw_id}
├── Auto-initialize: Logging and GitHub tracking
├── Task spawns: State loader (runs automatically)
├── Task spawns: Plan locator (runs automatically)
├── Task spawns: Implementor (runs automatically + logs)
├── Task spawns: Committer (runs automatically + logs)
└── Auto-verify: All logs and comments created

Time: ~3-5 minutes (mostly automated)
Cost: $0 (all sub-agents in same Claude Pro session)
Logging: Automatic, complete, timestamped
GitHub comments: Automatic at every step
```

### Automated Mode (External Processes - For Reference)
```
adw_plan_build.py → adw_build.py
    ├── subprocess.run → claude -p "/implement"      $$
    └── subprocess.run → claude -p "/commit"         $$

Time: ~8-10 minutes
Cost: $$$ (2 separate Claude API calls)
Logging: Automatic
GitHub comments: Automatic
```

## Sub-Agent Best Practices

### When to Use Task Tool vs Direct Commands

**Use Task Tool (Sub-Agent) When:**
- ✅ Task requires complex implementation
- ✅ Task generates significant code
- ✅ Task needs error handling/retries
- ✅ Task is time-consuming
- ✅ Task benefits from focused attention

**Use Direct Commands When:**
- ✅ Task is simple bash operation
- ✅ Task just reads/writes files
- ✅ You want immediate inline execution

## Error Handling with Sub-Agents

Sub-agents provide better error handling:

```markdown
# Sub-agent automatically retries on failure
Task: Implement solution
If fails: Sub-agent can analyze error and retry with corrections
If still fails: Main orchestrator gets clear error message
```

**Benefits:**
- Automatic retry logic
- Better error messages
- Graceful degradation
- User stays informed

## Resuming Workflows

If workflow state exists:

```bash
# Load existing state
STATE_FILE="agents/$1/adw_state.json"
if [ -f "$STATE_FILE" ]; then
  ADW_ID=$(jq -r '.adw_id' $STATE_FILE)
  ISSUE_NUMBER=$(jq -r '.issue_number' $STATE_FILE)
  CURRENT_PHASE=$(jq -r '.current_phase' $STATE_FILE)

  echo "Resuming workflow: $ADW_ID"
  echo "Current phase: $CURRENT_PHASE"

  # Use sub-agent to verify phase and continue
  Task: Verify workflow phase and continue
  Subagent: general-purpose
  Prompt: Analyze this state and continue from current phase: {state}
fi
```

**File Reference:**
- State loading: `adws/adw_modules/state.py:ADWState.load()` (function ~lines 78-100)

## Variables

- `$1` = ADW ID (required for build phase)
- OR `$1` = Can be omitted to search for latest interactive workflow

## Logging and Issue Updates

### Log File Format
All logs are created in `agents/{adw_id}/adw_build/execution.log` (matches automated system) with timestamped entries:
```
[2025-10-22T17:19:24Z] ========================================
[2025-10-22T17:19:24Z] ADW Build Phase Initialized
[2025-10-22T17:19:24Z] ADW ID: 61d49d73
[2025-10-22T17:19:24Z] ========================================
[2025-10-22T17:19:25Z] Step 1: Starting - Load State and Initialize
[2025-10-22T17:19:26Z] Step 1: State loaded for issue #20
[2025-10-22T17:19:26Z] Step 1: Completed - Load State and Initialize
...
[2025-10-22T17:25:00Z] ALL STEPS COMPLETE - Build phase successful
```

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in build phase:
- `ops` - Operational messages (starting, completion, state)
- `sdlc_implementor` - Implementation-specific messages

Common emojis:
- ✅ Success/completion
- ⏳ In progress
- ❌ Error
- ⚠️ Warning
- 📋 Information/state

Example sequence of comments for a successful build:
```
[ADW-BOT] 61d49d73_ops: ✅ Starting implementation phase
[ADW-BOT] 61d49d73_ops: ✅ Working on branch: `feature-issue-20-adw-61d49d73-social-media-footer`
[ADW-BOT] 61d49d73_ops: ✅ Found plan: `specs/issue-20-adw-61d49d73-sdlc_planner-social-media-footer.md`
[ADW-BOT] 61d49d73_sdlc_implementor: ⏳ Implementing solution from plan
[ADW-BOT] 61d49d73_sdlc_implementor: ✅ Solution implemented
[ADW-BOT] 61d49d73_sdlc_implementor: ✅ Implementation committed
[ADW-BOT] 61d49d73_ops: ✅ Implementation phase completed
[ADW-BOT] 61d49d73_ops: 📋 Build phase state: { ... }
```

## What to Do

- **DO** initialize logging FIRST (Step 0)
- **DO** log every step start and completion to `$LOG_FILE`
- **DO** post GitHub comments at major milestones
- **DO** use Task tool for complex implementation
- **DO** spawn sub-agents for time-consuming tasks
- **DO** let sub-agents handle errors and retries
- **DO** keep user informed of progress
- **DO** create same artifacts as automated system
- **DO** verify logging and comments at the end

## What NOT to Do

- **DON'T** skip Step 0 (logging initialization)
- **DON'T** forget to log step start/completion
- **DON'T** forget to post GitHub comments
- **DON'T** spawn external processes (costs money)
- **DON'T** manually run commands when sub-agent can do it
- **DON'T** call Anthropic API directly (Claude Code handles it)
- **DON'T** forget to update TodoWrite after each step

## File References Summary

All file references point to the actual automated system implementation:

- **Build Script**: `adws/adw_build.py`
- **Workflow Logic**: `adws/adw_modules/workflow_ops.py`
- **Agent Execution**: `adws/adw_modules/agent.py` ANCHOR: `execute_template`
- **State Management**: `adws/adw_modules/state.py` ANCHOR: `save`
- **Git Operations**: `adws/adw_modules/git_ops.py` ANCHOR: `create_branch`, `finalize_git_operations`
- **GitHub API**: `adws/adw_modules/github.py` ANCHOR: `fetch_issue`, `make_issue_comment`
- **Utilities**: `adws/adw_modules/utils.py` ANCHOR: `setup_logger`

## The Bottom Line

This intelligent guide with sub-agent delegation gives you:

✨ **The automation of the $$ build system**
✨ **The zero cost of interactive Claude Pro**
✨ **The speed of focused sub-agents**
✨ **The reliability of sub-agent error handling**
✨ **Complete logging and GitHub tracking**
✨ **Verification that nothing was missed**

All in one Claude Code session! 🚀
