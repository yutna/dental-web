# State 15: Requisition List Populated

Route and locale context:

- Route: `/[locale]/dental/requisitions`
- Auth boundary: signed-in + `requisition:read`

## Visual direction

- Keep lifecycle visibility with clear status progression chips.
- Show requester and approver context in grid for guard awareness.
- Actions adapt by status and role.
- Mobile uses segmented tabs by status plus cards.
- Keep filters sticky for operational throughput.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Requisitions                                                      [New requisition]      |
|------------------------------------------------------------------------------------------|
| Filter: [Pending ▼] [Date today ▼] [Requester ▼]                                         |
|------------------------------------------------------------------------------------------|
| Req#      Requester     Approver     Status      Items  Updated     Actions              |
| RQ-2101   nurse.a       -            PENDING     4      10:05       [Approve] [Cancel]  |
| RQ-2100   assistant.b   head.c       APPROVED    2      09:48       [Dispense]          |
| RQ-2098   nurse.a       head.c       DISPENSED   3      09:10       [Receive]           |
|------------------------------------------------------------------------------------------|
| Side panel: transition policy and activity timeline                                      |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- Approve, Dispense, Receive open focused confirmation overlays.
- Clicking row opens detail drawer with line items and stock source.

Trigger -> transition notes:

- Self-approval attempt -> `state-16-requisition-self-approval-blocked`.
- Dispense without number -> `state-17-requisition-dispense-guard`.
