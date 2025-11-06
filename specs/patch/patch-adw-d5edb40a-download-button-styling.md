# Patch: Style Download Button Consistently with UI

## Metadata
adw_id: `d5edb40a`
review_change_request: `For query results, make sure the download icon is style as a button like the rest of our ui and is just to the left of the "hide" button`

## Issue Summary
**Original Spec:** specs/issue-22-adw-d5edb40a-sdlc_planner-table-exports.md
**Issue:** The download button for query results is not styled consistently with other UI buttons and uses minimal styling with just a down arrow icon
**Solution:** Update the download button styling to match the secondary button style used throughout the UI and ensure proper placement to the left of the Hide button

## Files to Modify
Use these files to implement the patch:

- `app/client/src/style.css` - Update download button styles to match UI button styling
- `app/client/src/main.ts` - Update download button HTML structure and class names

## Implementation Steps
IMPORTANT: Execute every step in order, top to bottom.

### Step 1: Update download button CSS to match secondary button styling
- Modify the `.download-button` class in `app/client/src/style.css` (lines 337-351)
- Apply consistent button styling similar to `.secondary-button` class
- Maintain hover and active states for consistency
- Keep the loading state functionality

### Step 2: Update download button HTML structure and icon
- Modify the download button creation in `app/client/src/main.ts` (lines 312-319)
- Update the class name to use consistent button styling
- Replace the simple arrow icon with a more appropriate download icon or text
- Ensure proper placement before the toggle button

## Validation
Execute every command to validate the patch is complete with zero regressions.

- `cd app/client && bun tsc --noEmit` - Verify TypeScript compilation
- `cd app/client && bun run build` - Verify frontend builds successfully
- Start the application and test the download button functionality for query results
- Verify the download button appears styled like other UI buttons
- Confirm the download button is positioned just to the left of the Hide button

## Patch Scope
**Lines of code to change:** ~30
**Risk level:** low
**Testing required:** Visual verification of button styling and functional testing of CSV export