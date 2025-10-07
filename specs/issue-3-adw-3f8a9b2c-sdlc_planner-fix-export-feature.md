# Bug: Export Feature Not Working

## Metadata
issue_number: `3`
adw_id: `3f8a9b2c`
issue_json: `{"number":3,"title":"Newly created export feature does not work","body":"The newly created export feature does not work. Please investigate and fix this bug.  \n\nThe changes have not be pushed to main, they are still on the development branch"}`

## Bug Description
The recently implemented one-click CSV export feature (Issue #1) is not functioning correctly. The export endpoints were added in commit 332e112 on the `feature-issue-1-adw-aeeb3a3c-one-click-table-exports` branch but contain implementation bugs that prevent the table export functionality from working as expected.

**Symptoms:**
- Table export endpoint (`/api/export/table/{table_name}`) fails at runtime
- Export buttons appear in the UI but the export process fails when clicked
- Error occurs during CSV generation for table exports

**Expected Behavior:**
- Clicking the download button next to a table name should trigger a CSV file download
- The CSV should contain all table data with proper headers
- The export should work for all valid tables in the database

**Actual Behavior:**
- Export attempt fails due to incorrect cursor handling
- CSV generation does not complete successfully

## Problem Statement
The `export_table` endpoint in `app/server/server.py` has two critical bugs:

1. **Missing `.fetchall()` call**: The endpoint calls `execute_query_safely()` which returns a `sqlite3.Cursor` object, but then tries to iterate over the cursor directly without calling `.fetchall()` to retrieve the results. This causes a runtime error during export.

2. **Unsafe SQL execution**: The PRAGMA query for getting column information uses f-string interpolation (`f"PRAGMA table_info({table_name})"`) instead of the secure `execute_query_safely()` function, creating a potential security vulnerability and inconsistency with the codebase's security standards.

## Solution Statement
Fix the `export_table` endpoint by:

1. Add `.fetchall()` call after `execute_query_safely()` to properly retrieve query results before iteration
2. Replace the unsafe f-string PRAGMA query with a secure call to `execute_query_safely()` using identifier_params
3. Ensure the fix follows the same pattern used elsewhere in the codebase (see `app/server/core/sql_processor.py` for reference)

## Steps to Reproduce
1. Start the application with `./scripts/start.sh`
2. Upload sample data (e.g., users.csv) to create a table
3. Click the download button (⬇) next to the table name in the Available Tables section
4. Observe that the export fails with an error

## Root Cause Analysis
The bug was introduced during the implementation of Issue #1 (one-click table exports). The developer incorrectly assumed that `execute_query_safely()` returns a list of results, when it actually returns a `sqlite3.Cursor` object. This is evident from:

**Correct usage in `app/server/core/sql_processor.py` (lines 84-89):**
```python
cursor_info = execute_query_safely(
    conn,
    "PRAGMA table_info({table})",
    identifier_params={'table': table_name}
)
columns_info = cursor_info.fetchall()  # ← Correct: calls fetchall()
```

**Incorrect usage in `app/server/server.py` (lines 373-377, 387):**
```python
results = execute_query_safely(
    conn,
    "SELECT * FROM {table}",
    identifier_params={'table': table_name}
)  # ← Bug: missing .fetchall() call

# ...
for row in results:  # ← Tries to iterate cursor directly
    data.append(dict(zip(columns, row)))
```

Additionally, line 381 uses unsafe f-string interpolation:
```python
cursor.execute(f"PRAGMA table_info({table_name})")  # ← Security issue
```

This should use `execute_query_safely()` with `identifier_params` instead.

## Relevant Files
Use these files to fix the bug:

- `app/server/server.py` (lines 355-401) - Contains the buggy `export_table` endpoint that needs to be fixed
- `app/server/core/sql_processor.py` (lines 84-101) - Reference implementation showing correct usage of `execute_query_safely()`
- `app/server/core/sql_security.py` - Contains the `execute_query_safely()` function definition and return type documentation
- `.claude/commands/e2e/test_export_functionality.md` - E2E test specification for validating the fix

## Step by Step Tasks
IMPORTANT: Execute every step in order, top to bottom.

### Task 1: Fix the missing fetchall() call in export_table endpoint
- Open `app/server/server.py`
- Locate the `export_table` function (line 356)
- Find the `execute_query_safely()` call (lines 373-377)
- Add `.fetchall()` immediately after the execute_query_safely call to retrieve results from the cursor
- Store the fetched results in the `results` variable

### Task 2: Replace unsafe PRAGMA query with secure execution
- In the same `export_table` function
- Locate the unsafe PRAGMA query on line 381: `cursor.execute(f"PRAGMA table_info({table_name})")`
- Replace it with a secure call to `execute_query_safely()` using `identifier_params`
- Use the pattern from `sql_processor.py` lines 84-89 as reference
- Call `.fetchall()` on the returned cursor to get column information

### Task 3: Verify the query results export endpoint is correct
- Review the `export_query_results` endpoint (lines 403-425)
- Verify it does not have the same bug (it uses `execute_sql_safely` from sql_processor which returns a dict, not a cursor)
- Confirm the implementation is correct and matches the expected return type

### Task 4: Run Validation Commands
- Run all validation commands listed below to ensure the bug is fixed with zero regressions
- Verify server tests pass
- Verify TypeScript compilation succeeds
- Verify client build succeeds
- Run the E2E test to validate export functionality works

## Validation Commands
Execute every command to validate the bug is fixed with zero regressions.

- `cd app/server && uv run python -c "import server; print('Server imports successfully')"` - Verify server code is syntactically correct and imports without errors
- `cd app/server && uv run pytest -v` - Run server tests to validate the bug is fixed with zero regressions
- `cd app/client && bun tsc --noEmit` - Run frontend TypeScript checks to validate no regressions
- `cd app/client && bun run build` - Run frontend build to validate the bug is fixed with zero regressions
- Read `.claude/commands/test_e2e.md`, then read and execute `.claude/commands/e2e/test_export_functionality.md` test file to validate export functionality works

## Notes
- The bug only affects the table export endpoint (`/api/export/table/{table_name}`), not the query results export endpoint (`/api/export/query`)
- The query results export endpoint uses `execute_sql_safely()` from `sql_processor.py` which returns a dictionary with results already fetched, so it does not have this bug
- After fixing, the export feature should work exactly as specified in the original feature spec (specs/issue-1-adw-aeeb3a3c-one-click-table-exports.md)
- This is a minimal surgical fix - only two lines need to be changed in `export_table` function
- The fix should reference the correct usage pattern already present in `sql_processor.py:84-101` for consistency
