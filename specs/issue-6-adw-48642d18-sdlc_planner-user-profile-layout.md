# Feature: User Profile Layout

## Metadata
issue_number: `6`
adw_id: `48642d18`
issue_json: `{"body":"Can we add a new user profile option in the top right hand corner\nNo log in required, but when the user clicks on it it should show a standard set of placeholder options to for profile management\n","number":6,"title":"Add New User Profile Layout"}`

## Feature Description
Add a user profile icon/button in the top right corner of the application header that opens a dropdown menu with standard placeholder profile management options. This feature provides a consistent user interface pattern without requiring authentication, allowing users to access profile-related functionality through a familiar UI pattern.

## User Story
As a user of the Natural Language SQL Interface
I want to see a user profile icon in the top right corner with accessible profile management options
So that I can access profile-related features through a familiar and intuitive interface pattern

## Problem Statement
The current application header lacks a user profile interface element, which is a standard UI pattern in modern web applications. Users expect to find profile-related options in the top right corner of the interface. Without this visual element, there's no clear location for profile management features, even if authentication is not currently implemented.

## Solution Statement
Implement a user profile component in the top right corner of the application header consisting of:
1. A profile icon/avatar button positioned in the header
2. A dropdown menu that appears when the icon is clicked
3. Standard placeholder menu items for profile management (View Profile, Account Settings, Help & Support, About)
4. Click-outside-to-close functionality
5. Responsive styling that matches the existing design system
6. Smooth animations for dropdown appearance

The implementation will be frontend-only with no backend authentication requirements, using placeholder functionality for menu items.

## Relevant Files
Use these files to implement the feature:

- `app/client/index.html` - Main HTML structure where the profile button will be added to the header/container
- `app/client/src/main.ts` - Main TypeScript file where profile dropdown initialization and event handlers will be added
- `app/client/src/style.css` - CSS file where profile button and dropdown menu styles will be added
- `.claude/commands/e2e/test_basic_query.md` - Reference for E2E test format and structure
- `.claude/commands/test_e2e.md` - Reference for understanding how to create and run E2E tests

### New Files
- `.claude/commands/e2e/test_user_profile.md` - E2E test file to validate the user profile dropdown functionality

## Implementation Plan

### Phase 1: Foundation
1. Design the user profile component structure and determine menu items
2. Identify insertion point in the HTML (header area of the container)
3. Plan the CSS classes and styling approach to match existing design patterns
4. Define the dropdown menu items and their placeholder actions

### Phase 2: Core Implementation
1. Add the profile button HTML structure to the header
2. Implement the dropdown menu HTML structure (initially hidden)
3. Add CSS styling for the profile button, dropdown, and animations
4. Implement JavaScript/TypeScript functionality for:
   - Toggle dropdown on profile button click
   - Close dropdown when clicking outside
   - Placeholder click handlers for menu items
5. Ensure responsive design works on different screen sizes

### Phase 3: Integration
1. Verify the profile component doesn't interfere with existing UI elements
2. Test the dropdown behavior with existing modals and overlays
3. Ensure proper z-index layering
4. Validate accessibility features (keyboard navigation, ARIA attributes)
5. Test cross-browser compatibility

## Step by Step Tasks

### Task 1: Create E2E Test Specification
- Read `.claude/commands/test_e2e.md` and `.claude/commands/e2e/test_basic_query.md` to understand the E2E test format
- Create `.claude/commands/e2e/test_user_profile.md` with test steps to:
  - Navigate to the application
  - Verify profile icon is visible in top right corner
  - Click the profile icon
  - Verify dropdown menu appears with expected items (View Profile, Account Settings, Help & Support, About)
  - Click outside the dropdown
  - Verify dropdown closes
  - Take screenshots at each major step
- Include success criteria and expected UI elements

### Task 2: Modify HTML Structure
- Open `app/client/index.html`
- Locate the `<h1>Natural Language SQL Interface</h1>` header element
- Restructure the header area to create a flex container with the title on the left and profile button on the right
- Add a new header div wrapping the h1 and profile button with class `app-header`
- Add profile button HTML structure:
  ```html
  <button id="profile-button" class="profile-button" aria-label="User profile menu" aria-expanded="false" aria-haspopup="true">
    <span class="profile-icon">👤</span>
  </button>
  ```
- Add dropdown menu HTML structure immediately after the profile button:
  ```html
  <div id="profile-dropdown" class="profile-dropdown" role="menu" aria-labelledby="profile-button" style="display: none;">
    <div class="profile-dropdown-header">
      <div class="profile-avatar">👤</div>
      <div class="profile-info">
        <div class="profile-name">Guest User</div>
        <div class="profile-email">guest@example.com</div>
      </div>
    </div>
    <div class="profile-dropdown-divider"></div>
    <ul class="profile-menu-items">
      <li><button class="profile-menu-item" data-action="view-profile">View Profile</button></li>
      <li><button class="profile-menu-item" data-action="account-settings">Account Settings</button></li>
      <li><button class="profile-menu-item" data-action="help-support">Help & Support</button></li>
      <li><button class="profile-menu-item" data-action="about">About</button></li>
    </ul>
  </div>
  ```

### Task 3: Add CSS Styling
- Open `app/client/src/style.css`
- Add styling for the app header layout:
  ```css
  .app-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    position: relative;
  }

  .app-header h1 {
    margin: 0;
  }
  ```
