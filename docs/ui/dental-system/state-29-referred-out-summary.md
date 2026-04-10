# State 29: Referred-Out Summary

Route and locale context:

- Route: `/[locale]/dental/visits/:id`
- Auth boundary: signed-in + `workflow:read`

## Visual direction

- Terminal summary state with emphasis on referral destination and notes.
- Keep timeline and referral document actions in one place.
- Avoid showing treatment action buttons once terminal state is reached.
- Mobile stacks referral details above timeline.
- Semantic info styling for handoff clarity.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Visit D31 / HN0032                                                         REFERRED-OUT  |
|------------------------------------------------------------------------------------------|
| Referral destination: Oral Surgery Center                                                |
| Referral reason: Impacted molar requiring specialist extraction                          |
| Referred by: Dr. Narin at 11:02                                                          |
|------------------------------------------------------------------------------------------|
| Timeline: in-treatment -> referred-out                                                   |
| [Print referral letter] [Back to queue]                                                  |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Print referral letter` opens print route with referral template.
- `Back to queue` returns to daily operations view.

Trigger -> transition notes:

- Unauthorized print access -> `state-26-print-forbidden`.
