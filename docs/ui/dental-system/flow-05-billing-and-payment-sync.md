# Flow 05: Billing and Payment Sync

## Flow scope

- Send chargeable visit to cashier and reconcile payment until completed.

## ASCII flow

```txt
[/[locale]/dental/billing/waiting]
  -> [Visit in-treatment with payable items]
      -> [Send to cashier]
      -> [waiting-payment + invoice id]
  -> [Sync payment]
      -> paid -> [auto-complete visit]
      -> provider unavailable -> [sync error inline + retry queue]
      -> partial payment -> [remain waiting-payment]
```

## Notes

- Waiting-payment board supports polling refresh and manual retry.
- Sync failures never mutate stage incorrectly.
