# State 03: Sign-In Contract Mismatch

Route and locale context:

- Route: `POST /[locale]/session` render fail state on `/[locale]/session/new`
- Auth boundary: public

## Visual direction

- Same card shell as other auth states for consistency.
- Error styling uses semantic error tokens but with technical detail suffix.
- Copy communicates system mismatch without exposing sensitive payload internals.
- Keep primary CTA available for retry after environment correction.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Web                                                                    EN | TH   |
|------------------------------------------------------------------------------------------|
|                           +------------------------------------------+                   |
|                           | Sign in to continue                      |                   |
|                           |------------------------------------------|                   |
|                           | ! Contract mismatch: expected field      |                   |
|                           |   `principal.permissions` not present.   |                   |
|                           |------------------------------------------|                   |
|                           | Email                                   |                   |
|                           | [ admin@clinic.test                  ]   |                   |
|                           | Password                                |                   |
|                           | [ *******************************    ]   |                   |
|                           |                                          |                   |
|                           | [ Try again ]                            |                   |
|                           +------------------------------------------+                   |
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Integration error alert with safe message.
- Retry button remains primary action.
- Optional support link slot reserved below CTA.

Trigger -> transition notes:

- Retry after backend contract fixed -> `state-04-dashboard-loading-skeleton`.
- Persistent mismatch -> remain in this state.

Permission/policy constraints:

- Public page; no authorization gate.
