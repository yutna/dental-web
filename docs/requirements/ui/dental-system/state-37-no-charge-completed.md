# State 37: Completed Without Payment

Route and locale context:

- Route: `/[locale]/dental/visits/:id`
- Auth boundary: signed-in + `workflow:read`

## Visual direction

- Completion summary mirrors paid-complete layout for consistency.
- Payment section explicitly marks not-required.
- Keep follow-up and print actions available.
- Mobile keeps completion badge and key metadata above timeline.
- Use semantic success/readiness styling.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Visit D40 / HN0099                                                          COMPLETED     |
|------------------------------------------------------------------------------------------|
| Payment status: NOT-REQUIRED                                                             |
| Invoice: none                                                                            |
| Completion reason: non-charge treatment pathway                                           |
|------------------------------------------------------------------------------------------|
| Timeline: in-treatment -> completed (no-charge)                                          |
| [Print treatment summary] [Create follow-up appointment] [Back to queue]                |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- Follow-up appointment action opens scheduling prefilled data.
- Print action follows standard print permission checks.

Trigger -> transition notes:

- Unauthorized print -> `state-26-print-forbidden`.
