# Phase 05 - Supply, Stock, Requisition, and Billing Integration

## Goal

Deliver transaction layer from usage to billing completion:

- Medication and supply usage records
- Stock deduction and compensation flows
- Requisition lifecycle with guards
- Runtime coverage pricing and invoice item composition
- Payment status synchronization

## Scenarios covered

- `@must` insufficient stock failure
- `@must` rollback on voided source post
- `@must` requisition self-approval guard
- `@must` requisition receive stock-in
- `@must` billing send + payment completion behavior

## Scope (files/directories)

- `app/domains/dental/supply_costing/*`
- `app/use_cases/dental/supply_costing/*`
- `app/queries/dental/supply_costing/*`
- `app/controllers/dental/usage/*`
- `app/controllers/dental/stock/*`
- `app/controllers/dental/requisitions/*`
- `app/integrations/backend/providers/dental/cashier_provider.rb`
- `app/integrations/backend/providers/dental/pharmacy_provider.rb`
- `app/policies/dental/requisition_policy.rb`

## Implementation details carried from specifications

- Implement usage status machine (`pending_deduct`, `deducted`, `failed`).
- Enforce stock movement idempotency by reference.
- Implement requisition transition matrix and role-aware guards.
- Build invoice payload from procedures + medications + supplies.
- Apply runtime pricing and copay rules exactly once per item snapshot.

## Risk notes and guard conditions

- Risk: duplicate deductions under retries.
  - Guard: idempotent unique references and transaction boundaries.
- Risk: billing mismatch between dental and cashier systems.
  - Guard: contract parity tests and reconciliation query.

TODO markers to preserve in implementation:

- TODO (P05-DL-001): confirm callback/webhook authentication mechanism for payment sync endpoint.
- TODO (P05-DL-003): confirm handling rule for invoice cancellation after partial payment.

## Decision log (phase 05)

| Decision ID | Temporary decision | Scope | Fallback | Exit criteria |
|---|---|---|---|---|
| P05-DL-001 | Payment callback authentication uses shared secret signature + idempotency key check. | Cashier -> dental payment sync endpoints. | Invalid signature payload is discarded and logged for review. | Cashier team provides canonical callback auth standard. |
| P05-DL-002 | Stock movement idempotency key is `(reference_type, reference_id, direction)` and is unique. | Usage deductions and requisition stock-in/out records. | Duplicate attempts are ignored and return existing movement result. | Stock platform mandates alternate idempotency format. |
| P05-DL-003 | Partial payment keeps stage at waiting-payment; no auto rollback to in-treatment. | Invoice lifecycle transitions. | Manual correction flow via privileged admin endpoint. | Billing governance approves different partial/void transition model. |

## Tests to add/update in this phase

- Request specs for usage sync, deduction, rollback, requisition transitions.
- Policy specs for requisition role matrix.
- Contract specs for cashier and pharmacy payload mapping.
- Integration/system spec for in-treatment -> waiting-payment -> completed via payment sync.
