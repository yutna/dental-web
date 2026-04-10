# State 18: Requisition Received Success

Route and locale context:

- Route: `/[locale]/dental/requisitions/:id`
- Auth boundary: signed-in + `requisition:receive`

## Visual direction

- Confirmation summary page emphasizes stock-in outcomes.
- Show before/after stock balances for transparency.
- Timeline confirmation appears immediately below summary.
- Mobile presents item rows as collapsible accordions.
- Keep success messaging concise and auditable.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Requisition RQ-2098                                                           RECEIVED   |
|------------------------------------------------------------------------------------------|
| Receiver: pharmacist.k   Received at: 10:44   Stock movement refs: MOV-IN-7811..7813    |
|------------------------------------------------------------------------------------------|
| Item                    Qty received   Stock before   Stock after                         |
| Lidocaine 2%            10             12             22                                  |
| Gauze Pack              30             80             110                                 |
| Needle 27G              50             140            190                                 |
|------------------------------------------------------------------------------------------|
| Timeline: pending -> approved -> dispensed -> received                                   |
| [Back to requisitions] [Print receive note]                                              |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Print receive note` routes to print subsystem with role checks.
- Stock movement references open drawer for audit inspection.

Trigger -> transition notes:

- Print not allowed by policy -> `state-26-print-forbidden`.
