# ADW Guide: Planning Phase (Intelligent Sub-Agent Automation)

Interactive guide with intelligent sub-agent delegation for maximum automation at $0 cost.

## Architecture Overview

This intelligent guide uses Claude Code's **Task tool** to spawn sub-agents within the same session, automating the entire workflow while staying at zero cost (covered by Claude Pro).

### Intelligent Architecture with Sub-Agents

```
Interactive Flow (this guide with sub-agents)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You (in Claude Code CLI)
├── /adw_guide_plan
│   ├── Main orchestrator (this guide)
│   ├── Task → Sub-agent: Fetch & analyze issue
│   ├── Task → Sub-agent: Classify issue type
│   ├── Task → Sub-agent: Generate branch name
│   ├── Task → Sub-agent: Create plan (/feature, /bug, /chore)
│   ├── Task → Sub-agent: Create commit
│   └── Task → Sub-agent: Create pull request
│
All in ONE Claude Code session = $0 (Claude Pro)

Automated Flow (for reference - costs $$$)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trigger_webhook.py (FastAPI server)
├── subprocess.Popen → adw_plan_build.py
    ├── subprocess.run → adw_plan.py
        ├── subprocess.run → claude -p "/classify_issue"
        ├── subprocess.run → claude -p "/generate_branch_name"
        ├── subprocess.run → claude -p "/feature"
        ├── subprocess.run → claude -p "/commit"
        └── subprocess.run → claude -p "/pull_request"

Each subprocess = separate Claude API call = $$$
```

### Key Innovation: Task Tool for Sub-Agents

Instead of manually running each slash command, we use the **Task tool** to delegate to specialized sub-agents:

```markdown
# Old approach (manual):
You run: /classify_issue
You run: /generate_branch_name
You run: /feature
...

# New approach (intelligent delegation):
Task tool spawns: "Classify this issue: {issue_json}"
Task tool spawns: "Generate branch name for {type} issue {number}"
Task tool spawns: "Create implementation plan for {issue}"
...
```

**Benefits:**
- ✅ Fully automated - just provide issue number
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

**IMPORTANT:** This guide uses intelligent sub-agent delegation to automate the entire planning phase. Just provide an issue number and the guide orchestrates everything automatically.

**CRITICAL EXECUTION RULES:**
1. **Never stop until all 13 steps are complete** - Check your TodoWrite list after EVERY step
2. **Mark each step complete immediately** after finishing it using TodoWrite
3. **Automatically proceed to the next pending step** without waiting for user input
4. **Only ask the user questions** at Step 0 (issue number) - everything else runs automatically
5. **After ANY SlashCommand or tool execution completes**, immediately:
   - Log completion to `$LOG_FILE`
   - Post GitHub comment
   - Update your TodoWrite list (mark current step complete, next step in_progress)
   - Continue to the next pending step WITHOUT waiting for user input
   - Check your TodoWrite list to see what's next
   - DO NOT stop or pause - keep executing until all steps are complete
6. **Display final summary only** when Step 13 is marked "completed" in your TodoWrite list

**Why this matters:** The automated system (`adws/adw_plan.py`) runs all steps sequentially without pausing. This interactive guide must match that behavior to provide the same experience. The slash commands now include auto-continuation instructions, so you MUST honor them and keep working.

### Step 0: Gather Information and Initialize

Ask the user: "What is the GitHub issue number you want to work on?"

**As soon as user provides issue number, initialize TodoWrite tracking:**
Create todo list with all 13 steps:
0. Gather Information and Initialize
1. Fetch Issue Details
2. Classify Issue
3. Generate ADW ID
4. Generate Branch Name
5. Create Branch and Initialize Logging
6. Create State File
7. Create Implementation Plan
8. Verify and Store Plan File
9. Create Commit
10. Push and Create Pull Request
11. Complete Planning Phase
12. Verify Logging and Comments

Mark Step 0 as "in_progress" immediately.

