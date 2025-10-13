# Feature: Dark Mode Toggle for SQL Interface

## Metadata
issue_number: `12`
adw_id: `777c8c50`
issue_json: `{"body":"Lets implement a quick switch dark mode for the SQL interface","number":12,"title":"Dark Mode"}`

## Feature Description
Implement a quick-switch dark mode toggle for the Natural Language SQL Interface application. This feature will allow users to seamlessly switch between light and dark themes, providing a better viewing experience in low-light environments and reducing eye strain. The dark mode will apply consistent theming across all UI components including the query input, results tables, modals, and navigation elements. The user's theme preference will be persisted in local storage to maintain consistency across sessions.

## User Story
As a user of the SQL interface
I want to toggle between light and dark modes
So that I can work comfortably in different lighting conditions and reduce eye strain during extended use

## Problem Statement
Currently, the SQL interface only supports a light theme. Users working in low-light environments or during extended periods experience eye strain. Modern applications provide dark mode as a standard feature to improve user comfort and accessibility. Without this option, users cannot customize their visual experience to match their preferences or environmental conditions.

## Solution Statement
Add a dark mode toggle button to the application header (next to the existing profile button) that allows users to instantly switch between light and dark themes. The implementation will use CSS custom properties (CSS variables) to enable smooth theme transitions. The selected theme will be stored in localStorage to persist across browser sessions. All components including inputs, tables, modals, buttons, and text will have properly contrasted dark mode variants that maintain readability and visual hierarchy.

## Relevant Files
Use these files to implement the feature:

- **app/client/src/style.css** (line 1-717)
  - Contains all CSS variables and styles for the application
  - Defines color palette using CSS custom properties in :root
  - Needs dark mode color scheme added
  - All component styles reference CSS variables for easy theming

- **app/client/src/main.ts** (line 1-659)
  - Main TypeScript entry point for client-side functionality
  - Already has `initializeUserProfile()` pattern we can follow
  - Needs new `initializeDarkMode()` function added
  - Handles DOM manipulation and event listeners

- **app/client/index.html**
  - Contains the HTML structure including header with profile button
  - Needs dark mode toggle button added to `.app-header`
  - Should be placed between h1 and profile button for visual balance

- **Read `.claude/commands/test_e2e.md`** to understand E2E test structure
- **Read `.claude/commands/e2e/test_basic_query.md`** to see example E2E test format

### New Files

- **.claude/commands/e2e/test_dark_mode.md**
  - E2E test file to validate dark mode toggle functionality
  - Will test theme switching, persistence, and visual appearance
  - Follows the pattern from `test_basic_query.md`

## Implementation Plan

### Phase 1: Foundation
1. Define dark mode color palette using CSS custom properties
2. Create theme switching mechanism with localStorage persistence
3. Add data attribute to document root for theme identification

### Phase 2: Core Implementation
1. Add dark mode toggle button to application header
2. Implement JavaScript theme switching logic
3. Apply dark mode styles to all components using CSS variables
4. Test visual consistency across all UI elements

### Phase 3: Integration
1. Integrate theme toggle with existing header components
2. Ensure theme persists across page reloads
3. Validate accessibility and contrast ratios
4. Create comprehensive E2E tests

## Step by Step Tasks

### Task 1: Add Dark Mode Color Palette to CSS
- Open `app/client/src/style.css`
- After the existing `:root` block (after line 21), add a new `[data-theme="dark"]` selector
- Define dark mode color variables:
  - Background colors (dark backgrounds)
  - Surface colors (elevated surfaces)
  - Text colors (light text for dark backgrounds)
  - Border colors (subtle borders)
  - Primary/secondary colors (adjusted for dark theme)
- Ensure sufficient contrast ratios for accessibility (WCAG AA standard: 4.5:1 for normal text, 3:1 for large text)

### Task 2: Add Theme Transition Smoothing
- In `app/client/src/style.css`, add transition properties to commonly themed elements
- Target elements: body, containers, buttons, inputs, tables, modals
- Use `transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease;`
- Prevents jarring visual changes when switching themes

### Task 3: Create Dark Mode Toggle Button HTML
- Open `app/client/index.html`
- Locate the `.app-header` section (contains h1 and profile button)
- Add a new toggle button between the h1 and profile button:
  ```html
  <button id="dark-mode-toggle" class="dark-mode-toggle" aria-label="Toggle dark mode" title="Toggle dark mode">
    <span class="theme-icon">🌙</span>
  </button>
  ```
- This button will display a moon icon (🌙) for dark mode activation and sun icon (☀️) when dark mode is active

### Task 4: Style the Dark Mode Toggle Button
- In `app/client/src/style.css`, add styles for `.dark-mode-toggle` class
- Follow the same visual pattern as `.profile-button` (circular, hover effects, transitions)
- Ensure the button is visually consistent with the existing header design
- Add hover and active states for user feedback

### Task 5: Implement Dark Mode JavaScript Logic
- Open `app/client/src/main.ts`
- Create new function `initializeDarkMode()` following the pattern of `initializeUserProfile()`
- Implement theme detection from localStorage on page load
- Add event listener to toggle button for theme switching
- Update localStorage when theme changes
- Toggle `data-theme="dark"` attribute on document root element
- Update toggle button icon (🌙 ↔ ☀️) based on current theme

### Task 6: Call Dark Mode Initialization
- In `app/client/src/main.ts`, locate the `DOMContentLoaded` event listener (line 8)
- Add `initializeDarkMode();` to the initialization sequence
- Place it before `initializeUserProfile();` to ensure theme is applied early

