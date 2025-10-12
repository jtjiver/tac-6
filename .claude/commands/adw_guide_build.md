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

## Instructions

**IMPORTANT:** This guide uses intelligent sub-agent delegation to automate the entire implementation phase. Just provide an ADW ID and the guide orchestrates everything automatically.

**CRITICAL EXECUTION RULES:**
1. **Never stop until all 8 steps are complete** - Check your TodoWrite list after EVERY step
2. **Mark each step complete immediately** after finishing it using TodoWrite
3. **Automatically proceed to the next pending step** without waiting for user input
4. **Only ask the user questions** at Step 1 (ADW ID) - everything else runs automatically
5. **If a slash command completes** (e.g., /implement, /commit), immediately continue with the next step
6. **Display final summary only** when Step 8 is marked "completed" in your TodoWrite list

**Why this matters:** The automated system (`adws/adw_build.py`) runs all steps sequentially without pausing. This interactive guide must match that behavior to provide the same experience.

### Step 1: Load State and Initialize (Automated)

Ask the user: "What is the ADW ID you want to continue working on?"

**Initialize TodoWrite tracking:**
Create todo list with all 8 steps:
1. Load State and Initialize
2. Verify Branch
3. Locate Plan File
4. Implement Solution
5. Review Changes
6. Create Commit
7. Update State
8. Complete Build Phase

Mark Step 1 as "in_progress" immediately.

Once provided, spawn a sub-agent to load and verify the state:

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
- Automated: `adws/adw_modules/state.py:ADWState.load()` line 60-82
- Build: `adws/adw_build.py` line 100-150

Initialize logging:
```bash
mkdir -p agents/{adw_id}/logs
LOG_FILE="agents/{adw_id}/logs/adw_guide_build_$(date +%s).log"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Build phase started for issue #{issue_number}" >> $LOG_FILE
```

Post to GitHub:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting implementation phase"
```

Display: "Found workflow for issue #{issue_number} on branch `{branch_name}`"

### Step 2: Verify Branch (Automated)

Automatically check and switch to correct branch:

```bash
# This mimics: adws/adw_modules/git_ops.py:ensure_branch()
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "{branch_name}" ]; then
  git checkout {branch_name}
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Switched to branch {branch_name}" >> $LOG_FILE
fi

gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Working on branch: \`{branch_name}\`"
```

**File Reference:**
- Automated: `adws/adw_build.py` line 152-180

Display: "✅ On branch: `{branch_name}`"

### Step 3: Locate Plan File (Automated with Sub-Agent)

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
- Automated: `adws/adw_build.py` line 182-210

Store plan file path and log:
```bash
PLAN_FILE={plan_file_from_subagent}
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Using plan file: $PLAN_FILE" >> $LOG_FILE
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Found plan: \`$PLAN_FILE\`"
```

Display: "✅ Plan file located: `{plan_file}`"

### Step 4: Implement Solution (Automated with SlashCommand)

**What This Step Does:**
- Uses SlashCommand to implement all changes from the plan (creates agent artifacts)
- Mimics `adws/adw_modules/workflow_ops.py:implement_solution()`

Post pre-implementation status:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_implementor: ✅ Implementing solution from plan"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running /implement command" >> $LOG_FILE
```

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
- Automated: `adws/adw_modules/workflow_ops.py:implement_solution()` line 328-365
- Calls: `adws/adw_modules/agent.py:execute_template("/implement")` line 262-299
- Executes: `.claude/commands/implement.md`
- Model: `opus` for complex implementation
- Agent folder: `agents/{adw_id}/sdlc_implementor/`

The slash command will implement the solution and report completion.

Post implementation status with detailed summary:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Implementation complete" >> $LOG_FILE

# Post detailed implementation summary to GitHub issue
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_implementor: ✅ Implementation Complete

## Feature Implemented
{Brief description of what was built}

## Changes Made
{Bullet points of key changes:
- Files modified with descriptions
- New features added
- Enhancements made
- Technical details}

## Validation
{Results from running validation commands:
- TypeScript check results
- Build results
- Test results}

## Files Changed
\`\`\`
{Output from git diff --stat}
\`\`\`

Ready for testing phase."
```