Display: "Starting planning phase for issue #{issue_number}"

**Before continuing:** Mark Step 0 complete, mark Step 1 as in_progress.

### Step 1: Fetch Issue Details (Automated with Sub-Agent)

**BEFORE starting Step 1:**
```bash
# Note: LOG_FILE doesn't exist yet, will be created in Step 5
echo "Step 1: Fetching issue details..."
```

Spawn a sub-agent to fetch and analyze the issue:

```markdown
# Use Task tool to delegate issue fetching
Task: Fetch and analyze GitHub issue
Subagent: general-purpose
Prompt: |
  Fetch GitHub issue #{issue_number} and analyze it.

  1. Run: gh issue view {issue_number} --json number,title,body
  2. Parse the JSON response
  3. Display the issue details to me in this format:
     - Issue number
     - Title
     - Body summary
  4. Return the full issue JSON for use in next steps

  File Reference: This mimics adws/adw_modules/github.py:fetch_issue()
```

**File Reference:**
- Automated: `adws/adw_modules/github.py` ANCHOR: `fetch_issue`
- Uses: `gh api` or `gh issue view`

Store the issue JSON for subsequent steps.

Display: "✅ Fetched issue #{issue_number}: {issue_title}"

**Update TodoWrite:** Mark Step 1 complete, Step 2 in_progress. Then immediately continue to Step 2.

### Step 2: Classify Issue (Automated with SlashCommand)

**BEFORE starting Step 2:**
```bash
echo "Step 2: Classifying issue..."
```

**What This Step Does:**
- Uses SlashCommand to classify the issue (creates agent artifacts)
- Mimics `adws/adw_modules/workflow_ops.py:classify_issue()`
- Returns `/feature`, `/bug`, or `/chore`

Execute the classification slash command:

```bash
# Use SlashCommand tool to create agent artifacts
# Note: This will create agent artifacts but without adw_id yet
/classify_issue '{issue_json}'
```

This will automatically:
1. Create: `agents/{temp_id}/issue_classifier/prompts/classify_issue.txt`
2. Create: `agents/{temp_id}/issue_classifier/raw_output.jsonl`
3. Create: `agents/{temp_id}/issue_classifier/raw_output.json`
4. Return the classification: `/feature`, `/bug`, or `/chore`

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py` ANCHOR: `classify_issue`
- Calls: `adws/adw_modules/agent.py` ANCHOR: `execute_template`
- Executes: `.claude/commands/classify_issue.md`
- Agent folder: `agents/{adw_id}/issue_classifier/`

Store the classification for next steps.

Display to user:
```
🔍 Issue Classification: {classification}
```

**Update TodoWrite:** Mark Step 2 complete, Step 3 in_progress. Then immediately continue to Step 3.

### Step 3: Generate ADW ID (Automated)

**BEFORE starting Step 3:**
```bash
echo "Step 3: Generating ADW ID..."
```

**What This Step Does:**
- Creates an 8-character unique identifier
- Mimics `adws/adw_modules/utils.py:make_adw_id()`

Automatically generate ADW ID:

```bash
# This mimics: adws/adw_modules/utils.py:make_adw_id()
ADW_ID=$(python3 -c "import uuid; print(str(uuid.uuid4())[:8])")
```

**File Reference:**
- Automated: `adws/adw_modules/utils.py` ANCHOR: `make_adw_id`

Display: "🆔 ADW ID: `{adw_id}`"

**Update TodoWrite:** Mark Step 3 complete, Step 4 in_progress. Then immediately continue to Step 4.

### Step 4: Generate Branch Name (Automated with SlashCommand)

**BEFORE starting Step 4:**
```bash
echo "Step 4: Generating branch name..."
```

**What This Step Does:**
- Uses SlashCommand to generate semantic branch name (creates agent artifacts)
- Mimics `adws/adw_modules/workflow_ops.py:generate_branch_name()`

Execute the branch name generation slash command:

```bash
# Use SlashCommand tool to create agent artifacts
/generate_branch_name {issue_number} '{classification}' '{issue_title}' {adw_id}
```

This will automatically:
1. Create: `agents/{adw_id}/branch_generator/prompts/generate_branch_name.txt`
2. Create: `agents/{adw_id}/branch_generator/raw_output.jsonl`
3. Create: `agents/{adw_id}/branch_generator/raw_output.json`
4. Return the branch name in format: `{type}-issue-{number}-adw-{adw_id}-{slug}`

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py` ANCHOR: `generate_branch_name`
- Calls: `adws/adw_modules/agent.py` ANCHOR: `execute_template`
- Executes: `.claude/commands/generate_branch_name.md`
- Model: `sonnet` (default in agent.py)
- Agent folder: `agents/{adw_id}/branch_generator/`

