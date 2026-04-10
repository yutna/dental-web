# State 17: Requisition Dispense Guard

Route and locale context:

- Route: `PATCH /[locale]/dental/requisitions/:id/transition`
- Auth boundary: signed-in + `requisition:dispense`

## Visual direction

- Inline form modal requests dispense number before transition.
- Missing value error appears directly under field.
- Keep line items visible for pharmacist verification.
- Mobile uses larger field and one-tap barcode scan action.
- Maintain semantic warning, not destructive tone.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| [Backdrop]                                                                               |
|            +------------------------------------------------------------------+          |
|            | Dispense requisition RQ-2100                                      |          |
|            | Items: 2                                                          |          |
|            | Dispense number [________________________]                         |          |
|            | ! STATE_GUARD_VIOLATION: dispense number is required              |          |
|            |                                                                  |          |
|            | [Cancel] [Confirm dispense]                                       |          |
|            +------------------------------------------------------------------+          |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Confirm dispense` disabled until valid dispense number entered.
- Optional scan button can populate dispense number.

Trigger -> transition notes:

- Valid number submitted -> requisition becomes `dispensed`.
- Invalid -> stays approved with guard message.