**IMPORTANT:** The implementation summary should include:
- What feature/fix was implemented
- Which files were modified and what changed
- Validation results (TypeScript, build, tests)
- Git diff stats showing lines changed

Display: "✅ Implementation complete with summary posted to issue"

**IMPORTANT:** Mark Step 4 as completed in TodoWrite and immediately proceed to Step 5. DO NOT wait for user input.

### Step 5: Review Changes (Automated)

**What This Step Does:**
- Shows user what was changed
- Prepares for commit

Automatically show changes:
```bash
# This mimics: adws/adw_build.py review changes section
git status
git diff --stat

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Changes reviewed" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_build.py` line 240-265

Display summary of changes to user.

### Step 6: Create Commit (Automated with SlashCommand)

**What This Step Does:**
- Uses SlashCommand to create semantic commit (creates agent artifacts)
- Mimics `adws/adw_modules/workflow_ops.py:create_commit()`

Post pre-commit status:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Creating commit" >> $LOG_FILE
```

Execute the commit slash command:

```bash
# Use SlashCommand tool to create agent artifacts
/commit sdlc_implementor {type} '{issue_json}'
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
- Automated: `adws/adw_modules/workflow_ops.py:create_commit()` line 238-272
- Calls: `adws/adw_modules/agent.py:execute_template("/commit")` line 262-299
- Executes: `.claude/commands/commit.md`
- Git ops: `adws/adw_modules/git_ops.py:commit_changes()` line 37-56
- Model: `sonnet` (fast commit generation)
- Agent folder: `agents/{adw_id}/sdlc_implementor/` (reuses implementor folder)

Post commit completion:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_sdlc_implementor: ✅ Implementation committed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Changes committed" >> $LOG_FILE
```

Display: "✅ Changes committed successfully"

**IMPORTANT:** Mark Step 6 as completed in TodoWrite and immediately proceed to Step 7. DO NOT wait for user input.

### Step 7: Update State (Automated)

**What This Step Does:**
- Updates workflow state to indicate build completion
- Mimics `adws/adw_modules/state.py:ADWState.save()`

Automatically update state:
```bash
# This mimics: adws/adw_modules/state.py:ADWState.save()
jq '.current_phase = "build_complete" | .plan_file = "'"$PLAN_FILE"'"' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] State updated to build_complete" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_modules/state.py:ADWState.save()` line 38-58
- Build: `adws/adw_build.py` line 290-310

Display: "✅ State updated: build_complete"

### Step 8: Complete Build Phase (Automated)

**What This Step Does:**
- Posts completion messages
- Provides next steps guidance

Post completion:
```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Implementation phase completed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Build phase completed" >> $LOG_FILE

# Post final state
FINAL_STATE=$(cat agents/{adw_id}/adw_state.json | jq -r .)
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: 📋 Build phase state:
\`\`\`json
$FINAL_STATE
\`\`\`"
```

**File Reference:**
- Automated: `adws/adw_build.py` line 312-330

**FINAL STEP:** Mark Step 8 as completed in TodoWrite. Verify ALL 8 steps show "completed" status. You are now done with the build phase.

Display comprehensive summary to user:

```markdown
✅ Implementation phase complete!

**What was done:**
- Loaded workflow state for ADW ID: {adw_id}
- Switched to branch: `{branch_name}`
- Located plan file: `{plan_file}`
- Implemented all changes from plan
- Changes committed to branch

**Artifacts created (identical to automated system):**
```
agents/{adw_id}/
├── adw_state.json                           # Updated state
├── logs/
│   └── adw_guide_build_{timestamp}.log      # Build phase log
└── sdlc_implementor/                        # Implementation artifacts
    └── output/
