# ADW System Documentation

Welcome to the AI Developer Workflow (ADW) system documentation! This directory contains comprehensive guides comparing the automated Python workflow vs the interactive Claude Code approach.

---

## 📚 Documentation Index

### 1. **ADW_AGENTS_GUIDE.md** - Complete Agent Catalog
**What it covers:**
- All 14 specialized AI agents in the system
- What each agent does and when it's created
- Input/output specifications
- Model selection rationale (Opus vs Sonnet)
- Folder structure and naming conventions
- Code references to automated system

**Read this if you want to:**
- Understand what each agent folder contains
- Know when agents are created
- Learn the difference between PHASE and AGENT folders
- Understand SDLC agent naming
- See iteration patterns for test resolvers

---

### 2. **COMPARISON_SUMMARY.md** - High-Level Comparison
**What it covers:**
- Quick reference table (costs, times, steps)
- Agent comparison by phase
- Execution approach differences
- Folder structure verification
- Logging format comparison
- GitHub tracking differences
- Error handling approaches
- Cost analysis and savings calculations
- Speed comparisons and reasons
- When to use each approach

**Read this if you want to:**
- Understand the big picture differences
- See cost savings ($792-$2,976/year)
- Compare execution speeds (2-4x faster interactive)
- Decide which approach to use
- Get monthly/annual savings projections

---

### 3. **COMPARISON_PLANNING_PHASE.md** - Detailed Planning Phase
**What it covers:**
- Step-by-step comparison of all 13 planning steps
- Code snippets from both approaches
- Exact log outputs for comparison
- Subprocess vs Task tool differences
- Agent folder creation at each step
- GitHub comment examples
- Cost breakdown per agent
- Time breakdown per step

**Read this if you want to:**
- See exactly what happens at each step
- Understand how logging differs
- Compare code implementations
- Verify artifact creation
- See detailed cost per agent ($3.20 vs $0)
- Understand the 2-2.3x speedup

---

### 4. **COMPARISON_BUILD_PHASE.md** (Coming Soon)
**Will cover:**
- Step-by-step comparison of build phase
- `sdlc_implementor` agent details
- Implementation approach differences
- Cost breakdown ($3.05 vs $0)
- Speed comparison (1.6-3.3x faster)

---

### 5. **COMPARISON_BUILD_PHASE.md** - Detailed Build Phase
**What it covers:**
- Step-by-step comparison of all 10 build steps
- `sdlc_implementor` agent details
- Implementation approach differences
- Cost breakdown ($3.05 vs $0)
- Speed comparison (1.7x faster)

**Read this if you want to:**
- Understand implementation phase in detail
- See how Opus calls work in both modes
- Compare code implementation approaches
- Verify build artifacts creation

---

### 6. **COEXISTENCE_GUIDE.md** - Running Both Approaches
**What it covers:**
- How automated and interactive coexist
- Shared resources (no conflicts!)
- What's different between the two
- Running both on same issue
- Migration path options
- Troubleshooting common issues

**Read this if you want to:**
- Understand if both can run together (YES!)
- Know which approach to use when
- Learn how to compare both approaches
- Understand the layered architecture

---

## 🎯 Quick Start Guide

### If you're new to ADW:
1. Start with **COMPARISON_SUMMARY.md** to understand the big picture
2. Read **ADW_AGENTS_GUIDE.md** to learn about all the agents
3. Dive into **COMPARISON_PLANNING_PHASE.md** for detailed examples

### If you want to understand costs:
1. See **COMPARISON_SUMMARY.md** → "Cost Analysis" section
2. Note: Interactive saves $6.60-$21.60 per workflow
3. Annual savings: $792-$2,976 for typical usage

### If you want to understand speed:
1. See **COMPARISON_SUMMARY.md** → "Speed Comparison" section
2. Interactive is 2-4x faster across all phases
3. Reasons: No subprocess overhead, shared context, parallel execution

### If you're debugging:
1. Check **ADW_AGENTS_GUIDE.md** to identify which agent folder you need
2. Use **COMPARISON_PLANNING_PHASE.md** for step-by-step expectations
3. Compare your logs to the documented examples

---

## 📊 Key Statistics

### Cost Comparison (Per Workflow)
| Phase | Automated | Interactive | Savings |
|-------|-----------|-------------|---------|
| Planning | $3.20 | $0.00 | $3.20 |
| Build | $3.05 | $0.00 | $3.05 |
| Testing | $0.35-$18.35 | $0.00 | $0.35-$18.35 |
| **Total** | **$6.60-$24.60** | **$0.00** | **$6.60-$24.60** |

### Speed Comparison
| Phase | Automated | Interactive | Speedup |
|-------|-----------|-------------|---------|
| Planning | 5-7 min | 2-3 min | 2-2.3x |
| Build | 8-10 min | 3-5 min | 1.6-3.3x |
| Testing | 15-20 min | 5-7 min | 2.1-4x |
| **Total** | **28-37 min** | **10-15 min** | **2.5x avg** |

### Artifacts Created
**Result:** ✅ **100% Identical** in both approaches

Both systems create:
- Same folder structure (`agents/{adw_id}/`)
- Same agent folders (`sdlc_planner/`, `issue_classifier/`, etc.)
- Same phase folders (`adw_plan/`, `adw_build/`, `adw_test/`)
- Same spec files
- Same git commits
- Same PRs

**Only differences:**
- Log timestamp format (minor)
- `mode` field in state file: `"automated"` vs `"interactive_intelligent"`

