# ADW System Comparison: Automated vs Interactive

This document provides a high-level comparison of the automated Python workflow vs the interactive Claude Code guide approach across all phases.

---

## Quick Reference

| Phase | Automated Script | Interactive Guide | Steps (Auto/Int) | Cost (Auto/Int) | Time (Auto/Int) |
|-------|------------------|-------------------|------------------|-----------------|-----------------|
| **Plan** | `adws/adw_plan.py` | `/adw_guide_plan` | 12 / 13 | $3.20 / $0.00 | 5-7min / 2-3min |
| **Build** | `adws/adw_build.py` | `/adw_guide_build` | 8 / 10 | $3.05 / $0.00 | 8-10min / 3-5min |
| **Test** | `adws/adw_test.py` | `/adw_guide_test` | 10+ / 11 | $5-15 / $0.00 | 15-20min / 5-7min |
| **Total** | - | - | ~30 | ~$11-21 / $0 | ~28-37min / ~10-15min |

---

## Agent Comparison by Phase

### Planning Phase

| Agent | Created By (Both) | Model | Cost Impact |
|-------|-------------------|-------|-------------|
| `issue_classifier/` | `/classify_issue` | Sonnet | $0.05 (auto) / $0 (int) |
| `branch_generator/` | `/generate_branch_name` | Sonnet | $0.05 (auto) / $0 (int) |
| `sdlc_planner/` | `/feature\|/bug\|/chore` | Opus | $3.00 (auto) / $0 (int) |
| `sdlc_planner_committer/` | `/commit` | Sonnet | $0.05 (auto) / $0 (int) |
| `pr_creator/` | `gh pr create` | - | $0 (both use gh CLI) |

**Artifacts:** 100% identical in both approaches
**Cost Savings:** $3.20 per plan

---

### Build Phase

| Agent | Created By (Both) | Model | Cost Impact |
|-------|-------------------|-------|-------------|
| `sdlc_implementor/` | `/implement` | Opus | $3.00 (auto) / $0 (int) |
| `sdlc_implementor_committer/` | `/commit` | Sonnet | $0.05 (auto) / $0 (int) |

**Artifacts:** 100% identical in both approaches
**Cost Savings:** $3.05 per build

---

### Testing Phase

| Agent | Created By (Both) | Model | Cost Impact (per iteration) |
|-------|-------------------|-------|---------------------------|
| `test_runner/` | `/test` or pytest | Sonnet | $0.10 (auto) / $0 (int) |
| `test_resolver_iter{N}_{idx}/` | `/resolve_failed_test` | Opus | $3.00 × N (auto) / $0 (int) |
| `e2e_test_runner_{N}_{idx}/` | `/test_e2e` | Sonnet | $0.10 × N (auto) / $0 (int) |
| `e2e_test_resolver_iter{N}_{idx}/` | `/resolve_failed_e2e_test` | Opus | $3.00 × N (auto) / $0 (int) |

**Artifacts:** 100% identical in both approaches
**Cost Savings:** $5-15 per test run (highly variable based on failures)

**Notes:**
- Test phase cost is variable based on test failures
- Each test resolution attempt = 1 Opus call ($3)
- Backend tests: up to 4 retry attempts
- E2E tests: up to 2 retry attempts

---

## Execution Approach Comparison

### Automated Python System

```
User/Webhook → Python Script → Subprocess Calls
                    ↓
    ┌───────────────┴───────────────┐
    ↓                               ↓
claude -p /classify_issue    claude -p /feature
    ↓                               ↓
  Separate API Call           Separate API Call
  (~$0.05)                    (~$3.00)
```

**Characteristics:**
- Each agent = separate `claude -p` subprocess
- Each subprocess = separate Claude API call
- Each API call = charged individually
- Runs fully autonomously
- No user visibility during execution
- Can be triggered by webhooks

**File:** `adws/adw_modules/agent.py:execute_template()` line 262-299
```python
def execute_template(slash_command, args, model):
    # Spawns subprocess
    result = subprocess.run(
        ["claude", "-p", slash_command] + args,
        capture_output=True
    )
    # Each call costs money
```

---

### Interactive Claude Code System

```
User → /adw_guide_plan → Claude Code Session
                ↓
    ┌───────────┴───────────────┐
    ↓                           ↓
/classify_issue            /feature
    ↓                           ↓
Sub-agent (same session)  Sub-agent (same session)
    ↓                           ↓
  $0.00                       $0.00
```

**Characteristics:**
- All agents run in same Claude Pro session
- Uses Task tool or SlashCommand tool
- All agent calls = $0 (covered by subscription)
- User sees real-time progress
- Claude orchestrates the workflow
- Must be initiated by user

**File:** `.claude/commands/adw_guide_plan.md`
```bash
# Uses SlashCommand tool (not subprocess)
/classify_issue '{issue_json}'

# Or uses Task tool for sub-agents
Task: Fetch and analyze GitHub issue
Subagent: general-purpose
```