Store the branch name.

Display: "✅ Branch name: `{branch_name}`"

**Update TodoWrite:** Mark Step 4 complete, Step 5 in_progress. Then immediately continue to Step 5.

### Step 5: Create Branch and Initialize Logging (Automated)

**BEFORE starting Step 5:**
```bash
echo "Step 5: Creating branch and initializing logging..."
```

**What This Step Does:**
- Creates feature branch
- Initializes logging infrastructure
- Posts first GitHub comment
- Mimics `adws/adw_modules/git_ops.py:create_branch()`

Automatically execute setup:

```bash
# This mimics: adws/adw_modules/git_ops.py:create_branch()
git checkout -b {branch_name}
echo "Step 5: Branch created: {branch_name}"

# This mimics: adws/adw_modules/utils.py:setup_logger()
# Create phase folder (matches automated system structure)
mkdir -p agents/{adw_id}/adw_plan
LOG_FILE="agents/{adw_id}/adw_plan/execution.log"

# Write initial log entries
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW Planning Phase Initialized" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW ID: {adw_id}" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Issue: #{issue_number}" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Branch: {branch_name}" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Log file: $LOG_FILE" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Creating branch and initializing logging" >> $LOG_FILE

# Post first GitHub comment
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting planning phase"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Posted GitHub comment - Starting planning" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Completed - Create Branch and Initialize Logging" >> $LOG_FILE
```

**CRITICAL:** Store `$LOG_FILE` path and use it in ALL subsequent steps.

**File Reference:**
- Automated: `adws/adw_modules/git_ops.py` ANCHOR: `create_branch`
- Logging: `adws/adw_modules/utils.py` ANCHOR: `setup_logger`
- GitHub: `adws/adw_modules/github.py` ANCHOR: `make_issue_comment`

Display: "✅ Branch created: `{branch_name}`"
Display: "📝 Log file initialized: `{log_file}`"

**Update TodoWrite:** Mark Step 5 complete, Step 6 in_progress. Then immediately continue to Step 6.

### Step 6: Create State File (Automated)

**BEFORE starting Step 6:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Starting - Create State File" >> $LOG_FILE
```

**What This Step Does:**
- Creates persistent state for workflow tracking
- Mimics `adws/adw_modules/state.py:ADWState`

Automatically create state file:

```bash
# This mimics: adws/adw_modules/state.py:ADWState.save()
mkdir -p agents/{adw_id}
cat > agents/{adw_id}/adw_state.json << EOF
{
  "adw_id": "{adw_id}",
  "issue_number": "{issue_number}",
  "issue_class": "{classification}",
  "branch_name": "{branch_name}",
  "current_phase": "planning",
  "mode": "interactive_intelligent"
}
EOF

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: State file created" >> $LOG_FILE

# Post to GitHub
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Working on branch: \`{branch_name}\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Posted GitHub comment - Branch info" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Completed - Create State File" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_modules/state.py:ADWState` class
- Save: ANCHOR: `save`
- Load: method `load()` (classmethod)

Display: "✅ State file created: `agents/{adw_id}/adw_state.json`"

