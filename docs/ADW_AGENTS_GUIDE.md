# ADW Agents: Complete Guide

## Overview

The AI Developer Workflow (ADW) system uses **specialized AI agents** to handle different aspects of software development. This document catalogs all agents, what they do, and when they're created.

---

## What is an Agent?

An **agent** is a specialized AI worker that:
- Has a specific role (planning, implementing, testing, etc.)
- Receives a focused prompt for its task
- Generates outputs (code, plans, commit messages, etc.)
- Leaves an audit trail of its work

### Agent Artifacts

Each agent creates a folder structure:
```
agents/{adw_id}/{agent_name}/
├── prompts/
│   └── {command}.txt          # The prompt sent to Claude
├── raw_output.jsonl           # Streaming output (line-by-line)
└── raw_output.json            # Final structured output
```

---

## Agent Types

### SDLC Agents (Software Development Life Cycle)

These handle the core development workflow:

| Agent | What It Does |
|-------|--------------|
| `sdlc_planner` | Creates implementation plans |
| `sdlc_planner_committer` | Commits the plan |
| `sdlc_implementor` | Implements the plan |
| `sdlc_implementor_committer` | Commits the implementation |

### Utility Agents

These handle supporting tasks:

| Agent | What It Does |
|-------|--------------|
| `issue_classifier` | Classifies issue as feature/bug/chore |
| `branch_generator` | Generates semantic branch names |
| `pr_creator` | Creates pull requests |

### Testing Agents

These handle quality assurance:

| Agent | What It Does |
|-------|--------------|
| `test_runner` | Runs backend test suites |
| `test_resolver_iter{N}_{idx}` | Fixes failed tests (with retries) |
| `e2e_test_runner_{iteration}_{idx}` | Runs E2E browser tests |
| `e2e_test_resolver_iter{N}_{idx}` | Fixes failed E2E tests (with retries) |

### Review Agents (Planned)

These handle code review:

| Agent | What It Does |
|-------|--------------|
| `sdlc_reviewer` | Reviews implementation vs spec |
| `patch_applier` | Applies fixes for blockers |

---

## Complete Agent Catalog

### 1. `issue_classifier/`

**Purpose:** Classify GitHub issue as `/feature`, `/bug`, or `/chore`

**Created by:**
- Slash Command: `/classify_issue`
- Phase: Planning
- Step: 2

**Model:** Claude Sonnet (fast classification)

**Input:**
```json
{
  "issue_number": 20,
  "title": "Add dark mode",
  "body": "Users want dark mode..."
}
```

**Output:**
```json
{
  "classification": "/feature",
  "confidence": "high"
}
```

**Code References:**
- Automated: `adws/adw_modules/workflow_ops.py:classify_issue()` ANCHOR: `classify_issue`
- Interactive: `.claude/commands/classify_issue.md`
- Constant: `AGENT_CLASSIFIER = "issue_classifier"`

---

### 2. `branch_generator/`

**Purpose:** Generate semantic branch name

**Created by:**
- Slash Command: `/generate_branch_name`
- Phase: Planning
- Step: 4

**Model:** Claude Sonnet (fast generation)

**Input:**
```json
{
  "issue_number": 20,
  "issue_class": "/feature",
  "title": "Add dark mode",
  "adw_id": "abc12345"
}
```

**Output:**
```
feature-issue-20-adw-abc12345-add-dark-mode
```

**Code References:**
- Automated: `adws/adw_modules/workflow_ops.py:generate_branch_name()` ANCHOR: `generate_branch_name`
- Interactive: `.claude/commands/generate_branch_name.md`
- Constant: `AGENT_BRANCH_GENERATOR = "branch_generator"`

---

### 3. `sdlc_planner/`

**Purpose:** Create detailed implementation plan (spec file)

**Created by:**
- Slash Command: `/feature`, `/bug`, or `/chore`
- Phase: Planning
- Step: 7

**Model:** Claude Opus (complex planning)

**Input:**
```json
{
  "issue_number": 20,
  "adw_id": "abc12345",
  "issue": {
    "title": "Add dark mode",
    "body": "Users want dark mode..."
  }
}
```

**Output:**
- Creates: `specs/issue-20-adw-abc12345-sdlc_planner-add-dark-mode.md`
- Contains: Technical approach, files to modify, acceptance criteria, testing strategy

**Code References:**
- Automated: `adws/adw_modules/workflow_ops.py:build_plan()` ANCHOR: `build_plan`
- Interactive: `.claude/commands/feature.md` (or `bug.md`, `chore.md`)
- Constant: `AGENT_PLANNER = "sdlc_planner"`

