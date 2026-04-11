# State 28: Room Assignment Unavailable

Route and locale context:

- Route: `PATCH /[locale]/dental/visits/:id/transition`
- Auth boundary: signed-in + `workflow:transition`

## Visual direction

- Guard-failure dialog focused on operational recovery.
- Show nearest available room time to reduce dead-end behavior.
- Keep non-blocking path to keep visit in checked-in stage.
- Mobile uses bottom sheet with large retry button.
- Visual emphasis is warning, not error panic.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| [Backdrop]                                                                               |
|            +------------------------------------------------------------------+          |
|            | Cannot start screening now                                        |          |
|            | No examination room is currently available.                        |          |
|            | Next expected slot: Room 3 at 10:25                               |          |
|            | Current stage remains: checked-in                                  |          |
|            |                                                                  |          |
|            | [Retry room check] [Return to queue]                               |          |
|            +------------------------------------------------------------------+          |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Retry room check` re-evaluates room availability.
- `Return to queue` keeps patient in checked-in lane.

Trigger -> transition notes:

- Room becomes available -> `state-08-screening-form-entry`.
