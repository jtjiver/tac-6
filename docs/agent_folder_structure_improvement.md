# Agent Folder Structure Improvement

## Issue Summary

When using the interactive intelligent guide (`/adw_guide_plan`), we're not creating the same detailed agent folder structure that the automated system creates. This makes it harder to debug and track what each sub-agent did.

## Current State (Interactive Guide)

```
agents/57ee23f4/
├── adw_state.json
└── logs/
    └── adw_guide_plan_1760298396.log
```

## Desired State (Automated System)

```
agents/57ee23f4/
├── adw_state.json
├── logs/
│   └── adw_guide_plan_1760298396.log
├── issue_classifier/              # Classification sub-agent
│   ├── prompts/
│   │   └── classify_issue.txt     # The prompt sent
│   ├── raw_output.jsonl           # Raw JSONL output from Claude Code
│   └── raw_output.json            # Converted JSON array
├── branch_generator/              # Branch name sub-agent
│   ├── prompts/
│   │   └── generate_branch_name.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
├── sdlc_planner/                  # Planning sub-agent
│   ├── prompts/
│   │   └── feature.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
├── sdlc_implementor/              # Implementation sub-agent (from build phase)
│   ├── prompts/
│   │   └── implement.txt
│   ├── raw_output.jsonl
│   └── raw_output.json
└── pr_creator/                    # PR creation sub-agent
    ├── prompts/
    │   └── pull_request.txt
    ├── raw_output.jsonl
    └── raw_output.json
```

## How the Automated System Does It

### 1. Agent Module (`adws/adw_modules/agent.py`)

The `save_prompt()` function (lines 148-172) creates the folder structure:

```python
def save_prompt(prompt: str, adw_id: str, agent_name: str = "ops") -> None:
    """Save a prompt to the appropriate logging directory."""
    # Extract slash command from prompt
    match = re.match(r"^(/\w+)", prompt)
    if not match:
        return

    slash_command = match.group(1)
    command_name = slash_command[1:]  # Remove leading slash

    # Create directory: agents/{adw_id}/{agent_name}/prompts/
    project_root = os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    )
    prompt_dir = os.path.join(project_root, "agents", adw_id, agent_name, "prompts")
    os.makedirs(prompt_dir, exist_ok=True)

    # Save prompt to file
    prompt_file = os.path.join(prompt_dir, f"{command_name}.txt")
    with open(prompt_file, "w") as f:
        f.write(prompt)

    print(f"Saved prompt to: {prompt_file}")
```

### 2. Prompt Execution (`prompt_claude_code()`, lines 175-259)

The `prompt_claude_code()` function creates output files:

```python
def prompt_claude_code(request: AgentPromptRequest) -> AgentPromptResponse:
    """Execute Claude Code with the given prompt configuration."""

    # Save prompt before execution
    save_prompt(request.prompt, request.adw_id, request.agent_name)

    # Create output directory: agents/{adw_id}/{agent_name}/
    output_dir = os.path.dirname(request.output_file)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    # Build command
    cmd = [CLAUDE_PATH, "-p", request.prompt]
    cmd.extend(["--model", request.model])
    cmd.extend(["--output-format", "stream-json"])
    cmd.append("--verbose")

    # Execute and save to: agents/{adw_id}/{agent_name}/raw_output.jsonl
    with open(request.output_file, "w") as f:
        result = subprocess.run(
            cmd, stdout=f, stderr=subprocess.PIPE, text=True, env=env
        )

    # Parse JSONL and create JSON array
    messages, result_message = parse_jsonl_output(request.output_file)
    json_file = convert_jsonl_to_json(request.output_file)  # Creates raw_output.json
```

### 3. Template Execution (`execute_template()`, lines 262-299)

The `execute_template()` function ties it all together:

```python
def execute_template(request: AgentTemplateRequest) -> AgentPromptResponse:
    """Execute a Claude Code template with slash command and arguments."""

    # Construct prompt from slash command and args
    prompt = f"{request.slash_command} {' '.join(request.args)}"

    # Create output directory: agents/{adw_id}/{agent_name}/
    project_root = os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    )
    output_dir = os.path.join(
        project_root, "agents", request.adw_id, request.agent_name
    )
    os.makedirs(output_dir, exist_ok=True)

    # Build output file path: agents/{adw_id}/{agent_name}/raw_output.jsonl
    output_file = os.path.join(output_dir, "raw_output.jsonl")

    # Create prompt request
    prompt_request = AgentPromptRequest(
        prompt=prompt,
        adw_id=request.adw_id,
        agent_name=request.agent_name,  # e.g., "issue_classifier", "sdlc_planner"
        model=request.model,
        dangerously_skip_permissions=True,
        output_file=output_file,
    )

    # Execute and return response
    return prompt_claude_code(prompt_request)
```

## How to Replicate in Interactive Guide

### Current Problem

When we use the `Task` tool in the interactive guide, we're spawning sub-agents but not capturing their outputs to structured files. The Task tool runs everything in the same Claude Code session and doesn't create the folder structure.