### Task 7: Test Dark Mode on All Components
- Manually test theme switching on:
  - Query input section
  - Results tables
  - Upload modal
  - Available tables section
  - Profile dropdown
  - Buttons (primary, secondary, toggle)
  - Error and success messages
- Verify all text remains readable with sufficient contrast
- Check that borders and shadows are visible but not harsh

### Task 8: Create E2E Test File for Dark Mode
- Create `.claude/commands/e2e/test_dark_mode.md`
- Follow the structure from `test_basic_query.md`
- Test scenarios:
  1. Toggle dark mode on and verify theme changes
  2. Reload page and verify dark mode persists
  3. Toggle back to light mode
  4. Take screenshots of both themes
- Include verification of localStorage values
- Test that all components render correctly in both themes

### Task 9: Run All Validation Commands
- Execute all commands listed in the "Validation Commands" section
- Fix any issues that arise
- Ensure zero regressions in existing functionality
- Verify dark mode works in all supported browsers

## Testing Strategy

### Backend Unit Tests
No backend changes are required for this feature. All changes are client-side only (HTML, CSS, TypeScript).

### Frontend E2E Tests
Create `.claude/commands/e2e/test_dark_mode.md` to validate:
- **Initial State**: Application loads in light mode by default (no localStorage)
- **Theme Toggle**: Clicking the dark mode button switches to dark theme
- **Visual Verification**: Screenshots confirm dark theme is applied to all components
- **Persistence**: Reloading the page maintains the selected theme
- **Toggle Back**: Switching back to light mode works correctly
- **LocalStorage**: Verify theme preference is stored and retrieved from localStorage

User flow to test:
1. Navigate to application
2. Take screenshot of initial light mode
3. Click dark mode toggle button
4. Verify all UI elements have dark theme applied
5. Take screenshot of dark mode
6. Reload page
7. Verify dark mode persists after reload
8. Click toggle button again
9. Verify light mode is restored
10. Take screenshot of restored light mode

### Edge Cases
- **Browser without localStorage**: Gracefully fallback to light mode
- **Invalid localStorage value**: Clear and default to light mode
- **System preference detection**: (Optional future enhancement) Detect `prefers-color-scheme` media query
- **Mid-query theme switch**: Ensure toggling theme during query execution doesn't break UI
- **Modal open**: Verify theme switch works when modal is open
- **Results displayed**: Verify theme switch works with active query results

## Acceptance Criteria
- [ ] Dark mode toggle button is visible in the application header
- [ ] Clicking the toggle button switches between light and dark themes instantly
- [ ] All UI components (inputs, tables, buttons, modals) have proper dark mode styling
- [ ] Text maintains sufficient contrast ratios in both themes (WCAG AA compliant)
- [ ] Selected theme persists across browser sessions using localStorage
- [ ] Theme icon updates appropriately (🌙 for light mode, ☀️ for dark mode)
- [ ] Smooth transitions occur when switching themes (no jarring flashes)
- [ ] E2E test validates core dark mode functionality with screenshots
- [ ] Zero regressions in existing features
- [ ] All validation commands pass without errors

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

1. Read `.claude/commands/test_e2e.md` to understand how to run E2E tests
2. Read and execute `.claude/commands/e2e/test_dark_mode.md` to validate dark mode functionality works correctly
3. `cd app/client && bun run tsc --noEmit` - Verify TypeScript compiles without errors
4. `cd app/client && bun run build` - Verify production build completes successfully
5. `./scripts/start.sh` - Start the application and manually verify:
   - Dark mode toggle button appears in header
   - Clicking toggle switches theme
   - Theme persists after page reload
   - All components look correct in both themes
6. Test in different browsers (Chrome, Firefox, Safari) to ensure cross-browser compatibility

## Notes

### Design Considerations
- **Dark mode colors should not be pure black (#000000)**: Use dark grays (#1a1a1a, #2d2d2d) for better visual comfort
- **Maintain visual hierarchy**: Ensure elevated surfaces (modals, cards) are lighter than backgrounds in dark mode
- **Preserve brand colors**: Keep primary gradient (purple) recognizable in dark mode with adjusted brightness
- **Icon choice**: Moon (🌙) universally represents dark mode activation; Sun (☀️) represents light mode

### Performance
- Theme switching should be instant (< 100ms) using CSS custom properties
- No page reflow or re-rendering required, only color updates
- localStorage operations are synchronous and negligible in performance impact

### Accessibility
- Toggle button has `aria-label` for screen readers
- `title` attribute provides tooltip on hover
- Contrast ratios meet WCAG AA standards (4.5:1 for normal text, 3:1 for large text)
- Color is not the only indicator of theme (icon changes too)

### Future Enhancements
- Auto-detect system theme preference using `prefers-color-scheme` media query
- Add "Auto" option that follows system preference
- Provide theme customization options (accent colors, font sizes)
- Sync theme preference across devices using user account settings

### Technical Implementation Notes
- Using CSS custom properties enables instant theme switching without JavaScript-heavy solutions
- `data-theme` attribute on document root is a clean, maintainable approach
- localStorage key should be descriptive: `sql-interface-theme`
- Default to light mode if no preference is stored
- Theme initialization must happen before DOM render to prevent flash of wrong theme

### CSS Variable Strategy
```css
/* Light mode (default) */
:root {
  --background: #f5f7fa;
  --surface: #ffffff;
  --text-primary: #2c3e50;
  /* ... */
}

/* Dark mode */
[data-theme="dark"] {
  --background: #1a1a1a;
  --surface: #2d2d2d;
  --text-primary: #e0e0e0;
  /* ... */
}
```

All existing components already use `var(--background)`, `var(--surface)`, etc., so adding the dark theme selector will automatically apply dark colors throughout the app.
