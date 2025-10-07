# Chore: Update the interactive adw process

## Metadata
issue_number: `4`
adw_id: `4a7b3c9d`
issue_json: `{"number":4,"title":"Update the interactive adw process","body":"Can we update the newly created interactive ads process.  This will involve updating the new set up adw_guide_* files ONLY\n\nEach file will need updating to implement the same behaviour\n\n1. If there is only one next course of action or only the option to run one /slash command, do no ask or prompt the user to run any slash (/) commands, you can safely run these \n2. Can we update the adw_guide_* files to write status updates to the issue being worked on just like our fully automated flow does.  Check the corresponding file to understand what the issue updates look like\n3. Can we make sure the all loggin is generated in the `agents` directory just as we do for the automated process.  Check the corresponding file to understand the logging\n4. Can we ensure that the Claude Code configuration is updated so we do not prompt the user to run the next slash command, rather they are in the allow list of commands, so Claude Code just runs them\n\n# Files\nFile To Update -- File To check against to extract the additional logic (Do not change this file)\nadw_guide_plan.md -- plan.md\nadw_guide_build.md -- build.md\nadw_guide_test.md - test.md\nadw_guide_review.md -- review.md\nadw_guide_pr.md -- pul_request.md\nadw_guide_status.md -- dont thin we have an automated version\n\n\n# Stages in the worklow\n\nMake sure that we have the following commands captured and available for Claude Code to run without prompting in the workflow. These are examples commands from a previous run, the specific details can be ignored. It is the pattern we need to follow.\n\nPlanning Phase:\n  1. /adw_guide_plan\n  2. gh issue view 3 --json number,title,body\n  3. git checkout -b bug-issue-3-adw-3f8a9b2c-export-feature-not-working\n  4. Write: agents/3f8a9b2c/adw_state.json\n  5. /bug 3 3f8a9b2c\n  6. Read: README.md\n  7. Read: specs/issue-1-adw-aeeb3a3c-one-click-table-exports.md\n  8. Read: app/client/src/api/client.ts\n  9. Read: app/server/core/sql_processor.py\n  10. cd app/server && uv run pytest -v\n  11. cd app/client && bun tsc --noEmit\n  12. Write: specs/issue-3-adw-3f8a9b2c-sdlc_planner-fix-export-feature.md\n\n  Build Phase:\n  13. /adw_guide_build 3f8a9b2c\n  14. /implement specs/issue-3-adw-3f8a9b2c-sdlc_planner-fix-export-feature.md\n  15. Read: specs/issue-3-adw-3f8a9b2c-sdlc_planner-fix-export-feature.md\n  16. Edit: app/server/server.py (add .fetchall())\n  17. Edit: app/server/server.py (replace unsafe PRAGMA)\n  18. cd app/server && uv run pytest -v\n  19. cd app/client && bun tsc --noEmit\n  20. git commit -m \"sdlc_implementor: fix: resolve table export bugs\"\n  21. Edit: agents/3f8a9b2c/adw_state.json (update to build_complete)\n\n  Test Phase:\n  22. /adw_guide_test 3f8a9b2c\n  23. ./scripts/reset_db.sh\n  24. nohup sh ./scripts/start.sh > /dev/null 2>&1 &\n  25. mcp__playwright__browser_navigate: http://localhost:5173\n  26. mcp__playwright__browser_click: download button for users table\n  27. mcp__playwright__browser_click: download button for query results\n  28. ./scripts/stop_apps.sh\n  29. Edit: agents/3f8a9b2c/adw_state.json (update to testing_complete)\n\n  Review Phase:\n  30. /adw_guide_review 3f8a9b2c\n  31. /review specs/issue-3-adw-3f8a9b2c-sdlc_planner-fix-export-feature.md\n  32. git commit -m \"review: complete implementation review...\"\n  33. Edit: agents/3f8a9b2c/adw_state.json (update to review_complete)\n\n  PR Phase:\n  34. /adw_guide_pr 3f8a9b2c\n  35. git push -u origin bug-issue-3-adw-3f8a9b2c-export-feature-not-working\n  36. /pull_request\n  37. gh pr create --title \"bug: #3...\" --base main\n  38. gh issue comment 3 --body \"✅ Implementation complete!...\""}`

## Chore Description
Update the interactive ADW guide files (`adw_guide_*`) to align with the automated workflow by:

1. **Auto-running slash commands**: When there's only one next step or a single slash command to run, execute it directly without prompting the user
2. **GitHub issue status updates**: Add status update comments to GitHub issues at key phases, matching the automated workflow behavior seen in `adws/adw_*.py` files
3. **Structured logging**: Create session logs in the `agents/{adw_id}/` directory to track workflow execution
4. **Claude Code permissions**: Update `.claude/settings.local.json` to add all interactive workflow slash commands to the allow list so they run without user confirmation

This will make the interactive workflow smoother by reducing manual steps while maintaining the zero-cost benefit of running through Claude Code CLI.

## Relevant Files

### Interactive Guide Files (to be updated)
- `.claude/commands/adw_guide_plan.md` - Planning phase guide
  - Currently asks user to run commands; needs to auto-run single-path commands
  - Should add GitHub issue status updates like `adws/adw_plan.py` does (lines 114-278)
  - Should create logging in `agents/{adw_id}/` directory

- `.claude/commands/adw_guide_build.md` - Build/implementation phase guide
  - Needs to auto-run `/implement` command directly
  - Should add GitHub issue status updates like `adws/adw_build.py` does (lines 86-238)
  - Should create session logs

- `.claude/commands/adw_guide_test.md` - Testing phase guide
  - Should auto-run test commands when appropriate
  - Should add GitHub issue status updates like `adws/adw_test.py` does
  - Should log test results to `agents/{adw_id}/` directory

- `.claude/commands/adw_guide_review.md` - Review phase guide
  - Should auto-run `/review` command directly
  - Should add GitHub issue status updates like `adws/adw_review.py` does (lines 90-150)
  - Should create review logs

- `.claude/commands/adw_guide_pr.md` - Pull request phase guide
  - Should auto-run `/pull_request` command directly
  - Should add GitHub issue status updates and completion comments
  - Should log PR creation details

- `.claude/commands/adw_guide_status.md` - Status check guide
  - Already read-only, minimal changes needed
  - Should reference the new logging locations

### Reference Files (for extracting patterns - DO NOT MODIFY)
- `adws/adw_plan.py` - Automated planning implementation
  - Lines 114-278: GitHub issue comment patterns to replicate
  - Uses `make_issue_comment()` with formatted messages
  - Logs to `agents/{adw_id}/` with `setup_logger()`

- `adws/adw_build.py` - Automated build implementation
  - Lines 86-238: Implementation phase issue updates
  - Shows commit message generation and state management

- `adws/adw_test.py` - Automated test implementation
  - Shows test result logging patterns
  - Demonstrates retry logic with issue comments

- `adws/adw_review.py` - Automated review implementation
  - Lines 90-150: Review execution and result reporting
  - Shows screenshot handling and issue tracking

- `.claude/commands/pull_request.md` - PR creation template
  - Referenced by `adw_guide_pr.md` for PR creation logic

### Configuration Files (to be updated)
- `.claude/settings.local.json` - Claude Code permissions
  - Currently has: `/review`, `/pull_request` in allow list
  - Needs to add: `/chore`, `/bug`, `/feature`, `/implement`, `/test`, `/test_e2e`, `/commit`, `/adw_guide_build`, `/adw_guide_test`, `/adw_guide_review`, `/adw_guide_pr`, `/adw_guide_status`
  - Also needs: `Bash(./scripts/reset_db.sh:*)`, `Bash(./scripts/start.sh:*)`, `Bash(gh issue comment:*)`

### Supporting Files
- `adws/adw_modules/github.py` - Contains `make_issue_comment()` function pattern to replicate
- `adws/adw_modules/workflow_ops.py` - Contains `format_issue_message()` pattern to replicate
- `adws/adw_modules/utils.py` - Contains `setup_logger()` pattern to adapt for interactive mode

## Step by Step Tasks

### Step 1: Analyze Automated Workflow Patterns
- Read `adws/adw_plan.py` to understand:
  - GitHub issue comment format and timing (when comments are posted)
  - Logging setup with `setup_logger(adw_id, "adw_plan")`
  - State management patterns
  - Message formatting with `format_issue_message(adw_id, agent_name, message)`
- Read `adws/adw_build.py`, `adws/adw_test.py`, `adws/adw_review.py` for similar patterns
- Identify the key phases where issue comments are added:
  - Start of phase
  - Major milestones
  - Completion of phase
  - Errors/failures
- Document the logging structure in `agents/{adw_id}/` directory