### Solution Options

#### Option 1: Manual Folder Creation (Simple but Limited)

After each Task tool invocation, manually create the folder structure:

```markdown
# After Task completes
1. Create folder: agents/{adw_id}/{agent_name}/prompts/
2. Save the prompt we sent to: {agent_name}/prompts/{command}.txt
3. Save the response to: {agent_name}/output.txt
```

**Pros:**
- Simple to implement
- Works with current Task tool

**Cons:**
- Manual folder creation for each step
- Doesn't capture raw JSONL output
- Not identical to automated system

#### Option 2: Use SlashCommand Tool Directly (Better)

Instead of using generic Task tool, use SlashCommand tool which goes through the same code path as automated system:

```markdown
# Instead of Task tool:
Task: Classify issue
Prompt: ...

# Use SlashCommand tool:
SlashCommand: /classify_issue '{issue_json}'
```

**Pros:**
- Uses exact same code path as automated system
- Automatically creates folder structure
- Captures all outputs (prompts, JSONL, JSON)
- Identical artifacts

**Cons:**
- Less flexible than Task tool
- Can't run in parallel (sequential only)
- Requires exact slash command format

#### Option 3: Hybrid Approach (Recommended)

Use SlashCommand for critical steps that need artifact preservation, Task tool for simple operations:

```markdown
# Use SlashCommand for important operations:
- Classification: SlashCommand /classify_issue
- Planning: SlashCommand /feature
- Implementation: SlashCommand /implement
- Commits: SlashCommand /commit

# Use Task tool for simple operations:
- Fetching issue data
- Generating ADW ID
- Updating state files
- Posting to GitHub
```

**Pros:**
- Best of both worlds
- Critical operations have full artifacts
- Simple operations stay fast and parallel
- Mostly identical to automated system

**Cons:**
- Mixed approach may be confusing
- Not 100% identical artifacts

## Recommended Implementation

Update `/adw_guide_plan.md` to use SlashCommand for steps that create important artifacts:

### Step 2: Classify Issue
```markdown
# OLD (Task tool):
Task: Classify GitHub issue type
Subagent: general-purpose
Prompt: Classify this issue...

# NEW (SlashCommand):
Execute: /classify_issue '{issue_json}'

This will automatically:
1. Create: agents/{adw_id}/issue_classifier/prompts/classify_issue.txt
2. Create: agents/{adw_id}/issue_classifier/raw_output.jsonl
3. Create: agents/{adw_id}/issue_classifier/raw_output.json
4. Return the classification
```

### Step 4: Generate Branch Name
```markdown
# Use SlashCommand:
Execute: /generate_branch_name {issue_number} {classification} '{issue_title}'

Artifacts: agents/{adw_id}/branch_generator/...
```

### Step 7: Create Plan
```markdown
# Use SlashCommand:
Execute: {classification} {issue_number} {adw_id} '{issue_json}'

Artifacts: agents/{adw_id}/sdlc_planner/...
```

### Step 9: Create Commit
```markdown
# Use SlashCommand:
Execute: /commit sdlc_planner {type} '{issue_json}'

Artifacts: agents/{adw_id}/sdlc_planner/... (commit output)
```

### Step 10: Create PR
```markdown
# Use SlashCommand:
Execute: /commit-commands:commit-push-pr

OR use gh pr create directly with manual folder creation
```

## Implementation Steps

1. **Update adw_guide_plan.md** - Replace Task tool calls with SlashCommand calls for:
   - Step 2: /classify_issue
   - Step 4: /generate_branch_name
   - Step 7: /{classification}
   - Step 9: /commit

2. **Keep Task tool for**:
   - Step 1: Fetching issue (simple gh command)
   - Step 3: Generating ADW ID (simple UUID)
   - Step 5: Git operations (branch creation)
   - Step 6: State file creation
   - Step 8: Plan file verification

3. **Test the changes** by running `/adw_guide_plan {issue_number}` and verifying the folder structure matches automated system

4. **Update other guides** (adw_guide_build.md, adw_guide_test.md) with same pattern

## Benefits of This Approach

1. **Identical artifacts** to automated system
2. **Better debugging** - can review exact prompts and outputs
3. **Auditability** - complete trace of what each agent did
4. **Consistency** - same structure whether interactive or automated
5. **Historical record** - agents folder becomes complete execution log

## File References

- Agent module: `adws/adw_modules/agent.py`
  - `save_prompt()`: line 148-172
  - `prompt_claude_code()`: line 175-259
  - `execute_template()`: line 262-299

- Workflow operations: `adws/adw_modules/workflow_ops.py`
  - `classify_issue()`: line 98-146 (calls execute_template with agent_name="issue_classifier")
  - `build_plan()`: line 149-175 (calls execute_template with agent_name="sdlc_planner")

## Next Steps

1. Implement SlashCommand approach in adw_guide_plan.md
2. Test with a real issue
3. Verify folder structure matches automated system
4. Update adw_guide_build.md and adw_guide_test.md
5. Document the new approach
