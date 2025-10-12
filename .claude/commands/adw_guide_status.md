# ADW Guide: Status Check

**Purpose:** Inspect workflow state and progress across all intelligent ADW guide phases.

This is a read-only diagnostic command that displays the current state of ADW workflows without making any changes. Use this between any workflow phases to check progress, identify next steps, and verify workflow integrity.

## Overview

The ADW Status command provides visibility into the intelligent workflow system by reading state files and displaying progress indicators. Unlike the other guide commands that orchestrate Claude as a sub-agent, this command simply reads and presents existing state information.

**Part of the Intelligent Workflow System:**
- `/adw_guide_plan` → Creates plan and initializes state
- `/adw_guide_build` → Implements plan using Claude sub-agent
- `/adw_guide_test` → Validates implementation with Claude sub-agent
- `/adw_guide_review` → Reviews against spec with Claude sub-agent
- `/adw_guide_pr` → Creates pull request
- `/adw_guide_status` → **[YOU ARE HERE]** Checks progress at any point

## Variables

- `$1` = ADW ID (optional - will show all if not provided)

## State Management Integration

This command reads from the ADW state management system:

**Core State File:** `agents/{adw_id}/adw_state.json`
- Managed by: `adws/adw_modules/state.py` (ADWState class)
- Contains: ADW ID, issue number, branch name, plan file, issue class
- Additional fields: current_phase, mode, pr_created, pr_url

**State Structure:**
```json
{
  "adw_id": "abc12345",
  "issue_number": "1",
  "issue_class": "/feature",
  "branch_name": "feature-issue-1-adw-abc12345-description",
  "plan_file": "specs/issue-1-adw-abc12345-description.md",
  "current_phase": "build_complete",
  "mode": "interactive",
  "pr_created": false
}
```

## When to Use This Command

Use `/adw_guide_status` at any point during your workflow to:

1. **Check Progress:** See which phases are complete and what's next
2. **Resume After Break:** Identify where you left off in a workflow
3. **Debug Workflow:** Verify state integrity if something seems wrong
4. **Find ADW ID:** List all active workflows to find your ADW ID
5. **Between Phases:** Confirm one phase completed before starting the next
6. **Multiple Workflows:** Track several concurrent workflows

**Examples:**
- After `/adw_guide_plan` completes → Run status to verify state and get ADW ID
- Before `/adw_guide_build` → Confirm planning phase is complete
- After long break → Check which workflows need attention
- Error troubleshooting → Verify current_phase matches expected state

## Instructions

This command helps you check the status of your interactive ADW workflows.

### Step 1: Find Workflows

If ADW ID is provided, load that specific workflow:
```bash
cat agents/$1/adw_state.json
```

If no ADW ID is provided, find all interactive workflows:
```bash
find agents/*/adw_state.json -type f -exec grep -l '"mode": "interactive"' {} \; | while read f; do
  echo "=== $(dirname $f) ==="
  cat "$f"
  echo ""
done
```

### Step 2: Display Status

For each workflow found, display in a user-friendly format:

```
🔍 ADW Workflow Status

**ADW ID:** `{adw_id}`
**Issue:** #{issue_number}
**Branch:** `{branch_name}`
**Current Phase:** {current_phase}
**Mode:** Interactive (zero API cost)

**Progress:**
- Planning: {✅ or ⬜}
- Implementation: {✅ or ⬜}
- Testing: {✅ or ⬜}
- Review: {✅ or ⬜}
- Pull Request: {✅ or ⬜}

**Files:**
- Plan: `{plan_file}`
- State: `agents/{adw_id}/adw_state.json`
- Logs: `agents/{adw_id}/logs/`
```

### Step 3: Show Phase Indicators

Based on `current_phase`, show appropriate indicators:

| Phase Value | Display |
|-------------|---------|
| `planning` | ✅ Planning • ⬜ Implementation • ⬜ Testing • ⬜ Review • ⬜ PR |
| `build_complete` | ✅ Planning • ✅ Implementation • ⬜ Testing • ⬜ Review • ⬜ PR |
| `testing_complete` | ✅ Planning • ✅ Implementation • ✅ Testing • ⬜ Review • ⬜ PR |
| `review_complete` | ✅ Planning • ✅ Implementation • ✅ Testing • ✅ Review • ⬜ PR |
| `complete` | ✅ Planning • ✅ Implementation • ✅ Testing • ✅ Review • ✅ PR |

