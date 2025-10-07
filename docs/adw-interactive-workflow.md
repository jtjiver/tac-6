## ADW Interactive Workflow - Zero API Cost Solution

### Overview

This document describes how to run ADW workflows **inside Claude Code interactively** to avoid API costs while maintaining the benefits of structured workflows, templates, and automation.

### The Problem

Running ADW scripts programmatically (`uv run adws/adw_plan_build.py`) costs money because it launches Claude Code CLI in non-interactive mode, which uses Anthropic API credits.

### The Solution: Semi-Automated Interactive Workflow

Instead of fully autonomous execution, we can run each phase **manually inside Claude Code** using slash commands. This gives us:

✅ **Zero API costs** (covered by Claude Pro subscription)
✅ **Same templates and structure** (uses existing `.claude/commands/*.md` files)
✅ **Same workflows** (plan → build → test → review → document)
✅ **Human oversight** (you approve each phase transition)
✅ **State management** (tracks progress between phases)

❌ **Trade-off**: Not fully autonomous (requires you to kick off each phase)

### Architecture Analysis

#### Current Automated Flow

```
adw_plan_build_review.py
    ↓ subprocess.run()
adw_plan.py
    ↓ execute_template("/feature")
    ↓ subprocess.run([claude, "-p", "/feature"])
    ↓ 💸 API COST
    ↓
adw_build.py
    ↓ execute_template("/implement")
    ↓ subprocess.run([claude, "-p", "/implement"])
    ↓ 💸 API COST
    ↓
adw_review.py
    ↓ execute_template("/review")
    ↓ subprocess.run([claude, "-p", "/review"])
    ↓ 💸 API COST
```

#### New Interactive Flow

```
You (in Claude Code terminal)
    ↓
/feature <issue-number>
    ↓ Interactive Claude Code (Free!)
    ↓ Creates plan + commits
    ↓
/implement <plan-file>
    ↓ Interactive Claude Code (Free!)
    ↓ Implements + commits
    ↓
/review <spec-file>
    ↓ Interactive Claude Code (Free!)
    ↓ Reviews + commits
```

### What Already Exists

Your project **already has** all the slash commands needed:

| Slash Command | File | Purpose |
|---------------|------|---------|
| `/feature` | `.claude/commands/feature.md` | Create implementation plan for feature |
| `/bug` | `.claude/commands/bug.md` | Create implementation plan for bug fix |
| `/chore` | `.claude/commands/chore.md` | Create implementation plan for chore |
| `/implement` | `.claude/commands/implement.md` | Implement a plan file |
| `/test` | `.claude/commands/test.md` | Run tests and fix failures |
| `/test_e2e` | `.claude/commands/test_e2e.md` | Run E2E tests |
| `/review` | `.claude/commands/review.md` | Review implementation against spec |
| `/document` | `.claude/commands/document.md` | Generate documentation |
| `/commit` | `.claude/commands/commit.md` | Create semantic commit message |
| `/pull_request` | `.claude/commands/pull_request.md` | Create pull request |

### Step-by-Step Interactive Workflow

#### Phase 1: Planning

```bash
# In Claude Code interactive session
/feature 1
```

**What happens:**
1. Claude reads the GitHub issue
2. Creates implementation plan in `specs/issue-1-adw-{id}-*.md`
3. Commits the plan
4. Reports the plan file path

**Output:** Plan file path (e.g., `specs/issue-1-adw-abc123-feature-name.md`)

#### Phase 2: Implementation

```bash
# In Claude Code interactive session
/implement specs/issue-1-adw-abc123-feature-name.md
```

**What happens:**
1. Claude reads the plan
2. Implements all changes
3. You review the changes
4. Claude can commit or you commit manually

**Output:** Implementation summary + git diff stats

#### Phase 3: Testing

```bash
# In Claude Code interactive session
/test
```

**What happens:**
1. Runs test suite
2. If failures, attempts to fix
3. Re-runs until passing or max attempts

**Alternative:** Run tests manually and use `/resolve_failed_test` if needed

#### Phase 4: Review

```bash
# In Claude Code interactive session
/review specs/issue-1-adw-abc123-feature-name.md
```

**What happens:**
1. Reviews implementation against spec
2. Takes screenshots if needed
3. Identifies issues (blockers, tech debt)
4. Creates review report

#### Phase 5: Pull Request

```bash
# In Claude Code interactive session
/pull_request
```

**What happens:**
1. Generates PR description
2. Creates pull request with `gh pr create`
3. Links to issue

### Enhanced Semi-Automated Approach

We can create **helper slash commands** that guide you through the workflow without making subprocess calls:

#### New Command: `/adw_interactive_plan`

Create: `.claude/commands/adw_interactive_plan.md`

