# 01 - Overview: Dental System End-to-End Decomposition

## Goal

Design a Rails BFF implementation blueprint for the complete dental system from TOR-aligned requirements, preserving:

- Canonical UI contract ownership in Rails.
- Policy-first authorization through Pundit.
- Locale-scoped user-facing experience (`/en`, `/th`).
- Integration boundaries through `app/integrations/backend/*`.

## Delivery baseline

- Source corpus includes all dental requirement documents and cross-module references needed to remove ambiguity.
- Decomposition is vertical-slice first (`@must` scenarios first), with explicit guard conditions and regression test mapping.
- Admin backend coverage is included for all CRUD-style resources even when not explicitly detailed in source docs.

## Decomposition map

| Phase | Name | Primary objective |
|---|---|---|
| 01 | Foundation and contracts | Build canonical seams (routes, policies, domain contracts, errors, mappers) |
| 02 | Master data and admin operations | Deliver full dental master data, references, coverage, and admin governance |
| 03 | Workflow and queue lifecycle | Deliver 9-stage visit flow, queue dashboard, timeline, payment transition guards |
| 04 | Clinical forms and patient history | Deliver 22 forms, post persistence, cumulative tooth map, shared form dispatch |
| 05 | Supply, stock, requisition, billing | Deliver usage sync, stock movement idempotency, requisition lifecycle, cashier integration |
| 06 | Integration, authz, and hardening | Deliver role-policy matrix, integration parity, RLS strategy, audit compliance |
| 07 | Printing, release hardening, and go-live controls | Deliver print journeys, quality gates, deployment-readiness checks |

## Target Rails implementation homes

- `app/domains/dental/*` for entities, value objects, and domain invariants.
- `app/use_cases/dental/*` for orchestration and transaction boundaries.
- `app/queries/dental/*` for read models and dashboard/history aggregation.
- `app/integrations/backend/*` for external APIs and provider-specific translation.
- `app/policies/dental/*` for action-level authorization.
- `app/controllers/dental/*` and locale routes for endpoint boundaries.
- `app/views/dental/*` + helpers/presenters for declarative UI composition.

## Cross-cutting non-functional commitments

- Transition and pricing enforcement are deterministic and auditable.
- Stock movement is idempotent by reference and reversible by compensating records.
- Master data remains soft-delete with reference integrity.
- Timeline and audit entries are append-only.
- Performance targets from source SRS are treated as acceptance constraints.

## Risks and governance checkpoints

- Risk: contract drift between dental BFF and backend modules.
  - Mitigation: contract specs per integration endpoint, mapper parity tests.
- Risk: permission mismatch across roles and sensitive transitions.
  - Mitigation: Pundit policy specs + request specs for each guarded action.
- Risk: regulator-facing print/legal wording unclear.
  - Mitigation: explicit TODO contracts in phase 07 before final implementation lock.

## Required validation plan and execution order

1. `bin/rubocop`
2. `bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"`
3. `bundle exec i18n-tasks health` (when locale keys changed)
4. `bin/ci` as final gate

If critical workflow/system coverage is required:

- `bin/rspec spec/system`
