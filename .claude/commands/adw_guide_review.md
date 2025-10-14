# ADW Guide: Review Phase (Intelligent Sub-Agent Automation)

Interactive guide with intelligent sub-agent delegation for maximum automation at $0 cost.

## Architecture Overview

This intelligent guide uses Claude Code's **SlashCommand tool** for critical review operations that need artifact preservation, automating the entire review workflow while staying at zero cost (covered by Claude Pro).

### Intelligent Architecture with Sub-Agents

```
Interactive Flow (this guide with sub-agents)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You (in Claude Code CLI)
├── /adw_guide_review
│   ├── Main orchestrator (this guide)
│   ├── Task → Sub-agent: Load state
│   ├── Task → Sub-agent: Find spec file
│   ├── Task → Sub-agent: Run implementation review (/review)
│   ├── Task → Sub-agent: Upload screenshots to R2
│   ├── Task → Sub-agent: Analyze review results
│   ├── Task → Sub-agent: Resolve blockers (/patch)
│   ├── Task → Sub-agent: Create commit
│   └── Task → Sub-agent: Update PR
│
All in ONE Claude Code session = $0 (Claude Pro)

Automated Flow (for reference - costs $$$)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trigger_webhook.py (FastAPI server)
├── subprocess.Popen → adw_review.py
    ├── subprocess.run → claude -p "/review"
    ├── subprocess.run → upload screenshots to R2
    ├── subprocess.run → claude -p "/patch" (for each blocker)
    ├── subprocess.run → claude -p "/commit"
    └── subprocess.run → claude -p "/pull_request"

Each subprocess = separate Claude API call = $$$
```

### Key Innovation: Task Tool for Sub-Agents

Instead of manually running each slash command, we use the **Task tool** to delegate to specialized sub-agents:

```markdown
# Old approach (manual):
You run: /review
You analyze results
You run: /patch for each blocker
You run: /commit
...

# New approach (intelligent delegation):
Task tool spawns: "Review implementation against spec: {spec_file}"
Task tool spawns: "Upload screenshots to R2: {screenshots}"
Task tool spawns: "Resolve blocker issue: {issue_description}"
Task tool spawns: "Create review commit"
...
```

**Benefits:**
- ✅ Fully automated - just provide ADW ID
- ✅ Sub-agents run in parallel when possible
- ✅ Still $0 cost (same Claude Code session)
- ✅ More robust error handling
- ✅ Better progress tracking
- ✅ Screenshots automatically uploaded to cloud storage

## Variables

- `$1` = ADW ID (required for review to find state and spec)

## Instructions

**IMPORTANT:** This guide uses intelligent sub-agent delegation to automate the entire review phase. Just provide an ADW ID and the guide orchestrates everything automatically.

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

**Why this matters:** The automated system (`adws/adw_review.py`) runs all steps sequentially without pausing. This interactive guide must match that behavior to provide the same experience. The slash commands now include auto-continuation instructions, so you MUST honor them and keep working.

### Step 1: Load State and Initialize (Automated with Sub-Agent)

**What This Step Does:**
- Spawns sub-agent to load state file
- Initializes logging infrastructure
- Mimics `adws/adw_review.py` state loading

Ask the user: "What is the ADW ID for the workflow you want to review?"

**Initialize TodoWrite tracking:**
Create todo list with all 9 steps:
1. Load State and Initialize
2. Find Specification File
3. Run Implementation Review
4. Upload Screenshots to R2
5. Post Review Results to GitHub
6. Resolve Blocker Issues
7. Create Review Commit
8. Push and Update PR
9. Complete Review Phase

Mark Step 1 as "in_progress" immediately.

Once provided, spawn a sub-agent to load and verify state:

```markdown
# Use Task tool to delegate state loading
Task: Load ADW state and initialize review
Subagent: general-purpose
Prompt: |
  Load the ADW workflow state and initialize review phase.

  ADW ID: {adw_id}

  1. Load state from: agents/{adw_id}/adw_state.json
  2. Verify required fields exist:
     - issue_number
     - branch_name
     - plan_file (or spec file path)
  3. Initialize logging:
     - Create: agents/{adw_id}/logs/adw_guide_review_{timestamp}.log
     - Log entry: "Review phase started for issue #{issue_number}"
  4. Checkout the branch from state
  5. Post to GitHub: gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Starting review phase"
  6. Return the state data including issue_number, branch_name, plan_file

  File Reference: This mimics adws/adw_review.py lines 432-492
```

