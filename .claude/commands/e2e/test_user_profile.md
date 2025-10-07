# E2E Test: User Profile Dropdown

Test user profile dropdown functionality in the Natural Language SQL Interface application.

## User Story

As a user
I want to access profile management options from a dropdown menu
So that I can navigate to profile-related features through a familiar interface pattern

## Test Steps

1. Navigate to the `Application URL`
2. Take a screenshot of the initial state
3. **Verify** the page title is "Natural Language SQL Interface"
4. **Verify** the profile button is visible in the top right corner of the header
5. **Verify** the profile button contains a user icon

6. Click the profile button
7. Take a screenshot of the dropdown menu opened
8. **Verify** the dropdown menu is visible
9. **Verify** the dropdown header shows:
   - Profile avatar icon
   - "Guest User" as the profile name
   - "guest@example.com" as the email
10. **Verify** the dropdown menu contains the following menu items:
    - "View Profile"
    - "Account Settings"
    - "Help & Support"
    - "About"

11. Click the "View Profile" menu item
12. **Verify** a message appears indicating the feature is coming soon or placeholder functionality
13. **Verify** the dropdown closes after clicking the menu item

14. Click the profile button again to reopen the dropdown
15. Take a screenshot of the reopened dropdown
16. Click outside the dropdown (on the page background)
17. **Verify** the dropdown closes when clicking outside

18. Click the profile button again to reopen the dropdown
19. Press the Escape key
20. **Verify** the dropdown closes when pressing Escape

## Success Criteria
- Profile button is visible in top right corner
- Profile button opens dropdown when clicked
- Dropdown shows user info header with avatar, name, and email
- Dropdown contains all 4 menu items
- Clicking a menu item triggers placeholder functionality
- Clicking a menu item closes the dropdown
- Clicking outside the dropdown closes it
- Pressing Escape key closes the dropdown
- 3 screenshots are taken
