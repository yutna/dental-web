# Flow 04: Requisition Lifecycle

## Flow scope

- Pending -> approved -> dispensed -> received, plus guarded rejection branches.

## ASCII flow

```txt
[/[locale]/dental/requisitions]
  -> [Create requisition -> pending]
  -> [Approve]
      -> approver == requester -> [STATE_GUARD_VIOLATION]
      -> approver != requester -> [approved]
  -> [Dispense]
      -> missing dispense number -> [STATE_GUARD_VIOLATION]
      -> valid -> [dispensed]
  -> [Receive]
      -> role allowed -> [received + stock in]
      -> role denied -> [forbidden]
  -> [Cancel path]
      -> pending/approved + reason -> [cancelled]
```

## Notes

- Transition actions are exposed as row actions + confirmation overlays.
- Timeline pane tracks actor, time, and reason for each transition.