**Update TodoWrite:** Mark Step 6 complete, Step 7 in_progress. Then immediately continue to Step 7.

### Step 7: Create Implementation Plan (Automated with SlashCommand)

**BEFORE starting Step 7:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Starting - Create Implementation Plan" >> $LOG_FILE

# Post pre-planning status
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Issue classified as: {classification}"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Posted GitHub comment - Classification" >> $LOG_FILE

gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_planner: ⏳ Creating implementation plan"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Posted GitHub comment - Planning starting" >> $LOG_FILE
```

**What This Step Does:**
- Uses SlashCommand to create detailed implementation plan (creates agent artifacts)
- Mimics `adws/adw_modules/workflow_ops.py:build_plan()`
- Executes the appropriate slash command based on classification

Execute the planning slash command based on classification:

```bash
# Use SlashCommand tool to create agent artifacts
# Execute one of: /feature, /bug, or /chore
{classification} {issue_number} {adw_id} '{issue_json}'
```

This will automatically:
1. Create: `agents/{adw_id}/sdlc_planner/prompts/{feature|bug|chore}.txt`
2. Create: `agents/{adw_id}/sdlc_planner/raw_output.jsonl`
3. Create: `agents/{adw_id}/sdlc_planner/raw_output.json`
4. Create plan file: `specs/issue-{issue_number}-adw-{adw_id}-sdlc_planner-{slug}.md`
5. Return the plan file path

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py` ANCHOR: `build_plan`
- Calls: `adws/adw_modules/agent.py` ANCHOR: `execute_template`
- Executes: `.claude/commands/{chore,bug,feature}.md`
- Model: `opus` for complex planning (from agent.py:SLASH_COMMAND_MODEL_MAP)
- Agent folder: `agents/{adw_id}/sdlc_planner/`

The slash command will create the plan and return the file path.

**AFTER planning completes:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Plan creation completed" >> $LOG_FILE

# Post planning completion
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_planner: ✅ Implementation plan created"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Posted GitHub comment - Plan created" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Completed - Create Implementation Plan" >> $LOG_FILE
```

Display: "✅ Implementation plan created"

**Update TodoWrite:** Mark Step 7 complete, Step 8 in_progress. Then immediately continue to Step 8.

### Step 8: Verify and Store Plan File (Automated)

**BEFORE starting Step 8:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Starting - Verify and Store Plan File" >> $LOG_FILE
```

**What This Step Does:**
- Verifies plan file creation
- Updates state with plan path

Automatically verify and store:

```bash
# Extract plan file path from sub-agent response
PLAN_FILE={plan_file_from_subagent}

# Verify existence
if [ ! -f "$PLAN_FILE" ]; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: ERROR - Plan file not found" >> $LOG_FILE
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ❌ Plan file creation failed"
  exit 1
fi

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Plan file verified: $PLAN_FILE" >> $LOG_FILE

# Update state
jq --arg plan_file "$PLAN_FILE" '.plan_file = $plan_file' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: State updated with plan file" >> $LOG_FILE

# Post to GitHub
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Plan file created: \`$PLAN_FILE\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Posted GitHub comment - Plan file path" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 8: Completed - Verify and Store Plan File" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_plan.py` line 200-224
- State update: `adws/adw_modules/state.py:ADWState.update()` line 28-36

Display: "✅ Plan file verified: `{plan_file}`"

**Update TodoWrite:** Mark Step 8 complete, Step 9 in_progress. Then immediately continue to Step 9.

### Step 9: Create Commit (Automated with SlashCommand)

**BEFORE starting Step 9:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Starting - Create Commit" >> $LOG_FILE
```

**What This Step Does:**
- Uses SlashCommand to create semantic commit (creates agent artifacts)
- Mimics `adws/adw_modules/workflow_ops.py:create_commit()`

Execute the commit slash command:

```bash
# Extract type from classification (remove slash if present)
TYPE=$(echo "{classification}" | sed 's/\///')

