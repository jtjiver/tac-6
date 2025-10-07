# ADW Guide: Planning Phase

Interactive guide to help you through the ADW planning phase without API costs.

## Instructions

**IMPORTANT:** This is a guide command that helps you run the workflow manually. It does NOT make subprocess calls or programmatic API calls. Everything you do here is covered by your Claude Pro subscription at zero additional cost.

Follow these steps to complete the planning phase:

### Step 1: Gather Information

1. Ask the user: "What is the GitHub issue number you want to work on?"
2. Fetch the issue from GitHub using `gh issue view <issue-number> --json number,title,body`
3. Parse the issue JSON

### Step 2: Classify the Issue

Analyze the issue and determine if this is:
- **Feature**: New functionality or enhancement
- **Bug**: Something broken that needs fixing
- **Chore**: Maintenance, refactoring, documentation, or cleanup

Display your classification to the user and ask for confirmation.

### Step 3: Generate ADW ID

Create a unique 8-character ID for this workflow (e.g., using first 8 chars of a UUID or timestamp-based).

Display: "ADW ID: `{adw_id}`"

### Step 4: Generate Branch Name

Based on the issue classification and details, generate a semantic branch name:
- Format: `{type}-issue-{number}-adw-{adw_id}-{slug}`
- Examples:
  - `feature-issue-1-adw-abc12345-table-exports`
  - `bug-issue-42-adw-xyz98765-fix-sql-injection`
  - `chore-issue-7-adw-def45678-update-dependencies`

### Step 5: Create Branch

Tell the user to run:
```bash
git checkout -b {branch-name}
```

Wait for confirmation that the branch is created.

### Step 6: Create State File

Create an interactive state file to track progress:

```bash
mkdir -p agents/{adw_id}
cat > agents/{adw_id}/adw_state.json << EOF
{
  "adw_id": "{adw_id}",
  "issue_number": "{issue_number}",
  "issue_class": "/{classification}",
  "branch_name": "{branch_name}",
  "current_phase": "planning",
  "mode": "interactive"
}
EOF
```

Tell the user: "✅ State file created: `agents/{adw_id}/adw_state.json`"

### Step 7: Guide User to Create Plan

Based on the classification, tell the user:

**For Features:**
"Now let's create the implementation plan. Run the following command:
```
/{classification} {issue_number} {adw_id} '{issue_json}'
```

Example: `/feature 1 abc12345 '{"number":1,"title":"...","body":"..."}'`"

**For Bugs:**
"Now let's create the bug fix plan. Run the following command:
```
/bug {issue_number} {adw_id} '{issue_json}'
```"

**For Chores:**
"Now let's create the chore plan. Run the following command:
```
/chore {issue_number} {adw_id} '{issue_json}'
```"

Wait for the user to confirm the plan was created successfully.

### Step 8: Update State and Report Next Steps

After the plan is created, tell the user:

"✅ Planning phase complete!

**What was created:**
- Branch: `{branch_name}`
- State file: `agents/{adw_id}/adw_state.json`
- Plan file: `specs/issue-{issue_number}-adw-{adw_id}-*.md`

**Next steps:**
1. Review the plan file in `specs/`
2. When ready to implement, run: `/adw_guide_build {adw_id}`

**Cost so far:** $0 (covered by Claude Pro) ✨"

## What NOT to Do

- **DO NOT** call subprocess.run()
- **DO NOT** call execute_template() or prompt_claude_code()
- **DO NOT** make programmatic API calls
- **DO** guide the user on what commands to run
- **DO** wait for user confirmation at each step
- **DO** explain what's happening and why

## Variables

If the user provides an ADW ID as an argument, try to resume from existing state:
- `$1` = ADW ID (optional - if provided, resume existing workflow)
