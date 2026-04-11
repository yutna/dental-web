# State 26: Print Forbidden

Route and locale context:

- Route: `/[locale]/dental/print/:visit_id/:type`
- Auth boundary: signed-in but no `print:read` policy permission

## Visual direction

- Distinct forbidden layout within print shell to avoid confusion.
- Keep clear return paths to visit/workspace pages.
- Include audit reference for compliance review.
- Mobile keeps CTA order consistent with desktop.
- Ensure message remains neutral and actionable.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Print Access                                                                              |
|------------------------------------------------------------------------------------------|
| 403 Forbidden                                                                             |
| You are not allowed to print this document type for visit D14.                           |
| Required permission: dental.print.read                                                    |
| Audit ref: PRINT-DENY-2026-0410-09                                                       |
|------------------------------------------------------------------------------------------|
| [Back to visit] [Request temporary access]                                                |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Back to visit` returns to workflow detail page preserving locale.
- `Request temporary access` opens admin approval request form.

Trigger -> transition notes:

- Access granted and retry -> `state-25-print-preview-ready`.
