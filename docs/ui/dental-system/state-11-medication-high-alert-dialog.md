# State 11: Medication High-Alert Dialog

Route and locale context:

- Route: `/[locale]/dental/visits/:id/clinical?tab=medication`
- Auth boundary: signed-in + `clinical:write`

## Visual direction

- High-salience warning overlay with concise risk details.
- Keep dosage and patient identifiers visible in modal context.
- Primary action requires explicit confirmation phrasing.
- Mobile uses full-width bottom sheet with sticky confirm button.
- Avoid alarming color overload; use semantic warning emphasis.

## ASCII wireframe

```txt
Background: Medication form with selected item Diazepam 5mg

+------------------------------------------------------------------------------------------+
| [Backdrop]                                                                               |
|            +------------------------------------------------------------------+          |
|            | High-alert medication                                            |          |
|            | Item: Diazepam 5mg (category: High-alert)                        |          |
|            | Patient: HN0008 Somchai J.                                       |          |
|            | Dose: 1 tab nightly x 5 days                                     |          |
|            |                                                                  |          |
|            | Confirm this order after double-checking indication and dose.     |          |
|            |                                                                  |          |
|            | [Cancel] [Confirm and continue]                                   |          |
|            +------------------------------------------------------------------+          |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Confirm and continue` writes medication usage and starts deduction flow.
- `Cancel` returns focus to medication row.

Trigger -> transition notes:

- Allergy conflict detected after confirm -> `state-12-medication-allergy-warning`.
- No conflict -> usage list refresh with pending_deduct row.
