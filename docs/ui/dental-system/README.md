# Dental System UI Design

## Summary

- Feature slug: `dental-system`
- Intent: design complete, responsive, policy-aware UI artifacts for dental workflows, clinical forms, stock/requisition, billing, print, and admin governance.
- Scope: all workflows and states from `docs/tasks/dental-system/*` including admin dashboard and error/forbidden paths.
- Out of scope: implementation code, backend infra provisioning.

## Source used

- `docs/tasks/dental-system/00-specifications.md`
- `docs/tasks/dental-system/01-overview.md`
- `docs/tasks/dental-system/phase-01-foundation.md`
- `docs/tasks/dental-system/phase-02-master-data-and-admin.md`
- `docs/tasks/dental-system/phase-03-workflow-and-queue.md`
- `docs/tasks/dental-system/phase-04-clinical-forms-and-history.md`
- `docs/tasks/dental-system/phase-05-supply-costing-and-billing.md`
- `docs/tasks/dental-system/phase-06-integration-authz-and-audit.md`
- `docs/tasks/dental-system/phase-07-printing-and-release-hardening.md`
- `docs/tasks/dental-system/test-scenarios.md`
- Existing layout baseline in `app/views/layouts/application.html.erb`, `app/views/workspace/show.html.erb`, and admin pages.
- UI contracts in `config/ui_component_specs.yml`.

## Step 1.5 UI element inventory (required)

Forms & data entry:

- [x] Primary forms: check-in/screening/treatment completion, procedure, medication/supply usage, requisition CRUD, master data CRUD, print options.
- [x] Shared/imported forms: referral, lab/radiology/pharmacy dispatch, next appointment.
- [x] Search/selector drawers: patient search, item selector, dentist assignment, coverage picker.
- [x] Inline edit affordances: queue stage quick actions, requisition line edits, admin activation toggle.

Overlays:

- [x] Confirmation dialogs: complete treatment, cancel visit, receive requisition, delete/deactivate master item.
- [x] Warning/blocked-action dialogs: vitals missing, self-approval blocked, missing dispense number, allergy/high-alert warning.
- [x] Error-specific modals: integration timeout/payment sync failure details.
- [x] Side drawers: patient history, cumulative tooth map, stock movement detail.

Data displays:

- [x] KPI/stat cards: queue counters, waiting-payment counters, admin catalog health, stock alerts.
- [x] Data tables (required columns): queue grid contract (`id`, `patient_name`, `mrn`, `service`, `dentist`, `starts_at`, `status`) and requisition/admin grids.
- [x] Detail panels: timeline, payment detail, audit trail.
- [x] Timeline/activity areas: append-only transition and action timeline.
- [x] Print/export surfaces: appointment print, certificate, treatment summary, dental chart.

Cross-cutting:

- [x] Role-differentiated views: dentist, assistant, nurse, pharmacist, cashier, head dental, admin.
- [x] Permission-conditioned actions: Pundit-gated actions and unauthorized branches.
- [x] Async/integration feedback states: loading skeleton, retry, conflict, sync failure.
- [x] Locale-sensitive copy areas (`en`, `th`).

Depth classification:

- **Full** (multi-stage workflows, overlays, drawers, role variants, integration feedback, admin governance).

## Step 2 Page pattern + density

- Primary layout pattern: **workspace + list-detail** with sticky header and side context panel.
- Density: **cozy desktop / compact mobile**.
- Required page regions:
  - app shell: sticky top bar, optional left rail on large screens
  - page header: title, visit identity, global stage action cluster
  - filter row: queue/date/stage/source filters
  - primary content: data grid + form panes + timeline
  - side context: alerts, stock warnings, audit markers
- Accessibility focus:
  - keyboard path: skip link -> shell actions -> stage actions -> form fields -> save/confirm
  - visible focus: semantic focus ring on every interactive element
  - reduced motion: skeleton shimmer disabled under reduced-motion preference
  - contrast: WCAG AA with semantic tokens (`--color-app-*`)

## Step 3 Route map (Rails semantics)

