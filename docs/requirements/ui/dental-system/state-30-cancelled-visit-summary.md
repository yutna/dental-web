# State 30: Cancelled Visit Summary

Route and locale context:

- Route: `/[locale]/dental/visits/:id`
- Auth boundary: signed-in + `workflow:read`

## Visual direction

- Terminal cancellation summary with reason and actor details.
- Clearly indicate no further clinical actions are available.
- Keep ability to create a new visit for same patient quickly.
- Mobile prioritizes reason and next actions at top.
- Neutral warning tone, not punitive.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Visit D33 / HN0048                                                           CANCELLED    |
|------------------------------------------------------------------------------------------|
| Cancelled by: assistant01 at 09:18                                                      |
| Reason: Patient requested reschedule                                                     |
| Queue status: cancelled                                                                  |
|------------------------------------------------------------------------------------------|
| [Create new visit] [Back to queue] [View audit trail]                                   |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Create new visit` pre-fills patient identity from canceled visit.
- `View audit trail` opens immutable action log drawer.

Trigger -> transition notes:

- New visit created -> `state-27-check-in-created` flow path.
