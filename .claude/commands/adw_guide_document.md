# ADW Guide: Documentation Phase (Intelligent Sub-Agent Automation)

Interactive guide with intelligent sub-agent delegation for maximum automation at $0 cost.

## Architecture Overview

This intelligent guide uses Claude Code's **SlashCommand tool** for documentation generation, automating the entire documentation workflow while staying at zero cost (covered by Claude Pro).

### Intelligent Architecture with Sub-Agents

```
Interactive Flow (this guide with sub-agents)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You (in Claude Code CLI)
├── /adw_guide_document
│   ├── Main orchestrator (this guide)
│   ├── Task → Sub-agent: Load state and verify branch
│   ├── Task → Sub-agent: Check for changes
│   ├── Task → Sub-agent: Find spec file
│   ├── SlashCommand → /document (generates documentation)
│   ├── Task → Sub-agent: Create commit
│   └── Task → Sub-agent: Push and update PR
│
All in ONE Claude Code session = $0 (Claude Pro)

Automated Flow (for reference - costs $$$)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trigger_webhook.py (FastAPI server)
├── subprocess.Popen → adw_document.py
    ├── subprocess.run → claude -p "/document"
    └── subprocess.run → claude -p "/commit"

Each subprocess = separate Claude API call = $$$
```

### Key Innovation: Task Tool for Sub-Agents

Instead of manually running each documentation command, we use the **Task tool** to delegate to specialized sub-agents:

```markdown
# Old approach (manual):
You check for changes
You run: /document
You run: /commit
...

# New approach (intelligent delegation):
Task tool spawns: "Check for git changes"
Task tool spawns: "Generate documentation from spec and diff"
Task tool spawns: "Create documentation commit"
...
```

**Benefits:**
- ✅ Fully automated - just provide ADW ID
- ✅ Sub-agents run in parallel when possible
- ✅ Still $0 cost (same Claude Code session)
- ✅ More robust error handling
- ✅ Better progress tracking
- ✅ Automatically handles no-change scenarios

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

**IMPORTANT:** This guide uses intelligent sub-agent delegation to automate the entire documentation phase. Just provide an ADW ID and the guide orchestrates everything automatically.

**CRITICAL EXECUTION RULES:**
1. **Never stop until all 8 steps are complete** - Check your TodoWrite list after EVERY step
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
6. **Display final summary only** when Step 7 is marked "completed" in your TodoWrite list

**Why this matters:** The automated system (`adws/adw_document.py`) runs all steps sequentially without pausing. This interactive guide must match that behavior to provide the same experience. The slash commands now include auto-continuation instructions, so you MUST honor them and keep working.

### Step 0: Initialize Logging (MUST DO FIRST) ⚠️

**This step happens BEFORE you ask for ADW ID!**

Ask the user: "What is the ADW ID for the workflow you want to document?"

**As soon as user provides ADW ID, initialize TodoWrite tracking:**
Create todo list with all 8 steps:
0. Initialize Logging
1. Load State and Verify Branch
2. Check for Changes
3. Find Specification File and Screenshots
4. Generate Documentation
5. Create Commit
6. Push and Update PR
7. Complete Documentation Phase

Mark Step 0 as "in_progress" immediately.

**Initialize logging FIRST (before doing anything else):**

```bash
# CRITICAL: Create log file and store path in variable
ADW_ID="{user_provided_adw_id}"
# Create phase folder (matches automated system structure)
mkdir -p agents/$ADW_ID/adw_document
LOG_FILE="agents/$ADW_ID/adw_document/execution.log"

# Write initial log entry
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW Documentation Phase Initialized" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ADW ID: $ADW_ID" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Log file: $LOG_FILE" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE

# Display log file path for confirmation
echo "📝 Log file initialized: $LOG_FILE"
```

**CRITICAL:** Store `$LOG_FILE` path and use it in ALL subsequent steps.

