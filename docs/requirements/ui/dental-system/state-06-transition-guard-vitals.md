# State 06: Transition Guard - Vitals Missing

Route and locale context:

- Route: `/[locale]/dental/visits/:id`
- Auth boundary: signed-in + transition permission

## Visual direction

- Modal overlay above active visit workspace for focused correction.
- Show exact missing fields and one-click jump to form section.
- Preserve user-entered data in background.
- Mobile uses bottom sheet variant of the same modal content.
- Layering uses semantic modal/backdrop levels.

## ASCII wireframe

```txt
Background: Visit D12 workspace (screening stage)

+------------------------------------------------------------------------------------------+
| [Backdrop]                                                                               |
|            +------------------------------------------------------------------+          |
|            | Transition blocked                                                |          |
|            | Cannot move to ready-for-treatment yet.                           |          |
|            | Missing required vitals:                                          |          |
|            | - Blood pressure                                                  |          |
|            | - Pulse                                                           |          |
|            | - Weight                                                          |          |
|            |                                                                  |          |
|            | [Go to vitals form] [Save draft] [Cancel]                        |          |
|            +------------------------------------------------------------------+          |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Go to vitals form` focuses first missing field.
- `Save draft` keeps current stage and stores partial data.

Trigger -> transition notes:

- All vitals completed and submit transition -> `state-09-treatment-form-in-progress`.
- Cancel -> returns to previous screening view.
