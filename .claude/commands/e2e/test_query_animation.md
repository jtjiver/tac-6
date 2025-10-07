# E2E Test: Query Button Animation

Test that celebratory animations (confetti/fireworks) trigger when the query button is clicked.

## User Story

As a user
I want to see celebratory animations when I click the query button
So that I get immediate visual feedback and the interface feels more engaging and fun to use

## Test Steps

1. Navigate to the `Application URL`
2. Take a screenshot of the initial state
3. **Verify** the page title is "Natural Language SQL Interface"
4. **Verify** core UI elements are present:
   - Query input textbox
   - Query button
   - Upload Data button
   - Available Tables section

5. Enter the query: "Show me all users from the users table"
6. Take a screenshot showing the query input ready for execution
7. Click the Query button
8. **Verify** the confetti animation canvas element appears in the DOM (canvas element with confetti styles)
9. Take a screenshot immediately after clicking to capture the animation (within 100-200ms)
10. **Verify** the query results appear despite the animation running
11. **Verify** the SQL translation is displayed
12. Take a screenshot of the final results with animation completed

## Success Criteria
- Query button click triggers confetti animation
- Canvas element for confetti is present in the DOM after button click
- Animation doesn't block or prevent query execution
- Query results display correctly alongside animation
- SQL translation appears as expected
- 3 screenshots are taken showing: initial state, animation in progress, and final results

## Animation Detection

The test should verify the presence of the confetti canvas element which is dynamically created by the canvas-confetti library. This canvas typically has:
- Tag name: `canvas`
- Inline styles for positioning
- Z-index that places it above other content

If the canvas element is detected after button click, the animation feature is working correctly.
