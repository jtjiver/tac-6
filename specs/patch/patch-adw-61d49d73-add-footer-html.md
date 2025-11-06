# Patch: Add Social Media Footer HTML Structure

## Metadata
adw_id: `61d49d73`
review_change_request: `Footer HTML structure not implemented: The spec requires adding a <footer> element with social media links to app/client/index.html (Step 2), but no footer exists in the DOM. The HTML file remains unchanged from the original implementation. Resolution: Add footer HTML markup to app/client/index.html before the closing </div> tags (line 124) with semantic <footer> element, social media links (Twitter, GitHub, LinkedIn, Facebook, Instagram), accessibility attributes (aria-labels), and security attributes (target="_blank" rel="noopener noreferrer").`

## Issue Summary
**Original Spec:** /opt/asw/projects/personal/tac/tac-6/specs/issue-20-adw-61d49d73-sdlc_planner-social-media-footer.md
**Issue:** The footer HTML structure is missing from app/client/index.html. No <footer> element with social media links exists in the DOM.
**Solution:** Add semantic footer HTML markup with social media links (Twitter, GitHub, LinkedIn, Facebook, Instagram) before the closing </div> tag at line 124 in app/client/index.html, including proper accessibility and security attributes.

## Files to Modify
Use these files to implement the patch:

- `app/client/index.html` (line 124) - Add footer HTML structure before closing </div> tags

## Implementation Steps
IMPORTANT: Execute every step in order, top to bottom.

### Step 1: Add Footer HTML Structure
- Open `app/client/index.html`
- Insert footer HTML after line 123 (after `</div>` closing the main container) and before line 124 (before the final `</div>`)
- Use semantic `<footer class="app-footer">` element
- Add inner container `<div class="footer-content">`
- Include copyright text: "© 2024 Natural Language SQL Interface"
- Add social media links section with `<div class="social-media-links">`

### Step 2: Add Social Media Links
- Add 5 social media links with the following structure for each:
  - Twitter: `<a href="https://twitter.com/yourproject" target="_blank" rel="noopener noreferrer" class="social-link" aria-label="Follow us on Twitter">🐦 Twitter</a>`
  - GitHub: `<a href="https://github.com/yourorganization/yourproject" target="_blank" rel="noopener noreferrer" class="social-link" aria-label="Visit our GitHub repository">💻 GitHub</a>`
  - LinkedIn: `<a href="https://linkedin.com/company/yourproject" target="_blank" rel="noopener noreferrer" class="social-link" aria-label="Connect with us on LinkedIn">💼 LinkedIn</a>`
  - Facebook: `<a href="https://facebook.com/yourproject" target="_blank" rel="noopener noreferrer" class="social-link" aria-label="Like us on Facebook">📘 Facebook</a>`
  - Instagram: `<a href="https://instagram.com/yourproject" target="_blank" rel="noopener noreferrer" class="social-link" aria-label="Follow us on Instagram">📷 Instagram</a>`
- Use emoji icons for consistency with existing design (profile button uses 👤)
- Ensure all links have target="_blank" and rel="noopener noreferrer" for security

## Validation
Execute every command to validate the patch is complete with zero regressions.

- Start the application: `./scripts/start.sh`
- Open browser to http://localhost:5173 and verify footer appears at bottom of page
- Verify all 5 social media links are visible
- Verify links have proper href attributes (even if placeholder URLs)
- Test that clicking links opens in new tab
- Run TypeScript type checking: `cd app/client && bun tsc --noEmit`
- Run frontend build: `cd app/client && bun run build`

## Patch Scope
**Lines of code to change:** ~20 lines (adding new footer HTML)
**Risk level:** low (purely additive HTML, no existing code modified)
**Testing required:** Visual verification in browser, ensure no layout breakage
