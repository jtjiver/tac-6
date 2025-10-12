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

## Instructions

**IMPORTANT:** This guide uses intelligent sub-agent delegation to automate the entire planning phase. Just provide an issue number and the guide orchestrates everything automatically.

### Step 1: Gather Information

Ask the user: "What is the GitHub issue number you want to work on?"

Once provided, spawn a sub-agent to fetch and analyze the issue:

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
- Automated: `adws/adw_modules/github.py:fetch_issue()` line 49-93
- Uses: `gh api` or `gh issue view`

Store the issue JSON for subsequent steps.

### Step 2: Classify the Issue (Automated with Sub-Agent)

**What This Step Does:**
- Spawns a sub-agent to classify the issue
- Mimics `adws/adw_modules/workflow_ops.py:classify_issue()`
- Returns `/feature`, `/bug`, or `/chore`

Automatically delegate to classification sub-agent:

```markdown
# Use Task tool to delegate classification
Task: Classify GitHub issue type
Subagent: general-purpose
Prompt: |
  Classify this GitHub issue and determine the appropriate workflow type.

  Issue JSON: {issue_json}

  Analyze and determine if this is:
  - **Feature**: New functionality or enhancement → return "/feature"
  - **Bug**: Something broken that needs fixing → return "/bug"
  - **Chore**: Maintenance, refactoring, documentation, or cleanup → return "/chore"

  Read the classification guide: .claude/commands/classify_issue.md

  Return ONLY the classification: /feature, /bug, or /chore

  File Reference: This mimics adws/adw_modules/workflow_ops.py:classify_issue() line 98-146
```

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py:classify_issue()` line 98-146
- Calls: `adws/adw_modules/agent.py:execute_template("/classify_issue")` line 262-299
- Executes: `.claude/commands/classify_issue.md`

The sub-agent will analyze and return the classification. Store it for next steps.

Display to user:
```
🔍 Issue Classification: {classification}
```

### Step 3: Generate ADW ID (Automated)

**What This Step Does:**
- Creates an 8-character unique identifier
- Mimics `adws/adw_modules/utils.py:make_adw_id()`

Automatically generate ADW ID:

```bash
# This mimics: adws/adw_modules/utils.py:make_adw_id()
ADW_ID=$(python3 -c "import uuid; print(str(uuid.uuid4())[:8])")
```

**File Reference:**
- Automated: `adws/adw_modules/utils.py:make_adw_id()` line 31-36

Display: "🆔 ADW ID: `{adw_id}`"

### Step 4: Generate Branch Name (Automated with Sub-Agent)

**What This Step Does:**
- Spawns a sub-agent to generate semantic branch name
- Mimics `adws/adw_modules/workflow_ops.py:generate_branch_name()`

Delegate branch name generation to sub-agent:

```markdown
# Use Task tool to delegate branch name generation
Task: Generate semantic branch name
Subagent: general-purpose
Prompt: |
  Generate a semantic branch name for this issue.

  Issue: #{issue_number} - {issue_title}
  Classification: {classification} (feature/bug/chore)
  ADW ID: {adw_id}

  Read the branch naming guide: .claude/commands/generate_branch_name.md

  Format: {type}-issue-{number}-adw-{adw_id}-{slug}

  Where:
  - {type} = feature, bug, or chore (without slash)
  - {number} = {issue_number}
  - {adw_id} = {adw_id}
  - {slug} = short descriptive slug (3-5 words, kebab-case)

  Return ONLY the branch name, nothing else.

  File Reference: This mimics adws/adw_modules/workflow_ops.py:generate_branch_name() line 205-235
```

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py:generate_branch_name()` line 205-235
- Calls: `adws/adw_modules/agent.py:execute_template("/generate_branch_name")` line 262-299
- Executes: `.claude/commands/generate_branch_name.md`
- Model: `sonnet` (line 27 in agent.py)

Store the branch name.

### Step 5: Create Branch and Initialize Logging (Automated)

**What This Step Does:**
- Creates feature branch
- Initializes logging infrastructure
- Mimics `adws/adw_modules/git_ops.py:create_branch()`

Automatically execute setup:

```bash
# This mimics: adws/adw_modules/git_ops.py:create_branch()
git checkout -b {branch_name}

# This mimics: adws/adw_modules/utils.py:setup_logger()
mkdir -p agents/{adw_id}/logs
LOG_FILE="agents/{adw_id}/logs/adw_guide_plan_$(date +%s).log"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Planning phase started for issue #{issue_number}" >> $LOG_FILE

# Post to GitHub
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting planning phase"
```

**File Reference:**
- Automated: `adws/adw_modules/git_ops.py:create_branch()` line 13-35
- Logging: `adws/adw_modules/utils.py:setup_logger()` line 56-80
- GitHub: `adws/adw_modules/github.py:make_issue_comment()` line 95-127

Display: "✅ Branch created: `{branch_name}`"

### Step 6: Create State File (Automated)

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

# Post to GitHub
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Working on branch: \`{branch_name}\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] State file created" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_modules/state.py:ADWState` class
- Save: line 38-58, Load: line 60-82

Display: "✅ State file created: `agents/{adw_id}/adw_state.json`"

### Step 7: Create Implementation Plan (Automated with Sub-Agent)

**What This Step Does:**
- Spawns a sub-agent to create detailed implementation plan
- Mimics `adws/adw_modules/workflow_ops.py:build_plan()`
- Executes the appropriate slash command based on classification

Post pre-planning status:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Issue classified as: {classification}"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running {classification} planning command" >> $LOG_FILE
```

Delegate plan creation to specialized sub-agent:

```markdown
# Use Task tool to delegate plan creation
Task: Create detailed implementation plan
Subagent: general-purpose
Prompt: |
  Create a detailed implementation plan for this GitHub issue.

  Issue Number: {issue_number}
  ADW ID: {adw_id}
  Classification: {classification}
  Issue Details: {issue_json}

  Execute the appropriate planning command:
  {classification} {issue_number} {adw_id} '{issue_json}'

  This will:
  1. Analyze the issue requirements thoroughly
  2. Research the codebase structure
  3. Identify files to modify
  4. Create step-by-step implementation plan
  5. Write plan to: specs/issue-{issue_number}-adw-{adw_id}-sdlc_planner-{slug}.md
  6. Return the full path to the created plan file

  IMPORTANT: Return ONLY the plan file path, nothing else.

  File Reference:
  - Mimics: adws/adw_modules/workflow_ops.py:build_plan() line 149-175
  - Calls: adws/adw_modules/agent.py:execute_template() line 262-299
  - Executes: .claude/commands/{chore,bug,feature}.md
  - Model: opus (from agent.py:SLASH_COMMAND_MODEL_MAP line 48-51)
```

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py:build_plan()` line 149-175
- Calls: `adws/adw_modules/agent.py:execute_template()` line 262-299
- Executes: `.claude/commands/{chore,bug,feature}.md`
- Model: `opus` for complex planning

The sub-agent will create the plan and return the file path.

Post planning completion:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_planner: ✅ Implementation plan created"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Plan creation completed" >> $LOG_FILE
```

### Step 8: Verify and Store Plan File (Automated)

**What This Step Does:**
- Verifies plan file creation
- Updates state with plan path

Automatically verify and store:

```bash
# Extract plan file path from sub-agent response
PLAN_FILE={plan_file_from_subagent}

# Verify existence
if [ ! -f "$PLAN_FILE" ]; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Plan file not found" >> $LOG_FILE
  gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ❌ Plan file creation failed"
  exit 1
fi

# Update state
jq --arg plan_file "$PLAN_FILE" '.plan_file = $plan_file' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

# Post to GitHub
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Plan file created: \`$PLAN_FILE\`"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Plan file verified: $PLAN_FILE" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_plan.py` line 200-224
- State update: `adws/adw_modules/state.py:ADWState.update()` line 28-36

Display: "✅ Plan file verified: `{plan_file}`"

### Step 9: Create Commit (Automated with Sub-Agent)

**What This Step Does:**
- Spawns a sub-agent to create semantic commit
- Mimics `adws/adw_modules/workflow_ops.py:create_commit()`

Delegate commit creation to sub-agent:

```markdown
# Use Task tool to delegate commit creation
Task: Create semantic commit for plan
Subagent: general-purpose
Prompt: |
  Create a semantic commit for the implementation plan.

  Agent: sdlc_planner
  Type: {type} (feature/bug/chore without slash)
  Issue: {issue_json}

  Execute the commit command:
  /commit sdlc_planner {type} '{issue_json}'

  This will:
  1. Stage all changes (git add .)
  2. Analyze the plan file changes
  3. Generate semantic commit message following project conventions
  4. Create commit with proper attribution
  5. Return the commit SHA

  IMPORTANT: Ensure the commit is created successfully.

  File Reference:
  - Mimics: adws/adw_modules/workflow_ops.py:create_commit() line 238-272
  - Calls: adws/adw_modules/agent.py:execute_template("/commit")
  - Executes: .claude/commands/commit.md
  - Model: sonnet (from agent.py line 45)
```

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py:create_commit()` line 238-272
- Calls: `adws/adw_modules/agent.py:execute_template("/commit")` line 262-299
- Executes: `.claude/commands/commit.md`
- Git ops: `adws/adw_modules/git_ops.py:commit_changes()` line 37-56

Post commit completion:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_planner: ✅ Plan committed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Commit created" >> $LOG_FILE
```

Display: "✅ Plan committed successfully"

### Step 10: Push and Create Pull Request (Automated with Sub-Agent)

**What This Step Does:**
- Pushes branch to remote
- Spawns sub-agent to create or update PR
- Mimics `adws/adw_modules/git_ops.py:finalize_git_operations()`

First, push the branch:

```bash
# This mimics: adws/adw_modules/git_ops.py:finalize_git_operations() line 110-123
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Pushing branch to remote" >> $LOG_FILE
git push -u origin {branch_name}
```

**File Reference:**
- Automated: `adws/adw_modules/git_ops.py:finalize_git_operations()` line 80-139

Then delegate PR creation to sub-agent:

```markdown
# Use Task tool to delegate PR creation
Task: Create or update pull request
Subagent: general-purpose
Prompt: |
  Create or update a pull request for this implementation plan.

  Branch: {branch_name}
  Issue: {issue_json}
  Plan File: {plan_file}
  ADW ID: {adw_id}

  Execute the pull request command:
  /pull_request {branch_name} '{issue_json}' {plan_file} {adw_id}

  This will:
  1. Check if PR already exists for this branch
  2. If exists: Add comment with plan summary
  3. If new: Create PR with:
     - Title: Link to issue + summary
     - Body: Plan overview + testing checklist
     - Link to issue
  4. Return the PR URL

  IMPORTANT: Return the full PR URL.

  File Reference:
  - Mimics: adws/adw_modules/workflow_ops.py:create_pull_request() line 275-325
  - Calls: adws/adw_modules/agent.py:execute_template("/pull_request")
  - Executes: .claude/commands/pull_request.md
  - Model: sonnet (from agent.py line 46)
```

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py:create_pull_request()` line 275-325
- Calls: `adws/adw_modules/agent.py:execute_template("/pull_request")` line 262-299
- Executes: `.claude/commands/pull_request.md`

Post PR creation:

```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Pull request created/updated" >> $LOG_FILE
```

Store PR URL from sub-agent response.

### Step 11: Complete Planning Phase (Automated)

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

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Planning phase completed" >> $LOG_FILE
```

Post completion:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Planning phase completed"

# Post final state
FINAL_STATE=$(cat agents/{adw_id}/adw_state.json | jq -r .)
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: 📋 Final planning state:
\`\`\`json
$FINAL_STATE
\`\`\`"
```

**File Reference:**
- Automated: `adws/adw_plan.py` line 266-278

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
├── logs/
│   └── adw_guide_plan_{timestamp}.log       # Execution log
├── issue_classifier/                        # From classification sub-agent
│   └── output/
├── branch_generator/                        # From branch name sub-agent
│   └── output/
├── sdlc_planner/                           # From planning sub-agent
│   └── output/
└── pr_creator/                             # From PR creation sub-agent
    └── output/
