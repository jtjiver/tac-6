## ADW API Billing Explained

### Overview

This document explains how ADW (AI Developer Workflow) scripts incur Anthropic API costs, even though you have a Claude Pro subscription.

### The Key Distinction

| Usage Type | How You Access | Billing |
|------------|----------------|---------|
| **Interactive Claude Code** | You type `claude` in terminal, chat normally | Claude Pro subscription ($20/month) |
| **Programmatic Claude Code** | Scripts call `claude -p "prompt"` | Anthropic API credits (pay-per-token) 💸 |

### Why You're Getting Charged

When you run ADW scripts like:

```bash
uv run adws/adw_plan_build_review.py 1
```

Behind the scenes:
1. ✅ Launches Claude Code CLI programmatically
2. ❌ Claude Code makes API calls using your `ANTHROPIC_API_KEY`
3. 💸 **You get billed for API usage**

**Important**: Your Claude Pro subscription ($20/month) does NOT cover programmatic/automated API usage through scripts. It only covers interactive terminal usage.

### Complete Call Chain

Here's the exact flow showing where the API calls (and charges) happen:

```
adw_plan_build_review.py
├─ Line 76: subprocess.run(["uv", "run", "adw_build.py", "1", "aeeb3a3c"])
│
└─> adw_build.py
    ├─ Line 161: implement_response = implement_plan(plan_file, adw_id, logger)
    │
    └─> adw_modules/workflow_ops.py
        ├─ Line 178-202: def implement_plan(...)
        ├─ Line 185-190: Creates AgentTemplateRequest with "/implement" command
        ├─ Line 196: implement_response = execute_template(implement_template_request)
        │
        └─> adw_modules/agent.py
            ├─ Line 262-299: def execute_template(request)
            ├─ Line 273: prompt = f"{request.slash_command} {' '.join(request.args)}"
            │             # This creates: "/implement /path/to/plan.md"
            ├─ Line 289-295: Creates AgentPromptRequest
            ├─ Line 299: return prompt_claude_code(prompt_request)
            │
            └─> adw_modules/agent.py
                ├─ Line 175-259: def prompt_claude_code(request)
                ├─ Line 192-195: Builds command:
                │   cmd = [CLAUDE_PATH, "-p", request.prompt]
                │   cmd.extend(["--model", request.model])
                │   # Example: ["claude", "-p", "/implement spec.md", "--model", "opus"]
                │
                ├─ Line 202: env = get_claude_env()  # Gets filtered env vars
                │
                ├─ Line 207-209: 💰 THE ACTUAL CALL THAT COSTS MONEY:
                │   result = subprocess.run(
                │       cmd,                    # ["claude", "-p", "/implement spec.md"]
                │       stdout=f,
                │       stderr=subprocess.PIPE,
                │       text=True,
                │       env=env                 # Includes ANTHROPIC_API_KEY
                │   )
                │
                └─> Claude Code CLI (external process)
                    └─> Makes Anthropic API calls using ANTHROPIC_API_KEY
                        └─> 💸 YOU GET BILLED HERE
```

### The Exact Line That Costs Money

**File**: `/opt/asw/projects/personal/tac/tac-6/adws/adw_modules/agent.py`
**Line**: `207-209`

```python
result = subprocess.run(
    cmd,        # ["claude", "-p", "/implement /path/to/spec.md", "--model", "opus"]
    stdout=f,
    stderr=subprocess.PIPE,
    text=True,
    env=env     # Contains ANTHROPIC_API_KEY
)
```

This launches Claude Code CLI, which then makes API calls to Anthropic, charging your account.

### Billing Flow Diagram

```
Your ADW Script
    ↓
subprocess.run([claude, "-p", prompt])
    ↓
Claude Code CLI (programmatic mode)
    ↓
Makes Anthropic API calls
    ↓
Uses ANTHROPIC_API_KEY from environment
    ↓
💰 Charges YOUR Anthropic API account
    ↓
(NOT covered by Claude Pro subscription)
```

### Model Costs

ADW uses different models for different tasks (configured in `adw_modules/agent.py:27-52`):

| Task | Model | Relative Cost |
|------|-------|---------------|
| Planning (`/feature`, `/bug`) | **Opus** | High 💰💰💰 |
| Implementation (`/implement`) | **Opus** | High 💰💰💰 |
| Review (`/review`) | **Opus** | High 💰💰💰 |
| Testing (`/test`) | **Sonnet** | Medium 💰 |
| Classification (`/classify_issue`) | **Sonnet** | Low 💰 |
| Documentation (`/document`) | **Sonnet** | Medium 💰 |

#### Cost Breakdown Example

For a typical `adw_plan_build_review.py` run:
- Planning (Opus): ~$0.50-$2.00
- Implementation (Opus): ~$1.00-$5.00
- Review (Opus): ~$0.50-$2.00