| Route | Controller#action (proposed) | Turbo behavior | Auth boundary |
| --- | --- | --- | --- |
| `/[locale]/workspace` | `Dental::QueueController#index` | full page + frame refresh | signed-in + `workspace:read` |
| `/[locale]/dental/visits/:id` | `Dental::WorkflowController#show` | full page | signed-in + `workflow:read` |
| `PATCH /[locale]/dental/visits/:id/transition` | `Dental::WorkflowController#transition` | inline status update | signed-in + `workflow:transition` |
| `/[locale]/dental/visits/:id/clinical` | `Dental::ClinicalController#show` | tabbed turbo-frames | signed-in + `clinical:read` |
| `POST /[locale]/dental/visits/:id/clinical_posts` | `Dental::ClinicalPostsController#create` | form frame submit | signed-in + `clinical:write` |
| `/[locale]/dental/usage` | `Dental::UsageController#index` | table + drawer | signed-in + `stock:read` |
| `POST /[locale]/dental/usage/:id/deduct` | `Dental::UsageController#deduct` | inline row status | signed-in + `stock:write` |
| `/[locale]/dental/requisitions` | `Dental::RequisitionsController#index` | full page + filters frame | signed-in + `requisition:read` |
| `PATCH /[locale]/dental/requisitions/:id/transition` | `Dental::RequisitionsController#transition` | inline row + modal close | signed-in + policy-gated action |
| `/[locale]/dental/billing/waiting` | `Dental::BillingController#waiting_payment` | polling frame update | signed-in + `billing:read` |
| `POST /[locale]/dental/billing/:id/sync` | `Dental::BillingController#sync` | inline toast + row update | signed-in + `billing:sync` |
| `/[locale]/dental/print/:visit_id/:type` | `Dental::PrintController#show` | full page print surface | signed-in + `print:read` |
| `/[locale]/admin` | `Admin::DashboardController#show` | full page | signed-in + `admin:access` |
| `/[locale]/admin/dental/master_data/*` | `Admin::Dental::MasterData::*` | table + modal + drawer | signed-in + `admin:dental:*` |

Notes:

- All user-facing routes remain locale-scoped (`/en`, `/th`).
- Modal and drawer surfaces are Turbo Frame overlays over current page state.
- Unauthorized and forbidden states are explicit state artifacts, not silent redirects only.

## Step 3.5 Complete state and overlay inventory

Mandatory page states:

1. loading, empty, error, permission-denied, populated are represented for queue/workspace and admin list surfaces.

Workflow stage states:

1. registered/check-in, checked-in room-guard, screening, ready-for-treatment, dentist-assignment guard, in-treatment, waiting-payment, completed (paid), completed (no-charge), referred-out, cancelled, invalid-transition.

Tab/view variants:

1. queue view, clinical tabs, usage table, requisition list, admin master-data list.

Modal/dialog variants:

1. high-alert warning, allergy warning, guard failure, self-approval blocked, missing dispense number, print forbidden.

Drawer/selector variants:

1. history drawer, item selector drawer, stock movement drawer.

Inline feedback and integration variants:

1. payment sync failure, stock deduction failure, optimistic lock conflict, contract mismatch warning, appointment sync result, not-found state.

Print/export trigger states:

1. print preview ready and print forbidden state.

Gate check:

- [x] Every form has at least one wireframe.
- [x] Every modal/dialog has an overlay wireframe.
- [x] Every drawer/selector has a wireframe.
- [x] Every distinct error state has a wireframe.
- [x] Every tab/view variant has a wireframe.

## Step 5.5 Completeness traceability matrix

