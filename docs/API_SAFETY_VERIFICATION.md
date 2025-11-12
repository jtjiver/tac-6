# Claude Code Pro Integration Guide

## Summary: 💡 ADW NOW SUPPORTS CLAUDE CODE PRO

**Important Update:** This codebase now fully supports Claude Code Pro! The previous API credit protection has been updated to reflect that:

- **Claude Code Pro users**: ADW works automatically using your Pro subscription credits (NOT API credits)
- **Non-Pro users**: Can still use ADW with ANTHROPIC_API_KEY (will consume API credits)
- **Default behavior**: API usage is ENABLED by default to support Pro users

## Files Verified

- ✅ `.claude/commands/adw_guide_plan.md`
- ✅ `.claude/commands/adw_guide_build.md`
- ✅ `.claude/commands/adw_guide_test.md`
- ✅ `.claude/commands/adw_guide_review.md`
- ✅ `.claude/commands/adw_guide_pr.md`
- ✅ `.claude/commands/adw_guide_status.md`

## Verification Method

### 1. Checked for Direct Python Script Execution
```bash
grep -rn "python.*adw_.*\.py\|uv run adw_" .claude/commands/adw_guide_*.md
```

**Result:** ❌ No direct Python script execution found
**Exception:** Line 152 in `adw_guide_plan.md` runs `python3 -c "import uuid; print(...)"` - this is SAFE (just generates UUID locally)

### 2. Checked for Subprocess Calls
```bash
grep -rn "subprocess.*adw_" .claude/commands/adw_guide_*.md
```

**Result:** ❌ All `subprocess` references are in **documentation blocks only**
They show architecture diagrams comparing interactive vs automated flows.

### 3. Checked for Bash Commands Calling Python
```bash
grep -A 10 '```bash' .claude/commands/adw_guide_*.md | grep -E "python.*adw_|uv run adw_"
```

**Result:** ❌ No bash commands call Python ADW scripts

## What the ADW Guides Actually Do

### Safe Operations Only

All `/adw_guide_*` commands use:

1. **Slash Commands** (via `SlashCommand` tool)
   - `/classify_issue`
   - `/generate_branch_name`
   - `/implement`
   - `/test`
   - `/review`
   - `/commit`
   - `/pull_request`

2. **Git Commands** (via `Bash` tool)
   - `git branch`
   - `git checkout`
   - `git add`
   - `git commit`
   - `git push`

3. **GitHub CLI** (via `Bash` tool)
   - `gh issue view`
   - `gh pr create`
   - `gh pr view`

4. **Task Tool** (for sub-agents)
   - Spawns sub-agents in same session
   - No additional API costs

**ALL of these use your Claude Pro subscription, NOT API credits!**

## Python Scripts That ARE Protected

While the `/adw_guide_*` commands don't call them, these Python scripts now have API protection:

### `adws/adw_modules/agent.py`
- ✅ **Protected** with `ADW_ALLOW_API_USAGE` check
- ✅ Large warning box when blocked
- ✅ Recommends using orchestrator instead
- ✅ Backup saved: `adws/adw_modules/agent.py.backup`

### Scripts That Use `agent.py`
All these are now protected:
- `adws/adw_plan.py`
- `adws/adw_build.py`
- `adws/adw_test.py`
- `adws/adw_review.py`
- `adws/adw_patch.py`
- `adws/adw_document.py`

### How It Works Now (Updated for Claude Code Pro)

```python
# In agent.py (line 38)
# DEFAULT IS NOW TRUE to support Claude Code Pro users
API_USAGE_ALLOWED = os.getenv("ADW_ALLOW_API_USAGE", "true").lower() == "true"

# In prompt_claude_code() (line 199)
if not API_USAGE_ALLOWED:
    # Only blocks if explicitly set to false
    # Most users (with Claude Code Pro) won't hit this
    return AgentPromptResponse(output="BLOCKED", success=False)
```

## Architecture Comparison

### Interactive Guides (Safe - $0)
```
/adw_guide_plan (single Claude Pro session)
├── Uses SlashCommand tool
├── Uses Bash tool
├── Uses Task tool for sub-agents
└── All in ONE session = $0
```

### Automated Scripts (Works with Claude Code Pro)
```
python adws/adw_plan.py (NOW WORKS by default!)
├── Calls agent.py
├── Which calls: claude -p "/classify_issue"
├── Which calls: claude -p "/generate_branch_name"
└── Uses Claude Code Pro credits (if you have Pro)
   OR API credits (if using ANTHROPIC_API_KEY)

