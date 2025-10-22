# Claude CLI Authentication: API vs Subscription

## The Discovery

After extensive testing and documentation review, we've discovered the exact behavior of `claude -p` mode.

## How Claude Code Authenticates

### Rule 1: Environment Variable Takes Priority

From [Claude Support](https://support.claude.com/en/articles/11145838):

> **"If you have an ANTHROPIC_API_KEY environment variable set on your system, Claude Code will use this API key for authentication instead of your Claude subscription"**

### Rule 2: Without API Key, Uses Subscription

If `ANTHROPIC_API_KEY` is NOT set:
- `claude` (interactive) → Uses **Claude Pro subscription** ✅
- `claude -p` (print mode) → Uses **Claude Pro subscription** ✅

If `ANTHROPIC_API_KEY` IS set:
- `claude` (interactive) → Uses **API key** ❌
- `claude -p` (print mode) → Uses **API key** ❌

## Why It Works On One Server But Not Another

### Server 1 (Works Fine)
```bash
$ echo $ANTHROPIC_API_KEY
# (empty - not set)

$ claude -p "test"
# ✅ Uses Pro subscription
# ✅ Zero API costs
```

### Server 2 (Fails / Uses API)
```bash
$ echo $ANTHROPIC_API_KEY
sk-ant-api03-...  # SET!

$ claude -p "test"
# ❌ Uses API key
# ❌ Consumes API credits
# ❌ Fails when credits exhausted
```

## How to Check Your Setup

```bash
# Check if API key is set
echo ${ANTHROPIC_API_KEY:+API_KEY_IS_SET}

# Check where it's set
grep -r "ANTHROPIC_API_KEY" ~/.bashrc ~/.zshrc ~/.bash_profile ~/.profile .env* 2>/dev/null
```

## The Fix

### Option 1: Temporarily Unset (Per Session)
```bash
unset ANTHROPIC_API_KEY
claude /adw_guide_plan
```

### Option 2: Run Without API Key (One Command)
```bash
env -u ANTHROPIC_API_KEY claude /adw_guide_plan
```

### Option 3: Permanently Remove (Recommended)

Find where it's exported:
```bash
grep -n "ANTHROPIC_API_KEY" ~/.bashrc ~/.zshrc ~/.bash_profile
```

Comment it out or remove it:
```bash
# export ANTHROPIC_API_KEY=sk-ant-...  # Commented out for Claude Code
```

Then reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### Option 4: Use Separate Shell (Clean Environment)
```bash
# Start new shell without inheriting env
env -i bash --norc --noprofile
cd /path/to/project
claude /adw_guide_plan
```

## Why Do We Have ANTHROPIC_API_KEY Set?

The API key was likely set for the **automated Python ADW scripts** (`adws/adw_*.py`) which need it to call `agent.py` → `claude -p`.

But now:
1. ✅ We've protected those scripts from running
2. ✅ We're using `/adw_guide_*` interactive commands instead
3. ✅ We don't need the API key anymore!

## Recommended Setup

### For Interactive ADW Workflows (Claude Pro)
```bash
# .bashrc or .zshrc
# DO NOT set ANTHROPIC_API_KEY
# Claude Code will use your Pro subscription
```

### For Automated Scripts (API - if really needed)
```bash
# Only set when running Python scripts
export ADW_ALLOW_API_USAGE=true
export ANTHROPIC_API_KEY=sk-ant-...
python adws/adw_plan.py 12
```

But remember: The Python scripts are now **protected** and will warn you before using API!

## Testing Your Setup

### Test 1: Check Environment
```bash
# Should be empty
echo "API key: ${ANTHROPIC_API_KEY:+SET}"

# Should use subscription
claude -p "What is 2+2?"
```

### Test 2: Run ADW Workflow
```bash
# Start monitor in Terminal 1
./monitor_api_calls.sh

# Run workflow in Terminal 2
claude /adw_guide_plan

# Monitor should NOT alert (unless API key is set)
```

## Summary Table

| Scenario | ANTHROPIC_API_KEY | `claude` | `claude -p` | Cost |
|----------|-------------------|----------|-------------|------|
| **Recommended** | Not set | Pro ✅ | Pro ✅ | $0 |
| **Current Problem** | Set | API ❌ | API ❌ | $$$ |
| **Automated Scripts** | Set + ADW_ALLOW_API_USAGE | API ❌ | API ❌ | $$$ |

## What About Our ADW Scripts Protection?

The `agent.py` protection we added is still valuable because:

1. **Prevents accidental API use** - If someone tries to run Python scripts
2. **Shows big warning** - Makes it clear API credits would be used
3. **Recommends alternatives** - Points to orchestrator and interactive mode
4. **Double protection** - Even if API key is set, scripts are blocked

## Action Items

### For This Machine (Fix API Usage)

```bash
# 1. Find where API key is set
grep -rn "ANTHROPIC_API_KEY" ~/.bashrc ~/.zshrc ~/.bash_profile .env

# 2. Remove or comment it out
vim ~/.bashrc  # or whichever file has it

# 3. Reload shell
source ~/.bashrc

# 4. Verify it's gone
echo ${ANTHROPIC_API_KEY:+STILL_SET}
# Should output nothing

# 5. Test
claude -p "test"
# Should use Pro subscription now!
```

### For All Machines

**Best Practice:**
- ✅ Use `/adw_guide_*` commands (Pro subscription)
- ✅ Keep `ANTHROPIC_API_KEY` unset
- ✅ Use orchestrator for automation (Pro subscription)
- ❌ Don't use Python ADW scripts (they use API)

## Verification

After removing `ANTHROPIC_API_KEY`, verify:

```bash
# Should be empty
env | grep ANTHROPIC_API_KEY

# Should work (uses Pro)
claude -p "What is 1+1?"

# Should work (uses Pro)
claude /adw_guide_plan
```

## The Complete Picture

```
┌─────────────────────────────────────────────────────┐
│ Claude Code CLI Authentication Decision Tree        │
└─────────────────────────────────────────────────────┘

Is ANTHROPIC_API_KEY set?
  │
  ├─ YES → Use API key (costs money)
  │         └─ All modes: claude, claude -p, etc.
  │
  └─ NO  → Use Claude subscription (free)
            └─ All modes: claude, claude -p, etc.

┌─────────────────────────────────────────────────────┐
│ Our ADW Workflows                                    │
└─────────────────────────────────────────────────────┘

/adw_guide_* commands
  └─ Use Bash(claude -p "...")
      └─ If ANTHROPIC_API_KEY unset → Pro subscription ✅
      └─ If ANTHROPIC_API_KEY set → API (costs $$$) ❌

Orchestrator
  └─ Spawns claude /adw_guide_*
      └─ Same rules apply

Python scripts (adws/adw_*.py)
  └─ Call agent.py → claude -p
      └─ BLOCKED by our protection ✅
      └─ Would use API if unblocked ❌
```

## Conclusion

**The good news:**
- `/adw_guide_*` commands CAN use Pro subscription (no API cost)
- Just need to remove `ANTHROPIC_API_KEY` from environment

**The bad news:**
- If `ANTHROPIC_API_KEY` is set, you'll burn through API credits

**The fix:**
- Remove `ANTHROPIC_API_KEY` from your environment
- Use `/adw_guide_*` commands freely
- Cost: $0 (Claude Pro subscription only)

Ready to fix your environment and test again?
