# Dental System v2 - Remaining Tasks (Deep Audit)

Audit timestamp: 2026-04-11
Audit source board: docs/requirements/dental-system/implementation-task-board-v2.md
Method: ticket-by-ticket artifact audit (NEW/MODIFY/UPDATE/DELETE expectations vs repository state), then manual drift classification.

## Audit Summary

- Total ticket file actions audited: 193
- Action mismatches found: 77
- Status classes used:
  - `MISSING`: required artifact not found.
  - `DRIFT_PATH`: equivalent behavior appears implemented but file path/namespace differs from board contract.
  - `DRIFT_DELETE`: board requires file removal but file still exists.
  - `VERIFY_ONLY`: artifact exists but acceptance/gate still needs explicit validation.

## Remaining by Group

## G01 - API v1 Foundation

### T01.05 Clinical posts API endpoint

- Status: PARTIAL
- `DRIFT_PATH`: board expects `app/controllers/api/v1/clinical_posts_controller.rb`, current implementation uses `app/controllers/api/v1/visits/clinical_posts_controller.rb`.
- Action:
  - Decide canonical path contract:
    - Keep nested controller and update board/docs/tests accordingly, or
    - Add compatibility wrapper at board path and align routes.
  - Verify request spec still enforces target shape/auth semantics for `GET/POST /api/v1/visits/:visit_id/clinical_posts`.

### T01.06 Group gate

- Status: VERIFY_ONLY
- Action:
  - Run and record: `bin/rubocop`, ticket-related `bin/rspec`, and group gate `bin/ci`.

## G02 - Enterprise UI Component Library

- Status: no unresolved artifact gaps detected.
- Remaining action:
  - `VERIFY_ONLY`: run group gate and do desktop/mobile component click-through (showcase-level coverage).

## G03 - Queue & Workspace Rebuild

### T03.06 Queue group gate specs

- Status: PARTIAL
- `MISSING`: `spec/system/queue_dashboard_spec.rb`.
- Action:
  - Add enterprise queue system spec covering:
    - Search by HN/name.
    - Stage filter changes result set.
    - Poll/refresh behavior and actionable stage transitions from dashboard.
  - Re-run request specs already present for queue/filter/check-in assertions.

## G04 - Clinical Forms Rebuild

### T04.08 Clinical API endpoints and group gate

- Status: PARTIAL
- `DRIFT_PATH`: board references `app/controllers/api/v1/clinical_posts_controller.rb`; current path is nested visits controller.
- `MISSING`:
  - `app/serializers/api/v1/screening_form_serializer.rb`
  - `app/serializers/api/v1/treatment_form_serializer.rb`
  - `app/serializers/api/v1/medication_form_serializer.rb`
  - `spec/system/clinical_forms_enterprise_spec.rb`
- Action:
  - Add/align form serializers and wire them in clinical posts API response by form type.
  - Add system spec for end-to-end clinical flow including high-alert/allergy blocking behavior.
  - Run group gate for G04.

## G05 - Admin Console Full Coverage

### T05.02 Procedure items slide-over completion

- Status: PARTIAL
- `DRIFT_DELETE`:
  - `app/views/admin/dental/master_data/procedure_items/new.html.erb` still exists.
  - `app/views/admin/dental/master_data/procedure_items/edit.html.erb` still exists.
- Action:
  - Remove legacy full-page new/edit views or prove they are unreachable and update board contract.

### T05.03 Medication profiles CRUD

- Status: MISSING
- Required artifacts missing:
  - `app/controllers/admin/dental/master_data/medication_profiles_controller.rb`
  - `app/views/admin/dental/master_data/medication_profiles/index.html.erb`
  - `app/views/admin/dental/master_data/medication_profiles/_form.html.erb`
  - `app/policies/admin/dental/master_data/medication_profile_policy.rb`
  - `spec/requests/admin/dental/master_data/medication_profiles_spec.rb`
- Action:
  - Implement full CRUD + policy + request coverage.