**File Reference:**
- Automated: `adws/adw_modules/utils.py:setup_logger()` ANCHOR: `setup_logger`

Display: "✅ Logging initialized: `{log_file}`"

**Before continuing:** Mark Step 0 complete, mark Step 1 as in_progress.

### Step 1: Load State and Verify Branch (Automated with Sub-Agent)

**BEFORE starting Step 1:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Starting - Load State and Verify Branch" >> $LOG_FILE
```

**What This Step Does:**
- Loads workflow state
- Verifies required fields exist
- Checks out the correct git branch
- Mimics `adws/adw_document.py` lines 220-266

Spawn a sub-agent to load and verify state:

```markdown
# Use Task tool to delegate state loading
Task: Load ADW state and verify branch
Subagent: general-purpose
Prompt: |
  Load the ADW workflow state and checkout the correct branch.

  ADW ID: {adw_id}

  1. Load state from: agents/{adw_id}/adw_state.json
  2. Verify state exists
  3. Verify required fields:
     - issue_number
     - branch_name
  4. Extract state data
  5. Checkout the branch: git checkout {branch_name}
  6. Verify checkout success
  7. Return state data including issue_number and branch_name

  File Reference: This mimics adws/adw_document.py lines 220-266
```

**File Reference:**
- Automated: `adws/adw_document.py` lines 220-266
- State loading: `adws/adw_modules/state.py:ADWState.load()` (function ~lines 78-100)
- Logging: `adws/adw_modules/utils.py:setup_logger()` ANCHOR: `setup_logger`

Store the state data for subsequent steps.

**AFTER state loads:**
```bash
# Extract issue number from state
ISSUE_NUMBER="{issue_number_from_state}"
BRANCH_NAME="{branch_name_from_state}"

# Log state loaded
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: State loaded for issue #$ISSUE_NUMBER" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Branch: $BRANCH_NAME" >> $LOG_FILE

# Post initial GitHub comment
gh issue comment $ISSUE_NUMBER --body "📚 **Documentation Generation Started**

ADW ID: \`{adw_id}\`
Checking for changes against origin/main..."

# Log GitHub comment posted
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Posted GitHub comment - Starting documentation" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 1: Completed - Load State and Verify Branch" >> $LOG_FILE
```

Display: "✅ State loaded: Issue #{issue_number}, Branch: {branch_name}"

**Update TodoWrite:** Mark Step 1 complete, Step 2 in_progress. Then immediately continue to Step 2.

### Step 2: Check for Changes (Automated with Sub-Agent)

**BEFORE starting Step 2:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Starting - Check for Changes" >> $LOG_FILE
```

**What This Step Does:**
- Checks if there are changes between current branch and origin/main
- If no changes, skips documentation generation
- Mimics `adws/adw_document.py:check_for_changes()` lines 66-94

Spawn a sub-agent to check for changes:

```markdown
# Use Task tool to delegate change detection
Task: Check for git changes against main branch
Subagent: general-purpose
Prompt: |
  Check if there are changes between current branch and origin/main.

  1. Run: git diff origin/main --stat
  2. Analyze the output
  3. Determine if changes exist (non-empty output = changes exist)
  4. If changes exist:
     - Log the change summary
     - Return: {"has_changes": true, "summary": "<diff stat output>"}
  5. If no changes:
     - Log that no changes were found
     - Return: {"has_changes": false, "summary": "No changes"}

  File Reference: This mimics adws/adw_document.py:check_for_changes() lines 66-94
```

**File Reference:**
- Automated: `adws/adw_document.py:check_for_changes()` lines 66-94

**AFTER change check:**
```bash
HAS_CHANGES={has_changes_from_subagent}

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Changes detected: $HAS_CHANGES" >> $LOG_FILE

