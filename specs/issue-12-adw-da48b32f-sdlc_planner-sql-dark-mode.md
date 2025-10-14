# Feature: Dark Mode Toggle for SQL Interface

## Metadata
issue_number: `12`
adw_id: `da48b32f`
issue_json: `{"body":"Lets implement a quick switch dark mode for the SQL interface","number":12,"title":"Dark Mode"}`

## Feature Description
Implement a dark mode toggle switch for the SQL interface that allows users to seamlessly switch between light and dark themes. The feature will provide a persistent theme preference using localStorage, ensuring users' chosen theme is remembered across sessions. The dark mode will apply appropriate color schemes to all UI components including query sections, results tables, modals, buttons, and the profile dropdown.

## User Story
As a user of the Natural Language SQL Interface
I want to toggle between light and dark modes
So that I can work comfortably in different lighting conditions and reduce eye strain

## Problem Statement
The current SQL interface only supports a light theme, which can cause eye strain for users working in low-light environments or those who prefer dark themes. Many modern applications provide dark mode as a standard feature for better accessibility and user comfort.

## Solution Statement
Add a dark mode toggle button to the application header that switches between light and dark color schemes. The implementation will use CSS custom properties (CSS variables) for easy theme switching, store the user's preference in localStorage for persistence, and apply the theme on page load. The toggle will be placed near the profile button for easy access.

## Relevant Files
Use these files to implement the feature:

- `app/client/index.html` (lines 10-33) - Contains the app header structure where the dark mode toggle will be added
- `app/client/src/style.css` (lines 1-717) - Contains all CSS styling with CSS custom properties that need dark mode variants
- `app/client/src/main.ts` (lines 1-659) - Contains TypeScript initialization logic where dark mode toggle handler will be added

### New Files
- `.claude/commands/e2e/test_dark_mode.md` - E2E test file to validate dark mode functionality

## Implementation Plan

### Phase 1: Foundation
Create the dark mode CSS custom properties and define the color palette for dark theme. This includes establishing all color variables for backgrounds, surfaces, text, borders, and interactive elements in dark mode.

### Phase 2: Core Implementation
Add the dark mode toggle button to the UI, implement the theme switching logic in TypeScript, and ensure localStorage persistence. Wire up event handlers and apply the theme on page load based on saved preference or system preference.

### Phase 3: Integration
Test dark mode across all components (query section, results table, modals, buttons, profile dropdown) to ensure consistent styling. Verify smooth transitions between themes and proper persistence across page reloads.

## Step by Step Tasks
IMPORTANT: Execute every step in order, top to bottom.

