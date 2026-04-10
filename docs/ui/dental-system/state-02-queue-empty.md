# State 02: Queue Empty

Route and locale context:

- Route: `/[locale]/workspace`
- Auth boundary: signed-in + `workspace:read`

## Visual direction

- Preserve main grid shell so users do not lose orientation.
- Empty area uses clear next actions and no dead-end language.
- Keep one primary CTA and one secondary CTA.
- Mobile centers empty card with full-width actions.
- Tokenized semantic colors only.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Workspace                                                        [User ▼]          |
|------------------------------------------------------------------------------------------|
| KPI: [Total 0] [In progress 0] [Ready 0] [Waiting payment 0]                            |
|------------------------------------------------------------------------------------------|
| Queue today                                                                              |
| Search [....................]  Status [All ▼]  [Apply] [Reset]                          |
|------------------------------------------------------------------------------------------|
|                                  No visits in queue                                      |
|                         Start from check-in or import appointments                       |
|                           [Create Check-in]    [Sync Appointments]                       |
|------------------------------------------------------------------------------------------|
| Side context: tips for first setup and role-based next steps                             |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Create Check-in` opens check-in form drawer.
- `Sync Appointments` triggers integration sync with inline progress.

Trigger -> transition notes:

- Successful sync with entries -> `state-03-queue-populated`.
- Permission denied for sync -> `state-05-workflow-permission-denied`.