# Use SlashCommand tool to create agent artifacts
/commit sdlc_planner $TYPE '{issue_json}'
```

Where `{type}` is `feature`, `bug`, or `chore` (without the slash).

This will automatically:
1. Stage all changes (git add .)
2. Create: `agents/{adw_id}/sdlc_planner/prompts/commit.txt` (if not exists, appends to existing)
3. Analyze the plan file changes
4. Generate semantic commit message following project conventions
5. Create commit with proper attribution
6. Return the commit SHA

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py` ANCHOR: `create_commit`
- Calls: `adws/adw_modules/agent.py` ANCHOR: `execute_template`
- Executes: `.claude/commands/commit.md`
- Git ops: `adws/adw_modules/git_ops.py:commit_changes()` (helper function)
- Model: `sonnet` (default in agent.py)
- Agent folder: `agents/{adw_id}/sdlc_planner/` (reuses planner folder)

**AFTER commit completes:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Commit created" >> $LOG_FILE

# Post commit completion
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_planner: ✅ Plan committed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Posted GitHub comment - Commit created" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 9: Completed - Create Commit" >> $LOG_FILE
```

Display: "✅ Plan committed successfully"

**Update TodoWrite:** Mark Step 9 complete, Step 10 in_progress. Then immediately continue to Step 10.

### Step 10: Push and Create Pull Request (Automated)

**BEFORE starting Step 10:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 10: Starting - Push and Create Pull Request" >> $LOG_FILE
```

**What This Step Does:**
- Pushes branch to remote and creates PR
- Mimics `adws/adw_modules/git_ops.py:finalize_git_operations()`

Execute push and PR creation:

```bash
# Push branch to origin
git push -u origin {branch_name}
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 10: Branch pushed to origin" >> $LOG_FILE

# Create pull request
PR_URL=$(gh pr create --title "[Issue #{issue_number}] {issue_title}" \
  --body "Implementation plan: \`{plan_file}\`

Closes #{issue_number}" --json url -q .url)

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 10: Pull request created: $PR_URL" >> $LOG_FILE

# Post PR creation
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ PR created: $PR_URL"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 10: Posted GitHub comment - PR URL" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 10: Completed - Push and Create Pull Request" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_modules/git_ops.py` ANCHOR: `finalize_git_operations`
- Automated: `adws/adw_modules/workflow_ops.py` ANCHOR: `create_pull_request`

Store PR URL from command response.

Display: "✅ Pull request created: {pr_url}"

**Update TodoWrite:** Mark Step 10 complete, Step 11 in_progress. Then immediately continue to Step 11.

### Step 11: Complete Planning Phase (Automated)

**BEFORE starting Step 11:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 11: Starting - Complete Planning Phase" >> $LOG_FILE
```

**What This Step Does:**
- Finalizes state file
- Posts completion messages
- Displays comprehensive summary

Update state:

```bash
# This mimics: adws/adw_modules/state.py:ADWState.save()
jq '.current_phase = "planning_complete" | .pr_url = "{pr_url}"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 11: State updated to planning_complete" >> $LOG_FILE
```

Post completion:

```bash
# Post completion comment
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Planning phase completed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 11: Posted GitHub comment - Planning complete" >> $LOG_FILE

# Post final state
FINAL_STATE=$(cat agents/{adw_id}/adw_state.json | jq -r .)
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: 📋 Final planning state:
\`\`\`json
$FINAL_STATE
\`\`\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 11: Posted GitHub comment - Final state" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 11: Completed - Complete Planning Phase" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_plan.py` line 266-278

**Update TodoWrite:** Mark Step 11 complete, Step 12 in_progress. Then immediately continue to Step 12.

### Step 12: Verify Logging and Comments (FINAL CHECK) ✅

**BEFORE starting Step 12:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 12: Starting - Verify Logging and Comments" >> $LOG_FILE
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
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 12: Log file has $LOG_ENTRIES entries" >> $LOG_FILE

