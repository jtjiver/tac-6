# ADW Workflow Testing Checklist

## Objective

Test each phase of the ADW workflow to verify **zero API calls** are made and everything uses Claude Pro subscription only.

## Setup

### Terminal 1: Run the Monitor
```bash
./monitor_api_calls.sh
```

This will alert if:
- Any `python adws/adw_*.py` scripts run
- Any `uv run adws/adw_*.py` scripts run
- Any `claude -p` commands run (API mode)

Leave this running throughout all tests.

### Terminal 2: Run the Workflow
This is where you'll execute the actual workflow commands.

## Test Plan

### Phase 1: Plan Phase ✓

**Command:**
```bash
claude /adw_guide_plan
```

**When prompted:**
- Issue number: **12**

**What to Watch:**
- ✅ Should use `/classify_issue` (slash command)
- ✅ Should use `/generate_branch_name` (slash command)
- ✅ Should use `/feature` (slash command)
- ✅ Should use `/commit` (slash command)
- ✅ Should use `gh` commands
- ✅ Should use `git` commands
- ❌ Should NOT run `python adws/adw_plan.py`
- ❌ Should NOT run `uv run adws/adw_plan.py`
- ❌ Should NOT run `claude -p`

**Monitor should show:**
```
✅ No alerts
```

**Verify ADW ID created:**
```bash
# After plan completes, check for new ADW ID
ls agents/
# Should see a new 8-char hex directory (e.g., b4700210)
```

**Store ADW ID for next steps:**
```bash
ADW_ID=<your_adw_id_here>
```

---

### Phase 2: Build Phase ✓

**Command:**
```bash
claude /adw_guide_build $ADW_ID
```

**What to Watch:**
- ✅ Should use `/implement` (slash command)
- ✅ Should use `/commit` (slash command)
- ✅ Should use `git` commands
- ❌ Should NOT run `python adws/adw_build.py`
- ❌ Should NOT run `uv run adws/adw_build.py`
- ❌ Should NOT run `claude -p`

**Monitor should show:**
```
✅ No alerts
```

**Check if hook triggers (if enabled):**
```bash
# Check orchestrator log
tail -f agents/$ADW_ID/orchestrator/hook_trigger.log
```

---

### Phase 3: Test Phase ✓

**If hook triggered:** Watch orchestrator spawn test phase
**If manual:**
```bash
claude /adw_guide_test $ADW_ID
```

**What to Watch:**
- ✅ Should use `/test` (slash command)
- ✅ Should use `/resolve_failed_test` if needed (slash command)
- ✅ Should use `/test_e2e` (slash command)
- ✅ Should use `pytest` commands
- ✅ Should use `git` commands
- ❌ Should NOT run `python adws/adw_test.py`
- ❌ Should NOT run `uv run adws/adw_test.py`
- ❌ Should NOT run `claude -p`

**Monitor should show:**
```
✅ No alerts
```

---

### Phase 4: Review Phase ✓

**If hook triggered:** Watch orchestrator spawn review phase
**If manual:**
```bash
claude /adw_guide_review $ADW_ID
```

**What to Watch:**
- ✅ Should use `/review` (slash command)
- ✅ Should use browser for screenshots
- ✅ Should use `git` commands
- ❌ Should NOT run `python adws/adw_review.py`
- ❌ Should NOT run `uv run adws/adw_review.py`
- ❌ Should NOT run `claude -p`

**Monitor should show:**
```
✅ No alerts
```

---

### Phase 5: PR Phase ✓

**If hook triggered:** Watch orchestrator spawn PR phase
**If manual:**
```bash
claude /adw_guide_pr $ADW_ID
```

**What to Watch:**
- ✅ Should use `/pull_request` (slash command)
- ✅ Should use `git push`
- ✅ Should use `gh pr create`
- ❌ Should NOT run any Python ADW scripts
- ❌ Should NOT run `claude -p`

**Monitor should show:**
```
✅ No alerts
```

---

## Alternative: Test with Orchestrator

### Direct Orchestrator Test

**Terminal 1: Monitor**
```bash
./monitor_api_calls.sh
```

**Terminal 2: Run orchestrator**
```bash
./adws/orchestrate.sh $ADW_ID --chain post_build
```

**Or test full workflow with hooks:**
```bash
# Verify hooks enabled
jq '.automation.hooks_enabled' adws/adw_orchestrator_config.json

# Run plan phase
claude /adw_guide_plan
# Enter: 12

# Hook should auto-trigger build → test → review → pr
```

---

## Verification Checklist

After running all phases, verify:

### ✅ No API Calls Made
- [ ] Monitor showed **zero alerts** throughout all phases
- [ ] No `python adws/adw_*.py` processes detected
- [ ] No `uv run adws/adw_*.py` processes detected
- [ ] No `claude -p` commands detected

### ✅ All Work Completed
- [ ] Plan file created in `specs/`
- [ ] Code changes implemented
- [ ] Tests created and passing
- [ ] Screenshots captured (in review phase)
- [ ] PR created on GitHub

### ✅ Process Logs
```bash
# Check orchestrator logs if using hooks
cat agents/$ADW_ID/orchestrator/orchestrator.log

# Check for any mentions of Python scripts
grep -i "python.*adw_\|uv run.*adw_" agents/$ADW_ID/**/*.log

# Should find: nothing
```

### ✅ GitHub Issue
```bash
gh issue view 12
```

Check that:
- [ ] Comments from each phase appear
- [ ] PR link is posted
- [ ] No errors reported

---

## If Monitor Alerts Fire 🚨

If you see an alert about Python ADW scripts or `claude -p`:

### Immediate Actions
1. **Stop the workflow** (Ctrl+C)
2. **Check what triggered it:**
   ```bash
   ps aux | grep -E "python.*adws/adw_|uv run.*adws/|claude -p"
   ```
3. **Kill the process:**
   ```bash
   pkill -f "adws/adw_"
   ```

### Investigate
1. Check the command that was running
2. Look at recent logs:
   ```bash
   tail -100 agents/$ADW_ID/*/output/*.log
   ```
3. Find where Python script was called from

### Report Findings
Document:
- Which phase triggered it
- What command was run
- Which file needs to be updated

---

## Expected Results: All Green ✅

After testing all phases, you should have:

```
✅ Monitor: Zero alerts
✅ Plan created
✅ Code implemented
✅ Tests passing
✅ PR created
✅ API credits: Unchanged
✅ Cost: $0 (Claude Pro only)
```

---

## Quick Test (Just Monitor)

If you don't want to run full workflow, just test the monitor works:

```bash
# Terminal 1: Start monitor
./monitor_api_calls.sh

# Terminal 2: Trigger an alert (intentional)
# Try to run a protected script
cd adws && uv run adw_plan.py 12

# Monitor should alert with protection message
```

Expected output:
```
🚨 ALERT: Python ADW script detected!
[Shows blocked execution with API protection warning]
```

---

## Summary

Run monitor in one terminal, run workflow in another. If monitor stays quiet = everything is safe!

**Ready to test?**

```bash
# Terminal 1
./monitor_api_calls.sh

# Terminal 2
claude /adw_guide_plan
```

Enter issue **12** and watch for alerts!
