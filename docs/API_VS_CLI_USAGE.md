# ADW Scripts: API vs CLI Usage

## Summary

You're right! The `-p` flag in `claude -p` **DOES use the Anthropic API** and consumes API credits.

## Scripts That Use API (via `agent.py`)

### ❌ These consume API credits:

| Script | Uses API | Via |
|--------|----------|-----|
| `adw_plan.py` | ✅ YES | `workflow_ops.py` → `agent.py` → `claude -p` |
| `adw_build.py` | ✅ YES | `workflow_ops.py` → `agent.py` → `claude -p` |
| `adw_test.py` | ✅ YES | Direct → `agent.py` → `claude -p` |
| `adw_review.py` | ✅ YES | Direct → `agent.py` → `claude -p` |
| `adw_document.py` | ✅ YES | Direct → `agent.py` → `claude -p` |
| `adw_patch.py` | ✅ YES | Direct → `agent.py` → `claude -p` |

### How They Use API

**Example from `adw_test.py`:**
```python
from adw_modules.agent import execute_template

response = execute_template(test_template_request)
```

**What `execute_template` does (in `agent.py` line 192-194):**
```python
cmd = [CLAUDE_PATH, "-p", request.prompt]  # ← This uses API!
cmd.extend(["--model", request.model])
cmd.extend(["--output-format", "stream-json"])
```

**The `-p` flag** runs Claude in **programmatic mode** which uses the Anthropic API.

---

## Scripts That Use CLI Interactive Mode (Claude Pro)

### ✅ These use Claude Pro (FREE):

| Script | Uses API | What It Does |
|--------|----------|--------------|
| `adw_orchestrator_enhanced.py` | ❌ NO | Spawns `claude /adw_guide_*` commands |
| `adw_orchestrator.py` | ❌ NO | Spawns `claude /adw_guide_*` commands |

### How They Use CLI

**From `adw_orchestrator_enhanced.py` line 217:**
```python
cmd_string = f'claude "{command} {self.adw_id}"'
# Example: claude "/adw_guide_test 57ee23f4"
```

**This runs interactive slash commands** which use Claude Pro subscription, not API.

---

## The `/adw_guide_*` Slash Commands

### ✅ These use Claude Pro (FREE):

Located in `.claude/commands/`:
- `/adw_guide_plan` → Uses Claude Pro interactive
- `/adw_guide_build` → Uses Claude Pro interactive
- `/adw_guide_test` → Uses Claude Pro interactive
- `/adw_guide_review` → Uses Claude Pro interactive
- `/adw_guide_pr` → Uses Claude Pro interactive

**These are interactive sessions** that you could run manually:
```bash
claude /adw_guide_test 57ee23f4
```

---

## Key Difference

### API Mode (Costs Money)
```bash
claude -p "prompt text" --model opus
```
- Uses Anthropic API
- Consumes API credits
- Used by: `adw_plan.py`, `adw_build.py`, `adw_test.py`, `adw_review.py`

### Interactive Mode (Free with Claude Pro)
```bash
claude /adw_guide_test 57ee23f4
```
- Uses Claude Pro subscription
- No API credits consumed
- Used by: orchestrator, manual usage

---

## Call Chain Analysis

### ❌ API-Using Chain (adw_test.py)
```
adw_test.py
  ↓
execute_template() [agent.py]
  ↓
prompt_claude_code() [agent.py]
  ↓
subprocess.run(["claude", "-p", prompt, "--model", "sonnet"])
  ↓
Anthropic API ($$$ credits consumed)
```

### ✅ CLI-Using Chain (orchestrator)
```
adw_orchestrator_enhanced.py
  ↓
start_claude_session()
  ↓
subprocess.Popen('claude "/adw_guide_test 57ee23f4"')
  ↓
Claude Pro Interactive Session ($0 - subscription)
```

---

## What Your Orchestrator Actually Does

**Line 217 in `adw_orchestrator_enhanced.py`:**
```python
cmd_string = f'claude "{command} {self.adw_id}"'
# Becomes: claude "/adw_guide_test 57ee23f4"
```

**This is IDENTICAL to you typing:**
```bash
claude /adw_guide_test 57ee23f4
```

**It does NOT call `adw_test.py`** (which would use API).
**It calls `/adw_guide_test`** (which uses Claude Pro).

---

## The Critical Question: Which Mode Are You Using?

### If you run orchestrator:
```bash
./adws/orchestrate.sh 57ee23f4
```
**Result:** Uses Claude Pro ✅ (No API credits)

### If you run Python scripts directly:
```bash
python adws/adw_test.py 57ee23f4
```
**Result:** Uses Anthropic API ❌ (Consumes API credits)

---

## Why You Ran Out of API Credits

You likely ran the **Python scripts directly**:
```bash
python adws/adw_plan.py 10
python adws/adw_build.py 57ee23f4
python adws/adw_test.py 57ee23f4
python adws/adw_review.py 57ee23f4
```

Each of these calls `agent.py` which uses `claude -p` (API mode).

---

## Safe vs Unsafe for API Credits

### ✅ SAFE (Uses Claude Pro):
```bash
# Direct slash commands
claude /adw_guide_plan
claude /adw_guide_build 57ee23f4
claude /adw_guide_test 57ee23f4

# Orchestrator (spawns above commands)
./adws/orchestrate.sh 57ee23f4
python3 adws/adw_orchestrator_enhanced.py run 57ee23f4 --chain post_build
```

### ❌ UNSAFE (Uses API):
```bash
# Python scripts that call agent.py
python adws/adw_plan.py 10
python adws/adw_build.py 57ee23f4
python adws/adw_test.py 57ee23f4
python adws/adw_review.py 57ee23f4
python adws/adw_patch.py 57ee23f4
python adws/adw_document.py 57ee23f4
```

---

## Solution: Use Orchestrator or Slash Commands

### Full Automation (Hook-Triggered):
```bash
# Only uses Claude Pro!
claude /adw_guide_plan
# Hook triggers orchestrator → all phases use Claude Pro
```

### Semi-Automatic (Direct):
```bash
# Only uses Claude Pro!
claude /adw_guide_plan
claude /adw_guide_build <adw_id>
./adws/orchestrate.sh <adw_id>  # test → review → pr
```

### Manual (Individual Commands):
```bash
# Only uses Claude Pro!
claude /adw_guide_plan
claude /adw_guide_build <adw_id>
claude /adw_guide_test <adw_id>
claude /adw_guide_review <adw_id>
claude /adw_guide_pr <adw_id>
```

---

## Verification

### Check what orchestrator will run:
```bash
# Look at the config
jq '.phase_config' adws/adw_orchestrator_config.json
```

Output shows:
```json
{
  "test": {
    "command": "/adw_guide_test",  ← Slash command, not Python script
    "requires_adw_id": true
  }
}
```

**It runs `/adw_guide_test`** (interactive), NOT `adw_test.py` (API).

---

## Bottom Line

### Your orchestrator is 100% safe! ✅

It only runs:
- `claude /adw_guide_plan`
- `claude /adw_guide_build <id>`
- `claude /adw_guide_test <id>`
- `claude /adw_guide_review <id>`
- `claude /adw_guide_pr <id>`

**All of these use Claude Pro, NOT the API.**

**Zero API credits consumed by orchestrator!** 🎉