if [ "$HAS_CHANGES" = "false" ]; then
  # No changes - skip documentation
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: No changes - skipping documentation generation" >> $LOG_FILE

  # Post GitHub comment
  gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_ops: ℹ️ No changes detected between current branch and origin/main - skipping documentation generation"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Posted GitHub comment - No changes" >> $LOG_FILE

  # Complete step
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Completed - Check for Changes (no changes found)" >> $LOG_FILE

  # Skip to Step 7 (completion)
  # Mark Steps 2-6 as completed, Step 7 as in_progress

  # Jump directly to Step 7
else
  # Changes found - continue with documentation
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Changes found - proceeding with documentation" >> $LOG_FILE
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 2: Completed - Check for Changes (changes found)" >> $LOG_FILE
fi
```

Display: "✅ Changes detected: {has_changes}"

**Update TodoWrite:** Mark Step 2 complete, Step 3 in_progress (or Step 7 if no changes). Then immediately continue to next step.

### Step 3: Find Specification File and Screenshots (Automated with Sub-Agent)

**BEFORE starting Step 3:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Starting - Find Specification File and Screenshots" >> $LOG_FILE
```

**What This Step Does:**
- Locates the specification file from state
- Finds review screenshots if available
- Mimics `adws/adw_document.py:generate_documentation()` lines 134-150

Spawn a sub-agent to find spec and screenshots:

```markdown
# Use Task tool to delegate file location
Task: Find specification file and screenshots
Subagent: general-purpose
Prompt: |
  Find the specification file and screenshots for documentation.

  ADW ID: {adw_id}
  State: {state_data}

  1. Find spec file:
     - Check state.plan_file first
     - If not found, search specs/ directory for issue-{issue_number}-adw-{adw_id}*.md

  2. Find screenshots:
     - Check state.review_screenshots for screenshot URLs/paths
     - If found, extract the directory path from first screenshot
     - If not found, check: agents/{adw_id}/reviewer/review_img/
     - If directory exists and has files, use it

  3. Return:
     - spec_path: path to spec file or empty string
     - screenshots_dir: path to screenshots directory or empty string
     - screenshot_count: number of screenshots found

  File Reference: This mimics adws/adw_document.py:generate_documentation() lines 134-150
```

**File Reference:**
- Automated: `adws/adw_document.py:generate_documentation()` lines 134-150
- Spec finding: `adws/adw_modules/workflow_ops.py:find_spec_file()` lines 547-594

**AFTER finding files:**
```bash
SPEC_PATH="{spec_path_from_subagent}"
SCREENSHOTS_DIR="{screenshots_dir_from_subagent}"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Spec file: $SPEC_PATH" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Screenshots dir: $SCREENSHOTS_DIR" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 3: Completed - Find Specification File and Screenshots" >> $LOG_FILE
```

Display: "✅ Found spec: `{spec_path}`, Screenshots: `{screenshots_dir}`"

**Update TodoWrite:** Mark Step 3 complete, Step 4 in_progress. Then immediately continue to Step 4.

### Step 4: Generate Documentation (Automated with SlashCommand)

**BEFORE starting Step 4:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Starting - Generate Documentation" >> $LOG_FILE

# Post pre-documentation GitHub comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_documenter: ⏳ Generating documentation"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Posted GitHub comment - Documentation starting" >> $LOG_FILE
```

**What This Step Does:**
- Uses SlashCommand to generate comprehensive documentation
- Analyzes git diff against origin/main
- Creates markdown documentation in app_docs/
- Copies screenshots to app_docs/assets/
- Updates conditional_docs.md
- Mimics `adws/adw_document.py:generate_documentation()` lines 152-202

Execute the documentation slash command:

```bash
# Prepare arguments for /document command
# Arguments: adw_id, spec_path (or empty), screenshots_dir (if exists)

# Use SlashCommand tool to create agent artifacts
if [ -n "$SCREENSHOTS_DIR" ]; then
  /document {adw_id} {spec_path} {screenshots_dir}
else
  /document {adw_id} {spec_path}
