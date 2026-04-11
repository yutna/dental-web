# State 12: Medication Allergy Warning

Route and locale context:

- Route: `/[locale]/dental/visits/:id/clinical?tab=medication`
- Auth boundary: signed-in + `clinical:write`

## Visual direction

- Blocking safety modal with clear reason and required override flow.
- Present known allergy details in compact card style.
- Require explicit override reason for allowed roles.
- Mobile keeps large touch targets for safe decisions.
- Tokenized semantic danger colors with high contrast.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| [Backdrop]                                                                               |
|            +------------------------------------------------------------------+          |
|            | Allergy conflict detected                                         |          |
|            | Patient allergy: Penicillin (severe rash)                         |          |
|            | Ordered medication: Amoxicillin 500mg                             |          |
|            |                                                                  |          |
|            | This order is blocked unless authorized override is provided.     |          |
|            | Override reason [...............................................] |          |
|            |                                                                  |          |
|            | [Remove medication] [Request override]                            |          |
|            +------------------------------------------------------------------+          |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Remove medication` clears row and keeps form editable.
- `Request override` routes to approval workflow for allowed roles only.

Trigger -> transition notes:

- Override approved -> returns to treatment with warning badge.
- Override denied -> stays blocked and logs audit event.
