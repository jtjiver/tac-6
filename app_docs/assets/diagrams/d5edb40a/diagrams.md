# Diagrams for Table Export Feature (d5edb40a)

## Context Diagram

```mermaid
graph TB
    User[User/Browser]
    Client[Client Application<br/>TypeScript]
    Server[FastAPI Server<br/>Python]
    DB[(SQLite Database)]

    User -->|Clicks Export Button| Client
    Client -->|GET /api/export/table/:name<br/>POST /api/export/query| Server
    Server -->|Query Data| DB
    DB -->|Return Results| Server
    Server -->|Stream CSV Response| Client
    Client -->|Download File| User

    style Client fill:#e1f5ff
    style Server fill:#fff4e1
    style DB fill:#f0f0f0

    subgraph "New Components"
        ExportBtn[Download Buttons]
        ExportAPI[Export Endpoints]
    end

    Client -.->|Contains| ExportBtn
    Server -.->|Contains| ExportAPI

    style ExportBtn fill:#90EE90
    style ExportAPI fill:#90EE90
```

## Sequence Diagram

```mermaid
sequenceDiagram
    participant U as User
    participant B as Browser
    participant C as Client (main.ts)
    participant A as API Client
    participant S as Server
    participant D as Database

    Note over U,D: Table Export Flow
    U->>B: Click table download button
    B->>C: onclick event
    C->>C: Show loading state
    C->>A: exportTable(tableName)
    A->>S: GET /api/export/table/:name
    S->>S: Validate table name
    S->>D: SELECT * FROM table
    D-->>S: Return rows
    S->>S: Generate CSV stream
    S-->>A: Stream CSV response
    A-->>C: Blob data
    C->>C: Create download link
    C->>B: Trigger download
    B->>U: Save file dialog
    C->>C: Reset button state

    Note over U,D: Query Results Export Flow
    U->>B: Click results download button
    B->>C: onclick event
    C->>C: Show loading state
    C->>A: exportQuery(sql, columns)
    A->>S: POST /api/export/query
    S->>S: Validate and execute SQL
    S->>D: Execute query
    D-->>S: Return results
    S->>S: Generate CSV stream
    S-->>A: Stream CSV response
    A-->>C: Blob data
    C->>C: Create download link
    C->>B: Trigger download
    B->>U: Save file dialog
    C->>C: Reset button state
```

## Filesystem Structure

```
app/
├── client/
│   ├── src/
│   │   ├── main.ts                 *** (Download button UI logic)
│   │   ├── api/
│   │   │   └── client.ts           *** (Export API methods)
│   │   └── style.css               *** (Download button styles)
│   └── index.html                  *** (Results header structure)
│
└── server/
    ├── server.py                    *** (Export endpoints)
    └── core/
        ├── data_models.py           *** (ExportQueryRequest model)
        ├── sql_security.py          (Security validation)
        └── sql_processor.py         (SQL utilities)

Key Changes:
- main.ts: Added download button creation and click handlers for both tables and query results
- style.css: New .download-button styles with modern button design
- client.ts: New exportTable() and exportQuery() API methods
- server.py: New generate_csv_response() helper and two export endpoints
- data_models.py: New ExportQueryRequest Pydantic model
- index.html: Added .results-header-buttons container for button layout
```

## Component Breakdown

```
Download Button Component (Tables):
├── button.download-button
│   ├── Attributes: data-table="table_name"
│   ├── Content: "📥 Export CSV"
│   ├── Position: In table header, left of ✕ button
│   └── States:
│       ├── Default: White background, blue border
│       ├── Hover: Blue background, white text
│       ├── Loading: Disabled, spinner displayed
│       └── Error: Reset to default, error shown in UI

Download Button Component (Query Results):
├── button.download-button
│   ├── Attributes: data-sql="...", data-columns="..."
│   ├── Content: "📥 Export CSV"
│   ├── Position: In .results-header-buttons, before Hide button
│   └── States: (Same as table button)

CSS Class Hierarchy:
.download-button
├── Base styles: padding, border, colors, transitions
├── :hover - Background/color inversion
├── :active - Subtle press effect
├── .loading - Opacity reduced, cursor disabled
└── .loading-spinner - Animated spinner for loading state
```