```markdown
# ADW Interactive Plan

Guide the user through the planning phase of ADW workflow.

## Instructions

1. **Fetch Issue**: Ask the user for the GitHub issue number
2. **Classify Issue**: Determine if this is a /feature, /bug, or /chore
3. **Generate ADW ID**: Create an 8-character unique ID for this workflow
4. **Create Branch**: Generate semantic branch name and create it
5. **Create Plan**: Based on classification, tell the user to run:
   - `/feature <issue-number> <adw-id> <issue-json>`
   - `/bug <issue-number> <adw-id> <issue-json>`
   - `/chore <issue-number> <adw-id> <issue-json>`
6. **Report Next Steps**: Tell the user the plan file path and guide them to run `/adw_interactive_build`

## What NOT to do
- DO NOT make subprocess calls
- DO NOT run commands programmatically
- DO guide the user on what to run next
```

#### New Command: `/adw_interactive_build`

Create: `.claude/commands/adw_interactive_build.md`

```markdown
# ADW Interactive Build

Guide the user through the build phase of ADW workflow.

## Instructions

1. **Find Plan**: Locate the most recent plan file in `specs/`
2. **Checkout Branch**: Ensure we're on the correct feature branch
3. **Implement**: Tell the user to run `/implement <plan-file>`
4. **Commit**: After implementation, create commit with `/commit`
5. **Report Next Steps**: Guide the user to run `/adw_interactive_test`

## What NOT to do
- DO NOT make subprocess calls
- DO guide the user on what to run next
```

#### New Command: `/adw_interactive_test`

Create: `.claude/commands/adw_interactive_test.md`

```markdown
# ADW Interactive Test

Guide the user through the testing phase.

## Instructions

1. **Run Tests**: Tell the user to run `/test`
2. **E2E Tests**: If applicable, guide them to run `/test_e2e`
3. **Fix Failures**: If tests fail, use `/resolve_failed_test`
4. **Report Next Steps**: Guide the user to run `/adw_interactive_review`
```

#### New Command: `/adw_interactive_review`

Create: `.claude/commands/adw_interactive_review.md`

```markdown
# ADW Interactive Review

Guide the user through the review phase.

## Instructions

1. **Find Spec**: Locate the spec file from planning phase
2. **Review**: Tell the user to run `/review <spec-file>`
3. **Commit**: Create review commit if needed
4. **Report Next Steps**: Guide the user to run `/adw_interactive_pr`
```

#### New Command: `/adw_interactive_pr`

Create: `.claude/commands/adw_interactive_pr.md`

```markdown
# ADW Interactive PR

Guide the user through PR creation.

## Instructions

1. **Push Branch**: Ensure branch is pushed to remote
2. **Create PR**: Tell the user to run `/pull_request`
3. **Report**: Show PR URL and mark workflow complete
```

### State Management for Interactive Mode

We can still use state files to track progress:

#### Helper Script: `adws/interactive_state.py`

```python
"""Interactive ADW state helper - no subprocess calls"""

import json
import os
from pathlib import Path

STATE_DIR = Path("agents")

def create_interactive_state(issue_number: str, adw_id: str, issue_class: str, branch_name: str) -> dict:
    """Create new interactive state"""
    state = {
        "adw_id": adw_id,
        "issue_number": issue_number,
        "issue_class": issue_class,
        "branch_name": branch_name,
        "current_phase": "planning",
        "plan_file": None,
        "mode": "interactive"
    }

    state_file = STATE_DIR / adw_id / "adw_state.json"
    state_file.parent.mkdir(parents=True, exist_ok=True)
    state_file.write_text(json.dumps(state, indent=2))

    print(f"✅ Created interactive state: {state_file}")
    return state

def update_interactive_phase(adw_id: str, phase: str, **kwargs) -> dict:
    """Update current phase and additional fields"""
    state_file = STATE_DIR / adw_id / "adw_state.json"

    if not state_file.exists():
        raise FileNotFoundError(f"State file not found: {state_file}")

    state = json.loads(state_file.read_text())
    state["current_phase"] = phase
    state.update(kwargs)

    state_file.write_text(json.dumps(state, indent=2))
    print(f"✅ Updated phase to: {phase}")
    return state

def get_current_state(adw_id: str = None) -> dict:
    """Get current state by adw_id or find latest"""
    if adw_id:
        state_file = STATE_DIR / adw_id / "adw_state.json"
        if state_file.exists():
            return json.loads(state_file.read_text())

    # Find latest interactive state
    interactive_states = []
    for state_file in STATE_DIR.rglob("adw_state.json"):
        state = json.loads(state_file.read_text())
        if state.get("mode") == "interactive":
            interactive_states.append((state_file.stat().st_mtime, state))

    if interactive_states:
        return sorted(interactive_states, reverse=True)[0][1]

    return None

if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python interactive_state.py <command> [args]")
        sys.exit(1)

    command = sys.argv[1]

    if command == "create":
        issue_number = sys.argv[2]
        adw_id = sys.argv[3]
        issue_class = sys.argv[4]
        branch_name = sys.argv[5]
        state = create_interactive_state(issue_number, adw_id, issue_class, branch_name)
        print(json.dumps(state, indent=2))

    elif command == "update":
        adw_id = sys.argv[2]
        phase = sys.argv[3]
        state = update_interactive_phase(adw_id, phase)
        print(json.dumps(state, indent=2))

    elif command == "get":
        adw_id = sys.argv[2] if len(sys.argv) > 2 else None
        state = get_current_state(adw_id)
        if state:
            print(json.dumps(state, indent=2))
        else:
            print("No interactive state found")
```