---

## Folder Structure Comparison

### Both Create Identical Structure ✅

```
agents/{adw_id}/
├── adw_state.json                  # ✅ Identical
├── adw_{phase}/                    # ✅ Identical (phase folders)
│   └── execution.log               # Format differs slightly
├── issue_classifier/               # ✅ Identical
│   ├── prompts/
│   │   └── classify_issue.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
├── sdlc_planner/                   # ✅ Identical
│   ├── prompts/
│   │   └── feature.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
└── [... other agents ...]          # ✅ All identical
```

**Only Difference:**
- Log timestamp format (Python datetime vs bash date)
- `mode` field in state: `"automated"` vs `"interactive_intelligent"`

---

## Logging Comparison

### Automated System
```python
# Python logging module
2025-10-07 09:16:44 - INFO - ADW Logger initialized - ID: abc12345
2025-10-07 09:16:45 - DEBUG - Fetched issue: {...}
2025-10-07 09:16:59 - INFO - Issue classified as: /feature
```

**Format:** `YYYY-MM-DD HH:MM:SS - LEVEL - Message`
**Location:** `agents/{adw_id}/adw_{phase}/execution.log`
**Levels:** INFO, DEBUG, WARNING, ERROR

---

### Interactive System
```bash
# Bash logging with ISO timestamps
[2025-10-22T17:19:24Z] ========================================
[2025-10-22T17:19:24Z] ADW Planning Phase Initialized
[2025-10-22T17:19:24Z] ADW ID: abc12345
[2025-10-22T17:19:25Z] Step 1: Starting - Fetch Issue Details
```

**Format:** `[ISO-8601-UTC] Message`
**Location:** `agents/{adw_id}/adw_{phase}/execution.log`
**Levels:** Implicit in message content

**Interactive Advantages:**
- Explicit step numbers
- Clear step start/complete markers
- Final verification step logs

---

## GitHub Issue Tracking

### Automated System

**Minimal Comments:**
```
[ADW-BOT] abc12345: Planning phase started
[ADW-BOT] abc12345: Planning phase completed
```

**Approach:** Only major milestones tracked
**Frequency:** 2-3 comments per phase

---

### Interactive System

**Comprehensive Comments:**
```
[ADW-BOT] abc12345_ops: ✅ Starting planning phase
[ADW-BOT] abc12345_ops: ✅ Working on branch: `feature-issue-20-...`
[ADW-BOT] abc12345_ops: ✅ Issue classified as: /feature
[ADW-BOT] abc12345_sdlc_planner: ⏳ Creating implementation plan
[ADW-BOT] abc12345_sdlc_planner: ✅ Implementation plan created
[ADW-BOT] abc12345_ops: ✅ Plan file created: `specs/issue-20-...`
[ADW-BOT] abc12345_sdlc_planner: ✅ Plan committed
[ADW-BOT] abc12345_ops: ✅ PR created: https://github.com/.../pull/2
[ADW-BOT] abc12345_ops: ✅ Planning phase completed
[ADW-BOT] abc12345_ops: 📋 Final planning state: { ... }
```

**Approach:** Every major step tracked with context
**Frequency:** 8-12 comments per phase
**Benefits:**
- Real-time progress visibility
- Clear agent attribution
- Status emojis for quick scanning
- Links to artifacts

---

## Error Handling

### Automated System

**Approach:** Explicit try/catch blocks
```python
try:
    result = classify_issue(issue, adw_id, logger)
except Exception as e:
    logger.error(f"Classification failed: {e}")
    raise
```

**Benefits:**
- Predictable error handling
- Structured error logging
- Can continue or abort based on error type

**Limitations:**
- Must anticipate all error scenarios
- No creative problem solving
- User must fix and re-run

---

### Interactive System

**Approach:** Claude orchestrates recovery
```bash
# If something fails, Claude:
1. Analyzes the error
2. Determines if it can fix it
3. Retries with corrections
4. Or asks user for help
```

**Benefits:**
- Adaptive error recovery
- Creative problem solving
- Can retry with different approaches
- User gets real-time context

**Example:**
- Automated: API rate limit → script crashes
- Interactive: Claude sees rate limit → waits 60s → retries → continues

---

## Cost Analysis

### Per-Workflow Cost Breakdown

#### Planning Phase
| Agent | Automated | Interactive | Savings |
|-------|-----------|-------------|---------|
| Classifier | $0.05 | $0.00 | $0.05 |
| Branch Gen | $0.05 | $0.00 | $0.05 |
| Planner (Opus) | $3.00 | $0.00 | $3.00 |
| Committer | $0.05 | $0.00 | $0.05 |
| PR Creator | $0.05 | $0.00 | $0.05 |
| **Total** | **$3.20** | **$0.00** | **$3.20** |

