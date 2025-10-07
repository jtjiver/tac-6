## Creating GitHub Issues for ADW Interactive Workflow

### Overview

This guide explains how to create GitHub issues that work with the ADW interactive workflow (zero API cost approach).

### Issue Naming Convention

For the interactive workflow, you don't need to specify the workflow name in the issue title or body - the classification happens interactively when you run `/adw_guide_plan`.

### Issue Template

```markdown
**Title:** [Brief description of what you want to accomplish]

**Description:**
[Detailed description of the feature, bug, or chore]

**Acceptance Criteria:**
- [ ] [Specific requirement 1]
- [ ] [Specific requirement 2]
- [ ] [Specific requirement 3]

**Additional Context:**
[Any additional information, screenshots, or links]
```

### Examples

#### Example 1: Feature Request

```markdown
**Title:** Add one-click table exports to CSV

**Description:**
Users should be able to export tables and query results to CSV format with a single click. This will make it easier to work with data outside the application.

**Acceptance Criteria:**
- [ ] Add download button next to each table in "Available Tables"
- [ ] Add download button to query results section
- [ ] Clicking download should trigger CSV export
- [ ] CSV should include all columns and rows
- [ ] File should be named appropriately (e.g., `table_name.csv`)

**Additional Context:**
This will improve data portability and user experience.
```

**Issue Number:** #1

**How to work on it:**
```bash
# In Claude Code interactive terminal
/adw_guide_plan

# Claude asks: What issue number?
You: 1

# Claude classifies as /feature and guides you through
```

#### Example 2: Bug Report

```markdown
**Title:** SQL injection vulnerability in query processing

**Description:**
The application is vulnerable to SQL injection attacks when processing user queries. Malicious SQL can be injected through the natural language input field.

**Steps to Reproduce:**
1. Enter: `'; DROP TABLE users; --` in query field
2. Click Query button
3. Table is dropped

**Expected Behavior:**
SQL injection attempts should be blocked and sanitized.

**Acceptance Criteria:**
- [ ] All user input is sanitized
- [ ] SQL queries use parameterized statements
- [ ] Dangerous operations are blocked
- [ ] Security tests are added

**Additional Context:**
Critical security issue - needs immediate attention.
```

**Issue Number:** #42

**How to work on it:**
```bash
/adw_guide_plan
# Enter: 42
# Claude classifies as /bug and guides you
```

#### Example 3: Chore/Maintenance

```markdown
**Title:** Replace all print statements with proper logging

**Description:**
The codebase currently uses print statements for debugging and logging. These should be replaced with proper logging using Python's logging module for better log management and debugging.

**Acceptance Criteria:**
- [ ] All print() statements removed
- [ ] logging module configured
- [ ] Appropriate log levels used (DEBUG, INFO, WARNING, ERROR)
- [ ] Log output is readable and useful

**Additional Context:**
This will improve debugging and production monitoring capabilities.
```

**Issue Number:** #7

**How to work on it:**
```bash
/adw_guide_plan
# Enter: 7
# Claude classifies as /chore and guides you
```

### Comparison: Automated vs Interactive

#### Old Approach (Automated - Costs Money)

**Issue Title:** "Using adw_plan_build_review - Add table exports"

**Trigger:**
- Create issue with "Using adw_plan_build_review" in title
- OR comment "adw" on the issue
- OR use trigger scripts

**What happens:**
- Automated scripts detect the issue
- Runs `uv run adws/adw_plan_build_review.py <issue-number>`
- **Costs $2-9 in API credits** 💸

#### New Approach (Interactive - Zero Cost)

**Issue Title:** "Add table exports" (no special prefix needed)

**How to work on it:**
```bash
# In Claude Code interactive terminal
/adw_guide_plan
```

**What happens:**
- You run the guide commands manually
- Claude guides you through each phase
- Uses existing `/feature`, `/implement`, etc commands
- **Costs $0 (covered by Claude Pro)** ✨

### Key Differences

| Aspect | Automated | Interactive |
|--------|-----------|-------------|
| **Issue Title** | "Using adw_plan_build_review - Feature name" | "Feature name" (normal title) |
| **Trigger** | Special keyword in title/comment | Manual: `/adw_guide_plan` |
| **Workflow** | Fully autonomous | Manual phase transitions |
| **Cost** | $2-9 per workflow | $0 |
| **Control** | No control | Full control |
| **Speed** | Continuous | Manual kick-off |

### Recommended Issue Format

For the interactive workflow, create **simple, clear issues** without any special keywords:

```markdown
**Title:** [What you want to accomplish]