### Complete Interactive Workflow Example

```bash
# Session 1: Planning (in Claude Code)
You: I want to implement issue #1 for table exports

Claude: Let me help you with that. First, let me classify the issue and set up the workflow.

Claude: This is a /feature. I'm creating a plan with ADW ID: abc12345

Claude: I've created branch: feature-issue-1-adw-abc12345-table-exports

Claude: Now running /feature internally...

Claude: ✅ Plan created: specs/issue-1-adw-abc12345-table-exports.md

Claude: Next steps:
1. Review the plan I just created
2. When ready, run: /implement specs/issue-1-adw-abc12345-table-exports.md

---

# Session 2: Implementation (in Claude Code)
You: /implement specs/issue-1-adw-abc12345-table-exports.md

Claude: Reading plan and implementing...

Claude: ✅ Implementation complete!
- Added backend export endpoints
- Added frontend download buttons
- Added tests

Claude: Next steps:
1. Run: /test to validate
2. Then run: /review specs/issue-1-adw-abc12345-table-exports.md

---

# Session 3: Testing (in Claude Code)
You: /test

Claude: Running tests...

Claude: ✅ All tests passing!

Claude: Next steps:
Run: /review specs/issue-1-adw-abc12345-table-exports.md

---

# Session 4: Review (in Claude Code)
You: /review specs/issue-1-adw-abc12345-table-exports.md

Claude: Reviewing implementation against spec...

Claude: ✅ Review complete! No blockers found.

Claude: Next steps:
Run: /pull_request to create PR

---

# Session 5: PR Creation (in Claude Code)
You: /pull_request

Claude: ✅ Pull request created: https://github.com/user/repo/pull/123

Claude: Workflow complete! 🎉
```

### Cost Comparison

| Approach | Plan | Build | Test | Review | Total Cost |
|----------|------|-------|------|--------|------------|
| **Automated** (subprocess) | $1.00 | $3.00 | $0.50 | $1.50 | **$6.00** |
| **Interactive** (manual) | $0 | $0 | $0 | $0 | **$0** ✨ |

### Pros & Cons

#### Interactive Approach

**Pros:**
- ✅ **Zero API costs** (covered by Claude Pro)
- ✅ **Human oversight** at each phase
- ✅ **Same templates** and structure
- ✅ **Same workflows** and quality
- ✅ **Better control** over what gets committed
- ✅ **Can intervene** if something goes wrong

**Cons:**
- ❌ **Not fully autonomous** (requires manual kick-off)
- ❌ **Takes more time** (waiting for each phase)
- ❌ **Requires presence** (can't run overnight)

#### Automated Approach

**Pros:**
- ✅ **Fully autonomous** (hands-off)
- ✅ **Fast** (runs continuously)
- ✅ **Can run overnight** or while away

**Cons:**
- ❌ **Costs money** ($2-9 per workflow)
- ❌ **No oversight** (may commit unwanted changes)
- ❌ **Hard to intervene** once started

### Implementation Plan

To implement the interactive workflow:

#### 1. Create Interactive Guide Commands

```bash
# Create the new slash commands
touch .claude/commands/adw_interactive_plan.md
touch .claude/commands/adw_interactive_build.md
touch .claude/commands/adw_interactive_test.md
touch .claude/commands/adw_interactive_review.md
touch .claude/commands/adw_interactive_pr.md
```

#### 2. Populate Each Command

See the command templates in the "Enhanced Semi-Automated Approach" section above.

#### 3. Create State Helper Script

```bash
touch adws/interactive_state.py
chmod +x adws/interactive_state.py
```

#### 4. Test the Workflow

```bash
# In interactive Claude Code session
/adw_interactive_plan
```

### Hybrid Approach

You can also mix automated and interactive:

- **Interactive for expensive phases** (Plan, Build, Review) = $0
- **Automated for cheap phases** (Testing, Classification) = ~$1

This gives you cost savings while maintaining automation for tedious tasks.

### Summary

| Feature | Automated | Interactive | Hybrid |
|---------|-----------|-------------|--------|
| Cost | $2-9 | $0 | $0-2 |
| Speed | Fast | Medium | Medium |
| Control | Low | High | Medium |
| Oversight | None | Full | Partial |
| Best For | High volume | Cost savings | Balance |

### Recommendation

Start with the **fully interactive approach** to:
1. **Eliminate API costs** completely
2. **Learn the workflow** step by step
3. **Maintain quality** with human oversight

Once comfortable, optionally add automation for specific phases you trust.

### Next Steps

1. Create the 5 new interactive guide commands
2. Create the `interactive_state.py` helper script
3. Test with a simple issue
4. Document your learnings
5. Refine the workflow based on experience

This approach gives you **all the benefits of ADW workflows at zero cost**, with the only trade-off being that you need to manually kick off each phase.