**File Reference:**
- Automated: `adws/adw_review.py` lines 432-492
- State loading: `adws/adw_modules/state.py:ADWState.load()` line 60-82
- Logging: `adws/adw_modules/utils.py:setup_logger()` line 56-80

Store the state data for subsequent steps.

Display: "✅ State loaded: Issue #{issue_number}, Branch: {branch_name}"

### Step 2: Find Specification File (Automated with Sub-Agent)

**What This Step Does:**
- Spawns sub-agent to locate spec file
- Mimics `adws/adw_modules/workflow_ops.py:find_spec_file()`

Delegate spec file location to sub-agent:

```markdown
# Use Task tool to delegate spec file location
Task: Find specification file for review
Subagent: general-purpose
Prompt: |
  Find the specification file for this review.

  ADW ID: {adw_id}
  Issue Number: {issue_number}
  State: {state_data}

  Search strategy:
  1. Check state.plan_file first
  2. If not found, search git diff for spec/*.md files
  3. If still not found, search by pattern: specs/issue-{issue_number}-adw-{adw_id}*.md

  Return ONLY the full absolute path to the spec file.

  File Reference: This mimics adws/adw_modules/workflow_ops.py:find_spec_file() lines 537-584
```

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py:find_spec_file()` lines 537-584

Store the spec file path.

Display: "✅ Found specification: `{spec_file}`"

### Step 3: Run Implementation Review (Automated with Sub-Agent)

**What This Step Does:**
- Spawns sub-agent to run comprehensive review
- Executes /review command
- Captures screenshots of UI features
- Mimics `adws/adw_review.py:run_review()`

Post pre-review status:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_reviewer: ✅ Reviewing implementation against specification"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running review" >> $LOG_FILE
```

Execute review using SlashCommand:

```bash
# Use SlashCommand tool to create agent artifacts
/review {adw_id} {spec_file} reviewer
```

This will automatically:
1. Create: `agents/{adw_id}/reviewer/prompts/review.txt`
2. Create: `agents/{adw_id}/reviewer/raw_output.jsonl`
3. Create: `agents/{adw_id}/reviewer/raw_output.json`
4. Compare implementation to specification
5. Check if all requirements are met
6. Identify issues (blockers, tech_debt, skippable)
7. Capture screenshots of critical UI functionality
8. Save screenshots to: `agents/{adw_id}/reviewer/review_img/`
9. Return JSON review result with:
   - success: true/false (based on blocker presence)
   - review_summary: summary text
   - review_issues: array of issues with severity
   - screenshots: array of screenshot paths

**File Reference:**
- Automated: `adws/adw_review.py:run_review()` lines 90-144
- Calls: `adws/adw_modules/agent.py:execute_template()` line 262-299
- Executes: `.claude/commands/review.md`

Store the review result JSON.

**IMPORTANT:** Mark Step 3 as completed in TodoWrite and immediately proceed to Step 4. DO NOT wait for user input.

### Step 4: Upload Screenshots to R2 (Automated with Sub-Agent)

**What This Step Does:**
- Spawns sub-agent to upload screenshots to cloud storage
- Mimics `adws/adw_review.py:upload_and_map_screenshots()`
- Uses `adws/adw_modules/r2_uploader.py`

Delegate screenshot upload to sub-agent:

```markdown
# Use Task tool to delegate screenshot upload
Task: Upload review screenshots to R2 cloud storage
Subagent: general-purpose
Prompt: |
  Upload all review screenshots to Cloudflare R2 and update URLs.

  ADW ID: {adw_id}
  Review Result: {review_result_json}

  For each screenshot in review_result:
  1. Upload to R2 bucket with path: adw/{adw_id}/review/{filename}
  2. Generate public URL: https://{R2_PUBLIC_DOMAIN}/adw/{adw_id}/review/{filename}
  3. Update review_result.screenshot_urls array with public URLs
  4. Update review_result.review_issues[].screenshot_url with public URLs

  Environment variables needed:
  - CLOUDFLARE_ACCOUNT_ID
  - CLOUDFLARE_R2_ACCESS_KEY_ID
  - CLOUDFLARE_R2_SECRET_ACCESS_KEY
  - CLOUDFLARE_R2_BUCKET_NAME
  - CLOUDFLARE_R2_PUBLIC_DOMAIN (default: tac-public-imgs.iddagents.com)

  If R2 is not configured, skip upload and keep local paths.

  Return the updated review result JSON with public URLs.

  File Reference:
  - Mimics: adws/adw_review.py:upload_and_map_screenshots() lines 263-322
  - Uses: adws/adw_modules/r2_uploader.py:R2Uploader
  - Upload method: r2_uploader.py:upload_screenshots() lines 99-126
```