**Description:**
[Detailed explanation]

**Acceptance Criteria:**
- [ ] [Requirement 1]
- [ ] [Requirement 2]

**Notes:**
[Optional additional context]
```

That's it! No "Using adw_plan_build_review" or special prefixes needed.

### Complete Workflow Example

#### Step 1: Create GitHub Issue

```bash
gh issue create \
  --title "Add dark mode toggle" \
  --body "Users should be able to switch between light and dark themes.

**Acceptance Criteria:**
- [ ] Add theme toggle button in settings
- [ ] Implement theme state management
- [ ] Apply theme to all components
- [ ] Persist theme preference"
```

**Output:** Created issue #123

#### Step 2: Start Interactive Workflow

```bash
# In Claude Code terminal
/adw_guide_plan
```

**Claude asks:** What issue number?
**You enter:** 123

**Claude:**
- Fetches issue #123
- Classifies as `/feature`
- Generates ADW ID: `xyz98765`
- Creates branch: `feature-issue-123-adw-xyz98765-dark-mode`
- Guides you to run: `/feature 123 xyz98765 '...'`

#### Step 3: Continue Through Phases

```bash
# After planning completes
/adw_guide_build xyz98765

# After implementation
/adw_guide_test xyz98765

# After testing
/adw_guide_review xyz98765

# Create PR
/adw_guide_pr xyz98765
```

#### Step 4: Check Status Anytime

```bash
/adw_guide_status xyz98765
```

### Migration from Automated to Interactive

If you have existing issues with the old format:

**Old Issue Title:**
```
Using adw_plan_build_review - Add table exports
```

**For Interactive Workflow:**
1. **Option A:** Work on it as-is (the guide commands ignore title prefixes)
   ```bash
   /adw_guide_plan
   # Enter issue number when asked
   ```

2. **Option B:** Update the issue title to remove prefix
   ```bash
   gh issue edit <issue-number> --title "Add table exports"
   ```

### Best Practices

#### 1. Keep Issues Focused

✅ **Good:** "Add CSV export functionality"
❌ **Bad:** "Add CSV export, JSON export, PDF export, and email reports"

Split large features into multiple issues for the interactive workflow.

#### 2. Clear Acceptance Criteria

✅ **Good:**
```markdown
**Acceptance Criteria:**
- [ ] Download button appears next to each table
- [ ] Clicking button triggers CSV download
- [ ] CSV includes all data from table
- [ ] Tests validate export functionality
```

❌ **Bad:**
```markdown
**Acceptance Criteria:**
- [ ] It works
```

#### 3. Include Context

Add screenshots, links, or examples that help Claude understand what you want.

#### 4. Use Labels (Optional)

GitHub labels still work great:
- `feature` - New functionality
- `bug` - Something broken
- `chore` - Maintenance/refactoring
- `enhancement` - Improvement to existing feature

Labels help you organize but aren't required for the workflow.

### FAQ

**Q: Do I need "Using adw_guide_plan" in the title?**
A: No. The guide commands work with any issue format.

**Q: Can I use the automated workflow keywords?**
A: Yes, they don't hurt, but they're ignored in interactive mode. Just run `/adw_guide_plan` manually.

**Q: What if I forget the ADW ID?**
A: Run `/adw_guide_status` to see all your workflows and their IDs.

**Q: Can I pause and resume?**
A: Yes! The state is saved. Just run the appropriate guide command with your ADW ID.

**Q: Can I work on multiple issues simultaneously?**
A: Yes! Each gets its own ADW ID and branch. Use `/adw_guide_status` to track them all.

### Quick Reference

```bash
# Start new workflow
/adw_guide_plan

# Continue workflow
/adw_guide_build <adw-id>
/adw_guide_test <adw-id>
/adw_guide_review <adw-id>
/adw_guide_pr <adw-id>

# Check status
/adw_guide_status [adw-id]

# Create issue (using gh CLI)
gh issue create --title "..." --body "..."

# List issues
gh issue list

# View issue
gh issue view <issue-number>
```

### Summary

For the **interactive workflow (zero cost)**:
- ✅ Create normal GitHub issues (no special keywords)
- ✅ Run `/adw_guide_plan` in Claude Code
- ✅ Follow the guided workflow through each phase
- ✅ Save $2-9 per workflow
- ✅ Maintain full control

The interactive approach is **simpler** and **cheaper** - just create clear, well-written issues and let Claude guide you through the implementation!