# Show log summary to user
echo "=== Planning Log Summary ==="
echo "Log file: $LOG_FILE"
echo "Total entries: $LOG_ENTRIES"
echo ""
echo "Recent entries:"
tail -10 "$LOG_FILE"

# Verify GitHub comments were posted
echo ""
echo "=== GitHub Comments Verification ==="
echo "Checking issue #{issue_number} for ADW-BOT comments..."
gh issue view {issue_number} --comments | grep "ADW-BOT.*{adw_id}" | tail -10

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 12: Completed - Verify Logging and Comments" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ALL STEPS COMPLETE - Planning phase successful" >> $LOG_FILE
```

**Update TodoWrite:** Mark Step 12 complete. Verify ALL 13 steps (0-12) show "completed" status.

Display comprehensive summary to user:

```markdown
✅ Planning phase complete!

**What was created:**
- Branch: `{branch_name}`
- State file: `agents/{adw_id}/adw_state.json`
- Plan file: `{plan_file}`
- Log file: `agents/{adw_id}/logs/adw_guide_plan_*.log`
- Pull request: {pr_url}

**Artifacts created (identical to automated system):**
```
agents/{adw_id}/
├── adw_state.json                           # State tracking
├── adw_plan/                                # PHASE folder for planning
│   └── execution.log                        # Phase-level log (matches automated)
├── issue_classifier/                        # AGENT folder (slash command artifacts)
│   ├── prompts/
│   │   └── classify_issue.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
├── branch_generator/                        # AGENT folder (slash command artifacts)
│   ├── prompts/
│   │   └── generate_branch_name.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
└── sdlc_planner/                           # AGENT folder (SDLC planner artifacts)
    ├── prompts/
    │   ├── {feature|bug|chore}.txt
    │   └── commit.txt
    ├── raw_output.jsonl
    └── raw_output.json
```

**Folder Structure Notes:**
- **PHASE folders** (`adw_plan/`): Created by us, contain phase execution logs
- **AGENT folders** (`sdlc_planner/`, `issue_classifier/`): Created automatically by SlashCommand tool
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
1. ✅ Issue fetcher
2. ✅ Issue classifier (via /classify_issue)
3. ✅ Branch name generator (via /generate_branch_name)
4. ✅ Implementation planner (via /{classification})
5. ✅ Commit creator (via /commit)

**Next steps:**
1. Review the plan file: `{plan_file}`
2. When ready to implement: `/adw_guide_build {adw_id}`

**Cost so far:** $0 (all sub-agents in Claude Pro session) ✨

**Time saved:** ~5-10 minutes of manual slash command execution!
```

**FINAL STEP:** You are now DONE with the planning phase. All 13 steps are complete.

## Intelligent Architecture Comparison

### Old Interactive Mode (Manual Slash Commands)
```
Claude Code CLI Session
├── You manually run: /classify_issue
├── Wait for result
├── You manually run: /generate_branch_name
├── Wait for result
├── You manually run: /feature
├── Wait for result
├── You manually run: /commit
├── Wait for result
└── You manually run: /pull_request

Time: ~10-15 minutes of manual work
Cost: $0 (Claude Pro)
Logging: Manual (often forgotten)
GitHub comments: Manual (often forgotten)
```

### New Intelligent Mode (Sub-Agent Delegation with Tracking)
```
Claude Code CLI Session
├── You run: /adw_guide_plan {issue_number}
├── Auto-initialize: Logging and GitHub tracking
├── Task spawns: Issue fetcher (runs automatically)
├── SlashCommand: Issue classifier (runs automatically + logs)
├── SlashCommand: Branch generator (runs automatically + logs)
├── SlashCommand: Plan creator (runs automatically + logs)
├── SlashCommand: Commit creator (runs automatically + logs)
├── Auto: PR creator (runs automatically + logs)
└── Auto-verify: All logs and comments created

