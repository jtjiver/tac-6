# Feature: One Click Table Exports

## Metadata
issue_number: `1`
adw_id: `aeeb3a3c`
issue_json: `{"number":1,"title":"One Click Table Exports","body":"Using adw_plan_build_review add one click table exports and one click results export feature to get results as csv files\n\nCreate two new endpoints to support these features.  One exporting table, one for reporting query results.\n\nPlace a download button directly to the left of the 'x' icon for availabel tables.\nPlace a download button to the left of the `hide` button for query results.\n\nUse appropriate download icon"}`

## Feature Description
This feature enables users to export data from the Natural Language SQL Interface application with a single click. Users will be able to export both entire tables from the Available Tables section and query results from the Query Results section as CSV files. The feature adds intuitive download buttons with appropriate icons in the UI, making data export seamless and accessible without requiring SQL knowledge.

## User Story
As a data analyst or business user
I want to export table data and query results as CSV files with one click
So that I can analyze the data in external tools like Excel or share it with colleagues

## Problem Statement
Currently, users can view and query data within the application but have no way to export this data for external use. Users need to manually copy data or take screenshots, which is inefficient and error-prone, especially for large datasets. This limitation prevents users from performing advanced analysis in their preferred tools or sharing data with team members who don't have access to the application.

## Solution Statement
Implement one-click export functionality by adding download buttons to both the Available Tables section and Query Results section. Create two new API endpoints on the FastAPI backend to handle CSV generation and streaming. The download buttons will trigger these endpoints, allowing users to instantly download their data as properly formatted CSV files with appropriate headers and data types preserved.

## Relevant Files
Use these files to implement the feature:

- `app/server/server.py` - Add new API endpoints for table and query result exports
- `app/server/core/sql_processor.py` - Contains database query execution logic that will be reused for exports
- `app/server/core/data_models.py` - Add new data models for export requests/responses
- `app/client/src/main.ts` - Add download button event handlers and UI updates
- `app/client/src/api/client.ts` - Add API client methods for calling export endpoints
- `app/client/src/style.css` - Add styles for download buttons
- `app/client/index.html` - Update HTML structure if needed for download buttons
- `.claude/commands/test_e2e.md` - Reference for creating E2E test structure
- `.claude/commands/e2e/test_basic_query.md` - Reference for E2E test format

### New Files
- `.claude/commands/e2e/test_export_functionality.md` - E2E test for validating export functionality

## Implementation Plan
### Phase 1: Foundation
Create the backend infrastructure for CSV generation and export functionality, including data models and utility functions for formatting data as CSV.

### Phase 2: Core Implementation
Implement the API endpoints for table and query result exports, then add the frontend UI components including download buttons and client-side API integration.

### Phase 3: Integration
Integrate the export functionality with existing UI components, ensure proper error handling, and validate the feature works correctly with various data types and edge cases.

## Step by Step Tasks
IMPORTANT: Execute every step in order, top to bottom.

### Task 1: Create E2E Test Specification
- Read `.claude/commands/test_e2e.md` to understand E2E test structure
- Read `.claude/commands/e2e/test_basic_query.md` as an example
- Create `.claude/commands/e2e/test_export_functionality.md` with test steps for:
  - Exporting a table from Available Tables section
  - Running a query and exporting the results
  - Validating CSV downloads work correctly

### Task 2: Add Data Models for Export Functionality
- Open `app/server/core/data_models.py`
- Add `TableExportRequest` model with table_name field
- Add `QueryExportRequest` model with sql and columns fields
- Ensure models include proper validation

### Task 3: Create CSV Export Utility Function
- Open `app/server/server.py`
- Create a utility function `generate_csv_response()` that:
  - Takes query results and column names
  - Formats data as CSV using Python's csv module
  - Returns a StreamingResponse with appropriate headers
- Handle edge cases like null values, special characters in data

### Task 4: Implement Table Export Endpoint
- In `app/server/server.py`, add `GET /api/export/table/{table_name}` endpoint
- Use `sql_security.validate_identifier()` to validate table name
- Query all data from the specified table using `execute_query_safely()`
- Use the `generate_csv_response()` function to return CSV
- Add proper error handling for non-existent tables

