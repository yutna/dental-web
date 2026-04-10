# State 23: Admin Master Data CRUD

Route and locale context:

- Route: `/[locale]/admin/dental/master_data/procedure_items`
- Auth boundary: signed-in + `admin:dental:write`

## Visual direction

- Table-first management with slide-over form for create/edit.
- Keep reference integrity info visible before destructive actions.
- Include maker-checker badge for sensitive fields.
- Mobile uses list cards + full-screen edit panel.
- Ensure large datasets remain usable with filter chips.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Master Data: Procedure Items                                          [New item]         |
|------------------------------------------------------------------------------------------|
| Search [composite....]  Status [Active ▼]  Coverage [Any ▼]                              |
|------------------------------------------------------------------------------------------|
| Code      Name                    Price OPD  Coverage   Status   Ref count   Actions     |
| PROC-101  Composite Filling       1200       UCS        Active   88          [Edit]      |
| PROC-210  Extraction Simple       1600       Self-pay   Active   15          [Edit]      |
| PROC-350  Legacy Item             900        UCS        Inactive 310         [Reactivate]|
|------------------------------------------------------------------------------------------|
| Edit panel (slide-over):                                                                  |
| Name [....................................]                                               |
| OPD price [.....]  IPD price [.....]  Require approval [x]                               |
| [Save draft] [Submit for approval]                                                        |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- Deactivation is available only when policy allows and hard delete is blocked.
- Sensitive changes route to maker-checker pending state.

Trigger -> transition notes:

- Save with stale row version -> `state-24-admin-bulk-import-conflict` conflict UX pattern.