Time: ~2-3 minutes (mostly automated)
Cost: $0 (all sub-agents in same Claude Pro session)
Logging: Automatic, complete, timestamped
GitHub comments: Automatic at every step
```

### Automated Mode (External Processes - For Reference)
```
trigger_webhook.py (FastAPI server)
├── subprocess.Popen → adw_plan_build.py
    ├── subprocess.run → adw_plan.py
        ├── subprocess.run → claude -p "/classify_issue"      $$
        ├── subprocess.run → claude -p "/generate_branch"     $$
        ├── subprocess.run → claude -p "/feature"             $$
        ├── subprocess.run → claude -p "/commit"              $$
        └── subprocess.run → claude -p "/pull_request"        $$

Time: ~5-7 minutes (fully automated)
Cost: $$$ (5 separate Claude API calls)
Logging: Automatic
GitHub comments: Automatic
```

## Sub-Agent Best Practices

### When to Use Task Tool vs Direct Slash Commands

**Use Task Tool (Sub-Agent) When:**
- ✅ Task requires research/analysis (like fetching issue)
- ✅ Task generates content independently
- ✅ Task needs error handling/retries
- ✅ You want parallel execution
- ✅ Task is complex and benefits from focused attention

**Use Direct Slash Command When:**
- ✅ Task is classification or generation (slash commands exist)
- ✅ Task creates agent artifacts
- ✅ Task is deterministic
- ✅ You want immediate inline execution

### Parallel Sub-Agent Execution

You can spawn multiple sub-agents in parallel for independent tasks:

```markdown
# Spawn classification and ADW ID generation in parallel
Task 1: Classify issue
Bash: Generate ADW ID
(Both can run simultaneously in same session)
```

**File Reference:**
- Claude Code supports parallel tool calls
- All tools share the same session context
- Still $0 cost (covered by Claude Pro)

## Error Handling with Sub-Agents

Sub-agents provide better error handling:

```markdown
# Sub-agent automatically retries on failure
Task: Create implementation plan
If fails: Sub-agent can analyze error and retry with corrections
If still fails: Main orchestrator gets clear error message
```

**Benefits:**
- Automatic retry logic
- Better error messages
- Graceful degradation
- User stays informed

## Resuming Workflows

If ADW ID is provided as argument:

```bash
# Load existing state
STATE_FILE="agents/$1/adw_state.json"
if [ -f "$STATE_FILE" ]; then
  ADW_ID=$(jq -r '.adw_id' $STATE_FILE)
  ISSUE_NUMBER=$(jq -r '.issue_number' $STATE_FILE)
  CURRENT_PHASE=$(jq -r '.current_phase' $STATE_FILE)

  echo "Resuming workflow: $ADW_ID"
  echo "Current phase: $CURRENT_PHASE"

  # Use sub-agent to determine what's left to do
  Task: Analyze workflow state and resume
  Subagent: general-purpose
  Prompt: Analyze this state and complete remaining steps: {state}
