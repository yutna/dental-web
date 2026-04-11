# State 09: Treatment Form In Progress

Route and locale context:

- Route: `/[locale]/dental/visits/:id/clinical?tab=treatment`
- Auth boundary: signed-in + `clinical:write`

## Visual direction

- Action-oriented treatment canvas with stage actions near top-right.
- Procedure builder uses searchable selectors and compact rows.
- Timeline remains visible on side panel for context.
- Mobile switches to stepper: procedure -> medication -> summary.
- Keep visual continuity with workspace cards and border radius.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Visit D12 / Stage: in-treatment                                      [Send cashier]      |
|------------------------------------------------------------------------------------------|
| Procedure plan                                                                           |
| Item search [Composite filling.........................] [Add]                           |
|------------------------------------------------------------------------------------------|
| Row | Procedure                  Tooth   Surface   Qty  Price  Coverage  Action         |
| 01  | Composite Filling          26      O,M       1    1200   UCS       [Edit] [Void]  |
| 02  | Scaling                    16-26   All       1     800   Self-pay  [Edit] [Void]  |
|------------------------------------------------------------------------------------------|
| Notes [................................................................................] |
|------------------------------------------------------------------------------------------|
| Side panel: transition timeline + billing preview                                        |
| [Save treatment] [Complete no-charge] [Refer out]                                       |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Send cashier` opens billing confirmation modal.
- `Complete no-charge` validates payment status `not-required`.

Trigger -> transition notes:

- Missing required tooth/surface on save -> `state-10-procedure-validation-error`.
- Medication added high-alert -> `state-11-medication-high-alert-dialog`.
