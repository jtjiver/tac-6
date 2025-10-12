# ADW Workflow: PR and Issue Timing

## Critical Workflow Issue Identified

**Problem:** In the interactive workflow for Issue #10, we created a PR after the planning phase, then immediately merged it and closed the issue. This prevented us from continuing with the build/test/review phases.

## Root Cause

The ADW planning phase calls `finalize_git_operations()` which:
1. Pushes the branch
2. Creates a PR (if one doesn't exist)
3. Posts PR link to issue

This is **correct behavior** - but we misunderstood when to merge the PR.

## Correct Workflow

### Full Workflow Timeline

```
Issue #10: "Update Query animation" [OPEN]
│
├─ Phase 1: Planning (/adw_guide_plan)
│  ├─ Create specs/plan files
│  ├─ Commit: "docs: add planning artifacts"
│  ├─ Push branch
│  └─ Create PR #11 [OPEN, DRAFT] ← Issue stays OPEN!
│
├─ Phase 2: Build (/adw_guide_build)
│  ├─ Implement code changes
│  ├─ Commit: "feat: implement query animation"
│  ├─ Push to same branch
│  └─ PR #11 updated [OPEN, DRAFT] ← Same PR, Issue stays OPEN!
│
├─ Phase 3: Test (/adw_guide_test)
│  ├─ Run tests, fix failures
│  ├─ Commit: "test: add/fix tests"
│  ├─ Push to same branch
│  └─ PR #11 updated [OPEN, DRAFT] ← Same PR, Issue stays OPEN!
│
├─ Phase 4: Review (/adw_guide_review)
│  ├─ Review implementation vs spec
│  ├─ Fix blockers
│  ├─ Commit: "fix: resolve review blockers"
│  ├─ Push to same branch
│  ├─ Mark PR as "Ready for review"
│  └─ PR #11 updated [OPEN, READY] ← Same PR, Issue stays OPEN!
│
└─ Phase 5: Merge (Manual or /adw_guide_merge)
   ├─ Merge PR #11 → main
   ├─ Delete branch
   └─ Close Issue #10 [CLOSED] ← Only close issue AFTER merge!
```

## Key Rules

### DO ✅
1. **Create PR early** (after planning phase)
2. **Keep PR open** until ALL phases complete
3. **Keep issue open** until PR is merged
4. **Use same branch/PR** for all phases
5. **Mark PR as draft** until ready for final review
6. **Accumulate commits** on the same PR

### DON'T ❌
1. **Don't merge planning PR immediately**
2. **Don't close issue after planning**
3. **Don't create new branches/PRs** for each phase
4. **Don't merge until** build + test + review complete

## PR States by Phase

| Phase | PR State | Issue State | Branch |
|-------|----------|-------------|---------|
| Planning | Open (Draft) | Open | feature-issue-X-adw-Y |
| Build | Open (Draft) | Open | Same branch |
| Test | Open (Draft) | Open | Same branch |
| Review | Open (Ready) | Open | Same branch |
| Merge | Merged | Closed | Deleted |

## Interactive Guide Updates Needed

### 1. Planning Phase (adw_guide_plan.md)

**Step 10 should say:**

```markdown
### Step 10: Push and Create Draft PR

Execute: /commit-commands:commit-push-pr

This will:
1. Push branch to remote
2. Create DRAFT pull request (or update existing)
3. Post PR link to issue

**IMPORTANT:**
- PR is created in DRAFT state
- Issue remains OPEN
- DO NOT merge this PR yet!
- Continue to build phase: /adw_guide_build {adw_id}
```

### 2. Build Phase (adw_guide_build.md)

**Step 6 should clarify:**

```markdown
### Step 6: Commit and Push Changes

This adds implementation commits to the SAME PR created during planning.

**Status:**
- PR: Still OPEN (Draft)
- Issue: Still OPEN
- Branch: Same branch from planning

**Next:** Continue to test phase: /adw_guide_test {adw_id}
```

### 3. Review Phase (adw_guide_review.md)

**Step 8 should say:**

```markdown
### Step 8: Mark PR Ready for Review

If review passed:
- Update PR status from Draft to Ready
- gh pr ready {pr_number}
- Post to issue: "Ready for final review"

**Status:**
- PR: OPEN (Ready for Review)
- Issue: Still OPEN
- Branch: Same branch

**Next:**
- Manual merge when approved
- Or use: /adw_guide_merge {adw_id} (if we create this command)
```

## Automated Webhook System

The webhook system handles this correctly:

```python
# adws/adw_plan.py
finalize_git_operations(state, logger)  # Creates PR, keeps issue open

# adws/adw_build.py
finalize_git_operations(state, logger)  # Updates same PR

# adws/adw_test.py
finalize_git_operations(state, logger)  # Updates same PR

# adws/adw_review.py
finalize_git_operations(state, logger)  # Updates same PR, marks ready

# Webhook handler never auto-merges!
# Human decides when to merge and close issue
```

## What Went Wrong with Issue #10

**What we did:**
```
Issue #10 [OPEN]
└─ /adw_guide_plan → Created PR #11
   └─ Immediately merged PR #11 ❌
      └─ Closed Issue #10 ❌
         └─ Can't continue to build phase! 💥
```

**What we should have done:**
```
Issue #10 [OPEN]
├─ /adw_guide_plan → Created PR #11 [Draft]
├─ /adw_guide_build 57ee23f4 → Updated PR #11 [Draft]
├─ /adw_guide_test 57ee23f4 → Updated PR #11 [Draft]
├─ /adw_guide_review 57ee23f4 → Updated PR #11 [Ready]
└─ Merge PR #11 → Close Issue #10 ✅
```

## Recovery Strategy for Issue #10

Since we already merged the planning PR, we have options:

### Option A: Reopen Issue #10
```bash
gh issue reopen 10
/adw_guide_build 57ee23f4
# Continue with existing state
```

### Option B: Create Follow-up Issue
```bash
gh issue create --title "Implement query animation (continuation of #10)" \
  --body "Build phase for query animation feature planned in #10"
# Use new issue for build/test/review
```

### Option C: Start Fresh (Not Recommended)
```bash
# Delete ADW state
rm -rf agents/57ee23f4
# Start over with new /adw_guide_plan
```

## Recommendation: Add /adw_guide_merge Command

Create a new command that handles the final merge step:

```markdown
# .claude/commands/adw_guide_merge.md

Merge the ADW workflow PR and close the issue.

Steps:
1. Load state from agents/{adw_id}/adw_state.json
2. Verify current_phase = "review_complete"
3. Check PR status = "Ready for Review"
4. Merge PR with squash
5. Delete branch
6. Close issue
7. Update state: current_phase = "complete"
```

## Summary

**The Planning PR is NOT the Final PR!**

- Planning PR = **Work in Progress container**
- It accumulates commits from all phases
- Only merge after **all phases complete**
- Issue stays open until PR merged

This matches how the automated webhook system works!
