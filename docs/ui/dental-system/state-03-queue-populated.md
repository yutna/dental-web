# State 03: Queue Populated

Route and locale context:

- Route: `/[locale]/workspace`
- Auth boundary: signed-in + `workspace:read`

## Visual direction

- Data-dense table with breathable row height and sticky-ready headers.
- Queue status chips use semantic status tones, not raw color literals.
- Quick stage actions remain visible but secondary to patient identity.
- Mobile uses card rows with expandable details.
- Retain existing workspace tone from current app layout.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Workspace / Daily Queue                                       [Profile ▼]         |
|------------------------------------------------------------------------------------------|
| [Total 42] [Screening 8] [In treatment 14] [Waiting payment 6]                          |
|------------------------------------------------------------------------------------------|
| Search [HN0008................] Status [In progress ▼] [Apply] [Reset]                  |
|------------------------------------------------------------------------------------------|
| Q#   Patient           MRN      Service        Dentist      Start   Stage   Actions      |
| D12  Somchai Jaidee    HN0008   Scaling        Dr. Mook     09:00   SCRN    [Start Tx]  |
| D13  Mali Chai         HN0014   Filling        Dr. Narin    09:10   READY   [Start Tx]  |
| D14  Preecha N.        HN0045   Extraction     Dr. Arun     09:20   IN-TX   [Cashier]   |
| D15  Anya P.           HN0060   Whitening      Dr. Mook     09:30   WAITPAY [Sync]      |
|------------------------------------------------------------------------------------------|
| Timeline panel: latest transitions + guard alerts                                        |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Start Tx` opens treatment panel and stage transition confirm.
- `Cashier` opens billing send modal.
- `Sync` triggers payment sync on waiting-payment rows.

Trigger -> transition notes:

- Transition blocked by guard -> `state-06-transition-guard-vitals`.
- Invalid stage jump attempt -> `state-07-invalid-transition-blocked`.
- Cashier sync failure -> `state-20-payment-sync-failure`.
