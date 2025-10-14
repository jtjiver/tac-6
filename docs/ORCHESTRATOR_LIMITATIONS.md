# ADW Orchestrator Limitations

## Critical Issue: Cannot Orchestrate Interactive Guides

### The Problem

The orchestrator (`adws/adw_orchestrator_enhanced.py`) attempts to automate the ADW workflow by spawning `claude` CLI commands as subprocesses:

```python
# This DOES NOT WORK for interactive guides
cmd_string = f'claude "{command} {self.adw_id}"'
process = subprocess.Popen(cmd_string, shell=True, ...)
```

This approach has a fundamental flaw: **`claude` CLI spawns interactive sessions that block and cannot run headlessly.**

### Why Interactive Guides Can't Be Orchestrated

1. **Interactive Nature**: The `/adw_guide_*` commands are designed to run within an active Claude Code session where the user can see progress and intervene if needed.

2. **Session Requirements**: Claude Code sessions require:
   - TTY (terminal) for interactive input/output
   - User approval for certain tool calls
   - Context awareness of previous conversation state

3. **Blocking Behavior**: When you run `claude "/adw_guide_test 777c8c50"` as a subprocess:
   - It starts a new Claude Code session
   - The process blocks waiting for completion
   - You must manually exit (Ctrl+C) to continue
   - The orchestrator can't detect actual completion

### What Happens When You Try

```bash
$ ./adws/orchestrate.sh 777c8c50 post_plan

[1/4] Starting phase: build
🚀 Starting build phase: claude /adw_guide_build 777c8c50
⏳ Waiting for build phase (PID: 16828)

# Process blocks here waiting for interactive session
# You must Ctrl+C to exit
# Orchestrator thinks it completed but didn't actually run
```

## Two Distinct Workflows

### 1. Interactive Workflow (Manual, $0 Cost)

**Use Case**: Development and testing, learning the system, avoiding API costs

**How It Works**: Run commands manually within a single Claude Code session
```bash
# Start Claude Code
claude

# Inside the session, run guides sequentially:
/adw_guide_plan
# ... wait for completion, review results ...

/adw_guide_build <adw_id>
# ... implementation happens ...

/adw_guide_test <adw_id>
# ... tests run ...

/adw_guide_review <adw_id>
# ... code review ...

/adw_guide_pr <adw_id>
# ... PR finalization ...
```

**Pros**:
- Free (uses Claude Pro subscription, no API costs)
- Full visibility into what's happening
- Can intervene if issues arise
- Learn how the system works

**Cons**:
- Manual - must run each phase
- Can't run unattended
- Requires human present

### 2. Orchestrated Workflow (Automated, $$ Cost)

**Use Case**: Production automation, CI/CD integration, unattended operation

**How It Works**: Use Python automation scripts that call Anthropic API directly (NOT the CLI)

```python
# This is what should be implemented:
import anthropic

client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])

# Run build phase via API
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    messages=[{"role": "user", "content": f"/adw_guide_build {adw_id}"}],
    # ... proper API configuration
)
```

**Pros**:
- Fully automated
- Can run unattended
- Integrates with CI/CD
- Reliable completion detection

**Cons**:
- Costs API credits ($$)
- Less visibility into process
- Harder to debug issues
- Requires proper error handling

## Solution Options

### Option 1: Disable Orchestrator for Interactive Mode (RECOMMENDED)

Update `adw_orchestrator_enhanced.py` to detect when interactive guides are configured and refuse to run:

```python
def start_phase(self, phase: str) -> subprocess.Popen:
    """Start a Claude Code session for the given phase"""
    phase_config = self.config.get_phase_config(phase)
    command = phase_config['command']

    # Detect interactive guide commands
    if command.startswith('/adw_guide'):
        raise RuntimeError(
            f"Cannot orchestrate interactive guide: {command}\n"
            f"Interactive guides must be run manually within a Claude Code session.\n"
            f"Run 'claude' and then execute: {command} {self.adw_id}"
        )

    # Continue with automation for API-based commands...
```

### Option 2: Track PIDs and Provide Kill Utility

If you must use the orchestrator with interactive guides (not recommended), track spawned process IDs and provide cleanup:

```python
def start_phase(self, phase: str) -> subprocess.Popen:
    # ... existing code ...

    # Track PIDs for cleanup
    pid_file = f"agents/{self.adw_id}/pids/claude_sessions.txt"
    os.makedirs(os.path.dirname(pid_file), exist_ok=True)
    with open(pid_file, 'a') as f:
        f.write(f"{process.pid}\n")

    return process
```

Then provide cleanup script:
```bash
./adws/kill_claude_sessions.sh <adw_id>
```

### Option 3: Implement True API-Based Automation

Replace `claude` CLI calls with direct Anthropic API calls (requires implementing prompt templates, context management, etc.):

```python
def run_phase_via_api(self, phase: str):
    """Run phase using Anthropic API directly"""
    # Load prompt template for phase
    # Build conversation context
    # Call API with streaming
    # Parse results and update state
    # Handle errors and retries
```

This is the proper long-term solution but requires significant development.

## Current Recommendation

**Use the interactive workflow manually:**

```bash
# Start Claude Code
claude

# Run phases one at a time:
/adw_guide_plan          # Creates plan, opens PR
/adw_guide_build <id>    # Implements solution
/adw_guide_test <id>     # Runs E2E tests
/adw_guide_review <id>   # Code review
/adw_guide_pr <id>       # Finalizes PR
```

**Do NOT use the orchestrator** until it's updated to either:
1. Block interactive guide orchestration with clear error message, OR
2. Implement true API-based automation

## Cleanup

If you accidentally started orchestrator sessions:

```bash
# Kill all Claude sessions
./adws/kill_claude_sessions.sh

# Or for specific ADW ID:
./adws/kill_claude_sessions.sh 777c8c50
```

## Future Work

To make the orchestrator truly useful, we need:

1. **Separate command sets**:
   - `/adw_guide_*` - Interactive guides (manual, $0)
   - `/adw_api_*` - API-based automation (automated, $$)

2. **Proper API integration**:
   - Implement prompt templates
   - Handle conversation context
   - Stream responses
   - Parse structured output
   - Update GitHub automatically

3. **Hybrid mode**:
   - Run planning phase interactively (review and approve)
   - Run build/test/review phases via API (automated)
   - Run PR phase interactively (final human check)

Until then, **stick with the manual interactive workflow** using the `/adw_guide_*` commands.
