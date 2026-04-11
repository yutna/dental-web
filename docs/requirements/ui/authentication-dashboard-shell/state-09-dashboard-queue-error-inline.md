# State 09: Dashboard Queue Error Inline

Route and locale context:

- Route: `/[locale]/workspace` (queue frame error state)
- Auth boundary: signed-in + policy-gated

## Visual direction

- Error should be local to queue card, not a full-page crash.
- Keep filters and shell interactive for immediate retry/edit.
- Use semantic error surface with concise, actionable copy.
- Preserve last successful KPI cards to avoid blanking context.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| LOGO                             Clinical Workspace                       [Dr. Narin v]   |
|------------------------------------------------------------------------------------------|
| NAV                        | Overview cards (last successful snapshot)                   |
|                            | [Total 24] [In progress 6] [Ready 8] [Completed 10]         |
|                            |                                                              |
|                            | Appointment queue                                            |
|                            | [Search....................] [Status v] [Apply] [Reset]     |
|                            | ------------------------------------------------------------ |
|                            | ! Unable to refresh appointment queue right now.             |
|                            |   Please retry. If problem continues, contact support.       |
|                            | [Retry] [Reset filters]                                      |
|                            | ------------------------------------------------------------ |
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Inline error alert within queue card.
- Retry action re-requests queue frame.
- Reset filters fallback action.

Trigger -> transition notes:

- Retry success with rows -> `state-06-dashboard-populated`.
- Retry success with no rows -> `state-05-dashboard-empty-first-login`.
- Retry fails -> remain in this state.

Permission/policy constraints:

- Same workspace policy boundary.