**Total per workflow**: ~$2.00-$9.00 depending on complexity

### Helicone Integration for Cost Tracking

#### Why Helicone?

Helicone acts as a monitoring proxy that tracks:
- 💰 Cost per request
- ⏱️ Response times
- 📊 Token usage
- 🔍 Request details

#### Where Helicone Works

✅ **Your Application Server** (`app/server/`)
- File: `app/server/core/llm_processor.py`
- Manually configured to use Helicone proxy
- API calls route through: `https://anthropic.helicone.ai`
- Shows up in your Helicone dashboard

❌ **ADW Scripts** (`adws/`)
- Claude Code CLI does NOT support Helicone natively
- `HELICONE_API_KEY` is passed but **ignored** by Claude CLI
- No monitoring available for ADW costs
- Must track costs via Anthropic Console directly

#### Helicone Configuration (App Server)

```python
# app/server/core/llm_processor.py
helicone_key = os.environ.get("HELICONE_API_KEY")
if helicone_key:
    client = Anthropic(
        api_key=api_key,
        base_url="https://anthropic.helicone.ai",  # Helicone proxy
        default_headers={
            "Helicone-Auth": f"Bearer {helicone_key}",
            "Helicone-Property-App": "tac-6",
            "Helicone-Property-Environment": "production"
        }
    )
```

#### Why ADW Can't Use Helicone

Claude Code CLI:
- ❌ Doesn't check for `HELICONE_API_KEY` environment variable
- ❌ Doesn't have a `--base-url` flag to override API endpoint
- ❌ Makes direct API calls to Anthropic (bypasses any proxy)
- ❌ No built-in Helicone support

#### Monitoring ADW Costs

Since Helicone doesn't work with ADW, track costs via:

1. **Anthropic Console**: https://console.anthropic.com
   - View API usage dashboard
   - Set up billing alerts
   - Track spending by date

2. **ADW Logs**: Check model usage in logs
   ```bash
   # See which models were used
   grep "model" agents/aeeb3a3c/*/raw_output.jsonl
   ```

3. **Estimate Costs**: Use the model cost table above

### Cost Management Tips

#### 1. Use Sonnet When Possible

Edit `adw_modules/agent.py` to use Sonnet instead of Opus:

```python
SLASH_COMMAND_MODEL_MAP: Final[Dict[SlashCommand, str]] = {
    "/implement": "sonnet",  # Changed from "opus" - 90% cheaper!
    "/review": "sonnet",     # Changed from "opus"
    "/feature": "sonnet",    # Changed from "opus"
    # ...
}
```

**Trade-off**: Sonnet is faster and cheaper but may produce lower quality results for complex tasks.

#### 2. Monitor API Usage

Set up billing alerts in your Anthropic Console:
- Go to: https://console.anthropic.com/settings/billing
- Set daily/monthly spending limits
- Enable email alerts

#### 3. Use Smaller Workflows

Instead of full SDLC:
```bash
# Full workflow - most expensive
uv run adws/adw_sdlc.py 1

# Just plan and build - cheaper
uv run adws/adw_plan_build.py 1

# Just build with existing plan - cheapest
uv run adws/adw_build.py 1 <adw-id>
```

#### 4. Test Locally First

Before running ADW on complex features:
- Test manually with interactive Claude Code (free on Pro)
- Only use ADW for final implementation

#### 5. Batch Similar Changes

Group similar issues together and implement them in one ADW run to avoid multiple planning phases.

### Environment Variables

ADW requires these environment variables (from `.env` file):

```bash
# Required - Used for all API calls
ANTHROPIC_API_KEY=sk-ant-...

# Optional - For Helicone monitoring (doesn't work with ADW, only app server)
HELICONE_API_KEY=pk-helicone-...

# Optional - Path to Claude CLI
CLAUDE_CODE_PATH=claude
```

### Summary

| Component | Uses Helicone? | Costs Money? | Track Via |
|-----------|----------------|--------------|-----------|
| Interactive Claude Code | ❌ | ❌ (Pro subscription) | N/A |
| ADW Scripts | ❌ | ✅ | Anthropic Console |
| App Server (FastAPI) | ✅ | ✅ | Helicone Dashboard |

**Bottom Line**:
- Your Claude Pro subscription covers **interactive** usage only
- ADW scripts make **programmatic** API calls that **cost money**
- Helicone monitoring **only works** for your app server, not ADW
- Monitor ADW costs via **Anthropic Console** directly

### References

- Anthropic Console: https://console.anthropic.com
- Helicone Dashboard: https://helicone.ai/dashboard
- Claude Code Docs: https://docs.claude.com/en/docs/claude-code
- ADW Documentation: [adws/README.md](../adws/README.md)
