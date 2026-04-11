# State 13: Usage Deduction Failed

Route and locale context:

- Route: `/[locale]/dental/usage`
- Auth boundary: signed-in + `stock:write`

## Visual direction

- Failure is shown at row level with expandable diagnostics.
- Keep remaining successful rows visible to avoid context loss.
- Offer retry and adjust quantity actions inline.
- Mobile displays each usage as card with status badge and actions.
- Prioritize clarity over density for error resolution.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Usage Deduction Queue                                                                    |
|------------------------------------------------------------------------------------------|
| Ref        Item                    Requested   Available   Status         Actions         |
| POST-991   Lidocaine 2%            5 vial      2 vial      FAILED         [Retry] [Edit] |
|            Error: INSUFFICIENT_STOCK (missing 3 vial)                                   |
| POST-992   Composite Resin A2      1 unit      14 unit     DEDUCTED       [View]         |
|------------------------------------------------------------------------------------------|
| Drawer: stock movement details + last sync response                                      |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Retry` reruns deduction using current stock snapshot.
- `Edit` opens quantity correction modal with reason field.

Trigger -> transition notes:

- Retry success -> `state-14-usage-deducted-success`.
- Persistent failure -> remains failed with updated timestamp.