### Step 4: Suggest Next Action

Based on current phase, suggest what to do next:

**If phase is "planning":**
"Next step: Run `/adw_guide_build {adw_id}` to implement the plan"

**If phase is "build_complete":**
"Next step: Run `/adw_guide_test {adw_id}` to validate changes"

**If phase is "testing_complete":**
"Next step: Run `/adw_guide_review {adw_id}` to review implementation"

**If phase is "review_complete":**
"Next step: Run `/adw_guide_pr {adw_id}` to create pull request"

**If phase is "complete":**
"✅ Workflow complete! PR has been created."

### Step 5: Show Helpful Commands

Display available commands with intelligent workflow context:

"**Available ADW Guide Commands:**
- `/adw_guide_plan` - Start new workflow (initializes state, creates plan)
- `/adw_guide_build {adw_id}` - Implementation phase (orchestrates Claude sub-agent)
- `/adw_guide_test {adw_id}` - Testing phase (orchestrates Claude sub-agent)
- `/adw_guide_review {adw_id}` - Review phase (orchestrates Claude sub-agent)
- `/adw_guide_pr {adw_id}` - Create pull request (final step)
- `/adw_guide_status [adw_id]` - Check status (this command - read-only)

**Resume any phase:** Just run the command for that phase with your ADW ID.
All phases are idempotent and can be re-run safely."

### Step 6: Show Cost Summary

Always remind the user:

"💰 **Cost Summary:**
All interactive workflow phases: $0 (covered by Claude Pro subscription)

Total saved compared to automated workflow: ~$2-9 per workflow ✨"

## Example Output

```
🔍 ADW Workflow Status

Found 2 interactive workflows:

---
**ADW ID:** `abc12345`
**Issue:** #1
**Branch:** `feature-issue-1-adw-abc12345-table-exports`
**Current Phase:** review_complete
**Mode:** Interactive (zero API cost)

**Progress:**
✅ Planning → ✅ Implementation → ✅ Testing → ✅ Review → ⬜ PR

**Files:**
- Plan: `specs/issue-1-adw-abc12345-table-exports.md`
- State: `agents/abc12345/adw_state.json`
- Logs: `agents/abc12345/logs/` (4 log files)

**Recent logs:**
- `adw_guide_plan_1696694400.log`
- `adw_guide_build_1696698000.log`
- `adw_guide_test_1696701600.log`
- `adw_guide_review_1696705200.log`

**Next step:** Run `/adw_guide_pr abc12345` to create pull request

---
**ADW ID:** `xyz98765`
**Issue:** #42
**Branch:** `bug-issue-42-adw-xyz98765-fix-sql-injection`
**Current Phase:** complete
**Mode:** Interactive (zero API cost)

**Progress:**
✅ Planning → ✅ Implementation → ✅ Testing → ✅ Review → ✅ PR

✅ Workflow complete! PR has been created.

---

💰 **Cost Summary:**
All interactive workflow phases: $0 (covered by Claude Pro subscription)
Total saved: ~$4-18 ✨
```

## What NOT to Do

This is a **read-only diagnostic command** - it should only inspect and display state:

- **DO NOT** call subprocess.run() or execute any code
- **DO NOT** make programmatic API calls or invoke sub-agents
- **DO NOT** modify any state files or workflow data
- **DO NOT** trigger any workflow phases
- **DO** read and display state files from `agents/{adw_id}/adw_state.json`
- **DO** provide helpful guidance about next steps
- **DO** show clear workflow progress indicators
- **DO** reference the state management system (`adws/adw_modules/state.py`)

## Error Handling

If no workflows found:
"No interactive ADW workflows found. Start a new one with: `/adw_guide_plan`"

If ADW ID not found:
"ADW ID `{adw_id}` not found. Use `/adw_guide_status` to see all workflows."
