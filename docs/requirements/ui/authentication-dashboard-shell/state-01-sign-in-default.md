# State 01: Sign-In Default

Route and locale context:

- Route: `/[locale]/session/new`
- Locale variants: `/en/session/new`, `/th/session/new`
- Auth boundary: public (redirects to workspace if already signed in)

## Visual direction

- Centered authentication card over soft token-based surface gradient (`app-surface-*`) to keep focus on form.
- Strong vertical rhythm with clear label-input-button grouping and visible focus ring.
- Use compact but comfortable spacing for clinic front-desk speed.
- Keep animation minimal: only subtle card fade-in; respect reduced motion.
- Reserve top toast rail for system messages without layout jump.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Web                                                                    EN | TH   |
|------------------------------------------------------------------------------------------|
|                                                                                          |
|                           +------------------------------------------+                   |
|                           | Sign in to continue                      |                   |
|                           | Authentication via Rails BFF             |                   |
|                           |------------------------------------------|                   |
|                           | Email                                   |                   |
|                           | [ frontdesk@clinic.test              ]   |                   |
|                           |                                          |                   |
|                           | Password                                |                   |
|                           | [ *******************************    ]   |                   |
|                           |                                          |                   |
|                           | [ Sign in ]                              |                   |
|                           |                                          |                   |
|                           | Hint: local mode accepts any non-empty  |                   |
|                           | credentials for demo environment.        |                   |
|                           +------------------------------------------+                   |
|                                                                                          |
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Form fields: email, password.
- Primary action: Sign in.
- Secondary context: demo hint text.
- Locale switch link in shell header.

Trigger -> transition notes:

- Submit valid credentials -> `state-04-dashboard-loading-skeleton`.
- Submit invalid credentials -> `state-02-sign-in-invalid-credentials`.
- Contract mismatch from backend -> `state-03-sign-in-contract-mismatch`.

Permission/policy constraints:

- No Pundit policy gate on this page.
- If already signed in, transition directly to workspace route.
