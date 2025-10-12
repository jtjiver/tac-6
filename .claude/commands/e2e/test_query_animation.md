# E2E Test: Query Button Enhanced Animation

Test that enhanced multi-stage celebratory animations trigger when the query button is clicked.

## User Story

As a user
I want to see dramatic, colorful, multi-stage animations when I click the query button
So that I get immediate visual feedback and the interface feels more engaging, vibrant, and fun to use

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
9. Take a screenshot immediately after clicking to capture Stage 1 (center explosion) at ~100ms
10. Take a screenshot at ~200ms to capture Stage 2 (side fireworks)
11. Take a screenshot at ~400ms to capture Stage 3 (top-down rain)
12. Take a screenshot at ~600ms to capture Stage 4 (corner sparkles)
13. **Verify** the query results appear despite the animation running
14. **Verify** the SQL translation is displayed
15. Take a screenshot of the final results with animation completed (~1.5s)

## Success Criteria
- Query button click triggers enhanced multi-stage confetti animation
- Canvas element for confetti is present in the DOM after button click
- Multiple animation stages are visible in sequential screenshots:
  - Stage 1: Center explosion from button (immediate)
  - Stage 2: Left and right side fireworks (~150ms)
  - Stage 3: Top-down confetti rain (~300ms)
  - Stage 4: Corner sparkles (~500ms)
- Extended color palette (16 vibrant colors) is evident in screenshots
- Animation is dramatically more colorful and page-wide compared to original
- Animation doesn't block or prevent query execution
- Query results display correctly alongside animation
- SQL translation appears as expected
- Animation sequence completes within ~1.5 seconds
- 6 screenshots are taken showing: initial state, animation stages 1-4, and final results

## Enhanced Animation Detection

The test should verify the presence of the confetti canvas element which is dynamically created by the canvas-confetti library. This canvas typically has:
- Tag name: `canvas`
- Inline styles for positioning
- Z-index that places it above other content

Additionally, verify:
- Multiple particle bursts appear across different viewport locations (center, sides, top, corners)
- Extended color palette with 16+ colors is visible
- Animation duration is approximately 1.5 seconds (from first burst to last sparkle)
- Total particle count is significantly higher (~550 vs original 75)

If the canvas element is detected with multiple sequential bursts after button click, the enhanced animation feature is working correctly.

## Animation Stages

1. **Center Explosion** (0ms): Large radial burst from button position with 100 particles
2. **Side Fireworks** (150ms): Two angled bursts from left and right edges with 75 particles each
3. **Top-Down Rain** (300ms): Four sequential bursts cascading from top with 50 particles each
4. **Corner Sparkles** (500ms): Four small bursts from corners with 30 particles each

Total particles: ~550 particles across all stages
Total duration: ~1.5 seconds
Color palette: 16 vibrant colors