### T05.04 Supply categories/items CRUD

- Status: MISSING
- Required artifacts missing:
  - `app/controllers/admin/dental/master_data/supply_categories_controller.rb`
  - `app/controllers/admin/dental/master_data/supply_items_controller.rb`
  - `app/views/admin/dental/master_data/supply_categories/index.html.erb`
  - `app/views/admin/dental/master_data/supply_items/index.html.erb`
  - `app/views/admin/dental/master_data/supply_categories/_form.html.erb`
  - `app/views/admin/dental/master_data/supply_items/_form.html.erb`
  - `app/policies/admin/dental/master_data/supply_category_policy.rb`
  - `app/policies/admin/dental/master_data/supply_item_policy.rb`
  - `spec/requests/admin/dental/master_data/supply_categories_spec.rb`
  - `spec/requests/admin/dental/master_data/supply_items_spec.rb`

### T05.05 Reference data CRUD

- Status: MISSING
- Required artifacts missing:
  - `app/controllers/admin/dental/master_data/references_controller.rb`
  - `app/views/admin/dental/master_data/references/index.html.erb`
  - `app/views/admin/dental/master_data/references/_form.html.erb`
  - `app/policies/admin/dental/master_data/reference_policy.rb`
  - `spec/requests/admin/dental/master_data/references_spec.rb`

### T05.06 Coverage management + maker-checker

- Status: MISSING
- Required artifacts missing:
  - `app/controllers/admin/dental/master_data/coverages_controller.rb`
  - `app/views/admin/dental/master_data/coverages/index.html.erb`
  - `app/views/admin/dental/master_data/coverages/_form.html.erb`
  - `spec/requests/admin/dental/master_data/coverages_spec.rb`
- Action:
  - Confirm existing `submit_price_change_request` wiring supports coverage-specific flow and enforce copay exclusivity.

### T05.07 Admin API endpoints

- Status: MISSING
- Required artifacts missing:
  - `app/controllers/api/v1/admin/procedure_items_controller.rb`
  - `app/controllers/api/v1/admin/medication_profiles_controller.rb`
  - `app/controllers/api/v1/admin/supply_items_controller.rb`
  - `app/serializers/api/v1/admin/procedure_item_serializer.rb`
  - `app/serializers/api/v1/admin/medication_profile_serializer.rb`
  - `app/serializers/api/v1/admin/supply_item_serializer.rb`
  - `spec/requests/api/v1/admin/procedure_items_spec.rb`
  - `spec/system/admin_console_enterprise_spec.rb`
- Route gap:
  - `config/routes.rb` does not yet define `api/v1/admin` resources block from board.

## G06 - Supply, Requisition & Billing

### T06.01 Usage state machine namespace alignment

- Status: PARTIAL
- `DRIFT_PATH`:
  - Board path: `app/domains/dental/supply/usage_state_machine.rb`
  - Current path: `app/domains/dental/supply_costing/usage_state_machine.rb`
  - Board spec path missing: `spec/domains/dental/supply/usage_state_machine_spec.rb`
- Action:
  - Decide canonical namespace (`supply` vs `supply_costing`) and align board-facing contract paths/spec namespaces.

### T06.02-06.06 Use case namespace alignment + naming drift

- Status: PARTIAL
- `DRIFT_PATH` (implemented equivalents under `app/use_cases/dental/supply_costing/`):
  - `post_stock_movement.rb` (exists under supply_costing)
  - `void_usage.rb` (exists under supply_costing)
  - `sync_payment.rb` (exists under supply_costing)
  - Billing/create invoice equivalent implemented as `build_invoice.rb` under supply_costing.
  - Requisition lifecycle currently represented by `transition_requisition.rb`, `receive_requisition.rb`, `cancel_requisition.rb` under supply_costing.
