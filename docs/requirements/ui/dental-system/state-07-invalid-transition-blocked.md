# State 07: Invalid Transition Blocked

Route and locale context:

- Route: `PATCH /[locale]/dental/visits/:id/transition`
- Auth boundary: signed-in + transition permission

## Visual direction

- Inline error panel near stage action bar.
- Show allowed transitions as actionable chips.
- Avoid modal interruption for recoverable misuse.
- Mobile pins the error panel above sticky action footer.
- Keep language explicit and non-technical.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Visit D18 / Stage: registered                                                            |
|------------------------------------------------------------------------------------------|
| Attempted action: Move directly to completed                                             |
| Error: INVALID_STAGE_TRANSITION                                                          |
| Allowed now: [check-in] [cancel]                                                        |
|------------------------------------------------------------------------------------------|
| Timeline                                                                                 |
| 09:03 created by registration sync                                                       |
| 09:10 invalid transition rejected (user: assistant01)                                    |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- Clicking an allowed transition chip launches valid transition flow.
- Error panel is announced to screen readers via polite alert region.

Trigger -> transition notes:

- User selects `check-in` -> `state-08-screening-form-entry`.
- User selects `cancel` -> cancelled terminal state summary.
