# State 10: Procedure Validation Error

Route and locale context:

- Route: `/[locale]/dental/visits/:id/clinical?tab=treatment`
- Auth boundary: signed-in + `clinical:write`

## Visual direction

- Keep user in context with inline row-level error highlights.
- Error summary at top links to invalid rows.
- No modal for field-level validation to reduce friction.
- Mobile collapses summary into sticky banner with anchor links.
- Contrast and focus styling ensure rapid correction.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Error: 2 validation issues in treatment form                                             |
| - Row 1: surface is required for selected procedure                                      |
| - Row 2: tooth is required for selected procedure                                        |
|------------------------------------------------------------------------------------------|
| Row | Procedure              Tooth       Surface     Qty   Status                         |
| 01  | Composite Filling      26          [ -- ]      1     ! Surface required             |
| 02  | Extraction             [ -- ]      N/A         1     ! Tooth required               |
|------------------------------------------------------------------------------------------|
| [Fix errors] [Save draft]                                                                |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- Clicking error item focuses corresponding cell.
- Save disabled until blocking errors resolved.

Trigger -> transition notes:

- All errors resolved -> returns to `state-09-treatment-form-in-progress` saved state.
