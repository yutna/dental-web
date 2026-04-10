# Flow 06: Admin Master Data Governance

## Flow scope

- Admin dashboard, master data CRUD, maker-checker, and bulk conflict handling.

## ASCII flow

```txt
[/[locale]/admin]
  -> [Open dental master data console]
      -> [List/search/filter resources]
      -> [Create/Edit item]
          -> sensitive field change -> [Pending approval]
      -> [Deactivate referenced item]
          -> hard delete blocked -> [Deactivation only]
      -> [Bulk import CSV]
          -> stale row version -> [Optimistic lock conflict report]
          -> valid rows -> [Applied + audit events]
```

## Notes

- Audit trail panel is first-class in admin layout.
- Mobile uses stacked cards with expandable row actions.