---

### 4. `sdlc_planner_committer/`

**Purpose:** Commit the plan file with semantic message

**Created by:**
- Slash Command: `/commit`
- Phase: Planning
- Step: 9

**Model:** Claude Sonnet (fast commits)

**Input:**
```json
{
  "agent_name": "sdlc_planner",
  "type": "feature",
  "issue": {...}
}
```

**Output:**
```
sdlc_planner: feat: add dark mode implementation plan
```

**Code References:**
- Automated: `adws/adw_modules/workflow_ops.py:create_commit()` ANCHOR: `create_commit`
- Interactive: `.claude/commands/commit.md`
- Git: `adws/adw_modules/git_ops.py:commit_changes()` (helper function ~lines 79-98)

---

### 5. `pr_creator/`

**Purpose:** Create pull request with proper description

**Created by:**
- Slash Command: `/pull_request` or `gh pr create`
- Phase: Planning (or standalone)
- Step: 10

**Model:** Claude Sonnet (fast PR generation)

**Input:**
```json
{
  "issue_number": 20,
  "title": "Add dark mode",
  "plan_file": "specs/issue-20-...",
  "branch_name": "feature-issue-20-..."
}
```

**Output:**
- Creates PR with:
  - Title: `[Issue #20] Add dark mode`
  - Body: Summary + plan reference + closes issue link

**Code References:**
- Automated: `adws/adw_modules/workflow_ops.py:create_pull_request()` ANCHOR: `create_pull_request`
- Interactive: `.claude/commands/pull_request.md`
- Constant: `AGENT_PR_CREATOR = "pr_creator"`

---

### 6. `sdlc_implementor/`

**Purpose:** Implement all changes from the plan

**Created by:**
- Slash Command: `/implement`
- Phase: Build
- Step: 4

**Model:** Claude Opus (complex implementation)

**Input:**
```json
{
  "plan_file": "specs/issue-20-adw-abc12345-...",
  "adw_id": "abc12345"
}
```

**Output:**
- Creates/modifies files according to plan
- Follows project conventions
- Meets acceptance criteria

**Code References:**
- Automated: `adws/adw_modules/workflow_ops.py:implement_solution()` (function ~lines 182-206)
- Interactive: `.claude/commands/implement.md`
- Constant: `AGENT_IMPLEMENTOR = "sdlc_implementor"`

---

### 7. `sdlc_implementor_committer/`

**Purpose:** Commit the implementation with semantic message

**Created by:**
- Slash Command: `/commit`
- Phase: Build
- Step: 6

**Model:** Claude Sonnet (fast commits)

**Input:**
```json
{
  "agent_name": "sdlc_implementor",
  "type": "feature",
  "issue": {...}
}
```

**Output:**
```
sdlc_implementor: feat: implement dark mode functionality
```

**Code References:**
- Automated: `adws/adw_modules/workflow_ops.py:create_commit()` ANCHOR: `create_commit`
- Interactive: `.claude/commands/commit.md`

---

### 8. `test_runner/`

**Purpose:** Run backend test suite (pytest)

**Created by:**
- Slash Command: `/test` or direct pytest
- Phase: Testing
- Step: 1

**Model:** Claude Sonnet (test execution)

**Input:**
```json
{
  "test_command": "cd app/server && uv run pytest"
}
```

**Output:**
```json
{
  "total_tests": 67,
  "passed": 65,
  "failed": 2,
  "failures": [...]
}
```

**Code References:**
- Automated: `adws/adw_test.py:run_tests()` line 219
- Interactive: `.claude/commands/test.md`

---

### 9. `test_resolver_iter{N}_{idx}/`

**Purpose:** Analyze and fix failed tests (with retry attempts)

**Created by:**
- Slash Command: `/resolve_failed_test`
- Phase: Testing
- Step: 2

**Model:** Claude Opus (complex debugging)

**Iteration Pattern:**
- `test_resolver_iter1_0/` - First attempt, first test
- `test_resolver_iter1_1/` - First attempt, second test
- `test_resolver_iter2_0/` - Second attempt (retry), first test
- Maximum: 4 attempts (`MAX_TEST_RETRY_ATTEMPTS = 4`)

**Input:**
```json
{
  "test_name": "test_example",
  "error": "AssertionError: Expected 5, got 3",
  "test_path": "tests/test_example.py",
  "execution_command": "cd app/server && uv run pytest tests/test_example.py::test_example"
}
```

**Output:**
- Fixes the code causing the test failure
- Re-runs the test to verify fix

