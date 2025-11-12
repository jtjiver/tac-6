# Patch: Align Download Button Right Next to Hide Button

## Metadata
adw_id: `d5edb40a`
review_change_request: `For query results, the download button is still central. It needs to be moved to the right so it is aligned right and is just to the left of the "hide" button`

## Issue Summary
**Original Spec:** specs/issue-22-adw-d5edb40a-sdlc_planner-table-exports.md
**Issue:** The download button for query results appears centrally positioned between the title and Hide button instead of being aligned right next to the Hide button
**Solution:** Wrap the download and Hide buttons in a container div to group them together on the right side of the results header

## Files to Modify
Use these files to implement the patch:

- `app/client/index.html` - Add wrapper div for button grouping
- `app/client/src/main.ts` - Update button insertion logic
- `app/client/src/style.css` - Add styles for button container

## Implementation Steps
IMPORTANT: Execute every step in order, top to bottom.

### Step 1: Update HTML structure to group buttons
- Modify `app/client/index.html` line 61
- Wrap the Hide button in a new container div with class `results-header-buttons`
- This will group the download and hide buttons together

### Step 2: Update JavaScript to insert download button in the correct container
- Modify `app/client/src/main.ts` lines 317-319
- Change the insertion logic to append the download button to the button container
- Ensure the download button appears before the Hide button within the container

### Step 3: Add CSS styles for proper alignment
- Add new styles in `app/client/src/style.css` after line 162
- Create styles for `.results-header-buttons` container with `display: flex` and `align-items: center`
- Remove the `margin-right` from `.download-button` (line 350) since spacing will be handled by the container

## Validation
Execute every command to validate the patch is complete with zero regressions.

- `cd app/client && bun tsc --noEmit` - Verify TypeScript compilation
- `cd app/client && bun run build` - Build the frontend
- Start the application and visually verify the download button appears immediately to the left of the Hide button
- Click the download button to ensure functionality is preserved
- Read `.claude/commands/e2e/test_export_functionality.md` and execute the test

## Patch Scope
**Lines of code to change:** ~10
**Risk level:** low
**Testing required:** Visual verification of button placement and export functionality test