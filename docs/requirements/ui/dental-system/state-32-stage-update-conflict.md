# State 32: Stage Update Conflict (Concurrency)

Route and locale context:

- Route: `PATCH /[locale]/dental/visits/:id/transition`
- Auth boundary: signed-in + `workflow:transition`

## Visual direction

- Conflict banner appears near action region with latest-state preview.
- Encourage reload-and-review before retrying transition.
- Show who updated last and when.
- Mobile pins conflict card above sticky action controls.
- Use semantic warning style to avoid accidental repeated submit.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Conflict detected                                                                         |
| This visit was updated by another user while you were editing.                           |
| Last update: 10:16 by nurse.b                                                            |
| Your attempted transition: ready-for-treatment -> in-treatment                           |
| Current stage now: waiting-payment                                                       |
|------------------------------------------------------------------------------------------|
| [Reload latest state] [View timeline diff]                                               |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Reload latest state` refreshes visit detail and disables stale form.
- `View timeline diff` opens side-by-side change drawer.

Trigger -> transition notes:

- After reload, user can initiate only currently allowed transitions.
