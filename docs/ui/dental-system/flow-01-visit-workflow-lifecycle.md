# Flow 01: Visit Workflow Lifecycle

## Flow scope

- Queue intake through completion/refer/cancel.
- Includes guard failures and invalid transition branch.

## ASCII flow

```txt
[/[locale]/workspace queue]
  -> [Check-in]
      -> [registered -> checked-in]
      -> [Start screening]
          -> guard pass -> [screening]
          -> guard fail (vitals missing) -> [Blocked dialog + remain screening]
      -> [Screening complete]
          -> [ready-for-treatment]
      -> [Start treatment]
          -> dentist assigned? no -> [Guard error]
          -> yes -> [in-treatment]
      -> [Choose exit]
          -> send to cashier -> [waiting-payment]
          -> no-charge complete -> [completed]
          -> refer out -> [referred-out]
          -> cancel (pre-treatment stages) -> [cancelled]
      -> [Invalid transition attempt]
          -> [INVALID_STAGE_TRANSITION + allowed transitions]
```

## Notes

- Stage transitions are policy-gated and append timeline records.
- Mobile keeps stage actions as sticky footer action bar for one-handed flow.
