# Phase 01 - Foundation, Contracts, and Policy Skeletons

## Goal

Establish implementation seams and safety rails before business features:

- Canonical domain contracts and error taxonomy
- Route/controller/use-case boundaries
- Policy scaffolding
- Integration adapter skeletons
- Locale and audit scaffolding

## Scenarios covered

- `@must` unauthorized access rejected
- `@must` locale-scoped behavior
- `@must` guarded transition infrastructure exists

## Scope (files/directories)

- `config/routes.rb`
- `app/controllers/dental/*`
- `app/use_cases/dental/*`
- `app/domains/dental/*`
- `app/policies/dental/*`
- `app/integrations/backend/providers/dental/*`
- `app/integrations/backend/mappers/dental/*`
- `config/locales/en.yml`, `config/locales/th.yml`

## Implementation details carried from specifications

- Define normalized enums/value objects for:
  - visit stage/payment status
  - usage status
  - requisition status
  - stock source and direction
- Introduce explicit domain error classes:
  - invalid transition
  - guard violation
  - insufficient stock
  - contract mismatch
  - external integration unavailable
- Define base controller concerns:
  - locale-preserving path handling
  - authentication and policy checks
  - standardized error rendering
- Add policy classes with action map placeholders for all dental bounded contexts.

## Risk notes and guard conditions

- Risk: early implementation can bypass policy checks.
  - Guard: no controller action without explicit policy call path.
- Risk: enum drift across layers.
  - Guard: central enum definitions in domain layer and mapping tests.
- Risk: unknown integration payload details.
  - Guard: provider contracts accept strict typed inputs with TODO markers.

TODO markers to preserve in implementation:

- TODO (P01-DL-001): confirm final payload shape and identifier types for external invoice/payment callbacks.
- TODO (P01-DL-001): confirm whether stock references use UUID or string keys across external modules.

## Decision log (phase 01)

| Decision ID | Temporary decision | Scope | Fallback | Exit criteria |
|---|---|---|---|---|
| P01-DL-001 | Canonical identifiers in BFF domain models use string value objects, even if backend returns mixed UUID/string. | Domain contracts and provider mappers. | Keep mapper normalization rules and reject malformed identifiers. | External contract fixes ID type and mapper parity suite passes. |
| P01-DL-002 | Base controller enforces locale + auth + policy hooks by default in dental namespace. | `app/controllers/dental/*` | Explicit opt-out only for health/readiness endpoints. | Security review approves any exceptions. |
| P01-DL-003 | Error taxonomy is frozen early (`INVALID_STAGE_TRANSITION`, `STATE_GUARD_VIOLATION`, etc.) and reused across phases. | All dental use cases/controllers. | Unknown errors are wrapped into generic integration/service unavailable errors. | Contract owners approve final error catalog changes. |

## Tests to add/update in this phase

- Request specs for route-level access control and locale behavior.
- Policy specs for each new dental policy class (baseline deny/allow matrix skeleton).
- Contract specs for mapper/provider shape validation with fixture payloads.

## Foundation execution log (T01.08)

| Ticket | Commit | Result |
|---|---|---|
| T01.01 | `68fa19f` | error taxonomy and enum value objects added with domain specs |
| T01.02 | `70e28e8` | dental base controller/policy skeleton added with deny-by-default policy baseline |
| T01.03 | `f3e12cc` | dental provider interfaces and typed result contracts added with contract specs |
| T01.04 | `8f28259` | locale-scoped dental and admin-dental routes added with routing coverage |
| T01.05 | `e194e2a` | typed IDs, base entity, and dental use-case base added with specs |
| T01.06 | `23e87e5` | initial dental locale dictionary added in en/th and validated by i18n health |
| T01.07 | `fc16713` | deterministic forbidden/not-found/invalid-transition request contracts added |