- Add styling for the profile button:
  - Circular button with subtle background
  - Hover effects with color transition
  - Active state styling
  - Icon sizing and centering
- Add styling for the profile dropdown:
  - Positioned absolutely relative to the button
  - White background with shadow (matching modal styles)
  - Border-radius matching existing components
  - Smooth slide-down animation
  - Min-width for proper content display
  - z-index to appear above other content
- Add styling for dropdown header with avatar and user info
- Add styling for menu items:
  - Full-width buttons with left-aligned text
  - Hover effects matching existing buttons
  - Proper padding and spacing
  - Divider line styling
- Ensure responsive behavior on smaller screens

### Task 4: Implement JavaScript Functionality
- Open `app/client/src/main.ts`
- Add a new initialization function `initializeUserProfile()` to be called in the `DOMContentLoaded` event
- Implement the `initializeUserProfile()` function:
  - Get references to profile button and dropdown elements
  - Add click event listener to profile button to toggle dropdown visibility
  - Update `aria-expanded` attribute when toggling
  - Add click-outside detection to close dropdown:
    - Listen for clicks on the document
    - Check if click target is outside profile button and dropdown
    - Close dropdown if clicking outside
  - Add click handlers for menu items:
    - For each menu item, add a click event listener
    - Log the action to console (placeholder functionality)
    - Display a temporary message to the user (e.g., "This feature is coming soon!")
    - Close the dropdown after clicking an item
  - Add keyboard support:
    - Escape key to close dropdown
    - Arrow keys for navigation (optional enhancement)

### Task 5: Test Profile Component Manually
- Start the application using `./scripts/start.sh`
- Verify the profile icon appears in the top right corner
- Click the profile icon and verify the dropdown opens
- Verify all menu items are visible and properly styled
- Click each menu item and verify placeholder functionality
- Click outside the dropdown and verify it closes
- Test on different screen sizes to ensure responsive behavior
- Verify the profile component doesn't interfere with existing modals or UI elements

### Task 6: Run Validation Commands
- Execute all commands listed in the `Validation Commands` section
- Fix any TypeScript errors or test failures
- Ensure the frontend build completes successfully
- Run the E2E test to validate the feature works as expected

## Testing Strategy

### Unit Tests
- No backend unit tests required (frontend-only feature)
- Frontend TypeScript compilation serves as type checking

### Edge Cases
- **Rapid clicking**: Verify dropdown doesn't flicker or break when rapidly clicking the profile button
- **Multiple dropdowns**: Ensure only one dropdown instance exists
- **Modal interaction**: Test that opening the upload modal while dropdown is open closes the dropdown properly
- **Z-index conflicts**: Verify dropdown appears above all other content but below modals
- **Click-outside on other interactive elements**: Ensure clicking buttons or other elements closes the dropdown
- **Small screens**: Test on mobile viewport sizes to ensure dropdown is fully visible
- **No JavaScript**: Gracefully degrade (dropdown won't work, but icon should still be visible)

## Acceptance Criteria
1. ✅ Profile icon is visible in the top right corner of the header
2. ✅ Profile icon is properly aligned and doesn't overlap with existing content
3. ✅ Clicking the profile icon opens a dropdown menu
4. ✅ Dropdown menu contains the following items:
   - View Profile
   - Account Settings
   - Help & Support
   - About
5. ✅ Dropdown menu has a header section showing placeholder user info (avatar, name, email)
6. ✅ Clicking a menu item triggers a placeholder action (console log or temporary message)
7. ✅ Clicking outside the dropdown closes it
8. ✅ Pressing Escape key closes the dropdown
9. ✅ Dropdown styling matches the existing design system (colors, fonts, shadows, borders)
10. ✅ Profile component is responsive on different screen sizes
11. ✅ Clicking a menu item closes the dropdown
12. ✅ ARIA attributes are properly set for accessibility
13. ✅ E2E test validates the complete user flow
14. ✅ No TypeScript errors
15. ✅ Frontend build succeeds

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

- `cd app/client && bun tsc --noEmit` - Run TypeScript compilation to validate no type errors
- `cd app/client && bun run build` - Build the frontend to validate the feature works in production mode
- Read `.claude/commands/test_e2e.md`, then read and execute the new E2E test file `.claude/commands/e2e/test_user_profile.md` to validate the user profile functionality works as expected
- Manual validation:
  1. Start the application: `./scripts/start.sh`
  2. Open browser to http://localhost:5173
  3. Verify profile icon is visible in top right
  4. Click profile icon and verify dropdown appears
  5. Click each menu item and verify placeholder actions
  6. Click outside dropdown and verify it closes
  7. Test responsive behavior on mobile viewport

## Notes
- This feature is purely frontend and requires no backend changes
- All profile menu actions are placeholders (console logs or temporary UI messages)
- Future enhancements could include:
  - Real authentication integration
  - User profile data storage
  - Account settings page
  - Theme switching in profile menu
  - Keyboard navigation with arrow keys
  - Profile picture upload
- The profile icon uses a simple emoji (👤) for now, but could be replaced with an SVG icon or actual user avatar in the future
- Consider adding a badge or notification dot on the profile icon for future notifications
- The dropdown uses absolute positioning, which may need adjustment if the header layout changes
- CSS variables from the existing design system should be reused for consistency
- The implementation follows the existing patterns in the codebase (vanilla TypeScript, no frameworks)
