# State 05: Dashboard Empty First Login

Route and locale context:

- Route: `/[locale]/workspace`
- Auth boundary: signed-in + policy-gated

## Visual direction

- Keep shell and filters visible to teach structure even without data.
- Empty table cell becomes informative panel with next-step guidance.
- Maintain optimistic tone and clear action affordances.
- Avoid introducing modal; keep focus in main page flow.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| LOGO                             Clinical Workspace                       [Dr. Narin v]   |
|------------------------------------------------------------------------------------------|
| NAV                        | Overview cards (Total 0 | In progress 0 | Ready 0 | Done 0) |
| - Overview                 |                                                              |
| - Queue                    | Appointment queue                                            |
| - Components               | [Search....................] [All statuses v] [Apply]       |
|                            | ------------------------------------------------------------ |
|                            | Appointment | Patient | HN | Service | Dentist | Start | S | |
|                            |--------------------------------------------------------------|
|                            | No appointments found for current filters.                   |
|                            | Try broadening search or reset status filter.                |
|                            | [Reset filters]                                               |
|                            |--------------------------------------------------------------|
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Data grid headers still visible (contract stability).
- Empty message and reset shortcut.

Trigger -> transition notes:

- Apply broader filter / new incoming data -> `state-06-dashboard-populated`.
- Backend failure while filtering -> `state-09-dashboard-queue-error-inline`.

Permission/policy constraints:

- Same as workspace baseline (`workspace:read`).