**File Reference:**
- Automated: `adws/adw_review.py:upload_and_map_screenshots()` lines 263-322
- R2 Uploader: `adws/adw_modules/r2_uploader.py:R2Uploader` class
- Upload method: `r2_uploader.py:upload_screenshots()` lines 99-126

Store the updated review result with public URLs.

### Step 5: Post Review Results to GitHub (Automated)

**What This Step Does:**
- Posts formatted review results to GitHub issue
- Mimics `adws/adw_review.py:format_review_comment()`

Automatically format and post review results:

```bash
# This mimics: adws/adw_review.py:format_review_comment() lines 324-408

# Format review comment based on result
if [ "$REVIEW_SUCCESS" = "true" ]; then
  COMMENT="## ✅ Review Passed

The implementation matches the specification.

### Screenshots
{screenshot_urls_as_markdown_images}

### Review Data
\`\`\`json
{review_result_json}
\`\`\`"
else
  COMMENT="## ❌ Review Issues Found

Found {issue_count} issues during review:

### 🚨 Blockers
{blocker_issues_formatted}

### ⚠️ Tech Debt
{tech_debt_issues_formatted}

### ℹ️ Skippable
{skippable_issues_formatted}

### Review Data
\`\`\`json
{review_result_json}
\`\`\`"
fi

# Post to GitHub
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_reviewer: $COMMENT"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Review results posted" >> $LOG_FILE
```

**File Reference:**
- Automated: `adws/adw_review.py:format_review_comment()` lines 324-408

Display review summary to user with blocker count.

### Step 6: Resolve Blocker Issues (Automated with Sub-Agents)

**What This Step Does:**
- Spawns sub-agents to resolve blocker issues
- Creates patch plans for each blocker
- Implements patch plans automatically
- Mimics `adws/adw_review.py:resolve_review_issues()`

If blockers are found, automatically resolve them using SlashCommand:

For each blocker issue:

```bash
# Post status
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_review_patch_planner_{iteration}_{issue_num}: 📝 Creating patch plan"

# Use SlashCommand to create patch plan and artifacts
/patch {adw_id} review_patch_planner_{iteration}_{issue_num} '{review_change_request}' {spec_file} '{screenshots}'
```

This will automatically:
1. Create: `agents/{adw_id}/review_patch_planner_{iteration}_{issue_num}/prompts/patch.txt`
2. Create: `agents/{adw_id}/review_patch_planner_{iteration}_{issue_num}/raw_output.jsonl`
3. Create: `agents/{adw_id}/review_patch_planner_{iteration}_{issue_num}/raw_output.json`
4. Analyze blocker issue and create patch plan
5. Return patch plan file path

Then implement the patch:

```bash
# Use SlashCommand to implement patch and create artifacts
/implement {patch_plan_file} {adw_id} review_patch_implementor_{iteration}_{issue_num}
```

This will automatically:
1. Create: `agents/{adw_id}/review_patch_implementor_{iteration}_{issue_num}/prompts/implement.txt`
2. Create: `agents/{adw_id}/review_patch_implementor_{iteration}_{issue_num}/raw_output.jsonl`
3. Create: `agents/{adw_id}/review_patch_implementor_{iteration}_{issue_num}/raw_output.json`
4. Implement the patch plan
5. Post result to GitHub

Continue to next blocker until all are processed.

**File Reference:**
- Automated: `adws/adw_review.py:resolve_review_issues()` lines 147-260
- Patch creation: `adws/adw_modules/workflow_ops.py:create_and_implement_patch()` lines 587-654
- Executes: `.claude/commands/patch.md` and `.claude/commands/implement.md`

Post resolution results:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Resolution complete: {resolved_count} issues resolved, {failed_count} failed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Blocker resolution completed" >> $LOG_FILE
```

Display: "✅ Resolved {resolved_count} blocker issues"

**IMPORTANT:** Mark Step 6 as completed in TodoWrite and immediately proceed to Step 7. DO NOT wait for user input.

### Step 7: Create Review Commit (Automated with Sub-Agent)

**What This Step Does:**
- Spawns sub-agent to create semantic commit
- Mimics `adws/adw_modules/workflow_ops.py:create_commit()`

Create commit using SlashCommand:

```bash
# Use SlashCommand tool to create agent artifacts
/commit reviewer {type} '{issue_json}'
```

This will automatically:
1. Create: `agents/{adw_id}/reviewer/prompts/commit.txt`
2. Create: `agents/{adw_id}/reviewer/raw_output.jsonl`
3. Create: `agents/{adw_id}/reviewer/raw_output.json`
4. Stage all changes (git add .)
5. Analyze review artifacts and any blocker resolutions
6. Generate semantic commit message following project conventions
7. Create commit with proper attribution
8. Return the commit SHA

**File Reference:**
- Automated: `adws/adw_modules/workflow_ops.py:create_commit()` lines 238-272
- Executes: `.claude/commands/commit.md`

Post commit completion:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_reviewer: ✅ Review committed"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Review commit created" >> $LOG_FILE
```

