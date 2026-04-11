# State 04: Dashboard Loading Skeleton

Route and locale context:

- Route: `/[locale]/workspace`
- Controller/action: `WorkspaceController#show`
- Auth boundary: signed-in + policy-gated (`workspace:read`)

## Visual direction

- Full shell loads immediately, then queue area shows skeleton shimmer for operations >300ms.
- Sticky top bar stays interactive so profile and locale controls remain available.
- Favor layout stability; cards/table keep final dimensions to prevent jumping.
- Motion is subtle shimmer only; disable with reduced-motion preference.
- Colors from semantic app tokens for light/dark parity.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| LOGO                             Clinical Workspace                       [Dr. Narin v]   |
|------------------------------------------------------------------------------------------|
| NAV (desktop)             | Overview cards                                               |
| - Overview                | +---------+ +---------+ +---------+ +---------+             |
| - Queue                   | | Total   | | In prog | | Ready   | | Done    |             |
| - Components              | |   --    | |   --    | |   --    | |   --    |             |
| - Admin (if allowed)      | +---------+ +---------+ +---------+ +---------+             |
|                           |                                                              |
|                           | Appointment queue                                            |
|                           | [Search....................] [Status v] [Apply] [Reset]     |
|                           | ------------------------------------------------------------ |
|                           | [████████████████████████████████████████████████████████]   |
|                           | [████████████████████████████████████████████████████████]   |
|                           | [████████████████████████████████████████████████████████]   |
|                           | ------------------------------------------------------------ |
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Left nav shell, top header, KPI cards, queue filters.
- Skeleton rows inside queue frame only.

Trigger -> transition notes:

- Data returned with rows -> `state-06-dashboard-populated`.
- Data returned empty -> `state-05-dashboard-empty-first-login`.
- Data request fails -> `state-09-dashboard-queue-error-inline`.

Permission/policy constraints:

- If `workspace:read` fails, redirect path to `state-10-workspace-permission-denied`.
