# State 06: Dashboard Populated

Route and locale context:

- Route: `/[locale]/workspace`
- Auth boundary: signed-in + policy-gated

## Visual direction

- Data-dense but scannable queue with sticky header-ready table structure.
- KPI row uses semantic emphasis to show operational status differences.
- Keep visual hierarchy: header -> filters -> data grid -> side context.
- Mobile collapses nav and keeps top-right profile trigger persistent.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| LOGO                             Clinical Workspace                       [Dr. Narin v]   |
|------------------------------------------------------------------------------------------|
| NAV                        | Overview cards                                               |
| - Overview (active)        | [Total 24] [In progress 6] [Ready 8] [Completed 10]         |
| - Queue                    |                                                              |
| - Components               | Appointment queue                                            |
| - Admin                    | [Search: "Somchai"] [Status: In progress v] [Apply] [Reset] |
|                            | ------------------------------------------------------------ |
|                            | Appt   Patient        HN      Service     Dentist   Start S  |
|                            | D-301  Somchai Jaidee HN0008  Cleaning    Dr. Mook  09:00 IP |
|                            | D-302  Anna Chai      HN0012  Whitening   Dr. Narin 09:15 RD |
|                            | D-303  Preecha K.     HN0044  Filling     Dr. Mook  09:30 SC |
|                            | D-304  Mali N.        HN0078  X-Ray       Dr. Tonn  09:45 CP |
|                            | ------------------------------------------------------------ |
|                            | Side context: upcoming shifts / announcements (future slot)  |
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Queue table columns match component contract requirements.
- Search + status filter submit updates turbo frame only.
- Top-right profile trigger opens dropdown (`state-07`).

Trigger -> transition notes:

- Open profile menu -> `state-07-profile-dropdown-open`.
- Apply filters with no rows -> `state-05-dashboard-empty-first-login`.
- Queue fetch fails -> `state-09-dashboard-queue-error-inline`.

Permission/policy constraints:

- Admin nav appears only when principal has `admin:access`.