Display: "✅ Review artifacts committed"

**IMPORTANT:** Mark Step 7 as completed in TodoWrite and immediately proceed to Step 8. DO NOT wait for user input.

### Step 8: Push and Update PR (Automated)

**What This Step Does:**
- Pushes changes to remote
- Updates existing PR with review results
- Mimics `adws/adw_modules/git_ops.py:finalize_git_operations()`

Push changes:

```bash
# This mimics: adws/adw_modules/git_ops.py:finalize_git_operations() line 110-123
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Pushing changes to remote" >> $LOG_FILE
git push
```

**File Reference:**
- Automated: `adws/adw_modules/git_ops.py:finalize_git_operations()` lines 80-139

Display: "✅ Changes pushed to remote"

**IMPORTANT:** Mark Step 8 as completed in TodoWrite and immediately proceed to Step 9. DO NOT wait for user input.

### Step 9: Complete Review Phase (Automated)

**What This Step Does:**
- Finalizes state file
- Posts completion messages
- Displays comprehensive summary

Update state:

```bash
# This mimics: adws/adw_modules/state.py:ADWState.save()
jq '.current_phase = "review_complete" | .review_screenshots = {screenshot_urls}' \
  agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && \
  mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Review phase completed" >> $LOG_FILE
```

Post completion:

```bash
gh issue comment {issue_number} --body "[ADW-BOT] {adw_id}_ops: ✅ Review phase completed"
```

**File Reference:**
- Automated: `adws/adw_review.py` lines 725-734

Display comprehensive summary to user:

```markdown
✅ Review phase complete!

**What was created:**
- Review artifacts: `agents/{adw_id}/reviewer/`
- Screenshots: {screenshot_count} images
- Screenshot URLs: {public_url_count} uploaded to R2
- Log file: `agents/{adw_id}/logs/adw_guide_review_{timestamp}.log`

**Review Results:**
- Success: {success}
- Issues found: {total_issues}
  - Blockers: {blocker_count} ({resolved_count} resolved)
  - Tech Debt: {tech_debt_count}
  - Skippable: {skippable_count}

**Artifacts created (identical to automated system):**
```
agents/{adw_id}/
├── adw_state.json                           # State tracking
├── logs/
│   └── adw_guide_review_{timestamp}.log     # Execution log
├── reviewer/                                # From review sub-agent
│   ├── output/
│   └── review_img/                          # Screenshots (uploaded to R2)
├── review_patch_planner_1_*/                # From blocker resolution sub-agents
│   └── output/
└── review_patch_implementor_1_*/            # From blocker resolution sub-agents
    └── output/
```

**Sub-agents spawned (all in same session = $0):**
1. ✅ State loader
2. ✅ Spec file locator
3. ✅ Implementation reviewer
4. ✅ Screenshot uploader (R2)
5. ✅ Blocker resolver (for each blocker)
6. ✅ Commit creator

**GitHub issue updated:** Issue #{issue_number} has been updated with review results and screenshots

**Next steps:**
1. Review the results in the GitHub issue
2. If review passed, proceed to documentation or PR finalization
3. If blockers remain, manually investigate and resolve

**Cost so far:** $0 (all sub-agents in Claude Pro session) ✨

**Time saved:** ~15-30 minutes of manual review and fix iteration!
```

**FINAL STEP:** Mark Step 9 as completed in TodoWrite. Verify ALL 9 steps show "completed" status. You are now done with the review phase.

## Intelligent Architecture Comparison

### Old Interactive Mode (Manual Commands)
```
Claude Code CLI Session
├── You manually run: /review
├── Wait for result
├── Analyze screenshots
├── Upload screenshots manually
├── You manually run: /patch for each blocker
├── Wait for result
├── You manually run: /implement for each patch
├── Wait for result
└── You manually run: /commit

Time: ~30-45 minutes of manual work
Cost: $0 (Claude Pro)
```