- `MISSING` (board-contract names/paths not present):
  - `app/use_cases/dental/supply/execute_deduction.rb`
  - `app/use_cases/dental/supply/retry_deduction.rb`
  - `app/use_cases/dental/supply/create_requisition.rb`
  - `app/use_cases/dental/supply/approve_requisition.rb`
  - `app/use_cases/dental/supply/dispense_requisition.rb`
  - `app/use_cases/dental/supply/receive_requisition.rb`
  - `app/use_cases/dental/supply/cancel_requisition.rb`
  - `app/use_cases/dental/billing/create_invoice.rb`
  - `app/use_cases/dental/billing/sync_payment.rb`
  - `app/domains/dental/supply/requisition_state_machine.rb`
  - `spec/domains/dental/supply/requisition_state_machine_spec.rb`
  - `spec/use_cases/dental/supply/execute_deduction_spec.rb`
  - `spec/use_cases/dental/supply/post_stock_movement_spec.rb`
  - `spec/use_cases/dental/supply/void_usage_spec.rb`
  - `spec/use_cases/dental/billing/create_invoice_spec.rb`
  - `spec/use_cases/dental/billing/sync_payment_spec.rb`
- Action:
  - Either normalize to board namespace/contracts, or explicitly ratify `supply_costing` as canonical and update board + routes + spec names to remove ambiguity.

### T06.07 Waiting-payment and requisition UI

- Status: MISSING/PARTIAL
- `DRIFT_PATH`: controller currently appears as `app/controllers/dental/billing/waiting_controller.rb`, board expects `waiting_payments_controller.rb`.
- `MISSING`:
  - `app/views/dental/billing/waiting_payments/index.html.erb`
  - `app/controllers/dental/supply/requisitions_controller.rb`
  - `app/views/dental/supply/requisitions/index.html.erb`
  - `app/views/dental/supply/requisitions/show.html.erb`
  - `app/javascript/controllers/payment_polling_controller.js`

### T06.08 Supply/Billing API endpoints

- Status: MISSING
- Required artifacts missing:
  - `app/controllers/api/v1/requisitions_controller.rb`
  - `app/controllers/api/v1/invoices_controller.rb`
  - `app/controllers/api/v1/billing/sync_controller.rb`
  - `app/serializers/api/v1/requisition_serializer.rb`
  - `app/serializers/api/v1/invoice_serializer.rb`
  - `spec/requests/api/v1/requisitions_spec.rb`
  - `spec/requests/api/v1/invoices_spec.rb`
  - `spec/system/supply_billing_spec.rb`
- Route gap:
  - `config/routes.rb` does not yet include requisitions/invoices/billing sync API routes from board.

## G07 - Integration/AuthZ/Audit Hardening

- Status: no unresolved artifact gaps detected in board-mapped files.
- Remaining action:
  - `VERIFY_ONLY`: execute full policy/integration regression and confirm 403/role matrix behavior in request-level scenarios.

## G08 - Print & Release Gate

### T08.01-T08.04

- Status: no unresolved artifact gaps detected.

### T08.05 Release gate

- Status: MISSING (execution evidence)
- Required runs/evidence pending:
  - `bin/ci`
  - `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`
  - `bin/bundler-audit`
  - `bin/importmap audit`
  - `bundle exec i18n-tasks health`
  - Verify 38 UI states implemented.
  - Verify 7 flows end-to-end.
  - Verify API endpoints documented + tested.

## Cross-Cutting Route Gaps (Critical)

- `config/routes.rb` still missing board-defined API namespaces/resources for:
  - `api/v1/admin/*`
  - `api/v1/requisitions`
  - `api/v1/invoices`
  - `api/v1/billing/sync`

## Immediate Execution Order (Recommended)

1. Close contract drift decisions for clinical_posts path, supply vs supply_costing namespace, and waiting vs waiting_payments naming.
2. Complete G05 (admin HTML + API + policies + request/system specs).
3. Complete G06 API + requisition UI + missing/renamed supply/billing contracts.
4. Close G04 remaining serializers + system spec.
5. Add missing system specs (queue, clinical, admin, supply_billing).
6. Run full release gates and record evidence.

