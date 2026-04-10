# State 21: Payment Paid Auto Complete

Route and locale context:

- Route: `/[locale]/dental/visits/:id`
- Auth boundary: signed-in + `workflow:read`

## Visual direction

- Completion confirmation is compact and celebratory but clinical-safe.
- Timeline emphasizes automatic system transition from payment event.
- Keep print and follow-up actions immediately available.
- Mobile pins next actions at bottom for quick throughput.
- Success styling uses semantic readiness token.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Visit D14 / Preecha N.                                                    COMPLETED       |
|------------------------------------------------------------------------------------------|
| Payment status: PAID (from cashier sync 10:49)                                           |
| Invoice: INV-2026-9911   Amount: 2,450                                                   |
|------------------------------------------------------------------------------------------|
| Timeline                                                                                 |
| 10:31 in-treatment                                                                        |
| 10:36 sent to cashier -> waiting-payment                                                  |
| 10:49 payment paid sync received                                                          |
| 10:49 auto-transition -> completed                                                        |
|------------------------------------------------------------------------------------------|
| [Print treatment summary] [Create follow-up appointment] [Back to queue]                 |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Print treatment summary` opens print route for this visit.
- Follow-up appointment action pre-fills patient and dentist context.

Trigger -> transition notes:

- Print permission denied -> `state-26-print-forbidden`.