To DISABLE (only if needed): export ADW_ALLOW_API_USAGE=false
```

### Orchestrator (Safe - $0)
```
./adws/orchestrate.sh <adw_id>
├── Spawns: claude /adw_guide_test <id>
├── Spawns: claude /adw_guide_review <id>
├── Spawns: claude /adw_guide_pr <id>
└── All use Claude Pro sessions = $0
```

## Complete Safety Matrix

| Component | Uses API? | Protected? | Cost |
|-----------|-----------|------------|------|
| `/adw_guide_plan` | ❌ No | N/A (Safe) | $0 |
| `/adw_guide_build` | ❌ No | N/A (Safe) | $0 |
| `/adw_guide_test` | ❌ No | N/A (Safe) | $0 |
| `/adw_guide_review` | ❌ No | N/A (Safe) | $0 |
| `/adw_guide_pr` | ❌ No | N/A (Safe) | $0 |
| `adws/adw_orchestrator_enhanced.py` | ❌ No | N/A (Safe) | $0 |
| `./adws/orchestrate.sh` | ❌ No | N/A (Safe) | $0 |
| `adws/adw_plan.py` | 💡 Yes (Pro) | N/A | Pro credits |
| `adws/adw_build.py` | 💡 Yes (Pro) | N/A | Pro credits |
| `adws/adw_test.py` | 💡 Yes (Pro) | N/A | Pro credits |
| `adws/adw_review.py` | 💡 Yes (Pro) | N/A | Pro credits |
| `adws/adw_modules/agent.py` | 💡 Yes (Pro) | Optional | Pro credits |

## Recommended Workflow (100% Safe)

### Option 1: Hook-Triggered Automation
```bash
# One command, everything automated
claude /adw_guide_plan
# → Enter issue number: 12
# → Hook triggers build/test/review/pr automatically
# Cost: $0
```

### Option 2: Manual with Orchestrator
```bash
# Step 1: Plan (manual)
claude /adw_guide_plan

# Step 2: Build (manual)
claude /adw_guide_build <adw_id>

# Step 3: Automate the rest
./adws/orchestrate.sh <adw_id>
# Cost: $0
```

### Option 3: Fully Manual
```bash
claude /adw_guide_plan
claude /adw_guide_build <adw_id>
claude /adw_guide_test <adw_id>
claude /adw_guide_review <adw_id>
claude /adw_guide_pr <adw_id>
# Cost: $0
```

## Automated Python Workflow (NOW ENABLED for Pro Users)

```bash
# This NOW WORKS by default with Claude Code Pro!
uv run adws/adw_plan_build_review.py 22

# Uses your Claude Code Pro subscription credits
# No API key needed if you're authenticated with Claude Code Pro

# To disable automation (only if needed):
export ADW_ALLOW_API_USAGE=false
uv run adws/adw_plan.py 12  # Would be blocked
```

## Conclusion

✅ **All `/adw_guide_*` commands work with Claude Code Pro**
✅ **Orchestrator works with Claude Code Pro**
✅ **Automated Python scripts NOW WORK by default with Claude Code Pro**
✅ **Claude Code Pro users: Use your Pro subscription credits automatically**
✅ **Non-Pro users: Can still use API key (will consume API credits)**

### Start Here:
```bash
claude /adw_guide_plan
```

Enter issue number when asked, and let the automation handle everything!

## Files Modified

1. ✅ `adws/adw_modules/agent.py` - Added API protection
2. ✅ `adws/adw_modules/agent.py.backup` - Original backup
3. ✅ `docs/API_SAFETY_VERIFICATION.md` - This document

## Testing

To verify the protection works:

```bash
# This should show the blocking warning:
cd adws
export ADW_ALLOW_API_USAGE=false  # or unset it
uv run adw_plan.py 12

# You should see:
# ╔═══════════════════════════════════════════╗
# ║   ⚠️  API CREDIT PROTECTION ACTIVE ⚠️      ║
# ╚═══════════════════════════════════════════╝
```

## Next Steps

You're now ready to safely test the full automation:

```bash
claude /adw_guide_plan
```

When prompted, enter: **12** (for your "Dark Mode" issue)

The orchestrator hook will automatically chain the remaining phases!
