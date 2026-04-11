# State 35: Dentist Assignment Required

Route and locale context:

- Route: `PATCH /[locale]/dental/visits/:id/transition`
- Auth boundary: signed-in + `workflow:transition`

## Visual direction

- Guard modal focused on assignment completion before treatment start.
- Include quick selector for available dentists to reduce extra navigation.
- Keep visit in ready-for-treatment stage until assignment confirmed.
- Mobile uses full-width selector and sticky confirm button.
- Use warning emphasis with actionable controls.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| [Backdrop]                                                                               |
|            +------------------------------------------------------------------+          |
|            | Cannot start treatment yet                                        |          |
|            | Dentist assignment is required.                                   |          |
|            | Current stage: ready-for-treatment                                |          |
|            | Assign dentist [Dr. Narin ▼]                                      |          |
|            |                                                                  |          |
|            | [Assign and continue] [Cancel]                                    |          |
|            +------------------------------------------------------------------+          |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Assign and continue` writes assignment then retries transition.
- `Cancel` keeps current stage unchanged.

Trigger -> transition notes:

- Assignment saved -> transition to in-treatment and open treatment form.
