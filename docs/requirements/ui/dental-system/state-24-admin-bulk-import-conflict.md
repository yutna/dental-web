# State 24: Admin Bulk Import Conflict

Route and locale context:

- Route: `/[locale]/admin/dental/master_data/imports/:id`
- Auth boundary: signed-in + `admin:dental:bulk_update`

## Visual direction

- Conflict report page with clear pass/fail partition.
- Keep import job summary at top and row-level remediation below.
- Offer deterministic actions: reload row, overwrite (if allowed), skip.
- Mobile shows conflicts as expandable cards.
- Avoid ambiguous conflict messaging.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Bulk Import Result: JOB-7781                                                             |
|------------------------------------------------------------------------------------------|
| Total rows 120 | Applied 109 | Conflicts 11 | Failed 0                                   |
|------------------------------------------------------------------------------------------|
| Conflict rows                                                                           |
| Row 32  Code PROC-101  Reason: stale updated_at                                          |
| Current value: OPD 1200 / Imported value: OPD 1250                                       |
| Actions: [Reload current] [Overwrite with approval] [Skip]                               |
|------------------------------------------------------------------------------------------|
| [Download conflict CSV] [Retry unresolved rows]                                          |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Overwrite with approval` requires maker-checker permission.
- `Retry unresolved rows` creates follow-up import job with only conflicts.

Trigger -> transition notes:

- All conflicts resolved -> return to `state-23-admin-master-data-crud` with success summary.
