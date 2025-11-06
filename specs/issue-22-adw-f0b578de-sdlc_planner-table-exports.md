# Feature: One Click Table Exports

## Metadata
issue_number: `22`
adw_id: `f0b578de`
issue_json: `{"number":22,"title":"One Click Table Exports","body":"Using adw_plan_build_review add one click table exports and one click results export feature to get results as csv files\\n\\nCreate two new endpoints to support these features.  One exporting table, one for reporting query results.\\n\\nPlace a download button directly to the left of the 'x' icon for availabel tables.\\nPlace a download button to the left of the 'hide' button for query results.\\n\\nUse appropriate download icon"}`

## Feature Description
This feature enhances the Natural Language SQL Interface application by adding one-click CSV export functionality for both database tables and query results. Users will be able to download their data as CSV files directly from the UI through strategically placed download buttons with appropriate icons. The backend already has the export endpoints implemented (`/api/export/table/{table_name}` and `/api/export/query`), but the UI needs refinement to ensure download buttons are positioned correctly and have proper visual indicators.

## User Story
As a data analyst
I want to export tables and query results as CSV files with a single click
So that I can analyze data offline or share it with colleagues

## Problem Statement
Users currently need to manually copy or screenshot data from the application when they want to work with it outside the browser. While the backend export functionality exists, the UI placement and visual design of the export buttons may not be optimal for user discovery and interaction. The buttons need to be consistently positioned and use appropriate download icons to make the feature intuitive.

## Solution Statement
We will enhance the existing CSV export functionality by ensuring download buttons are correctly positioned in the UI (to the left of the 'x' icon for tables and to the left of the 'hide' button for query results) and use appropriate download icons. The solution leverages the existing backend endpoints while improving the frontend user experience through better button placement and visual design.

## Relevant Files
Use these files to implement the feature:

- `app/server/server.py` - Contains existing export endpoints that handle CSV generation
- `app/server/core/sql_security.py` - SQL security module for safe query execution during exports
- `app/client/src/main.ts` - Main frontend logic where table and query result UI is rendered
- `app/client/src/api/client.ts` - API client with existing export methods
- `app/client/src/style.css` - Styles for download buttons and icons
- `app/client/index.html` - HTML structure for results and tables sections
- `app/client/src/types.d.ts` - TypeScript type definitions for API responses
- `.claude/commands/test_e2e.md` - E2E test runner documentation
- `.claude/commands/e2e/test_basic_query.md` - Example E2E test structure

### New Files
- `.claude/commands/e2e/test_csv_export.md` - New E2E test file to validate CSV export functionality

## Implementation Plan
### Phase 1: Foundation
Verify and understand the existing CSV export implementation in both backend and frontend. Ensure all security measures are in place for safe data export operations.

### Phase 2: Core Implementation
Refine the UI placement of download buttons to match the specified positions (left of 'x' for tables, left of 'hide' for query results) and ensure proper download icons are used throughout.

### Phase 3: Integration
Ensure the export feature integrates seamlessly with existing functionality, handles edge cases gracefully, and provides appropriate user feedback during download operations.

## Step by Step Tasks
IMPORTANT: Execute every step in order, top to bottom.

### 1. Verify Backend Export Endpoints
- Read `app/server/server.py` to understand the existing export endpoints
- Verify `GET /api/export/table/{table_name}` endpoint functionality
- Verify `POST /api/export/query` endpoint functionality
- Check security measures in place for export operations
- Test endpoints manually with sample data to ensure CSV generation works

### 2. Create E2E Test File
- Create `.claude/commands/e2e/test_csv_export.md` based on the structure of `test_basic_query.md`
- Define test steps for both table export and query result export
- Include verification of button placement and download functionality
- Specify screenshot capture points for visual validation

### 3. Review Current Frontend Implementation
- Read `app/client/src/main.ts` to understand current button placement logic
- Identify the exact location where table row buttons are created (around line 434)
- Identify the exact location where query result header buttons are created (around line 306)
- Review current download icon implementation

### 4. Refine Table Export Button Placement
- Ensure download button is created directly to the left of the 'x' (delete) button for each table
- Verify button has the class `download-button` for consistent styling
- Ensure proper download icon is displayed (currently using SVG icon)
- Test button visibility and positioning with multiple tables

### 5. Refine Query Results Export Button Placement
- Ensure download button is positioned to the left of the 'Hide' button in results header
- Verify button only appears when results are present
- Ensure button disappears when results are cleared
- Test button behavior with different query results

### 6. Enhance Visual Design
- Review and update download button styles in `app/client/src/style.css`
- Ensure consistent hover and active states
- Verify loading state animation during export operations
- Ensure buttons are visually distinct and easy to identify

### 7. Handle Edge Cases
- Test export with empty tables
- Test export with tables containing special characters
- Test export with very large result sets
- Ensure proper error handling and user feedback for failed exports
- Test concurrent export operations

### 8. Add Accessibility Features
- Ensure download buttons have proper aria-labels
- Add keyboard navigation support if not present
- Verify screen reader compatibility
- Add tooltips to explain button functionality

### 9. Run Comprehensive Tests
- Execute unit tests: `cd app/server && uv run pytest`
- Execute TypeScript compilation: `cd app/client && bun tsc --noEmit`
- Build frontend: `cd app/client && bun run build`
- Run the new E2E test: Execute `.claude/commands/e2e/test_csv_export.md`

### 10. Validate Complete Feature
- Start the application using `./scripts/start.sh`
- Upload sample data using the Upload Data modal
- Verify download button appears to the left of 'x' for each table
- Execute a query and verify download button appears to the left of 'Hide'
- Test actual CSV downloads for both tables and query results
- Verify downloaded CSV files contain correct data and headers
- Run all validation commands listed below

## Testing Strategy
### Unit Tests
- Backend: Test export endpoint security validations
- Backend: Test CSV generation with various data types
- Backend: Test handling of NULL values in exports
- Frontend: Test button creation and positioning logic
- Frontend: Test API client export methods

### Edge Cases
- Empty tables or query results
- Tables with special characters in names
- Very large datasets (streaming response handling)
- Concurrent export requests
- Network failures during download
- Tables with mixed data types
- Query results with computed columns
- Unicode characters in data

## Acceptance Criteria
- Download buttons appear to the left of 'x' icon for all available tables
- Download button appears to the left of 'Hide' button for query results
- All download buttons use consistent and appropriate download icons
- CSV exports contain proper headers matching column names
- CSV exports handle NULL values correctly
- Download operations show loading state while in progress
- Error messages display appropriately for failed exports
- Downloaded files have descriptive names (e.g., `tablename.csv`, `query_results.csv`)
- Export functionality works across different browsers
- No regression in existing functionality

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

- `cd app/server && uv run pytest` - Run server tests to validate the feature works with zero regressions
- `cd app/server && uv run pytest tests/test_sql_injection.py -v` - Verify security measures remain intact
- `cd app/client && bun tsc --noEmit` - Run frontend tests to validate the feature works with zero regressions
- `cd app/client && bun run build` - Run frontend build to validate the feature works with zero regressions
- `./scripts/start.sh` - Start the application and manually test export functionality
- Read `.claude/commands/test_e2e.md`, then read and execute `.claude/commands/e2e/test_csv_export.md` to validate export functionality works end-to-end

## Notes
- The backend export endpoints are already implemented and functional
- The frontend already has download buttons, but their positioning may need refinement
- Security is critical - all exports must go through the sql_security module
- Consider implementing download progress indicators for large exports in future iterations
- The feature should work seamlessly with the existing ADW automation framework
- Future enhancement: Add support for other export formats (JSON, Excel) if needed