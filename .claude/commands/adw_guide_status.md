# ADW Guide: Status Check

Check the status of current or past ADW interactive workflows.

## Variables

- `$1` = ADW ID (optional - will show all if not provided)

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

Display available commands:

"**Available ADW Guide Commands:**
- `/adw_guide_plan` - Start new workflow
- `/adw_guide_build {adw_id}` - Implementation phase
- `/adw_guide_test {adw_id}` - Testing phase
- `/adw_guide_review {adw_id}` - Review phase
- `/adw_guide_pr {adw_id}` - Create pull request
- `/adw_guide_status [adw_id]` - Check status (this command)

**Resume any phase:** Just run the command for that phase with your ADW ID"

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

- **DO NOT** call subprocess.run()
- **DO NOT** make programmatic API calls
- **DO** read and display state files
- **DO** provide helpful guidance
- **DO** show clear next steps

## Error Handling

If no workflows found:
"No interactive ADW workflows found. Start a new one with: `/adw_guide_plan`"

If ADW ID not found:
"ADW ID `{adw_id}` not found. Use `/adw_guide_status` to see all workflows."