fi
```

This will automatically:
1. Create: `agents/{adw_id}/documenter/prompts/document.txt`
2. Create: `agents/{adw_id}/documenter/raw_output.jsonl`
3. Create: `agents/{adw_id}/documenter/raw_output.json`
4. Analyze git diff against origin/main to understand changes
5. Read specification file if provided
6. Copy screenshots from review_img/ to app_docs/assets/
7. Generate enhanced documentation artifacts:
   - **Context Diagram**: Visual representation of system components and their relationships
   - **Sequence Diagram**: Flow of interactions for key feature operations
   - **Database Schema Diagram**: Entity relationships and data model (if applicable)
   - **Filesystem Tree**: Directory structure showing app/client and app/server key files
   - Export diagrams to: `app_docs/assets/diagrams/{adw_id}/`
8. Generate documentation in format:
   - Overview of what was built
   - Screenshots section with relative paths
   - Enhanced diagrams section with context/sequence/schema/filesystem diagrams
   - Technical implementation details
   - How to use the feature
   - Configuration and testing info
9. Create documentation file: `app_docs/feature-{adw_id}-{descriptive-name}.md`
10. Update `.claude/commands/conditional_docs.md` with new entry
11. Return the documentation file path

**File Reference:**
- Automated: `adws/adw_document.py:generate_documentation()` lines 152-202
- Calls: `adws/adw_modules/agent.py:execute_template()` ANCHOR: `execute_template`
- Executes: `.claude/commands/document.md`
- Model: `sonnet` (from agent.py:SLASH_COMMAND_MODEL_MAP)
- Agent folder: `agents/{adw_id}/documenter/`

**AFTER /document completes:**
```bash
DOCUMENTATION_PATH="{doc_path_from_slash_command}"

# Log documentation created
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Documentation created: $DOCUMENTATION_PATH" >> $LOG_FILE

# Post GitHub success comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_documenter: ✅ Documentation generated at \`$DOCUMENTATION_PATH\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Posted GitHub comment - Documentation created" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 4: Completed - Generate Documentation" >> $LOG_FILE
```

Display: "✅ Documentation created: `{documentation_path}`"

**Update TodoWrite:** Mark Step 4 complete, Step 5 in_progress. Then immediately continue to Step 5.

### Step 5: Create Commit (Automated with SlashCommand)

**BEFORE starting Step 5:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Starting - Create Commit" >> $LOG_FILE
```

**What This Step Does:**
- Uses SlashCommand to create semantic commit
- Commits documentation files
- Mimics `adws/adw_document.py` lines 297-333

Execute the commit slash command:

```bash
# Extract issue class from state (should be "feature", "bug", or "chore" WITHOUT slash)
ISSUE_CLASS="{issue_class_from_state_without_slash}"

# Get issue JSON for commit context
ISSUE_JSON=$(gh issue view $ISSUE_NUMBER --json number,title,body)

# Use SlashCommand tool to create agent artifacts
/commit documenter $ISSUE_CLASS "$ISSUE_JSON"
```

This will automatically:
1. Create: `agents/{adw_id}/documenter/prompts/commit.txt` (appends if exists)
2. Stage all changes (git add .)
3. Analyze the documentation changes
4. Generate semantic commit message following project conventions
5. Create commit with proper attribution
6. Return the commit SHA

**File Reference:**
- Automated: `adws/adw_document.py` lines 297-333
- Calls: `adws/adw_modules/workflow_ops.py:create_commit()` ANCHOR: `create_commit`
- Executes: `.claude/commands/commit.md`
- Model: `sonnet` (fast commit generation)
- Agent folder: `agents/{adw_id}/documenter/` (reuses documenter folder)

**AFTER /commit completes:**
```bash
# Log commit created
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Documentation committed" >> $LOG_FILE

# Post GitHub success comment
gh issue comment $ISSUE_NUMBER --body "[ADW-BOT] {adw_id}_documenter: ✅ Documentation committed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Posted GitHub comment - Commit created" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 5: Completed - Create Commit" >> $LOG_FILE
```