### Step 2: Update `.claude/commands/adw_guide_plan.md`
- Modify Step 1 to automatically run `gh issue view` instead of asking user
- Modify Step 5 to automatically run `git checkout -b` instead of asking user
- Modify Step 6 to automatically create state file and agents directory
- Modify Step 7 to automatically run the classification slash command (`/chore`, `/bug`, or `/feature`)
- Add GitHub issue status updates at:
  - Start: "✅ Starting planning phase"
  - After classification: "✅ Issue classified as: {type}"
  - After branch creation: "✅ Working on branch: {branch_name}"
  - After plan creation: "✅ Plan file created: {path}"
  - Completion: "✅ Planning phase completed"
- Add logging instructions:
  - Create log file at `agents/{adw_id}/logs/adw_guide_plan_{timestamp}.log`
  - Log major actions and their results
- Keep Step 8 to guide user to next phase
- Update "What NOT to Do" section to reflect that commands are now auto-run

### Step 3: Update `.claude/commands/adw_guide_build.md`
- Modify Step 4 to automatically run `/implement {plan_file}` instead of asking user
- Remove Step 6 (commit guidance) - commits should be automatic after implementation
- Add automatic commit creation after successful implementation
- Modify Step 7 to automatically update state file to `build_complete`
- Add GitHub issue status updates at:
  - Start: "✅ Starting implementation phase"
  - After implementation: "✅ Solution implemented"
  - After commit: "✅ Implementation committed"
  - Completion: "✅ Implementation phase completed"
- Add logging:
  - Create log file at `agents/{adw_id}/logs/adw_guide_build_{timestamp}.log`
  - Log implementation steps and changes made
- Update Step 8 to automatically trigger next phase based on plan requirements

### Step 4: Update `.claude/commands/adw_guide_test.md`
- Modify Steps 3-6 to automatically run test commands:
  - Backend: `cd app/server && uv run pytest`
  - Frontend: `cd app/client && bun tsc --noEmit`
  - Build: `cd app/client && bun run build`
- Keep Step 7 for E2E tests as they may require user interaction
- Modify Step 8 to automatically update state to `testing_complete` after all tests pass
- Add automatic test failure resolution if tests fail (up to 3 attempts)
- Add GitHub issue status updates at:
  - Start: "✅ Starting testing phase"
  - Test results: "✅ Backend tests: {status}" / "✅ Frontend tests: {status}"
  - After fixes: "✅ Test failures resolved"
  - Completion: "✅ Testing phase completed"
- Add logging:
  - Create log file at `agents/{adw_id}/logs/adw_guide_test_{timestamp}.log`
  - Log test execution, results, and any fixes applied

### Step 5: Update `.claude/commands/adw_guide_review.md`
- Modify Step 4 to automatically run `/review {spec_file}` instead of asking user
- Modify Step 7 to automatically commit review artifacts
- Modify Step 8 to automatically update state to `review_complete`
- Add automatic issue resolution for blockers found in review
- Add GitHub issue status updates at:
  - Start: "✅ Starting review phase"
  - After review: "✅ Implementation reviewed"
  - Issues found: "⚠️ Review identified {count} issues"
  - After resolution: "✅ Review issues resolved"
  - Completion: "✅ Review phase completed"
- Add logging:
  - Create log file at `agents/{adw_id}/logs/adw_guide_review_{timestamp}.log`
  - Log review results, issues, and resolutions

### Step 6: Update `.claude/commands/adw_guide_pr.md`
- Modify Step 4 to automatically push branch with `git push -u origin {branch_name}`
- Modify Step 5 to automatically run `/pull_request` instead of asking user
- Modify Step 7 to automatically:
  - Update state to `complete` with `pr_created: true`
  - Add completion comment to GitHub issue with PR link
- Add GitHub issue status updates at:
  - Start: "✅ Starting PR phase"
  - After push: "✅ Branch pushed to remote"
  - After PR: "✅ Pull request created: {pr_url}"
  - Completion: "✅ Workflow complete - Ready for review"
- Add logging:
  - Create log file at `agents/{adw_id}/logs/adw_guide_pr_{timestamp}.log`
  - Log PR creation details and final state

### Step 7: Update `.claude/commands/adw_guide_status.md`
- Add reference to log files in the status display:
  - Show log directory: `agents/{adw_id}/logs/`
  - List recent log files for each phase
- Add GitHub issue link in status display
- Update examples to show new logging structure

