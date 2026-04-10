# State 14: Usage Deducted Success

Route and locale context:

- Route: `/[locale]/dental/usage`
- Auth boundary: signed-in + `stock:read`

## Visual direction

- Success feedback should be quiet and non-disruptive.
- Show status, deducted time, and movement reference in one row.
- Keep audit link nearby for traceability.
- Mobile keeps concise status chips and collapsible detail.
- Avoid modal interruptions for successful operations.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Usage Deduction Queue                                                                    |
|------------------------------------------------------------------------------------------|
| Ref        Item                    Qty   Status      Deducted at        Movement Ref      |
| POST-992   Composite Resin A2      1     DEDUCTED    10:22:14           MOV-OUT-8871      |
| POST-993   Gauze Pack              2     DEDUCTED    10:22:16           MOV-OUT-8872      |
|------------------------------------------------------------------------------------------|
| Toast: "2 usage records deducted successfully"                                           |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Movement Ref` opens stock movement drawer.
- Optional bulk export is available for audit roles.

Trigger -> transition notes:

- Source clinical post voided -> compensation flow and pending state reopen.
