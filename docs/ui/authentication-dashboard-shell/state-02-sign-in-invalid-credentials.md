# State 02: Sign-In Invalid Credentials

Route and locale context:

- Route: `POST /[locale]/session` render fail state on `/[locale]/session/new`
- Auth boundary: public

## Visual direction

- Keep same layout as default state to preserve spatial memory.
- Inject high-contrast semantic error banner above form within card.
- Preserve typed email to reduce friction on retry.
- Avoid modal interruption; error remains inline and screen-reader announced.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Web                                                                    EN | TH   |
|------------------------------------------------------------------------------------------|
|                           +------------------------------------------+                   |
|                           | Sign in to continue                      |                   |
|                           |------------------------------------------|                   |
|                           | ! Invalid email or password.             |                   |
|                           |------------------------------------------|                   |
|                           | Email                                   |                   |
|                           | [ frontdesk@clinic.test              ]   |                   |
|                           | Password                                |                   |
|                           | [ *******************************    ]   |                   |
|                           |                                          |                   |
|                           | [ Sign in ]                              |                   |
|                           +------------------------------------------+                   |
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Error region with `role=alert` behavior.
- Email value sticky, password cleared.
- Retry submit action.

Trigger -> transition notes:

- Retry with correct credentials -> `state-04-dashboard-loading-skeleton`.
- Repeat failure -> remain in this state.

Permission/policy constraints:

- Public page; no authorization gate.
