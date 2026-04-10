# State 33: Appointment Sync Creates Registered Queue

Route and locale context:

- Route: `/[locale]/workspace`
- Auth boundary: signed-in + `workflow:write`

## Visual direction

- Inline sync result panel embedded above queue table.
- Show created/skipped/error counts for transparency.
- Keep queue visible under result card to continue flow seamlessly.
- Mobile collapses details into expandable summary.
- Use semantic informational styling with concise copy.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Queue today                                                                              |
|------------------------------------------------------------------------------------------|
| Appointment sync completed                                                                |
| Created registered visits: 12   Skipped duplicates: 3   Errors: 1                        |
| Error detail: APPT-884 missing active VN                                                  |
| [View sync log] [Retry failed only]                                                       |
|------------------------------------------------------------------------------------------|
| Newly created rows (registered) appear at top of queue                                   |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `View sync log` opens detailed integration report drawer.
- `Retry failed only` retriggers filtered sync.

Trigger -> transition notes:

- Successful retries append additional registered rows without duplicates.
