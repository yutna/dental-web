# Flow 02: Clinical Forms and History

## Flow scope

- Screening, procedure, medication, and cumulative history workflow.
- Includes validation failures and safety warnings.

## ASCII flow

```txt
[/[locale]/dental/visits/:id/clinical]
  -> [Open screening tab]
      -> [Fill vitals] -> [Save clinical post]
  -> [Open treatment tab]
      -> [Procedure form]
          -> missing tooth/surface/root/piece -> [Validation error]
          -> valid -> [Procedure post saved]
      -> [Medication usage form]
          -> high-alert item -> [Warning modal]
          -> allergy detected -> [Blocked warning modal]
          -> confirmed valid -> [Usage post + deduction pending]
  -> [Open cumulative history drawer]
      -> [Tooth timeline + previous visits + image records]
```

## Notes

- Forms are schema-validated before persistence.
- Drawer and tab switches preserve locale and active visit context.
