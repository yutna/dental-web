# Phase 06 - Integration Contracts, Authorization, and Audit Compliance

## Goal

Stabilize integration parity and enforce role/policy boundaries:

- Registration/appointment/eligibility/cashier/pharmacy/queue contracts
- Role-permission enforcement via Pundit
- JWT claim-to-principal mapping and permission derivation
- Audit event model for clinical/admin actions
- RLS strategy and access constraints for sensitive clinical records

## Scenarios covered

- `@must` unauthorized workflow transition forbidden
- `@must` role-guarded requisition and admin actions
- `@must` integration contract parity for critical flows
- `@should` cross-module sync resilience fallback behaviors

## Scope (files/directories)

- `app/integrations/backend/providers/dental/*`
- `app/integrations/backend/mappers/dental/*`
- `app/policies/dental/*`
- `app/domains/security/*`
- `app/use_cases/security/*`
- `app/domains/dental/audit/*`
- `app/use_cases/dental/audit/*`

## Implementation details carried from specifications

- Map permissions from role matrix into policy action checks.
- Enforce maker-checker patterns for approval-sensitive flows.
- Implement audit event coverage for:
  - clinical writes/voids
  - stock and requisition transitions
  - workflow transitions and billing sends
  - master data changes
- Define retry + fallback strategy for external integration failures.

## Risk notes and guard conditions

- Risk: contract mismatch due upstream API drift.
  - Guard: contract specs per endpoint and strict mapper validation.
- Risk: policy bypass in non-controller entry points.
  - Guard: use-case level authorization assertions where applicable.

TODO markers to preserve in implementation:

- TODO (P06-DL-002): confirm canonical JWT claim names and whether permissions array is always present.
- TODO (P06-DL-001): confirm final RLS scope implementation strategy for SQLite environments where PostgreSQL RLS is unavailable.

## Decision log (phase 06)

| Decision ID | Temporary decision | Scope | Fallback | Exit criteria |
|---|---|---|---|---|
| P06-DL-001 | Authorization is enforced in Pundit + query scopes; no DB-native RLS dependency for SQLite runtime. | Clinical/history access and admin read isolation. | Add DB-native RLS adapter later only if runtime DB changes. | Platform decision mandates PostgreSQL RLS and migration plan is approved. |
| P06-DL-002 | JWT claim parser treats missing permissions as empty and applies deny-by-default. | Security principal mapping and policy checks. | Return forbidden with deterministic audit entry. | IAM contract guarantees stable permissions payload. |
| P06-DL-003 | Integration failures use bounded retries with deterministic fallback, never silent success. | Registration/eligibility/cashier/pharmacy adapters. | Expose operational error and preserve last consistent state. | Cross-team SLO and retry semantics ratified in contract docs. |

## Tests to add/update in this phase

- Contract specs for each integration provider and mapper.
- Policy specs per role matrix including deny-by-default checks.
- Request specs for authorization and forbidden outcomes.
- Audit specs ensuring event capture for all required operations.