### 1. Update CSS with Dark Mode Variables
- Open `app/client/src/style.css`
- Add dark mode CSS custom properties after the existing `:root` declaration
- Define dark theme color palette including:
  - Dark backgrounds (#1a1a1a, #2d2d2d)
  - Dark surfaces (#2d2d2d, #3d3d3d)
  - Light text for dark backgrounds (#e0e0e0, #b0b0b0)
  - Adjusted border colors for dark mode
  - Darker button hover states
- Create `[data-theme="dark"]` selector with all dark mode color overrides
- Ensure smooth transitions for theme changes with `transition: background-color 0.3s, color 0.3s, border-color 0.3s`

### 2. Add Dark Mode Toggle Button to HTML
- Open `app/client/index.html`
- Add a dark mode toggle button in the `.app-header` section between the `<h1>` and profile button
- Use appropriate HTML structure:
  ```html
  <button id="dark-mode-toggle" class="toggle-button" aria-label="Toggle dark mode">
    <span class="theme-icon">🌙</span>
  </button>
  ```
- Ensure button has proper accessibility attributes

### 3. Implement Dark Mode Toggle Logic in TypeScript
- Open `app/client/src/main.ts`
- Create new function `initializeDarkMode()` that:
  - Checks localStorage for saved theme preference (key: `theme`)
  - Falls back to system preference using `window.matchMedia('(prefers-color-scheme: dark)')`
  - Applies theme by setting `data-theme` attribute on document root
  - Sets up click handler for dark mode toggle button
  - Updates toggle button icon based on current theme (🌙 for light mode, ☀️ for dark mode)
  - Saves preference to localStorage on toggle
- Call `initializeDarkMode()` in the DOMContentLoaded event listener (line 9-15)
- Add smooth transition class to prevent flash on page load

### 4. Test Dark Mode Toggle Manually
- Start the application using `./scripts/start.sh`
- Verify toggle button appears in header
- Click toggle and verify theme switches
- Refresh page and verify theme persists
- Test all UI components in both themes:
  - Query input section
  - Results section
  - Tables section
  - Upload modal
  - Profile dropdown
  - All buttons and interactive elements

### 5. Create E2E Test for Dark Mode
- Create `.claude/commands/e2e/test_dark_mode.md`
- Include test steps to:
  - Navigate to application
  - Verify dark mode toggle button exists
  - Click toggle and verify dark theme is applied
  - Take screenshots of dark mode UI
  - Refresh page and verify theme persists
  - Toggle back to light mode
  - Verify localStorage contains correct theme value
- Follow the format and structure from `.claude/commands/e2e/test_basic_query.md`
- Include verification steps for major UI components in dark mode

### 6. Run All Validation Commands
- Execute all commands listed in the Validation Commands section
- Ensure zero regressions in existing functionality
- Verify E2E test passes successfully
- Fix any issues found during validation

## Testing Strategy

### Backend Unit Tests
No backend changes required for this feature, so no new backend tests needed.

### Frontend E2E Tests
Create `.claude/commands/e2e/test_dark_mode.md` to validate:
- Dark mode toggle button is visible and accessible
- Clicking toggle switches theme from light to dark
- Dark theme applies correct colors to all UI components:
  - Query input section (background, text, borders)
  - Results table (background, headers, rows)
  - Tables section (table cards, column tags)
  - Upload modal (background, buttons, drop zone)
  - Profile dropdown (background, menu items)
- Theme preference persists after page reload
- Toggle icon changes based on current theme (🌙 for light, ☀️ for dark)
- Clicking toggle again switches back to light mode

### Edge Cases
- User has no localStorage preference (should fall back to system preference)
- User has dark mode in system settings (should respect system preference on first load)
- localStorage is disabled or inaccessible (should gracefully fall back to light mode)
- Rapid clicking of toggle button (should handle debouncing properly)
- Theme switching while modals are open (should apply theme to open modals)
- Theme switching during query execution (should not interfere with loading states)

## Acceptance Criteria
- [ ] Dark mode toggle button is visible in the application header
- [ ] Clicking the toggle switches between light and dark themes
- [ ] Dark theme applies consistent colors across all UI components
- [ ] Theme preference is saved to localStorage with key `theme`
- [ ] Theme persists after page reload
- [ ] Toggle button icon changes based on current theme (🌙/☀️)
- [ ] No flashing or jarring transitions when switching themes
- [ ] System dark mode preference is respected on first visit
- [ ] All text remains readable in both light and dark modes
- [ ] All interactive elements (buttons, inputs) are properly styled in dark mode
- [ ] E2E test validates dark mode functionality
- [ ] Existing tests pass with zero regressions

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

Read `.claude/commands/test_e2e.md`, then read and execute your new E2E `.claude/commands/e2e/test_dark_mode.md` test file to validate this functionality works.

- `cd app/server && uv run pytest` - Run server tests to validate the feature works with zero regressions
- `cd app/client && bun run tsc --noEmit` - Run frontend type checking to validate the feature works with zero regressions
- `cd app/client && bun run build` - Run frontend build to validate the feature works with zero regressions

## Notes
- This feature is entirely frontend-based; no backend changes are required
- Consider using CSS transitions for smooth theme switching (e.g., `transition: background-color 0.3s, color 0.3s`)
- The dark mode implementation should respect the user's system preference on first visit if no localStorage preference exists
- Use `window.matchMedia('(prefers-color-scheme: dark)')` to detect system preference
- Consider adding a subtle animation or transition effect when toggling between themes
- Ensure all emoji and icon elements remain visible in dark mode
- Test with various color blindness filters to ensure accessibility
- Future consideration: Add theme option to profile dropdown menu for additional theme variants (auto/light/dark)