### New Intelligent Mode (Sub-Agent Delegation)
```
Claude Code CLI Session
├── You run: /adw_guide_review {adw_id}
├── Task spawns: State loader (runs automatically)
├── Task spawns: Spec locator (runs automatically)
├── Task spawns: Implementation reviewer (runs automatically)
├── Task spawns: Screenshot uploader (runs automatically)
├── Task spawns: Blocker resolvers (run automatically)
├── Task spawns: Commit creator (runs automatically)
└── Task spawns: PR updater (runs automatically)

Time: ~5-10 minutes (mostly automated)
Cost: $0 (all sub-agents in same Claude Pro session)
```

### Automated Mode (External Processes - For Reference)
```
trigger_webhook.py (FastAPI server)
├── subprocess.Popen → adw_review.py
    ├── subprocess.run → claude -p "/review"                  $$
    ├── subprocess.run → R2 screenshot upload
    ├── subprocess.run → claude -p "/patch" (blocker 1)       $$
    ├── subprocess.run → claude -p "/implement" (blocker 1)   $$
    ├── subprocess.run → claude -p "/patch" (blocker 2)       $$
    ├── subprocess.run → claude -p "/implement" (blocker 2)   $$
    ├── subprocess.run → claude -p "/commit"                  $$
    └── subprocess.run → git push

Time: ~10-15 minutes (fully automated)
Cost: $$$ (multiple Claude API calls per blocker)
```

## Sub-Agent Best Practices

### Review-Specific Sub-Agent Patterns

**Screenshot Capture Sub-Agent:**
- Captures critical UI functionality screenshots
- Follows e2e test files as navigation guides
- Focuses on critical paths only (1-5 screenshots)
- Numbers screenshots: 01_feature.png, 02_feature.png
- Stores in absolute paths: agents/{adw_id}/reviewer/review_img/

**Blocker Resolution Sub-Agent:**
- Creates patch plan with /patch command
- Implements patch with /implement command
- Unique agent names per iteration and issue
- Tracks resolution success/failure
- Posts updates to GitHub

**R2 Upload Sub-Agent:**
- Uploads screenshots to Cloudflare R2
- Generates public URLs for GitHub embedding
- Preserves local paths as fallback
- Updates review result with public URLs
- Gracefully handles missing R2 config

### Error Handling with Sub-Agents

Sub-agents provide better error handling:

```markdown
# Sub-agent automatically retries on failure
Task: Resolve blocker issue
If fails: Sub-agent can analyze error and retry with corrections
If still fails: Main orchestrator gets clear error message and continues to next blocker
```

**Benefits:**
- Automatic retry logic per blocker
- Better error messages
- Graceful degradation
- User stays informed
- Failed blockers don't stop entire review

## Review Retry Loop

The review includes an intelligent retry mechanism:

1. Run initial review
2. If blockers found, resolve them automatically
3. Re-run review to verify fixes (up to 3 attempts)
4. Report final status

**File Reference:**
- Retry loop: `adws/adw_review.py` lines 514-661
- Max attempts: `MAX_REVIEW_RETRY_ATTEMPTS = 3` (line 66)

## What to Do

- **DO** use Task tool for complex review operations
- **DO** spawn sub-agents for blocker resolution in parallel
- **DO** upload screenshots to R2 for public access
- **DO** let sub-agents handle retry logic
- **DO** create same artifacts as automated system
- **DO** post formatted results to GitHub with screenshots

## What NOT to Do

- **DON'T** spawn external processes (costs money)
- **DON'T** manually run /review, /patch, /implement when sub-agent can do it
- **DON'T** skip screenshot upload (makes GitHub reports better)
- **DON'T** stop review on first blocker (process all of them)

## File References Summary

All file references point to the actual automated system implementation:

- **Review Orchestrator**: `adws/adw_review.py`
- **Workflow Operations**: `adws/adw_modules/workflow_ops.py`
- **R2 Uploader**: `adws/adw_modules/r2_uploader.py`
- **Review Command**: `.claude/commands/review.md`
- **Patch Command**: `.claude/commands/patch.md`
- **Implement Command**: `.claude/commands/implement.md`
- **State Management**: `adws/adw_modules/state.py`
- **Git Operations**: `adws/adw_modules/git_ops.py`
- **GitHub API**: `adws/adw_modules/github.py`

## The Bottom Line

This intelligent guide with sub-agent delegation gives you:

✨ **The automation of the $$ webhook system**
✨ **The zero cost of interactive Claude Pro**
✨ **The speed of parallel execution**
✨ **The reliability of sub-agent error handling**
✨ **Cloud-hosted screenshots for professional GitHub reports**

All in one Claude Code session! 🚀