## Audit Notes

- This TODO intentionally tracks both hard missing artifacts and board-contract drift to prevent silent scope loss.
- If canonical implementation names are intentionally different, update board/docs in the same PR so future audits stay deterministic.

## Implementation Checklist (1 Ticket = 1 Commit)

Execution rules:

- Keep exactly one ticket per commit.
- Run validation commands for that ticket before commit.
- If locale keys changed, run i18n health for that ticket.
- Suggested commit format: type(scope): Txx.xx short summary

### G01

- [ ] T01.05 Align clinical posts API contract path (or ratify nested path)
  Commit: feat(api): T01.05 align clinical_posts controller contract
  Validate:
  - bin/rubocop app/controllers/api/v1 spec/requests/api/v1/clinical_posts_spec.rb config/routes.rb
  - bin/rspec spec/requests/api/v1/clinical_posts_spec.rb

- [ ] T01.06 API foundation gate evidence
  Commit: chore(qa): T01.06 api foundation gate evidence
  Validate:
  - bin/rubocop
  - bin/rspec spec/requests/api/v1/base_auth_spec.rb spec/requests/api/v1/queues_spec.rb spec/requests/api/v1/visits_spec.rb spec/requests/api/v1/clinical_posts_spec.rb
  - bin/ci

### G02

- [ ] T02.07 Component library group gate evidence (verify-only)
  Commit: chore(qa): T02.07 component library gate evidence
  Validate:
  - bin/rubocop app/views/components app/helpers/component_helper.rb app/helpers/dental/status_helper.rb spec/helpers
  - bin/rspec spec/helpers/component_helper_spec.rb spec/helpers/dental/status_helper_spec.rb
  - bin/ci

### G03

- [ ] T03.06 Add queue system spec and close queue gate
  Commit: test(workspace): T03.06 add queue dashboard system coverage
  Validate:
  - bin/rubocop spec/system/queue_dashboard_spec.rb spec/requests/workspace_spec.rb spec/requests/dental/workflow_queue_registration_spec.rb
  - bin/rspec spec/requests/workspace_spec.rb spec/requests/dental/workflow_queue_registration_spec.rb spec/system/queue_dashboard_spec.rb

### G04

- [ ] T04.08 Add missing clinical form serializers and enterprise system spec
  Commit: feat(clinical-api): T04.08 add form serializers and enterprise system spec
  Validate:
  - bin/rubocop app/serializers/api/v1 spec/requests/api/v1/clinical_posts_spec.rb spec/system/clinical_forms_enterprise_spec.rb
  - bin/rspec spec/requests/api/v1/clinical_posts_spec.rb spec/system/clinical_forms_enterprise_spec.rb
  - bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"

### G05

- [ ] T05.02 Remove legacy procedure full-page new/edit views (or formalize unreachable)
  Commit: refactor(admin): T05.02 finalize procedure slide-over only flow
  Validate:
  - bin/rubocop app/controllers/admin/dental/master_data/procedure_items_controller.rb app/views/admin/dental/master_data/procedure_items
  - bin/rspec spec/requests/admin/dental/master_data

- [ ] T05.03 Add medication profiles CRUD + policy + requests
  Commit: feat(admin): T05.03 medication profiles CRUD
  Validate:
  - bin/rubocop app/controllers/admin/dental/master_data/medication_profiles_controller.rb app/views/admin/dental/master_data/medication_profiles app/policies/admin/dental/master_data/medication_profile_policy.rb spec/requests/admin/dental/master_data/medication_profiles_spec.rb
  - bin/rspec spec/requests/admin/dental/master_data/medication_profiles_spec.rb
  - bundle exec i18n-tasks health

