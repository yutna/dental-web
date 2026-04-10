# State 10: Workspace Permission Denied

Route and locale context:

- User target route: `/[locale]/workspace`
- Actual result: redirect to `/[locale]` with alert message
- Auth boundary: signed-in but fails policy (`workspace:read`)

## Visual direction

- Keep denial feedback explicit but non-threatening.
- Present clear next actions: return home, contact admin.
- Reuse global toast rail and home shell to avoid dead-end screens.
- Maintain consistency in both EN and TH copy.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Web                                                                     EN | TH   |
|------------------------------------------------------------------------------------------|
| ALERT: You are not authorized to access this section.                                    |
|------------------------------------------------------------------------------------------|
| Welcome to Dental Web                                                                     |
| This site supports English and Thai.                                                      |
|                                                                                           |
| [Open sign-in flow]  [Open clinical workspace]                                            |
|                                                                                           |
| Help: Request `workspace:read` permission from your administrator.                        |
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Alert banner sourced from authorization handler.
- Safe fallback links from home screen.

Trigger -> transition notes:

- User gains permission and retries workspace route -> `state-04-dashboard-loading-skeleton`.
- User signs out -> `state-01-sign-in-default`.

Permission/policy constraints:

- This state is the policy failure outcome.
