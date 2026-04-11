# State 20: Payment Sync Failure

Route and locale context:

- Route: `/[locale]/dental/billing/waiting`
- Auth boundary: signed-in + `billing:sync`

## Visual direction

- Error appears inline at row and in side diagnostics panel.
- Keep stage unchanged visibly to avoid false completion assumptions.
- Present retry count and next automatic retry ETA.
- Mobile expands failed row with diagnostics accordion.
- Avoid blocking entire board due to one row failure.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Waiting Payment Board                                                                    |
|------------------------------------------------------------------------------------------|
| Visit D14 | INV-2026-9911 | Amount 2,450 | Payment PENDING                               |
| ! Sync failed: Cashier endpoint unavailable (HTTP 503)                                   |
| Retry: 2/5  Next retry: 10:47  Correlation: PAY-SYNC-44D2                                |
| [Retry now] [Open diagnostics] [Keep waiting]                                             |
|------------------------------------------------------------------------------------------|
| Other rows continue normal operations                                                     |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Retry now` executes immediate sync job.
- `Open diagnostics` opens modal with payload hash and audit trail.

Trigger -> transition notes:

- Retry success with paid -> `state-21-payment-paid-auto-complete`.
- Max retries exceeded -> escalated operational alert row.
