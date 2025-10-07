# E2E Test: Export Functionality

Test table and query result export functionality in the Natural Language SQL Interface application.

## User Story

As a data analyst or business user
I want to export table data and query results as CSV files with one click
So that I can analyze the data in external tools like Excel or share it with colleagues

## Test Steps

1. Navigate to the `Application URL`
2. Take a screenshot of the initial state
3. **Verify** the page title is "Natural Language SQL Interface"
4. **Verify** core UI elements are present:
   - Query input textbox
   - Query button
   - Upload Data button
   - Available Tables section

### Test Table Export

5. **Verify** that Available Tables section contains at least one table
6. **Verify** each table has a download button to the left of the × button
7. Take a screenshot showing the download button placement in Available Tables
8. Click the download button for the first available table
9. **Verify** a CSV file download is triggered (check that browser initiates download)
10. Take a screenshot after clicking download (if possible, show download notification)

### Test Query Results Export

11. Enter the query: "Show me all data from the first table"
12. Click the Query button
13. **Verify** the query results appear
14. **Verify** a download button appears to the left of the Hide button
15. Take a screenshot showing the download button placement in Query Results
16. Click the download button for query results
17. **Verify** a CSV file download is triggered for the query results
18. Take a screenshot after clicking download
19. Click "Hide" button to close results
20. **Verify** the download button is no longer visible when results are hidden

## Success Criteria
- Download buttons appear in correct positions (left of × for tables, left of Hide for results)
- Download buttons have appropriate download icons
- Clicking download button for table triggers CSV download
- Clicking download button for query results triggers CSV download
- Download buttons are styled consistently with existing UI
- No JavaScript errors occur during export operations
- At least 5 screenshots are taken documenting the export functionality