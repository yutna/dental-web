# State 27: Check-in Created From Registration

Route and locale context:

- Route: `POST /[locale]/dental/visits/check_in`
- Auth boundary: signed-in + `workflow:write`

## Visual direction

- Fast confirmation pattern after check-in to keep front-desk throughput high.
- Show VN/HN identity and queue position immediately.
- Offer direct jump to screening when room is ready.
- Mobile keeps confirmation card compact with one primary CTA.
- Use semantic success color only for final confirmation line.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Check-in completed                                                                        |
|------------------------------------------------------------------------------------------|
| Patient: Somchai Jaidee    HN: HN0008    VN: VN-20260410-014                             |
| Visit ID: D24              Current stage: checked-in                                     |
| Queue position: #5                                                                       |
|------------------------------------------------------------------------------------------|
| [Start screening] [Back to queue] [Print queue ticket]                                   |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Start screening` requests room allocation and opens screening form.
- `Back to queue` returns list preserving filters.

Trigger -> transition notes:

- Room available -> `state-08-screening-form-entry`.
- Room unavailable -> `state-28-room-assignment-unavailable`.
