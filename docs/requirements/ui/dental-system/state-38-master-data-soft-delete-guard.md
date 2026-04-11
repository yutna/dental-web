# State 38: Master Data Soft-Delete Guard

Route and locale context:

- Route: `DELETE /[locale]/admin/dental/master_data/:resource/:id`
- Auth boundary: signed-in + `admin:dental:write`

## Visual direction

- Blocking confirmation with explicit hard-delete prohibition.
- Show reference count and dependent entities to justify restriction.
- Provide safe alternative action: deactivate.
- Mobile keeps destructive action separated from safe action.
- Use semantic warning and error accents carefully.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| [Backdrop]                                                                               |
|            +------------------------------------------------------------------+          |
|            | Cannot delete PROC-101                                            |          |
|            | This record is referenced by 88 treatment records.                |          |
|            | Hard delete is blocked by policy.                                 |          |
|            |                                                                  |          |
|            | [Deactivate instead] [Cancel]                                     |          |
|            +------------------------------------------------------------------+          |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Deactivate instead` applies soft-delete and records audit event.
- `Cancel` returns to master-data list without changes.

Trigger -> transition notes:

- Successful deactivation returns to `state-23-admin-master-data-crud` with inactive badge.