fi
```

**File Reference:**
- State loading: `adws/adw_modules/state.py:ADWState.load()` (classmethod)

## Variables

- `$1` = Issue number (required for new workflow)
- OR `$1` = ADW ID (to resume existing workflow)

## Logging and Issue Updates

### Log File Format
All logs are created in `agents/{adw_id}/adw_plan/execution.log` (matches automated system) with timestamped entries:
```
[2025-10-22T17:19:24Z] ========================================
[2025-10-22T17:19:24Z] ADW Planning Phase Initialized
[2025-10-22T17:19:24Z] ADW ID: 61d49d73
[2025-10-22T17:19:24Z] Issue: #20
[2025-10-22T17:19:24Z] ========================================
[2025-10-22T17:19:25Z] Step 5: Creating branch and initializing logging
[2025-10-22T17:19:26Z] Step 5: Posted GitHub comment - Starting planning
[2025-10-22T17:19:26Z] Step 5: Completed - Create Branch and Initialize Logging
...
[2025-10-22T17:25:00Z] ALL STEPS COMPLETE - Planning phase successful
```

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in planning phase:
- `ops` - Operational messages (starting, completion, state)
- `sdlc_planner` - Planning-specific messages

Common emojis:
- ✅ Success/completion
- ⏳ In progress
- ❌ Error
- ⚠️ Warning
- 📋 Information/state

Example sequence of comments for a successful plan:
```
[ADW-BOT] 61d49d73_ops: ✅ Starting planning phase
[ADW-BOT] 61d49d73_ops: ✅ Working on branch: `feature-issue-20-adw-61d49d73-social-media-footer`
[ADW-BOT] 61d49d73_ops: ✅ Issue classified as: /feature
[ADW-BOT] 61d49d73_sdlc_planner: ⏳ Creating implementation plan
[ADW-BOT] 61d49d73_sdlc_planner: ✅ Implementation plan created
[ADW-BOT] 61d49d73_ops: ✅ Plan file created: `specs/issue-20-adw-61d49d73-sdlc_planner-social-media-footer.md`
[ADW-BOT] 61d49d73_sdlc_planner: ✅ Plan committed
[ADW-BOT] 61d49d73_ops: ✅ PR created: https://github.com/...
[ADW-BOT] 61d49d73_ops: ✅ Planning phase completed
[ADW-BOT] 61d49d73_ops: 📋 Final planning state: { ... }
```

## Key Advantages of Sub-Agent Approach

1. **Fully Automated**: Just provide issue number, everything else is handled
2. **Intelligent Delegation**: Sub-agents handle complex tasks independently
3. **Parallel Execution**: Independent tasks run simultaneously
4. **Better Error Handling**: Sub-agents can retry and self-correct
5. **Zero Cost**: All sub-agents run in same Claude Pro session
6. **Identical Artifacts**: Produces same output as expensive automated system
7. **Complete Tracking**: Full logging and GitHub comments
8. **Time Savings**: ~10 minutes of manual work → ~2 minutes automated

## What to Do

- **DO** initialize logging as soon as branch is created (Step 5)
- **DO** log every step start and completion to `$LOG_FILE`
- **DO** post GitHub comments at major milestones
- **DO** use Task tool for complex, independent tasks
- **DO** spawn sub-agents in parallel when tasks don't depend on each other
- **DO** let sub-agents handle errors and retries
- **DO** keep user informed of progress
- **DO** create same artifacts as automated system
- **DO** verify logging and comments at the end

## What NOT to Do

- **DON'T** skip Step 5 (logging initialization)
- **DON'T** forget to log step start/completion
- **DON'T** forget to post GitHub comments
- **DON'T** spawn external processes (costs money)
- **DON'T** manually run slash commands when sub-agent can do it
- **DON'T** wait for sequential execution if tasks can run in parallel
- **DON'T** call Anthropic API directly (Claude Code handles it)
- **DON'T** forget to update TodoWrite after each step

## File References Summary

All file references point to the actual automated system implementation:

- **Webhook**: `adws/adw_triggers/trigger_webhook.py`
- **Orchestrator**: `adws/adw_plan_build.py`, `adws/adw_plan.py`
- **Workflow Logic**: `adws/adw_modules/workflow_ops.py`
- **Agent Execution**: `adws/adw_modules/agent.py` (ANCHOR: `execute_template`)
- **State Management**: `adws/adw_modules/state.py`
- **Git Operations**: `adws/adw_modules/git_ops.py`
- **GitHub API**: `adws/adw_modules/github.py`
- **Utilities**: `adws/adw_modules/utils.py` (ANCHOR: `setup_logger`)

## The Bottom Line

This intelligent guide with sub-agent delegation gives you:

✨ **The automation of the $$ webhook system**
✨ **The zero cost of interactive Claude Pro**
✨ **The speed of parallel execution**
✨ **The reliability of sub-agent error handling**
✨ **Complete logging and GitHub tracking**
✨ **Verification that nothing was missed**

All in one Claude Code session! 🚀