Display: "✅ Documentation committed"

**Update TodoWrite:** Mark Step 5 complete, Step 6 in_progress. Then immediately continue to Step 6.

### Step 6: Push and Update PR (Automated)

**BEFORE starting Step 6:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Starting - Push and Update PR" >> $LOG_FILE
```

**What This Step Does:**
- Pushes documentation to remote
- Updates existing PR
- Mimics `adws/adw_document.py` lines 336-336

Push changes:

```bash
# This mimics: adws/adw_modules/git_ops.py:finalize_git_operations()
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Pushing changes to remote" >> $LOG_FILE
git push

# Check if PR exists and update it
if gh pr view &>/dev/null; then
  gh pr comment --body "[ADW-BOT] {adw_id}_ops: ✅ Documentation committed and pushed"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Updated PR with documentation status" >> $LOG_FILE
fi

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 6: Completed - Push and Update PR" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_document.py` line 336
- Git operations: `adws/adw_modules/git_ops.py:finalize_git_operations()` lines 80-139

Display: "✅ Changes pushed to remote"

**Update TodoWrite:** Mark Step 6 complete, Step 7 in_progress. Then immediately continue to Step 7.

### Step 7: Complete Documentation Phase (FINAL STEP) ✅

**BEFORE starting Step 7:**
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Starting - Complete Documentation Phase" >> $LOG_FILE
```

**What This Step Does:**
- Posts completion messages
- Updates state file
- Displays comprehensive summary
- Mimics `adws/adw_document.py` lines 338-360

Post completion:

```bash
# Post completion comment
gh issue comment $ISSUE_NUMBER --body "✅ **Documentation Workflow Completed**

ADW ID: \`{adw_id}\`
Documentation has been created at \`$DOCUMENTATION_PATH\` and committed."

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Posted GitHub comment - Documentation complete" >> $LOG_FILE

# Update state with documentation path
# This mimics: adws/adw_modules/state.py:ADWState.save()
jq '.documentation_path = "'"$DOCUMENTATION_PATH"'"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: State updated with documentation path" >> $LOG_FILE

# Complete step
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Step 7: Completed - Complete Documentation Phase" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ========================================" >> $LOG_FILE
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ALL STEPS COMPLETE - Documentation phase successful" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_document.py` lines 338-360
- State management: `adws/adw_modules/state.py:ADWState.save()` ANCHOR: `save`

**Update TodoWrite:** Mark Step 7 complete. Verify ALL 8 steps (0-7) show "completed" status.

Display comprehensive summary to user:

```markdown
✅ Documentation phase complete!

**What was created:**
- Documentation file: `{documentation_path}`
- Conditional docs updated: `.claude/commands/conditional_docs.md`
- Screenshots copied: `app_docs/assets/` (if applicable)
- State updated: `agents/{adw_id}/adw_state.json`

**Artifacts created (identical to automated system):**
```
agents/{adw_id}/
├── adw_state.json                           # Updated state
├── adw_document/                            # PHASE folder for documentation
│   └── execution.log                        # Phase-level log (matches automated)
└── documenter/                              # AGENT folder (documenter artifacts)
    ├── prompts/
    │   ├── document.txt
    │   └── commit.txt
    ├── raw_output.jsonl
    └── raw_output.json

app_docs/
├── feature-{adw_id}-{descriptive-name}.md   # Generated documentation
└── assets/                                   # Screenshots (if applicable)
    ├── 01_screenshot.png
    └── 02_screenshot.png
```

**Folder Structure Notes:**
- **PHASE folders** (`adw_document/`): Created by us, contain phase execution logs
- **AGENT folders** (`documenter/`): Created automatically by SlashCommand tool
- **Documentation location**: All docs live in `app_docs/` directory
```

**Logging verification:**
- Log file: `{log_file}`
- Total log entries: {log_entry_count}
- All steps logged ✅