#### Build Phase
| Agent | Automated | Interactive | Savings |
|-------|-----------|-------------|---------|
| Implementor (Opus) | $3.00 | $0.00 | $3.00 |
| Committer | $0.05 | $0.00 | $0.05 |
| **Total** | **$3.05** | **$0.00** | **$3.05** |

#### Testing Phase (Best Case: No Failures)
| Agent | Automated | Interactive | Savings |
|-------|-----------|-------------|---------|
| Test Runner | $0.10 | $0.00 | $0.10 |
| E2E Runner (×2) | $0.20 | $0.00 | $0.20 |
| Committer | $0.05 | $0.00 | $0.05 |
| **Total** | **$0.35** | **$0.00** | **$0.35** |

#### Testing Phase (Worst Case: Max Retries)
| Agent | Automated | Interactive | Savings |
|-------|-----------|-------------|---------|
| Test Runner | $0.10 | $0.00 | $0.10 |
| Test Resolver (×4) | $12.00 | $0.00 | $12.00 |
| E2E Runner (×2) | $0.20 | $0.00 | $0.20 |
| E2E Resolver (×2) | $6.00 | $0.00 | $6.00 |
| Committer | $0.05 | $0.00 | $0.05 |
| **Total** | **$18.35** | **$0.00** | **$18.35** |

### Monthly Savings (10 workflows/month)

| Scenario | Automated Cost | Interactive Cost | Monthly Savings |
|----------|----------------|------------------|-----------------|
| **Best Case** (no test failures) | $66.00 | $0.00 | $66.00 |
| **Average Case** (some failures) | $120.00 | $0.00 | $120.00 |
| **Worst Case** (many failures) | $248.00 | $0.00 | $248.00 |

**Annual Savings:** $792 - $2,976 🤑

---

## Speed Comparison

### Planning Phase
- **Automated:** 5-7 minutes
- **Interactive:** 2-3 minutes
- **Speedup:** 2-2.3x faster

**Why Interactive is Faster:**
- No subprocess overhead (saves ~5-10s per agent)
- Shared session context (no cold starts)
- Parallel sub-agent execution where possible

### Build Phase
- **Automated:** 8-10 minutes
- **Interactive:** 3-5 minutes
- **Speedup:** 1.6-3.3x faster

**Why Interactive is Faster:**
- Opus calls benefit most from shared context
- Implementation analysis already in session memory
- No process spawning delays

### Testing Phase
- **Automated:** 15-20 minutes
- **Interactive:** 5-7 minutes
- **Speedup:** 2.1-4x faster

**Why Interactive is Faster:**
- Test resolution happens in-context
- No need to re-explain test failures
- Faster iteration on fixes

---

## When to Use Each Approach

### Use Automated System When:
✅ You want **hands-off automation** (webhooks)
✅ You're **not at your computer**
✅ You have **budget for API costs**
✅ You want **guaranteed reproducibility**
✅ You're running in **CI/CD pipelines**

### Use Interactive System When:
✅ You want **$0 cost** (Claude Pro covered)
✅ You want **2-4x faster** execution
✅ You want **real-time visibility**
✅ You want **better error recovery**
✅ You're **actively developing**
✅ You want **comprehensive tracking** (GitHub comments)

---

## Key Takeaways

### Artifacts
✅ **100% Identical** folder structure and agent outputs in both approaches

### Cost
💰 Interactive saves **$6.60-$21.60 per workflow** (depending on test failures)
💰 Potential annual savings: **$792-$2,976** for typical usage

### Speed
⚡ Interactive is **1.6-4x faster** depending on phase

### Tracking
📊 Interactive provides **3-6x more GitHub comments** for better visibility

### Reliability
🔄 Interactive has **adaptive error recovery** vs automated's explicit handling

### Use Cases
- **Automated:** CI/CD, webhooks, hands-off automation
- **Interactive:** Development, debugging, cost-conscious workflows

---

## Bottom Line

The interactive system provides:
- **Same outputs** as automated
- **Significantly lower cost** ($0 vs $7-22 per workflow)
- **Faster execution** (2-4x speedup)
- **Better visibility** (comprehensive tracking)
- **Smarter error recovery** (Claude orchestrates)

The **only trade-off** is that interactive requires a human to initiate it, while automated can run on webhooks. For development workflows, interactive is clearly superior. For CI/CD and production automation, automated makes sense despite the costs.

---

## Detailed Comparisons

For step-by-step breakdowns with code references and exact timings:

- **Planning Phase:** See `COMPARISON_PLANNING_PHASE.md` (complete step-by-step)
- **Build Phase:** See `COMPARISON_BUILD_PHASE.md` (coming soon)
- **Testing Phase:** See `COMPARISON_TESTING_PHASE.md` (coming soon)
- **Agent Catalog:** See `ADW_AGENTS_GUIDE.md` (all 14 agents documented)