- [ ] T05.04 Add supply categories/items CRUD + policies + requests
  Commit: feat(admin): T05.04 supply categories and items CRUD
  Validate:
  - bin/rubocop app/controllers/admin/dental/master_data/supply_categories_controller.rb app/controllers/admin/dental/master_data/supply_items_controller.rb app/views/admin/dental/master_data/supply_categories app/views/admin/dental/master_data/supply_items app/policies/admin/dental/master_data/supply_category_policy.rb app/policies/admin/dental/master_data/supply_item_policy.rb spec/requests/admin/dental/master_data/supply_categories_spec.rb spec/requests/admin/dental/master_data/supply_items_spec.rb
  - bin/rspec spec/requests/admin/dental/master_data/supply_categories_spec.rb spec/requests/admin/dental/master_data/supply_items_spec.rb
  - bundle exec i18n-tasks health

- [ ] T05.05 Add references CRUD + policy + requests
  Commit: feat(admin): T05.05 reference data CRUD
  Validate:
  - bin/rubocop app/controllers/admin/dental/master_data/references_controller.rb app/views/admin/dental/master_data/references app/policies/admin/dental/master_data/reference_policy.rb spec/requests/admin/dental/master_data/references_spec.rb
  - bin/rspec spec/requests/admin/dental/master_data/references_spec.rb
  - bundle exec i18n-tasks health

- [ ] T05.06 Add coverages CRUD and maker-checker wiring
  Commit: feat(admin): T05.06 coverage management maker-checker
  Validate:
  - bin/rubocop app/controllers/admin/dental/master_data/coverages_controller.rb app/views/admin/dental/master_data/coverages app/use_cases/admin/dental/master_data/submit_price_change_request.rb spec/requests/admin/dental/master_data/coverages_spec.rb
  - bin/rspec spec/requests/admin/dental/master_data/coverages_spec.rb
  - bundle exec i18n-tasks health

- [ ] T05.07 Add admin API controllers/serializers/spec + system gate
  Commit: feat(api-admin): T05.07 admin api endpoints
  Validate:
  - bin/rubocop config/routes.rb app/controllers/api/v1/admin app/serializers/api/v1/admin spec/requests/api/v1/admin spec/system/admin_console_enterprise_spec.rb
  - bin/rspec spec/requests/api/v1/admin/procedure_items_spec.rb spec/system/admin_console_enterprise_spec.rb
  - bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"

### G06

- [ ] T06.01 Resolve usage state machine namespace contract + spec alignment
  Commit: refactor(supply): T06.01 usage state machine namespace alignment
  Validate:
  - bin/rubocop app/domains/dental spec/domains/dental spec/models/dental_usage_record_spec.rb
  - bin/rspec spec/domains/dental/supply_costing/usage_state_machine_spec.rb spec/models/dental_usage_record_spec.rb

- [ ] T06.02 Align stock movement use case contract path/name
  Commit: refactor(supply): T06.02 stock movement contract alignment
  Validate:
  - bin/rubocop app/use_cases/dental spec/use_cases/dental
  - bin/rspec spec/use_cases/dental/supply_costing/post_stock_movement_spec.rb

- [ ] T06.03 Align deduction/void/retry contract paths and add missing specs
  Commit: feat(supply): T06.03 deduction failure void retry flow
  Validate:
  - bin/rubocop app/use_cases/dental spec/use_cases/dental
  - bin/rspec spec/use_cases/dental/supply_costing/deduct_usage_spec.rb spec/use_cases/dental/supply_costing/void_usage_spec.rb spec/use_cases/dental/supply_costing/retry_usage_spec.rb

- [ ] T06.04 Add requisition lifecycle state machine and explicit use cases
  Commit: feat(supply): T06.04 requisition lifecycle state machine
  Validate:
  - bin/rubocop app/domains/dental app/use_cases/dental spec/domains/dental spec/use_cases/dental
  - bin/rspec spec/domains/dental spec/use_cases/dental/supply_costing/transition_requisition_spec.rb spec/use_cases/dental/supply_costing/receive_requisition_spec.rb spec/use_cases/dental/supply_costing/cancel_requisition_spec.rb