**Code References:**
- Automated: `adws/adw_test.py:resolve_failed_tests()` line 308
- Interactive: `.claude/commands/resolve_failed_test.md`

---

### 10. `e2e_test_runner_{iteration}_{idx}/`

**Purpose:** Run E2E browser tests using Playwright

**Created by:**
- Slash Command: `/test_e2e`
- Phase: Testing
- Step: 5

**Model:** Claude Sonnet (test orchestration)

**Folder Pattern:**
- `e2e_test_runner_0_0/` - First iteration, first test
- `e2e_test_runner_0_1/` - First iteration, second test
- One folder per E2E test file

**Input:**
```json
{
  "test_file": ".claude/commands/e2e/test_dark_mode.md",
  "application_url": "http://localhost:5173"
}
```

**Output:**
```json
{
  "test_name": "Dark Mode Toggle",
  "status": "passed",
  "screenshots": ["01_initial.png", "02_toggled.png"],
  "error": null
}
```

**Special Features:**
- Captures screenshots at key steps
- Saves to: `agents/{adw_id}/e2e_test_runner_0_{idx}/img/{test_name}/`

**Code References:**
- Automated: `adws/adw_test.py:run_e2e_tests()` line 489
- Executes: `adws/adw_test.py:execute_single_e2e_test()` line 524
- Interactive: `.claude/commands/test_e2e.md`

---

### 11. `e2e_test_resolver_iter{N}_{idx}/`

**Purpose:** Analyze and fix failed E2E tests

**Created by:**
- Slash Command: `/resolve_failed_e2e_test`
- Phase: Testing
- Step: 6

**Model:** Claude Opus (complex UI debugging)

**Iteration Pattern:**
- `e2e_test_resolver_iter1_0/` - First attempt
- `e2e_test_resolver_iter2_0/` - Second attempt (retry)
- Maximum: 2 attempts (`MAX_E2E_TEST_RETRY_ATTEMPTS = 2`)

**Input:**
```json
{
  "test_name": "Dark Mode Toggle",
  "test_file": ".claude/commands/e2e/test_dark_mode.md",
  "error": "Element not found: .dark-mode-toggle",
  "screenshots": ["01_failed_state.png"]
}
```

**Output:**
- Analyzes screenshots and error
- Fixes UI/functionality issues
- Returns success/failure

**Code References:**
- Automated: `adws/adw_test.py:resolve_failed_e2e_tests()` line 662
- Interactive: `.claude/commands/resolve_failed_e2e_test.md`

---

### 12. Review Agents (Planned - Not Yet Implemented)

#### `sdlc_reviewer/`

**Purpose:** Review implementation against spec

**Created by:**
- Slash Command: `/review`
- Phase: Review
- Model: Claude Opus

**Planned Features:**
- Compare implementation vs original plan
- Identify gaps or deviations
- Check acceptance criteria met
- Generate review report

---

#### `patch_applier/`

**Purpose:** Apply fixes for review blockers

**Created by:**
- Slash Command: `/patch`
- Phase: Review
- Model: Claude Opus

**Planned Features:**
- Fix issues identified in review
- Apply targeted patches
- Re-run affected tests

---

## Agent Naming Conventions

### Pattern: `{role}_{action}_{iteration}_{index}`

**Examples:**
- `sdlc_planner` - SDLC role, planning action
- `sdlc_implementor_committer` - SDLC role, implementing action, committing sub-action
- `test_resolver_iter2_3` - Test resolving role, iteration 2, test index 3
- `e2e_test_runner_0_1` - E2E test running role, iteration 0, test index 1

### Iteration Numbers

**Why iterations?**
- Tests may fail and need multiple fix attempts
- Each attempt gets its own folder for audit trail
- Prevents overwriting previous attempt data

**Iteration Pattern:**
```
iter1 → First fix attempt
iter2 → Second fix attempt (if iter1 didn't resolve)
iter3 → Third fix attempt (backend tests only)
iter4 → Fourth fix attempt (backend tests only)
```

**Limits:**
- Backend tests: 4 attempts (`MAX_TEST_RETRY_ATTEMPTS = 4`)
- E2E tests: 2 attempts (`MAX_E2E_TEST_RETRY_ATTEMPTS = 2`)

---

## Model Selection Strategy

### Claude Opus (Complex Tasks)
- `sdlc_planner` - Creating detailed implementation plans
- `sdlc_implementor` - Writing complex code
- `test_resolver_iter*` - Debugging test failures
- `e2e_test_resolver_iter*` - Debugging UI issues
- `sdlc_reviewer` - Comprehensive code review

**Rationale:** These tasks require deep reasoning, context understanding, and creative problem-solving.