**GitHub issue tracking:**
- Issue #{issue_number} updated with ADW-BOT comments
- All major milestones tracked ✅

**Documentation details:**
- File: `{documentation_path}`
- Screenshots: {screenshot_count} copied to assets/
- Conditional docs: Updated ✅

**Sub-agents spawned (all in same session = $0):**
1. ✅ State loader and branch verifier
2. ✅ Change detector
3. ✅ Spec and screenshot finder
4. ✅ Documentation generator (via /document)
5. ✅ Commit creator (via /commit)

**Next steps:**
1. Review the documentation file: `{documentation_path}`
2. Verify screenshots are rendering correctly
3. Check conditional_docs.md entry

**Cost so far:** $0 (all sub-agents in Claude Pro session) ✨

**Time saved:** ~10-15 minutes of manual documentation writing!
```

**FINAL STEP:** You are now DONE with the documentation phase. All 8 steps are complete.

## Intelligent Architecture Comparison

### Old Interactive Mode (Manual Documentation)
```
Claude Code CLI Session
├── You manually analyze git diff
├── You manually read spec
├── You manually write documentation
├── You manually copy screenshots
├── You manually update conditional_docs.md
├── You manually commit
└── You manually push

Time: ~20-30 minutes of manual work
Cost: $0 (Claude Pro)
Logging: Manual (often forgotten)
GitHub comments: Manual (often forgotten)
```

### New Intelligent Mode (Sub-Agent Delegation with Tracking)
```
Claude Code CLI Session
├── You run: /adw_guide_document {adw_id}
├── Auto-initialize: Logging and GitHub tracking
├── Task spawns: State loader (runs automatically)
├── Task spawns: Change detector (runs automatically)
├── Task spawns: File finder (runs automatically)
├── SlashCommand: Documentation generator (runs automatically + logs)
├── SlashCommand: Commit creator (runs automatically + logs)
├── Bash: Git operations (runs automatically + logs)
└── Auto-verify: All logs and comments created

Time: ~3-5 minutes (mostly automated)
Cost: $0 (all sub-agents in same Claude Pro session)
Logging: Automatic, complete, timestamped
GitHub comments: Automatic at every step
```

### Automated Mode (External Processes - For Reference)
```
adw_document.py
├── subprocess.run → claude -p "/document"      $$
└── subprocess.run → claude -p "/commit"        $$

Time: ~5-7 minutes
Cost: $$$ (2 separate Claude API calls)
Logging: Automatic
GitHub comments: Automatic
```

## Sub-Agent Best Practices

### When to Use Task Tool vs Direct Commands

**Use Task Tool (Sub-Agent) When:**
- ✅ Task requires analysis (change detection, file finding)
- ✅ Task generates content independently
- ✅ Task needs error handling/retries
- ✅ Task benefits from focused attention

**Use Direct Slash Command When:**
- ✅ Task is documentation generation (slash command exists)
- ✅ Task creates agent artifacts
- ✅ Task is deterministic (commit creation)
- ✅ You want immediate inline execution

## Special Case: No Changes Detected

The documentation phase gracefully handles scenarios where no changes exist:

```bash
# If no changes detected in Step 2:
1. Skip documentation generation (Steps 3-6)
2. Post informational comment to GitHub
3. Update state to indicate no documentation needed
4. Jump directly to Step 7 (completion)
5. Exit successfully
```

**File Reference:**
- No-change handling: `adws/adw_document.py` lines 109-131
- Success without documentation: `adws/adw_document.py` lines 282-340

## Variables

- `$1` = ADW ID (required for documentation to find state and artifacts)

## Logging and Issue Updates

### Log File Format
All logs are created in `agents/{adw_id}/adw_document/execution.log` (matches automated system) with timestamped entries:
```
[2025-10-24T10:30:00Z] ========================================
[2025-10-24T10:30:00Z] ADW Documentation Phase Initialized
[2025-10-24T10:30:00Z] ADW ID: 61d49d73
[2025-10-24T10:30:00Z] ========================================
[2025-10-24T10:30:01Z] Step 1: Starting - Load State and Verify Branch
[2025-10-24T10:30:02Z] Step 1: State loaded for issue #20
[2025-10-24T10:30:02Z] Step 1: Completed - Load State and Verify Branch
...
[2025-10-24T10:35:00Z] ALL STEPS COMPLETE - Documentation phase successful
```

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in documentation phase:
- `ops` - Operational messages (starting, completion, state)
- `documenter` - Documentation-specific messages

Common emojis:
- ✅ Success/completion
- ⏳ In progress
- ❌ Error
- ⚠️ Warning
- 📚 Documentation-related
- ℹ️ Information

Example sequence of comments for a successful documentation run:
```
📚 Documentation Generation Started
ADW ID: `61d49d73`
Checking for changes against origin/main...

