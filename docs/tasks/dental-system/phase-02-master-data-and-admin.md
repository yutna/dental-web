# Phase 02 - Master Data, Coverage, and Admin Backend Operations

## Goal

Implement all dental master resources and admin governance workflows:

- Procedure groups/items
- Medication profiles
- Supply categories/items
- Tooth/surface/root/piece/image references
- Procedure and supply coverages with runtime-ready rules
- Admin bulk operations and approval-aware controls

## Scenarios covered

- `@must` master data soft-delete guard
- `@must` policy-protected admin operations
- `@should` coverage expiry fallback
- `@could` bulk update optimistic locking

## Scope (files/directories)

- `app/domains/dental/master_data/*`
- `app/models/*` (new dental master models)
- `app/use_cases/dental/master_data/*`
- `app/queries/dental/master_data/*`
- `app/controllers/dental/master_data/*`
- `app/views/dental/master_data/*`
- `app/policies/dental/master_data_policy.rb`
- `config/locales/en.yml`, `config/locales/th.yml`

## Implementation details carried from specifications

- Enforce unique codes and mutually exclusive copay fields.
- Enforce soft-delete semantics for referenced resources.
- Support search and pagination targets for large catalogs.
- Persist denormalized external attributes with synchronization strategy.
- Provide bulk operations:
  - CSV import/export
  - multi-row update
  - conflict handling with optimistic locking

Admin backend details (required by request):

- CRUD console for all master entities.
- Bulk change review screen with maker-checker for coverage and price-sensitive updates.
- Audit list view for admin changes.

## Risk notes and guard conditions

- Risk: accidental pricing corruption by bulk edits.
  - Guard: optimistic lock + audit + approval for high-risk fields.
- Risk: stale denormalized fields.
  - Guard: periodic sync use case and contract tests against source payload.

TODO markers to preserve in implementation:

- TODO (P02-DL-001): confirm final approval role boundaries for price overrides and requireApproval toggles.
- TODO (P02-DL-002): confirm authoritative sync cadence for hospital drug and charge-item denormalized fields.

## Decision log (phase 02)

| Decision ID | Temporary decision | Scope | Fallback | Exit criteria |
|---|---|---|---|---|
| P02-DL-001 | Coverage and pricing changes require maker-checker approval when they alter payable amounts. | Admin coverage CRUD and bulk updates. | If approver unavailable, change remains pending and non-effective. | Approval governance finalized by business owner. |
| P02-DL-002 | Denormalized external fields sync every 6 hours plus manual re-sync endpoint. | Medication and charge mapping fields. | On sync failure, keep previous snapshot and raise admin alert. | Upstream event-driven contract becomes available and validated. |
| P02-DL-003 | Soft delete is mandatory for all referenced master records; hard delete disabled in UI/API. | All dental master resources. | Resource can be reactivated if deactivated incorrectly. | Data-retention policy explicitly permits hard delete for specific entities. |

## Tests to add/update in this phase

- Request specs for CRUD, search, filters, soft-delete protection.
- Policy specs for master data read/write/delete and admin-only actions.
- Use-case specs for bulk update conflict handling.
- Contract specs for coverage resolution fallback paths.
