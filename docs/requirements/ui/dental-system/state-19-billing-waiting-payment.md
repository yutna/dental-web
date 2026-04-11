# State 19: Billing Waiting Payment Board

Route and locale context:

- Route: `/[locale]/dental/billing/waiting`
- Auth boundary: signed-in + `billing:read`

## Visual direction

- Operational board style with status-first hierarchy.
- Keep invoice and visit linkage in same row.
- Polling status indicator is subtle and non-distracting.
- Mobile uses two-tier cards: patient summary + payment details.
- Semantic tokens distinguish pending vs paid vs failed sync.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Waiting Payment Board                                             Auto-refresh: 30s      |
|------------------------------------------------------------------------------------------|
| Visit    Patient         Invoice ID      Amount   Payment     Last sync   Actions         |
| D14      Preecha N.      INV-2026-9911   2,450    PENDING     10:40       [Sync now]      |
| D18      Mali C.         INV-2026-9912   1,200    PARTIAL     10:38       [Sync now]      |
| D21      Anna P.         INV-2026-9913     800    PAID        10:41       [View visit]    |
|------------------------------------------------------------------------------------------|
| KPI: Pending 7 | Partial 2 | Paid awaiting close 1                                       |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Sync now` triggers callback/poll reconciliation for selected invoice.
- `View visit` opens workflow detail and completion timeline.

Trigger -> transition notes:

- Sync paid -> `state-21-payment-paid-auto-complete`.
- Sync timeout/error -> `state-20-payment-sync-failure`.