### Claude Sonnet (Fast Tasks)
- `issue_classifier` - Simple classification
- `branch_generator` - Name generation
- `*_committer` - Commit message generation
- `pr_creator` - PR description generation
- `test_runner` - Test execution coordination
- `e2e_test_runner_*` - E2E test orchestration

**Rationale:** These tasks are more mechanical and benefit from faster response times.

---

## Folder Structure Summary

### Planning Phase
```
agents/{adw_id}/
├── adw_plan/                        # PHASE folder
│   └── execution.log
├── issue_classifier/                # AGENT folder
├── branch_generator/                # AGENT folder
├── sdlc_planner/                    # AGENT folder (SDLC)
├── sdlc_planner_committer/          # AGENT folder (SDLC)
└── pr_creator/                      # AGENT folder
```

### Build Phase
```
agents/{adw_id}/
├── adw_build/                       # PHASE folder
│   └── execution.log
├── sdlc_implementor/                # AGENT folder (SDLC)
└── sdlc_implementor_committer/      # AGENT folder (SDLC)
```

### Testing Phase
```
agents/{adw_id}/
├── adw_test/                        # PHASE folder
│   └── execution.log
├── test_runner/                     # AGENT folder
├── test_resolver_iter1_0/           # AGENT folder (retry 1)
├── test_resolver_iter2_0/           # AGENT folder (retry 2)
├── e2e_test_runner_0_0/             # AGENT folder (test 1)
├── e2e_test_runner_0_1/             # AGENT folder (test 2)
└── e2e_test_resolver_iter1_0/       # AGENT folder (E2E retry)
```

---

## Key Differences: PHASE vs AGENT Folders

| Type | Created By | Contains | Purpose |
|------|------------|----------|---------|
| **PHASE** | Guide commands | `execution.log` | Track overall phase progress |
| **AGENT** | Slash commands | `prompts/`, `raw_output.*` | Track individual agent work |

**Example:**
- `adw_plan/execution.log` - Contains logs for the entire planning phase
- `sdlc_planner/prompts/feature.txt` - Contains the specific prompt sent to the planner agent

---

## Code References

### Agent Constants
```python
# adws/adw_modules/workflow_ops.py lines 22-27
AGENT_PLANNER = "sdlc_planner"
AGENT_IMPLEMENTOR = "sdlc_implementor"
AGENT_CLASSIFIER = "issue_classifier"
AGENT_BRANCH_GENERATOR = "branch_generator"
AGENT_PR_CREATOR = "pr_creator"
```

### Agent Execution
```python
# adws/adw_modules/agent.py ANCHOR: execute_template
def execute_template(slash_command: str, args: list, model: str = None):
    """
    Executes a Claude Code slash command.
    Creates agent folder structure automatically.
    """
```

### Workflow Operations
- Classification: `adws/adw_modules/workflow_ops.py:classify_issue()` ANCHOR: `classify_issue`
- Branch Naming: `adws/adw_modules/workflow_ops.py:generate_branch_name()` ANCHOR: `generate_branch_name`
- Planning: `adws/adw_modules/workflow_ops.py:build_plan()` ANCHOR: `build_plan`
- Implementation: `adws/adw_modules/workflow_ops.py:implement_solution()` (function ~lines 182-206)
- Commits: `adws/adw_modules/workflow_ops.py:create_commit()` ANCHOR: `create_commit`
- PRs: `adws/adw_modules/workflow_ops.py:create_pull_request()` ANCHOR: `create_pull_request`

---

## Quick Reference: Agent by Phase

| Phase | Agents Created |
|-------|----------------|
| **Plan** | `issue_classifier`, `branch_generator`, `sdlc_planner`, `sdlc_planner_committer`, `pr_creator` |
| **Build** | `sdlc_implementor`, `sdlc_implementor_committer` |
| **Test** | `test_runner`, `test_resolver_iter*`, `e2e_test_runner_*`, `e2e_test_resolver_iter*` |
| **Review** | `sdlc_reviewer` (planned), `patch_applier` (planned) |

---

## Summary

The ADW system uses **14 specialized agent types** (12 active, 2 planned) to automate the complete software development lifecycle:

- **2 utility agents** handle classification and naming
- **4 SDLC agents** handle planning and implementation
- **1 PR agent** handles pull request creation
- **5 testing agents** handle test execution and fixing
- **2 review agents** (planned) will handle code review

Each agent is a specialized AI worker with a focused role, leaving behind a complete audit trail of its work. This modular architecture enables complex workflows while maintaining clear separation of concerns and full traceability.