| Requirement item | Category | Wireframed? | State/flow file | Notes |
| --- | --- | --- | --- | --- |
| 9-stage workflow transitions + guards | workflow | Yes | `flow-01-visit-workflow-lifecycle.md`, `state-06-transition-guard-vitals.md`, `state-07-invalid-transition-blocked.md`, `state-27-check-in-created.md`, `state-28-room-assignment-unavailable.md`, `state-35-dentist-assignment-required.md`, `state-29-referred-out-summary.md`, `state-30-cancelled-visit-summary.md`, `state-37-no-charge-completed.md` | Includes check-in success, room guard, dentist guard, refer-out, cancel, no-charge completion |
| Queue dashboard with KPIs + contract columns | dashboard | Yes | `state-01-queue-loading.md`, `state-02-queue-empty.md`, `state-03-queue-populated.md`, `state-04-queue-error-inline.md` | Includes responsive table behavior |
| Clinical forms and BR-CF validation | clinical | Yes | `flow-02-clinical-forms-and-history.md`, `state-08-screening-form-entry.md`, `state-10-procedure-validation-error.md` | Includes missing required tooth/surface |
| High-alert + allergy warning | medication safety | Yes | `state-11-medication-high-alert-dialog.md`, `state-12-medication-allergy-warning.md` | Explicit blocking/confirm behavior |
| Usage deduction lifecycle and rollback | stock | Yes | `flow-03-usage-stock-deduction.md`, `state-13-usage-deduction-failed.md`, `state-14-usage-deducted-success.md` | Includes insufficient stock and compensation |
| Requisition lifecycle + role guards | requisition | Yes | `flow-04-requisition-lifecycle.md`, `state-15-requisition-list-populated.md`, `state-16-requisition-self-approval-blocked.md`, `state-17-requisition-dispense-guard.md`, `state-18-requisition-received-success.md`, `state-36-requisition-cancelled.md` | Includes pending->approved->dispensed->received and cancel terminal |
| Billing send + waiting-payment + sync fail/success | billing | Yes | `flow-05-billing-and-payment-sync.md`, `state-19-billing-waiting-payment.md`, `state-20-payment-sync-failure.md`, `state-21-payment-paid-auto-complete.md` | Includes retry path |
| Admin dashboard + master data governance | admin | Yes | `flow-06-admin-master-data-governance.md`, `state-22-admin-dashboard-overview.md`, `state-23-admin-master-data-crud.md`, `state-24-admin-bulk-import-conflict.md`, `state-38-master-data-soft-delete-guard.md` | Includes maker-checker/optimistic lock and soft-delete guard |
| Print journeys + policy boundary | print | Yes | `flow-07-print-and-release-readiness.md`, `state-25-print-preview-ready.md`, `state-26-print-forbidden.md` | Includes legal-provisional flag note |
| Not found and concurrency conflict handling | resilience | Yes | `state-31-visit-not-found.md`, `state-32-stage-update-conflict.md` | Covers NOT_FOUND and stale update conflict paths |
| Appointment sync to registered queue | integration | Yes | `state-33-appointment-sync-registered-queue.md` | Covers should-scenario for appointment sync result |
| Coverage expiry pricing fallback | pricing | Yes | `state-34-coverage-expiry-fallback-pricing.md` | Covers should-scenario for expired coverage fallback to master price |
| Locale-sensitive UX EN/TH | i18n | Yes | All state files | Route and copy areas include `/[locale]` |
| Responsive design support | UX | Yes | All state files | Desktop + mobile intent in visual direction |
| Permission-denied/forbidden states | authz | Yes | `state-05-workflow-permission-denied.md`, `state-26-print-forbidden.md` | Policy-first UX branch |

Required checks:

- [x] Every required form is represented.
- [x] Every required overlay is represented.
- [x] Every required table column/KPI is represented.
- [x] Every distinct error/permission state is represented.
- [x] Every locale-sensitive state is represented where user-facing.
- [x] Every state file contains a Visual direction section.

## Artifact index

Flow files:

- `flow-01-visit-workflow-lifecycle.md`
- `flow-02-clinical-forms-and-history.md`
- `flow-03-usage-stock-deduction.md`
- `flow-04-requisition-lifecycle.md`
- `flow-05-billing-and-payment-sync.md`
- `flow-06-admin-master-data-governance.md`
- `flow-07-print-and-release-readiness.md`

State files:

- `state-01-queue-loading.md`
- `state-02-queue-empty.md`
- `state-03-queue-populated.md`
- `state-04-queue-error-inline.md`
- `state-05-workflow-permission-denied.md`
- `state-06-transition-guard-vitals.md`
- `state-07-invalid-transition-blocked.md`
- `state-08-screening-form-entry.md`
- `state-09-treatment-form-in-progress.md`
- `state-10-procedure-validation-error.md`
- `state-11-medication-high-alert-dialog.md`
- `state-12-medication-allergy-warning.md`
- `state-13-usage-deduction-failed.md`
- `state-14-usage-deducted-success.md`
- `state-15-requisition-list-populated.md`
- `state-16-requisition-self-approval-blocked.md`
- `state-17-requisition-dispense-guard.md`
- `state-18-requisition-received-success.md`
- `state-19-billing-waiting-payment.md`
- `state-20-payment-sync-failure.md`
- `state-21-payment-paid-auto-complete.md`
- `state-22-admin-dashboard-overview.md`
- `state-23-admin-master-data-crud.md`
- `state-24-admin-bulk-import-conflict.md`
- `state-25-print-preview-ready.md`
- `state-26-print-forbidden.md`
- `state-27-check-in-created.md`
- `state-28-room-assignment-unavailable.md`
- `state-29-referred-out-summary.md`
- `state-30-cancelled-visit-summary.md`
- `state-31-visit-not-found.md`
- `state-32-stage-update-conflict.md`
- `state-33-appointment-sync-registered-queue.md`
- `state-34-coverage-expiry-fallback-pricing.md`
- `state-35-dentist-assignment-required.md`
- `state-36-requisition-cancelled.md`
- `state-37-no-charge-completed.md`
- `state-38-master-data-soft-delete-guard.md`
