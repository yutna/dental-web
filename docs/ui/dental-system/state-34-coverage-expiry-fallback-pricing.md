# State 34: Coverage Expiry Fallback Pricing

Route and locale context:

- Route: `/[locale]/dental/visits/:id/clinical?tab=treatment`
- Auth boundary: signed-in + `clinical:write`

## Visual direction

- Pricing row communicates fallback source without blocking treatment flow.
- Show expired coverage and active fallback price side-by-side.
- Include tooltip/inline link to coverage history for auditability.
- Mobile displays compact source badge under each price line.
- Keep copy clear and non-technical for chairside speed.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Treatment pricing preview                                                                 |
|------------------------------------------------------------------------------------------|
| Item: Composite Filling                                                                   |
| Coverage status: UCS (expired on 2026-03-31)                                             |
| Applied price source: Master OPD fallback                                                 |
| Price applied: 1,200                                                                      |
| Copay: 0                                                                                  |
| [View coverage history]                                                                   |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `View coverage history` opens read-only drawer with effective windows.
- Price line is locked to snapshot once sent to cashier.

Trigger -> transition notes:

- If active coverage exists on re-evaluation, source label updates accordingly.
