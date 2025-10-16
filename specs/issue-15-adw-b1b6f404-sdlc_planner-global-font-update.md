# Chore: Global font update

## Metadata
issue_number: `15`
adw_id: `b1b6f404`
issue_json: `{"assignees":[],"body":"Please update the app to use the new google font https://fonts.google.com/specimen/Open+Sans","createdAt":"2025-10-14T06:31:04Z","labels":[],"number":15,"state":"OPEN","title":"Global font update","updatedAt":"2025-10-14T06:31:04Z"}`

## Chore Description
Update the application to use the Open Sans font from Google Fonts as the global font family. This change should apply to all text elements throughout the application, replacing the current system font stack with the Open Sans web font. The font should be loaded from Google Fonts CDN and applied consistently across all UI components.

## Relevant Files
Use these files to resolve the chore:

- `app/client/index.html` - Main HTML file where Google Fonts link needs to be added in the head section
- `app/client/src/style.css` - Main stylesheet where the font-family needs to be updated in the :root selector and potentially other locations that override font-family

## Step by Step Tasks
IMPORTANT: Execute every step in order, top to bottom.

### 1. Add Google Fonts link to HTML
- Open `app/client/index.html`
- Add the Google Fonts preconnect links in the head section for optimal performance
- Add the Open Sans font link from Google Fonts CDN
- The link should include multiple font weights (400, 500, 600, 700) to support the existing font-weight variations used in the application

### 2. Update root font-family in CSS
- Open `app/client/src/style.css`
- Update the font-family property in the :root selector to use 'Open Sans' as the primary font
- Keep the existing fallback fonts (system fonts) as a backup in case Open Sans fails to load
- Ensure the font stack follows this order: 'Open Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif

### 3. Check for font-family overrides
- Search through `app/client/src/style.css` for any other instances where font-family is explicitly set
- Update the monospace font references (like in .sql-query code) to maintain their intended appearance
- Ensure consistency across all text elements while preserving intentional font variations (like code blocks)

### 4. Build and test the application
- Run the build command to ensure there are no build errors
- Start the development server to visually verify the font change
- Check that the font loads correctly and is applied across all UI elements
- Verify that font weights (400, 500, 600, 700) render correctly for different text elements

### 5. Run validation commands
- Execute the validation commands to ensure no regressions

## Validation Commands
Execute every command to validate the chore is complete with zero regressions.

- `cd app/client && bun run build` - Build the client to ensure no build errors
- `cd app/server && uv run pytest` - Run server tests to validate the chore is complete with zero regressions

## Notes
- Open Sans is a humanist sans-serif typeface designed by Steve Matteson, known for its excellent legibility and clean appearance
- The font should be loaded asynchronously to prevent render blocking
- Consider adding font-display: swap to ensure text remains visible during font load
- The application currently uses different font weights (400, 500, 600, 700), all of which should be included from Google Fonts
- Maintain the existing monospace font for code blocks (Courier New) as it serves a specific purpose for code display