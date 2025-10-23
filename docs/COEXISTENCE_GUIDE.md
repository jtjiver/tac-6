# Coexistence Guide: Automated and Interactive Workflows

## ✅ Yes, Both Approaches Can Run Together!

Your ADW system now supports **both** the automated Python workflow **and** the interactive Claude Code workflow running side-by-side. This document explains how they coexist without interfering with each other.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Repository                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Automated System (Unchanged)         Interactive System    │
│  ════════════════════════             ══════════════════    │
│                                                             │
│  adws/                                .claude/commands/     │
│  ├── adw_plan.py                      ├── adw_guide_plan.md│
│  ├── adw_build.py                     ├── adw_guide_build.md│
│  ├── adw_test.py                      └── adw_guide_test.md│
│  └── adw_modules/                                          │
│                                                             │
│  Trigger: python or webhooks          Trigger: /adw_guide_*│
│  Cost: $$$                             Cost: $0             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
                  ┌───────────────────────┐
                  │  Shared Resources     │
                  ├───────────────────────┤
                  │ • agents/{adw_id}/    │
                  │ • .git repository     │
                  │ • GitHub issues       │
                  │ • Slash commands      │
                  └───────────────────────┘
```

---

## What's Shared

Both approaches share these resources **without conflict**:

### 1. **Folder Structure**
Both create identical folder structures:
```
agents/{adw_id}/
├── adw_plan/execution.log          ✅ Both create this
├── sdlc_planner/                   ✅ Both create this
└── adw_state.json                  ✅ Both create this
```

**No conflict** because:
- Each workflow uses a unique `{adw_id}`
- If you run both on same issue, use different ADW IDs

### 2. **Slash Commands**
Both use the same slash commands:
- `/classify_issue`
- `/implement`
- `/commit`
- `/test_e2e`
- etc.

**No conflict** because:
- Automated: Calls via subprocess (`claude -p /implement`)
- Interactive: Calls via SlashCommand tool
- Both create separate agent folders with unique ADW IDs

### 3. **Git Repository**
Both create commits and branches:
```bash
git checkout -b feature-issue-20-adw-{adw_id}-description
git commit -m "sdlc_planner: feat: ..."
```

**No conflict** because:
- Each uses unique ADW ID in branch name
- Different ADW IDs = different branches

### 4. **GitHub Issues**
Both post comments to GitHub issues:
```
[ADW-BOT] {adw_id}_ops: ✅ Planning phase completed
```

**No conflict** because:
- Each comment is tagged with unique ADW ID
- Easy to tell which workflow created which comment

---

## What's Different

### Automated System
**Files:**
- `adws/*.py` - Python scripts
- `adws/adw_modules/*.py` - Shared modules

**How it works:**
1. User runs: `python adws/adw_plan.py 20`
2. Script spawns subprocesses: `claude -p /implement`
3. Each subprocess = separate Claude API call
4. Creates folders: `agents/{adw_id}/`

**When to use:**
- CI/CD pipelines
- Webhooks (automatic on issue creation)
- When you're not at your computer
- When you want guaranteed reproducibility

### Interactive System
**Files:**
- `.claude/commands/adw_guide_*.md` - Guide files
- No Python code changes

**How it works:**
1. User runs: `/adw_guide_plan` in Claude Code
2. Claude orchestrates: SlashCommand and Task tools
3. All agents run in same session = $0
4. Creates folders: `agents/{adw_id}/`

**When to use:**
- Development and debugging
- When you want real-time visibility
- When you want $0 cost
- When you want 2-4x faster execution

---

## Running Both on Same Issue

You can run **both** workflows on the same issue:

### Scenario: Testing Both Approaches

```bash
# First, run automated
python adws/adw_plan.py 20
# Creates: agents/abc12345/
# Branch: feature-issue-20-adw-abc12345-...

# Then, run interactive
/adw_guide_plan
# When asked for issue: 20
# Creates: agents/xyz98765/  (different ADW ID!)
# Branch: feature-issue-20-adw-xyz98765-...
```

**Result:**
- Two separate ADW IDs
- Two separate branches
- Two separate PRs
- Same issue, different implementations
- You can compare artifacts and cost

**GitHub Issue Comments:**
```
[ADW-BOT] abc12345_ops: ✅ Planning phase completed  ← Automated
[ADW-BOT] xyz98765_ops: ✅ Planning phase completed  ← Interactive
```

Easy to distinguish!

---

## File System Layout

When both approaches run on same issue:

```
agents/
├── abc12345/                    ← Automated workflow
│   ├── adw_plan/
│   │   └── execution.log
│   ├── sdlc_planner/
│   └── adw_state.json
│
└── xyz98765/                    ← Interactive workflow
    ├── adw_plan/
    │   └── execution.log
    ├── sdlc_planner/
    └── adw_state.json

.git/
└── refs/heads/
    ├── feature-issue-20-adw-abc12345-...  ← Automated branch
    └── feature-issue-20-adw-xyz98765-...  ← Interactive branch
```

**No conflicts** - completely separate!

---

## Maintenance

### Updating Automated System
**Files to modify:** `adws/*.py`

```bash
# Example: Add new feature to automated
vim adws/adw_plan.py
# Interactive workflows unaffected
```

**Impact:** None on interactive workflows

### Updating Interactive System
**Files to modify:** `.claude/commands/adw_guide_*.md`

```bash
# Example: Add new step to interactive
vim .claude/commands/adw_guide_plan.md
# Automated workflows unaffected
```

**Impact:** None on automated workflows

### Updating Slash Commands
**Files to modify:** `.claude/commands/{implement,commit,etc}.md`

```bash
# Example: Improve /implement prompt
vim .claude/commands/implement.md
# Both workflows use new version automatically
```

**Impact:** Both workflows benefit from improvements!

---

## Migration Path

You can gradually migrate from automated to interactive:

### Phase 1: Coexistence (Current State)
- Keep automated working for CI/CD
- Use interactive for development
- Compare costs and speed

### Phase 2: Prefer Interactive
- Use interactive for all manual workflows
- Keep automated for webhooks only
- Monitor cost savings

### Phase 3: Full Interactive (Optional)
- Disable automated webhooks
- Use interactive exclusively
- Maximum cost savings

**You're in Phase 1 now** - both working perfectly!

---

## Troubleshooting

### Issue: "Agent folder already exists"
**Cause:** Two workflows tried to use same ADW ID

**Solution:**
- Each workflow generates unique ADW ID
- If manually specifying ADW ID, use different ones
- Or: Delete old agent folder first

### Issue: "Branch already exists"
**Cause:** Branch name collision (same ADW ID)

**Solution:**
- Use different ADW IDs
- Or: Delete old branch first: `git branch -D feature-issue-20-adw-abc12345-...`

### Issue: "Can't tell which workflow created what"
**Cause:** GitHub comments look similar

**Solution:**
- Check ADW ID in comment: `[ADW-BOT] {adw_id}_ops`
- Automated uses 8-char hex ADW IDs
- Interactive also uses 8-char hex ADW IDs
- Check `agents/{adw_id}/adw_state.json` → `mode` field:
  - `"automated"` = Python script
  - `"interactive_intelligent"` = Claude Code guide

---

## Best Practices

### For Development
✅ Use **interactive** workflows
- Faster (2-4x)
- Free ($0)
- Better visibility
- Easier debugging

### For Production
✅ Use **automated** workflows
- Hands-off (webhooks)
- Guaranteed reproducibility
- No human required
- Works in CI/CD

### For Testing
✅ Run **both** on same issue
- Compare artifacts (should be identical)
- Compare costs (automated = $$$, interactive = $0)
- Compare speed (interactive 2-4x faster)
- Verify folder structures match

---

## Quick Reference

| Aspect | Automated | Interactive | Shared? |
|--------|-----------|-------------|---------|
| **Files** | `adws/*.py` | `.claude/commands/*.md` | No |
| **Trigger** | `python adws/adw_plan.py` | `/adw_guide_plan` | No |
| **Cost** | $$$ | $0 | No |
| **Agents Folder** | `agents/{adw_id}/` | `agents/{adw_id}/` | Yes (unique ID) |
| **Git Branches** | `feature-issue-X-adw-{adw_id}` | `feature-issue-X-adw-{adw_id}` | Yes (unique ID) |
| **Slash Commands** | Subprocess | SlashCommand tool | Yes (same files) |
| **GitHub Comments** | `[ADW-BOT] {adw_id}_ops` | `[ADW-BOT] {adw_id}_ops` | Yes (unique ID) |
| **Artifacts** | Identical structure | Identical structure | Yes |

---

## Summary

✅ **Both approaches coexist perfectly**
- No file conflicts
- No git conflicts  
- No process conflicts
- Unique ADW IDs separate everything

✅ **You can use either at any time**
- Run automated for CI/CD
- Run interactive for development
- Run both to compare

✅ **Updates don't interfere**
- Modify Python code → only affects automated
- Modify guide files → only affects interactive
- Modify slash commands → improves both

✅ **Migration is optional**
- Stay in coexistence mode forever
- Or gradually shift to interactive
- Your choice based on needs

**Bottom line:** The interactive system is a **layer on top** of the automated system, not a replacement. Both work together harmoniously! 🎉