```

**Sub-agents spawned (all in same session = $0):**
1. ✅ Issue fetcher
2. ✅ Issue classifier
3. ✅ Branch name generator
4. ✅ Implementation planner
5. ✅ Commit creator
6. ✅ PR creator

**GitHub issue updated:** Issue #{issue_number} has been updated with progress

**Next steps:**
1. Review the plan file: `{plan_file}`
2. When ready to implement: `/adw_guide_build {adw_id}`

**Cost so far:** $0 (all sub-agents in Claude Pro session) ✨

**Time saved:** ~5-10 minutes of manual slash command execution!
```

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
```

### New Intelligent Mode (Sub-Agent Delegation)
```
Claude Code CLI Session
├── You run: /adw_guide_plan {issue_number}
├── Task spawns: Issue classifier (runs automatically)
├── Task spawns: Branch generator (runs automatically)
├── Task spawns: Plan creator (runs automatically)
├── Task spawns: Commit creator (runs automatically)
└── Task spawns: PR creator (runs automatically)

Time: ~2-3 minutes (mostly automated)
Cost: $0 (all sub-agents in same Claude Pro session)
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
```

## Sub-Agent Best Practices

### When to Use Task Tool vs Direct Slash Commands

**Use Task Tool (Sub-Agent) When:**
- ✅ Task requires research/analysis (like classification)
- ✅ Task generates content (like plan creation)
- ✅ Task needs error handling/retries
- ✅ You want parallel execution
- ✅ Task is complex and benefits from focused attention

**Use Direct Slash Command When:**
- ✅ Task is simple and deterministic
- ✅ Task is a bash operation (git commands)
- ✅ Task just needs to read/write files
- ✅ You want immediate inline execution

### Parallel Sub-Agent Execution

You can spawn multiple sub-agents in parallel for independent tasks:

```markdown
# Spawn classification and branch name generation in parallel
Task 1: Classify issue
Task 2: Generate ADW ID
(Both run simultaneously in same session)
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
- State loading: `adws/adw_modules/state.py:ADWState.load()` line 60-82

## Variables

- `$1` = Issue number (required for new workflow)
- OR `$1` = ADW ID (to resume existing workflow)

## Key Advantages of Sub-Agent Approach

1. **Fully Automated**: Just provide issue number, everything else is handled
2. **Intelligent Delegation**: Sub-agents handle complex tasks independently
3. **Parallel Execution**: Independent tasks run simultaneously
4. **Better Error Handling**: Sub-agents can retry and self-correct
5. **Zero Cost**: All sub-agents run in same Claude Pro session
6. **Identical Artifacts**: Produces same output as expensive automated system
7. **Time Savings**: ~10 minutes of manual work → ~2 minutes automated

## What to Do

- **DO** use Task tool for complex, independent tasks
- **DO** spawn sub-agents in parallel when tasks don't depend on each other
- **DO** let sub-agents handle errors and retries
- **DO** keep user informed of progress
- **DO** create same artifacts as automated system

## What NOT to Do

- **DON'T** spawn external processes (costs money)
- **DON'T** manually run slash commands when sub-agent can do it
- **DON'T** wait for sequential execution if tasks can run in parallel
- **DON'T** call Anthropic API directly (Claude Code handles it)

## File References Summary

All file references point to the actual automated system implementation:

- **Webhook**: `adws/adw_triggers/trigger_webhook.py`
- **Orchestrator**: `adws/adw_plan_build.py`, `adws/adw_plan.py`
- **Workflow Logic**: `adws/adw_modules/workflow_ops.py`
- **Agent Execution**: `adws/adw_modules/agent.py` (line 192-209 for `claude -p`)
- **State Management**: `adws/adw_modules/state.py`
- **Git Operations**: `adws/adw_modules/git_ops.py`
- **GitHub API**: `adws/adw_modules/github.py`
- **Utilities**: `adws/adw_modules/utils.py`

## The Bottom Line

This intelligent guide with sub-agent delegation gives you:

✨ **The automation of the $$ webhook system**
✨ **The zero cost of interactive Claude Pro**
✨ **The speed of parallel execution**
✨ **The reliability of sub-agent error handling**

All in one Claude Code session! 🚀
