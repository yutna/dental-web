# Phase 03 - Workflow, Queue, and Timeline

## Goal

Deliver dental visit lifecycle and queue operations with strict stage guards:

- Intake/check-in
- Stage transition execution
- Queue dashboard and stats
- Timeline append-only audit
- Payment-state bridge to completion

## Scenarios covered

- `@must` create visit from intake
- `@must` screening guard enforcement
- `@must` send to cashier -> waiting-payment
- `@must` auto-complete on paid sync

## Scope (files/directories)

- `app/domains/dental/workflow/*`
- `app/use_cases/dental/workflow/*`
- `app/queries/dental/workflow/*`
- `app/controllers/dental/workflow/*`
- `app/controllers/dental/queue/*`
- `app/views/dental/queue/*`
- `app/policies/dental/workflow_policy.rb`

## Implementation details carried from specifications

- Implement 9-stage transition matrix.
- Enforce guard conditions from workflow SRS (VN active, room availability, vitals, dentist assignment, payment constraints).
- Maintain stage-to-queue-status mapping.
- Keep timeline immutable append-only.
- Support near-real-time queue refresh behavior.

## Risk notes and guard conditions

- Risk: race condition during parallel stage updates.
  - Guard: optimistic locking and transaction-level checks.
- Risk: queue status divergence from workflow stage.
  - Guard: single mapping adapter used by all transition paths.

TODO markers to preserve in implementation:

- TODO (P03-DL-001): confirm whether queue refresh should use polling, websockets, or both in production.
- TODO (P03-DL-002): confirm authority for room-allocation source and fallback behavior.

## Decision log (phase 03)

| Decision ID | Temporary decision | Scope | Fallback | Exit criteria |
|---|---|---|---|---|
| P03-DL-001 | Queue/UI refresh uses polling every 30 seconds as production baseline. | Queue dashboard and waiting-payment monitor. | Manual refresh remains available for urgent updates. | Websocket contract and infra SLO approved. |
| P03-DL-002 | Room availability check uses local BFF guard endpoint backed by cached roster snapshot. | checked-in -> screening transition guard. | If roster source unavailable, transition fails safely with actionable error. | Central room allocation service contract finalized. |
| P03-DL-003 | Payment sync failure does not mutate stage/payment state and is retried asynchronously. | waiting-payment lifecycle and sync jobs. | Operator can trigger manual sync endpoint. | Cashier sync reliability and callback auth formally accepted. |

## Tests to add/update in this phase

- Request specs for stage transitions and guard violations.
- Policy specs for stage transition permissions by role.
- Query specs for queue aggregation/stat cards.
- System spec for end-to-end queue flow (check-in -> treatment -> payment waiting).