---

## 🔍 Agent Quick Reference

### Planning Phase Agents
1. `issue_classifier/` - Classifies as feature/bug/chore
2. `branch_generator/` - Generates branch names
3. `sdlc_planner/` - Creates implementation plans
4. `sdlc_planner_committer/` - Commits the plan
5. `pr_creator/` - Creates pull requests

### Build Phase Agents
6. `sdlc_implementor/` - Implements the plan
7. `sdlc_implementor_committer/` - Commits implementation

### Testing Phase Agents
8. `test_runner/` - Runs backend tests
9. `test_resolver_iter{N}_{idx}/` - Fixes failed tests (with retries)
10. `e2e_test_runner_{N}_{idx}/` - Runs E2E tests
11. `e2e_test_resolver_iter{N}_{idx}/` - Fixes failed E2E tests

### Review Phase Agents (Planned)
12. `sdlc_reviewer/` - Reviews implementation
13. `patch_applier/` - Applies review fixes

**Total:** 14 agent types (12 active, 2 planned)
**SDLC Agents:** Only 4 of the 14 (planner, planner_committer, implementor, implementor_committer)

---

## 🏗️ Folder Structure

### PHASE Folders
Created by guide commands, contain execution logs:
```
agents/{adw_id}/
├── adw_plan/execution.log
├── adw_build/execution.log
└── adw_test/execution.log
```

### AGENT Folders
Created automatically by slash commands, contain artifacts:
```
agents/{adw_id}/
├── issue_classifier/
│   ├── prompts/classify_issue.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
├── sdlc_planner/
│   ├── prompts/feature.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
└── [... other agents ...]
```

**Key Difference:**
- **PHASE folders**: Track overall phase progress
- **AGENT folders**: Track individual agent work

---

## 💡 When to Use Each Approach

### Use Automated System When:
- You want hands-off automation (webhooks)
- You're not at your computer
- You have budget for API costs (~$7-25 per workflow)
- You're running in CI/CD pipelines
- You need guaranteed reproducibility

### Use Interactive System When:
- You want $0 cost (Claude Pro covered)
- You want 2-4x faster execution
- You want real-time visibility
- You want better error recovery
- You're actively developing
- You want comprehensive GitHub tracking

---

## 🎓 Learning Path

### Beginner
1. **Read:** COMPARISON_SUMMARY.md (30 minutes)
   - Understand the two approaches
   - See cost and speed differences
   - Learn when to use each

2. **Skim:** ADW_AGENTS_GUIDE.md (20 minutes)
   - Get familiar with agent types
   - Understand folder structure
   - Know what SDLC agents are

3. **Try:** Run `/adw_guide_plan` on a test issue
   - See agents being created
   - Watch GitHub comments appear
   - Verify folder structure matches docs

### Intermediate
1. **Deep Dive:** COMPARISON_PLANNING_PHASE.md (45 minutes)
   - Understand each step in detail
   - Compare code implementations
   - See exact log outputs

2. **Explore:** Check your `agents/` folder
   - Open agent artifact files
   - Read the prompts sent to Claude
   - Review raw outputs

3. **Compare:** Run same workflow in both modes
   - Use automated on one issue
   - Use interactive on another
   - Compare artifacts and costs

### Advanced
1. **Study:** Code references in docs
   - Review `adws/adw_modules/` Python code
   - Review `.claude/commands/` guide files
   - Understand execution flow

2. **Extend:** Add your own agents
   - Create new slash commands
   - Add new workflow phases
   - Customize logging

3. **Optimize:** Tune the workflows
   - Adjust retry attempts
   - Modify agent prompts
   - Add custom validation

---

## 🔗 Related Documentation

### In This Repository
- `.claude/commands/adw_guide_plan.md` - Planning phase guide
- `.claude/commands/adw_guide_build.md` - Build phase guide
- `.claude/commands/adw_guide_test.md` - Testing phase guide
- `adws/adw_modules/` - Automated system code
- `.claude/commands/` - Interactive slash commands

### External Resources
- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Claude Pro Subscription](https://www.anthropic.com/claude)
- [GitHub CLI Documentation](https://cli.github.com/)

---

## 📝 Notes

### Documentation Status
- ✅ **Complete:** ADW_AGENTS_GUIDE.md
- ✅ **Complete:** COMPARISON_SUMMARY.md
- ✅ **Complete:** COMPARISON_PLANNING_PHASE.md
- 🚧 **In Progress:** COMPARISON_BUILD_PHASE.md
- 🚧 **In Progress:** COMPARISON_TESTING_PHASE.md

### Maintenance
These docs are kept in sync with:
- Automated system: `adws/` directory
- Interactive guides: `.claude/commands/adw_guide_*.md`
- Update docs when making changes to either system

### Contributing
When adding new agents or phases:
1. Update ADW_AGENTS_GUIDE.md with new agent details
2. Add comparison section to relevant COMPARISON_*.md
3. Update summary statistics in COMPARISON_SUMMARY.md
4. Update this README's agent count and quick reference

---

## 🎉 Summary

The ADW system provides two equivalent ways to run your development workflow:

1. **Automated Python** - Expensive ($7-25/workflow) but hands-off
2. **Interactive Claude Code** - Free ($0/workflow) and 2-4x faster

Both produce **identical artifacts** and create the same folder structure. The interactive approach is ideal for development, while automated is better for CI/CD.

**Start here:** Read `COMPARISON_SUMMARY.md` to understand the big picture, then dive into specific phases as needed!
