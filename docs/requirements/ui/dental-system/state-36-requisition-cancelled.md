# State 36: Requisition Cancelled

Route and locale context:

- Route: `/[locale]/dental/requisitions/:id`
- Auth boundary: signed-in + `requisition:read`

## Visual direction

- Terminal requisition card with cancellation reason and actor.
- Disable dispense/receive actions and show why they are unavailable.
- Keep audit and recreate actions visible for smooth continuation.
- Mobile collapses metadata into compact chips.
- Neutral warning styling.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Requisition RQ-2110                                                         CANCELLED     |
|------------------------------------------------------------------------------------------|
| Cancelled by: head.c at 11:12                                                           |
| Reason: Stock request no longer needed                                                   |
| Transition lock: dispense and receive are disabled                                        |
|------------------------------------------------------------------------------------------|
| [Create similar requisition] [Back to requisition list] [View audit trail]              |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Create similar requisition` clones line items into new pending draft.
- Audit trail drawer shows full transition sequence.

Trigger -> transition notes:

- New requisition draft created -> returns to pending flow in state-15.
