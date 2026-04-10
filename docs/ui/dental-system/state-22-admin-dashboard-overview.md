# State 22: Admin Dashboard Overview

Route and locale context:

- Route: `/[locale]/admin`
- Auth boundary: signed-in + `admin:access`

## Visual direction

- Extend current admin dashboard tone: concise KPI cards + direct action buttons.
- Add dental-domain governance widgets without overwhelming initial scan.
- Desktop: 3-column KPI and activity strip; mobile: stacked cards.
- Preserve token-driven visual system from existing admin pages.
- Include quick links to high-frequency admin tasks.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Admin Dashboard / Dental Governance                                      [Workspace]     |
|------------------------------------------------------------------------------------------|
| [Master resources 128] [Pending approvals 9] [Sync warnings 2] [Active items 113]       |
|------------------------------------------------------------------------------------------|
| Quick actions: [Manage procedures] [Manage medications] [Coverage pricing] [Bulk import] |
|------------------------------------------------------------------------------------------|
| Recent audit events                                                                       |
| 10:42 coverage update pending approval (user admin01)                                    |
| 10:37 item deactivated: SUP-221 (referenced, soft-deactivate)                            |
| 10:30 sync mismatch resolved: medication profile map                                      |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- Quick action tiles navigate into master data console filtered by resource.
- Audit stream rows open detail drawer with before/after values.

Trigger -> transition notes:

- Open resource manager -> `state-23-admin-master-data-crud`.
- Bulk import with stale versions -> `state-24-admin-bulk-import-conflict`.
