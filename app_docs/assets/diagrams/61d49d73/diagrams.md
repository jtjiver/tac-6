# Architecture Diagrams - Social Media Footer Feature

**ADW ID:** 61d49d73
**Feature:** Social Media Footer Links
**Date:** 2025-10-25

---

## Context Diagram

This diagram shows the overall system components and how the footer integrates with the application.

```mermaid
graph TB
    subgraph "Client Browser"
        HTML[HTML Page<br/>index.html]
        CSS[Stylesheet<br/>style.css]
        Footer[Footer Component<br/>NEW]
    end

    subgraph "Application Components"
        Header[Header Section]
        Main[Main Content<br/>Query Interface]
        Footer
    end

    subgraph "External Links"
        Twitter[Twitter]
        GitHub[GitHub]
        LinkedIn[LinkedIn]
        Facebook[Facebook]
        Instagram[Instagram]
    end

    HTML --> Header
    HTML --> Main
    HTML --> Footer
    CSS --> Footer

    Footer --> Twitter
    Footer --> GitHub
    Footer --> LinkedIn
    Footer --> Facebook
    Footer --> Instagram

    style Footer fill:#667eea,stroke:#764ba2,stroke-width:3px,color:#fff
    style CSS fill:#f9f9f9,stroke:#333
    style HTML fill:#f9f9f9,stroke:#333
```

---

## Sequence Diagram

This diagram illustrates the user interaction flow with the footer component.

```mermaid
sequenceDiagram
    participant User
    participant Browser
    participant HTML as index.html
    participant CSS as style.css
    participant SocialSite as Social Media Site

    User->>Browser: Navigate to application
    Browser->>HTML: Load page
    HTML->>CSS: Apply footer styles
    CSS-->>HTML: Render footer with gradient
    HTML-->>Browser: Display page with footer
    Browser-->>User: Show complete page

    User->>Browser: Hover over social link
    Browser->>CSS: Apply :hover styles
    CSS-->>Browser: Transform + shadow effect
    Browser-->>User: Visual feedback

    User->>Browser: Click social media link
    Browser->>Browser: Open new tab (target="_blank")
    Browser->>SocialSite: Navigate to social media URL
    SocialSite-->>Browser: Load social media page
    Browser-->>User: Display social media site
```

---

## Filesystem Structure

```
app/client/
├── index.html                    *** MODIFIED - Added footer HTML structure
├── src/
│   ├── style.css                 *** MODIFIED - Added footer styles and responsive design
│   └── main.ts
├── package.json
└── vite.config.ts

Key Changes:
- index.html: Added <footer> element with social media links before closing </div>
- style.css: Added .app-footer, .social-media-links, .social-link styles
- style.css: Added responsive @media queries for mobile footer layout
```

---

## Component Breakdown

### HTML Structure
```
<footer class="app-footer">
  └── <div class="footer-content">
      └── <div class="social-media-links">
          ├── <a class="social-link"> Twitter
          ├── <a class="social-link"> GitHub
          ├── <a class="social-link"> LinkedIn
          ├── <a class="social-link"> Facebook
          └── <a class="social-link"> Instagram
```

### CSS Classes
- `.app-footer` - Main footer container with gradient background
- `.footer-content` - Content wrapper with max-width constraint
- `.social-media-links` - Flexbox container for social links
- `.social-link` - Individual link styling with hover effects
- `.social-icon` - Emoji icon styling
- `.social-text` - Text label styling
