# State 16: Requisition Self-Approval Blocked

Route and locale context:

- Route: `PATCH /[locale]/dental/requisitions/:id/transition`
- Auth boundary: signed-in + requisition transition permission

## Visual direction

- Guard violation is modal and explicit to prevent accidental override.
- Include requester and current user identity side by side.
- Provide actionable reroute: assign another approver.
- Mobile keeps same content in bottom sheet with sticky actions.
- Error language mirrors API guard semantics.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| [Backdrop]                                                                               |
|            +------------------------------------------------------------------+          |
|            | Approval blocked                                                  |          |
|            | STATE_GUARD_VIOLATION: requester cannot approve own requisition   |          |
|            | Requester: nurse.a                                                 |          |
|            | You are signed in as: nurse.a                                      |          |
|            |                                                                  |          |
|            | [Select another approver] [Close]                                 |          |
|            +------------------------------------------------------------------+          |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Select another approver` opens user picker drawer filtered by allowed roles.
- Action is logged in requisition timeline.

Trigger -> transition notes:

- New approver assigned and approves -> `state-18-requisition-received-success` path continuation.
