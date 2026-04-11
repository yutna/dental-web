# Flow 03: Usage and Stock Deduction

## Flow scope

- Deduct medication/supply usage, handle failures, rollback after void.

## ASCII flow

```txt
[/[locale]/dental/usage]
  -> [usage status = pending_deduct]
      -> [Run deduction]
          -> stock sufficient -> [status deducted + movement out]
          -> insufficient stock -> [status failed + deduct_error]
  -> [Clinical post voided]
      -> [Compensating reverse movement]
      -> [usage returns pending_deduct or voided by policy]
```

## Notes

- Rows update inline; no blocking full-page loader.
- Failure branch surfaces retry action with clear stock deficit detail.