### Task 5: Implement Query Results Export Endpoint
- In `app/server/server.py`, add `POST /api/export/query` endpoint
- Accept SQL query and column names in request body
- Validate and execute the SQL query safely
- Use the `generate_csv_response()` function to return CSV
- Add proper error handling for invalid queries

### Task 6: Add API Client Methods
- Open `app/client/src/api/client.ts`
- Add `exportTable(tableName: string)` method that:
  - Calls the table export endpoint
  - Triggers browser download of the CSV file
- Add `exportQueryResults(sql: string, columns: string[])` method that:
  - Calls the query export endpoint
  - Triggers browser download of the CSV file
- Use the Fetch API with blob response type for file downloads

### Task 7: Add Download Button Styles
- Open `app/client/src/style.css`
- Add styles for `.download-button` class
- Style should match existing button patterns
- Add hover and active states
- Use a download icon (can use Unicode character or SVG)

### Task 8: Add Download Button to Available Tables
- Open `app/client/src/main.ts`
- In the `displayTables()` function:
  - Create a download button element for each table
  - Place it to the left of the remove (×) button
  - Add click handler that calls `exportTable()`
  - Use appropriate download icon (⬇ or custom SVG)

### Task 9: Add Download Button to Query Results
- Open `app/client/src/main.ts`
- In the `displayResults()` function:
  - Create a download button for query results
  - Place it to the left of the Hide button
  - Store current SQL and columns in data attributes
  - Add click handler that calls `exportQueryResults()`
- Ensure button is only shown when results are present

### Task 10: Add Error Handling and User Feedback
- Add try-catch blocks to all export functions
- Show loading state on buttons during export
- Display error messages if export fails
- Add success feedback (optional toast or visual indicator)

### Task 11: Test with Different Data Types
- Manually test exports with:
  - Tables containing special characters
  - Large datasets (100+ rows)
  - Queries with NULL values
  - Different column data types (text, numbers, dates)
- Verify CSV format is correct and opens in Excel/Google Sheets

### Task 12: Run Validation Commands
- Run server tests to ensure no regressions
- Run client TypeScript checks
- Run client build process
- Execute the E2E test for export functionality

## Testing Strategy
### Unit Tests
- Test CSV generation with various data types and edge cases
- Test endpoint parameter validation and error handling
- Test client-side download triggering mechanism
- Verify proper escaping of special characters in CSV

### Edge Cases
- Empty tables or query results
- Tables with special characters in names
- Very large datasets (performance testing)
- Columns with commas, quotes, or newlines in data
- NULL values in data
- Tables that no longer exist
- Invalid SQL queries in export request
- Network failures during download

## Acceptance Criteria
- Download buttons appear to the left of the × button for each table in Available Tables
- Download button appears to the left of the Hide button in Query Results
- Clicking download button immediately triggers CSV file download
- CSV files have proper headers matching column names
- CSV files open correctly in Excel and Google Sheets
- Special characters and NULL values are handled properly
- Download works for both small and large datasets
- Error messages are shown if export fails
- No regression in existing functionality

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

- `cd app/server && uv run pytest` - Run server tests to validate the feature works with zero regressions
- `cd app/server && uv run python -c "import server; print('Server imports successfully')"` - Verify server code is syntactically correct
- `cd app/client && bun tsc --noEmit` - Run frontend tests to validate the feature works with zero regressions
- `cd app/client && bun run build` - Run frontend build to validate the feature works with zero regressions
- Read `.claude/commands/test_e2e.md`, then read and execute `.claude/commands/e2e/test_export_functionality.md` test file to validate export functionality works

## Notes
- Consider adding format options (CSV, JSON, Excel) in future iterations
- May want to add download history or batch export features later
- Performance optimization may be needed for very large tables (>10,000 rows)
- Consider adding compression for large exports in the future
- The download icon should be consistent with modern web standards (consider using Font Awesome or similar icon library if already in use)