### Step 8: Update `.claude/settings.local.json`
- Add the following to the `permissions.allow` array:
  - `"SlashCommand(/chore:*)"` - For chore classification
  - `"SlashCommand(/bug:*)"` - For bug classification
  - `"SlashCommand(/feature:*)"` - For feature classification
  - `"SlashCommand(/implement:*)"` - For implementation phase
  - `"SlashCommand(/test:*)"` - For testing phase
  - `"SlashCommand(/test_e2e:*)"` - For E2E testing
  - `"SlashCommand(/commit)"` - For commit creation
  - `"SlashCommand(/adw_guide_build:*)"` - For build phase
  - `"SlashCommand(/adw_guide_test:*)"` - For test phase
  - `"SlashCommand(/adw_guide_review:*)"` - For review phase
  - `"SlashCommand(/adw_guide_pr:*)"` - For PR phase
  - `"SlashCommand(/adw_guide_status:*)"` - For status checks
  - `"Bash(./scripts/reset_db.sh:*)"` - For database reset
  - `"Bash(./scripts/start.sh:*)"` - For starting services
  - `"Bash(gh issue comment:*)"` - For GitHub issue updates
  - `"Bash(jq:*)"` - For JSON state file updates
  - `"Bash(nohup:*)"` - For background processes
- Ensure these are added in the correct JSON format
- Preserve existing allowed commands

### Step 9: Create Helper Functions for Issue Comments
- Add a section to each guide file explaining how to make issue comments:
  - Use `gh issue comment {issue_number} --body "{message}"`
  - Format messages as: `{adw_id}_{agent_name}: {emoji} {message}`
  - Agent names: `ops`, `sdlc_planner`, `sdlc_implementor`, `test_runner`, `reviewer`
  - Common emojis: ✅ success, ❌ error, ⚠️ warning, 🔍 info, 📋 status
- Add examples of formatted issue comments for each phase

### Step 10: Create Logging Helpers
- Add instructions to each guide for creating log directories:
  - `mkdir -p agents/{adw_id}/logs`
  - Create timestamped log files: `agents/{adw_id}/logs/{phase}_{timestamp}.log`
- Add simple logging pattern:
  - Echo important actions and results to log file
  - Include timestamps for each entry
  - Log errors with full output

### Step 11: Test the Updated Workflow
- Run validation commands to ensure all guides are properly formatted
- Verify that markdown syntax is correct
- Check that all referenced files exist
- Ensure state file paths are consistent

## Validation Commands
Execute every command to validate the chore is complete with zero regressions.

- `cd app/server && uv run pytest` - Run server tests to ensure no regressions
- `cd app/client && bun tsc --noEmit` - Validate TypeScript code compiles
- `find .claude/commands -name "adw_guide_*.md" -exec echo "Checking: {}" \; -exec head -1 {} \;` - Verify all guide files exist and are readable
- `cat .claude/settings.local.json | grep -E "(SlashCommand|Bash)" | wc -l` - Verify permissions were added
- `git diff .claude/settings.local.json` - Review configuration changes
- `ls -la .claude/commands/adw_guide_*.md` - Confirm all guide files are present

## Notes

### Issue Comment Format Pattern
Based on `adws/adw_plan.py` and related files, the issue comment format is:
```
{adw_id}_{agent_name}: {emoji} {message}
```

Example from automated flow:
```
3f8a9b2c_ops: ✅ Starting planning phase
3f8a9b2c_sdlc_planner: ✅ Building implementation plan
3f8a9b2c_sdlc_implementor: ✅ Solution implemented
```

### Logging Pattern
The automated scripts use Python's logging module, but for the interactive guides we'll use simpler bash-based logging:
```bash
LOG_FILE="agents/{adw_id}/logs/adw_guide_{phase}_$(date +%s).log"
mkdir -p agents/{adw_id}/logs
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Starting {phase} phase" >> $LOG_FILE
```

### State Management
The state file (`agents/{adw_id}/adw_state.json`) should be updated using `jq`:
```bash
jq '.current_phase = "build_complete"' agents/{adw_id}/adw_state.json > agents/{adw_id}/adw_state.json.tmp && mv agents/{adw_id}/adw_state.json.tmp agents/{adw_id}/adw_state.json
```

### Auto-run vs User Confirmation
Auto-run commands when:
- There's only one logical next step
- The command is safe and reversible
- It's a standard part of the workflow

Ask user confirmation for:
- E2E tests (may require visual inspection)
- First-time setup steps
- Commands that modify remote state (though these should be allowed in config)

### Cost Transparency
Always remind users that the interactive workflow is covered by Claude Pro subscription at zero additional cost. The automation improvements should not change this fundamental benefit.