- [ ] T06.05 Enforce self-approval and dispense stock guards by policy
  Commit: feat(supply): T06.05 self-approval and dispense guard
  Validate:
  - bin/rubocop app/policies/dental/requisition_policy.rb app/use_cases/dental spec/policies/dental/requisition_policy_spec.rb
  - bin/rspec spec/policies/dental/requisition_policy_spec.rb

- [ ] T06.06 Align billing create_invoice/sync_payment contract and specs
  Commit: feat(billing): T06.06 invoice create and payment sync
  Validate:
  - bin/rubocop app/use_cases/dental spec/use_cases/dental app/models/dental_invoice.rb
  - bin/rspec spec/use_cases/dental/supply_costing/build_invoice_spec.rb spec/use_cases/dental/supply_costing/sync_payment_spec.rb

- [ ] T06.07 Build waiting-payment board + requisition UI + polling controller
  Commit: feat(ui-billing): T06.07 waiting-payment and requisition ui
  Validate:
  - bin/rubocop config/routes.rb app/controllers/dental app/views/dental app/javascript/controllers/payment_polling_controller.js
  - bin/rspec spec/requests/dental
  - bundle exec i18n-tasks health

- [ ] T06.08 Add requisitions/invoices/billing sync API + serializers + specs
  Commit: feat(api-billing): T06.08 requisition and invoice api
  Validate:
  - bin/rubocop config/routes.rb app/controllers/api/v1 app/serializers/api/v1 spec/requests/api/v1 spec/system/supply_billing_spec.rb
  - bin/rspec spec/requests/api/v1/requisitions_spec.rb spec/requests/api/v1/invoices_spec.rb spec/system/supply_billing_spec.rb
  - bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"

### G07

- [ ] T07 group verification pass (policy/integration hardening)
  Commit: chore(qa): T07 hardening verification pass
  Validate:
  - bin/rubocop app/policies/dental app/integrations/backend spec/policies/dental spec/integrations/backend spec/use_cases/admin/dental/audit_trail_coverage_spec.rb
  - bin/rspec spec/policies/dental/full_policy_matrix_spec.rb spec/integrations/backend/dental/provider_contracts_spec.rb spec/integrations/backend/mappers/jwt_role_mapping_spec.rb spec/integrations/backend/http_client_retry_spec.rb spec/use_cases/admin/dental/audit_trail_coverage_spec.rb

### G08

- [ ] T08.05 Release gate and evidence collection
  Commit: chore(release): T08.05 release gate evidence
  Validate:
  - bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"
  - bin/ci
  - bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
  - bin/bundler-audit
  - bin/importmap audit
  - bundle exec i18n-tasks health

## Optional Helper Routine Per Ticket

- Step 1: implement only one ticket scope.
- Step 2: run ticket validation commands from this checklist.
- Step 3: stage only ticket files.
- Step 4: commit once.
- Step 5: append evidence log under docs/tasks/TODO.md (date, ticket, commands passed).

## Ticket Log

Use this log for audit-ready execution evidence. Add exactly one row per committed ticket.

| Date | Ticket | Commit SHA | Commands Passed | UAT Result |
| --- | --- | --- | --- | --- |
| YYYY-MM-DD | Txx.xx | `<short_sha>` | `bin/rubocop; bin/rspec ...` | Pending |
| YYYY-MM-DD | Txx.xx | `<short_sha>` | `bin/rubocop; bin/rspec ...; bundle exec i18n-tasks health` | APPROVE / REJECT + note |

Log rules:

- Date: use UTC date in `YYYY-MM-DD` format.
- Ticket: one ticket only (example: `T05.03`).
- Commit SHA: use short SHA from `git rev-parse --short HEAD` after commit.
- Commands Passed: list exact commands run for that ticket, separated by `;`.
- UAT Result: `Pending` until human gate result is known, then update to `APPROVE` or `REJECT` with short finding.