```

**Sub-agents spawned (all in same session = $0):**
1. ✅ State loader
2. ✅ Plan file locator
3. ✅ Solution implementor
4. ✅ Commit creator

**GitHub issue updated:** Issue #{issue_number} has been updated with progress

**Next steps:**
1. Run tests: `/adw_guide_test {adw_id}`
2. Or skip to review: `/adw_guide_review {adw_id}`
3. Or skip to PR: `/adw_guide_pr {adw_id}`

**Cost so far:** $0 (all sub-agents in Claude Pro session) ✨

**Time saved:** ~5-8 minutes of manual implementation and commits!
```

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
```

### New Intelligent Mode (Sub-Agent Delegation)
```
Claude Code CLI Session
├── You run: /adw_guide_build {adw_id}
├── Task spawns: State loader (runs automatically)
├── Task spawns: Plan locator (runs automatically)
├── Task spawns: Implementor (runs automatically)
└── Task spawns: Committer (runs automatically)

Time: ~3-5 minutes (mostly automated)
Cost: $0 (all sub-agents in same Claude Pro session)
```

### Automated Mode (External Processes - For Reference)
```
adw_plan_build.py → adw_build.py
    ├── subprocess.run → claude -p "/implement"      $$
    └── subprocess.run → claude -p "/commit"         $$

Time: ~8-10 minutes
Cost: $$$ (2 separate Claude API calls)
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
- State loading: `adws/adw_modules/state.py:ADWState.load()` line 60-82

## Variables

- `$1` = ADW ID (required for build phase)
- OR `$1` = Can be omitted to search for latest interactive workflow

## Logging and Issue Updates

### GitHub Issue Comment Format
All status updates follow this format:
```
[ADW-BOT] {adw_id}_{agent_name}: {emoji} {message}
```

Agent names used in build phase:
- `ops` - Operational messages (starting, completion)
- `sdlc_implementor` - Implementation-specific messages

Common emojis:
- ✅ Success/completion
- ❌ Error
- ⚠️ Warning

### Logging Pattern
Logs are created in `agents/{adw_id}/logs/adw_guide_build_{timestamp}.log` with entries like:
```
[2025-10-12T16:35:00Z] Build phase started for issue #123
[2025-10-12T16:35:15Z] Using plan file: specs/issue-123-adw-abc12345-feature.md
[2025-10-12T16:36:45Z] Running /implement command
[2025-10-12T16:40:00Z] Implementation complete
[2025-10-12T16:40:30Z] Changes committed
[2025-10-12T16:40:35Z] Build phase completed
```

## What to Do

- **DO** use Task tool for complex implementation
- **DO** spawn sub-agents for time-consuming tasks
- **DO** let sub-agents handle errors and retries
- **DO** keep user informed of progress
- **DO** create same artifacts as automated system
- **DO** post status updates to GitHub issues

## What NOT to Do

- **DON'T** spawn external processes (costs money)
- **DON'T** manually run commands when sub-agent can do it
- **DON'T** call Anthropic API directly (Claude Code handles it)

## File References Summary

All file references point to the actual automated system implementation:

- **Build Script**: `adws/adw_build.py`
- **Workflow Logic**: `adws/adw_modules/workflow_ops.py`
- **Agent Execution**: `adws/adw_modules/agent.py` (line 192-209 for `claude -p`)
- **State Management**: `adws/adw_modules/state.py`
- **Git Operations**: `adws/adw_modules/git_ops.py`
- **GitHub API**: `adws/adw_modules/github.py`
- **Utilities**: `adws/adw_modules/utils.py`

## The Bottom Line

This intelligent guide with sub-agent delegation gives you:

✨ **The automation of the $$ build system**
✨ **The zero cost of interactive Claude Pro**
✨ **The speed of focused sub-agents**
✨ **The reliability of sub-agent error handling**

All in one Claude Code session! 🚀