[ADW-BOT] 61d49d73_documenter: ⏳ Generating documentation
[ADW-BOT] 61d49d73_documenter: ✅ Documentation generated at `app_docs/feature-61d49d73-social-media-footer.md`
[ADW-BOT] 61d49d73_documenter: ✅ Documentation committed

✅ Documentation Workflow Completed
ADW ID: `61d49d73`
Documentation has been created at `app_docs/feature-61d49d73-social-media-footer.md` and committed.
```

## Key Advantages of Sub-Agent Approach

1. **Fully Automated**: Just provide ADW ID, everything else is handled
2. **Intelligent Delegation**: Sub-agents handle analysis and generation independently
3. **Graceful Handling**: Automatically detects and handles no-change scenarios
4. **Zero Cost**: All sub-agents run in same Claude Pro session
5. **Identical Artifacts**: Produces same output as expensive automated system
6. **Complete Tracking**: Full logging and GitHub comments
7. **Screenshot Management**: Automatically copies and references review screenshots
8. **Time Savings**: ~20 minutes of manual work → ~3 minutes automated

## What to Do

- **DO** initialize logging FIRST (Step 0)
- **DO** log every step start and completion to `$LOG_FILE`
- **DO** post GitHub comments at major milestones
- **DO** use Task tool for analysis tasks (change detection, file finding)
- **DO** let sub-agents handle errors and retries
- **DO** gracefully handle no-change scenarios
- **DO** keep user informed of progress
- **DO** create same artifacts as automated system

## What NOT to Do

- **DON'T** skip Step 0 (logging initialization)
- **DON'T** forget to log step start/completion
- **DON'T** forget to post GitHub comments
- **DON'T** spawn external processes (costs money)
- **DON'T** manually write documentation when /document can do it
- **DON'T** force documentation when no changes exist
- **DON'T** call Anthropic API directly (Claude Code handles it)
- **DON'T** forget to update TodoWrite after each step

## File References Summary

All file references point to the actual automated system implementation:

- **Documentation Orchestrator**: `adws/adw_document.py`
- **Workflow Operations**: `adws/adw_modules/workflow_ops.py`
- **State Management**: `adws/adw_modules/state.py`
- **Git Operations**: `adws/adw_modules/git_ops.py`
- **GitHub API**: `adws/adw_modules/github.py`
- **Agent Execution**: `adws/adw_modules/agent.py` ANCHOR: `execute_template`
- **Document Command**: `.claude/commands/document.md`
- **Commit Command**: `.claude/commands/commit.md`
- **Utilities**: `adws/adw_modules/utils.py` ANCHOR: `setup_logger`

## The Bottom Line

This intelligent guide with sub-agent delegation gives you:

✨ **The automation of the $$ webhook system**
✨ **The zero cost of interactive Claude Pro**
✨ **The speed of focused sub-agents**
✨ **The reliability of sub-agent error handling**
✨ **Complete logging and GitHub tracking**
✨ **Professional documentation with screenshots**
✨ **Verification that nothing was missed**

All in one Claude Code session! 🚀
