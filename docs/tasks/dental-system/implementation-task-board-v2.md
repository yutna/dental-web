# Dental System — Implementation Task Board v2

Purpose: execution board for building an enterprise-grade dental system with dual interface — HTML web app AND JSON API — from existing foundation code.

Source coverage: all files in `docs/tasks/dental-system/` (11 requirements) and `docs/ui/dental-system/` (48 UI designs).

## Architecture Model

This is ONE full-stack Rails app with BFF-style layering that serves two interfaces:

| Surface | Base path | Format | Auth | Purpose |
|---|---|---|---|---|
| HTML web app | `/:locale/*` | HTML via Turbo + Stimulus | Session cookie + Pundit | User-facing dental workflow |
| JSON API | `/api/v1/*` | JSON | Bearer token + Pundit | External consumer API |
| Admin console | `/:locale/admin/*` | HTML + JSON | Session cookie + `admin:access` | Data governance |

Both surfaces share: models, domain layer, use cases, queries, policies, integration providers.

Controllers are thin entry points. Business logic lives in use cases and queries.

```
Request → Controller (format routing) → Policy (authorize) → UseCase/Query → Model/Domain → Response
                                                                                    ↓
                                                                          HTML: ERB view
                                                                          JSON: Serializer
```

## Preserved Baseline

Code already passing (198+ specs, RuboCop clean, i18n healthy):

| Layer | Files | Notes |
|---|---|---|
| Auth (remote JWT + refresh) | 12 | Complete — `admin.s/123` works |
| Domain (state machine, enums, typed IDs, errors) | 18 | Solid — 9-stage visit SM, all enums |
| Models + migrations | 24 models, 10 migrations | All tables exist in schema |
| Use cases | 19 | Logic complete, controllers delegate properly |
| Queries | 12 | Queue, clinical, admin queries work |
| Policies | 11 | Deny-by-default Pundit |
| Integration providers | 13 | HTTP client, registry, dental provider stubs |
| Stimulus controllers | 11 | Polling, toast, combobox, medication form etc |
| Views | 31 | PROTOTYPE-LEVEL — full rebuild needed |
| Specs | 62 files | Solid test base to build on |

## What v2 Adds/Rebuilds

1. **NEW**: `/api/v1/*` JSON API namespace with token auth, serializers, pagination.
2. **REBUILD**: All HTML views to match UI design specs (enterprise-grade).
3. **NEW**: Reusable UI component partials and Stimulus controllers.
4. **EXPAND**: Admin CRUD for ALL master data entities (not just procedure items).
5. **NEW**: Supply chain, requisition lifecycle, billing/payment sync.
6. **NEW**: Print preview and document templates.
7. **HARDEN**: Full 9-role policy matrix, audit trail expansion, integration resilience.

## Execution Contract

- Atomic rule: 1 ticket = 1 commit.
- Quality rule: every ticket must pass lint + tests before commit.
- Group rule: execute tickets sequentially within group, then STOP for human UAT.
- Continue rule: next group only after human approves current group.
- Dual-format rule: every feature group delivers BOTH HTML views AND `/api/v1/*` endpoints.

Per-ticket checks:

1. `bin/rubocop`
2. `bin/rspec` (ticket-related specs)
3. `bundle exec i18n-tasks health` (when locale keys change)

Per-group checks:

1. `bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"`
2. `bin/ci`

## Group Roadmap

### G01 — API v1 Foundation & Serialization

Outcome: `/api/v1/*` routes, base controller with Bearer auth, JSON error envelope, serializer pattern, pagination concern. Core queue and visit endpoints live.

Stop gate: `curl` against `/api/v1/queues` and `/api/v1/visits/:id` returns structured JSON with auth enforcement.

### G02 — Enterprise UI Component Library

Outcome: overhauled application layout with responsive navigation, reusable component partials (data table, modal, slide-over, stat cards, status badges, filter bar, sticky save bar, tooth chart SVG), and Stimulus controllers for interactive behavior.

Stop gate: component showcase page renders all components correctly on desktop and mobile.

### G03 — Queue & Workspace Rebuild

Outcome: queue dashboard matching state-03 design (data-dense table, search, filters, stat chips, quick actions), visit detail with timeline panel, check-in flow, appointment sync. Plus API endpoints.

Stop gate: staff can browse queue, filter by status, search patients, and trigger stage actions from the dashboard.

### G04 — Clinical Forms Rebuild

Outcome: two-column clinical workspace (state-08/09), screening with full vitals (state-08), treatment procedure builder with data grid (state-09), medication form with blocking high-alert modal (state-11/12), visual tooth chart, image form with upload, history drawer with cumulative timeline. Plus API endpoints.

Stop gate: dentist can enter all clinical forms with enterprise-grade UI and see accurate history projections.

### G05 — Admin Console Full Coverage

Outcome: admin dashboard with KPI cards and audit stream (state-22), CRUD for ALL master data entities with slide-over pattern (state-23), bulk import with conflict resolution (state-24), coverage management with maker-checker, reference data management. Plus API endpoints.

Stop gate: admin can manage all master data entities end-to-end with approval workflows.

### G06 — Supply, Requisition & Billing

Outcome: usage deduction state machine, stock movement posting, requisition lifecycle (request → approve → dispense → receive/cancel), billing line builder, payment sync, waiting-payment board (state-19). Plus API endpoints.

Stop gate: supply/requisition/billing flows execute with proper failure handling and auto-complete on paid sync.

### G07 — Integration/AuthZ/Audit Hardening

Outcome: complete Pundit policy matrix for all 9 roles across all actions, fixture-based contract parity tests, JWT claims binding, expanded audit trail, bounded retry strategy, deterministic error surfaces.

Stop gate: role-based boundaries are airtight and integration failures don't corrupt state.

### G08 — Print & Release Gate

Outcome: print preview (state-25), treatment summary/certificate/chart templates, bilingual EN/TH output, legal-provisional watermark (state-26), print policy enforcement, release traceability gate.

Stop gate: all print templates render correctly, release gate passes, system is production-ready.

---

## Atomic Task Tickets

### G01 Tickets — API v1 Foundation

**T01.01** Add API v1 base controller wiring existing auth to Bearer token.

NOTE: Auth is ALREADY COMPLETE — remote JWT from `api-meditech-dev` works (login, refresh, logout, decode, permission injection). This ticket only creates a thin adapter that accepts the same JWT as a Bearer token and reuses the existing `SessionSnapshotMapper` + Pundit pipeline. No new auth logic.

Files:
- NEW `app/controllers/api/v1/base_controller.rb` — `authenticate_api_user!` extracts Bearer token from header, decodes via existing `SessionSnapshotMapper`, sets `Current.principal`, rescues → JSON error envelope `{ error: { code, message, details } }`, pagination params
- MODIFY `config/routes.rb` — add `namespace :api { namespace :v1 { ... } }` block

Auth flow for API consumers:
1. Client authenticates directly with remote API (`POST /auth/v1/login`) to get JWT — this is external, not our code.
2. Client sends JWT as `Authorization: Bearer <token>` to our `/api/v1/*` endpoints.
3. Our base controller decodes the JWT using the same mapper the HTML session flow uses.

Acceptance: unauthenticated request to any `/api/v1/*` returns `401 { error: { code: "UNAUTHORIZED" } }`. Valid JWT from remote API is accepted.

---

**T01.02** Add API serializer base and standard response envelope.

Files:
- NEW `app/serializers/base_serializer.rb` — `serialize(record)`, `serialize_collection(records, meta:)`
- NEW `app/serializers/api/v1/queue_entry_serializer.rb`
- NEW `app/serializers/api/v1/visit_serializer.rb`
- NEW `app/serializers/api/v1/clinical_post_serializer.rb`

Acceptance: serializers produce deterministic JSON shapes matching specification entity definitions.

---

**T01.03** Add queue entries API endpoint.

Files:
- NEW `app/controllers/api/v1/queues_controller.rb` — `index` (filtered, paginated), `create` (register)
- MODIFY `config/routes.rb` — add `resources :queues, only: [:index, :create]`
- NEW `spec/requests/api/v1/queues_spec.rb`

Acceptance: `GET /api/v1/queues` returns paginated queue list. `POST /api/v1/queues` registers entry. Auth enforced.

---

**T01.04** Add visits API endpoint.

Files:
- NEW `app/controllers/api/v1/visits_controller.rb` — `show`, `transition`, `check_in`
- MODIFY `config/routes.rb` — add visit routes
- NEW `spec/requests/api/v1/visits_spec.rb`

Acceptance: `GET /api/v1/visits/:id` returns visit snapshot. `PATCH /api/v1/visits/:id/transition` executes stage change with guard validation. `POST /api/v1/visits/check_in` works.

---

**T01.05** Add clinical posts API endpoint.

Files:
- NEW `app/controllers/api/v1/clinical_posts_controller.rb` — `index` (by visit), `create` (save form)
- MODIFY `config/routes.rb` — add clinical post routes
- NEW `spec/requests/api/v1/clinical_posts_spec.rb`

Acceptance: `GET /api/v1/visits/:visit_id/clinical_posts` returns form data. `POST` saves with validation.

---

**T01.06** API foundation group gate and specs.

Files:
- NEW `spec/requests/api/v1/base_auth_spec.rb` — token auth, error envelope, pagination
- UPDATE existing specs to ensure no regressions

Acceptance: `bin/ci` passes. All API endpoints return correct JSON shapes. Auth rejection is deterministic.

---

### G02 Tickets — Enterprise UI Component Library

**T02.01** Overhaul application layout with enterprise navigation.

Files:
- MODIFY `app/views/layouts/application.html.erb` — responsive shell: collapsible sidebar nav, top bar with profile/locale/workspace links, breadcrumb area, main content slot
- NEW `app/views/layouts/_sidebar_nav.html.erb` — nav items: Workspace, Dental, Admin, with active state
- NEW `app/views/layouts/_top_bar.html.erb` — profile menu, locale switcher, breadcrumb
- MODIFY `app/assets/tailwind/application.css` — layout utilities, z-layer tokens
- NEW `app/javascript/controllers/sidebar_controller.js` — collapse/expand, mobile drawer

Acceptance: layout renders correctly on desktop (sidebar + content) and mobile (hamburger → drawer). Navigation reflects current section.

---

**T02.02** Add reusable data table component.

Files:
- NEW `app/views/components/_data_table.html.erb` — sortable columns, row actions slot, empty state, loading skeleton
- NEW `app/helpers/component_helper.rb` — `render_data_table(columns:, rows:, actions:)` presenter
- NEW `app/javascript/controllers/data_table_controller.js` — client-side sort, row selection

Acceptance: data table renders with proper alignment, sort indicators, and responsive stacking on mobile.

---

**T02.03** Add modal and slide-over components.

Files:
- NEW `app/views/components/_modal.html.erb` — backdrop, focus trap, size variants (sm/md/lg), Turbo frame support
- NEW `app/views/components/_slide_over.html.erb` — right-edge panel for create/edit forms
- NEW `app/javascript/controllers/modal_controller.js` — open/close, ESC dismiss, focus trap
- NEW `app/javascript/controllers/slide_over_controller.js` — open/close with animation

Acceptance: modal blocks background interaction. Slide-over animates from right. Both dismiss on ESC and backdrop click.

---

**T02.04** Add stat cards and status badge components.

Files:
- NEW `app/views/components/_stat_card.html.erb` — icon, label, value, trend indicator
- NEW `app/views/components/_status_badge.html.erb` — semantic status tones (registered, in-progress, waiting, completed, cancelled)
- NEW `app/helpers/dental/status_helper.rb` — `stage_badge(stage)`, `payment_badge(status)` mapping

Acceptance: status badges use semantic design tokens. Stat cards lay out in responsive grid (3 cols desktop, stack mobile).

---

**T02.05** Add filter bar and sticky save bar components.

Files:
- NEW `app/views/components/_filter_bar.html.erb` — search input, dropdown filters, apply/reset actions
- NEW `app/views/components/_sticky_save_bar.html.erb` — fixed bottom bar with save actions, dirty indicator
- NEW `app/javascript/controllers/filter_bar_controller.js` — Turbo frame submit
- NEW `app/javascript/controllers/autosave_controller.js` — field blur → autosave indicator

Acceptance: filter bar submits via Turbo frame without full reload. Save bar sticks to viewport bottom and shows dirty state.

---

**T02.06** Add tooth chart SVG component.

Files:
- NEW `app/views/components/_tooth_chart.html.erb` — SVG dental chart with clickable tooth regions (universal numbering 1-32 + deciduous A-T)
- NEW `app/javascript/controllers/tooth_chart_controller.js` — click-to-select, multi-select mode, highlight states (treated, planned, problematic)
- NEW `app/assets/images/tooth_chart_base.svg` — base SVG template

Acceptance: tooth chart renders all 32 permanent teeth. Click selects/deselects tooth. Selected teeth highlighted. Works on mobile with touch.

---

**T02.07** Component library specs and group gate.

Files:
- NEW `spec/helpers/component_helper_spec.rb`
- NEW `spec/helpers/dental/status_helper_spec.rb`
- UPDATE i18n locale files for any new component keys

Acceptance: all helpers tested. `bin/ci` passes. Components render without errors when used in isolation.

---

### G03 Tickets — Queue & Workspace Rebuild

**T03.01** Rebuild queue dashboard with enterprise data table (state-03).

Files:
- REWRITE `app/views/workspace/show.html.erb` — data table layout matching state-03 wireframe: Q#, Patient, MRN, Service, Dentist, Start, Stage, Actions columns
- REWRITE `app/views/workspace/_appointments_grid.html.erb` — use data table component
- MODIFY `app/controllers/workspace_controller.rb` — pass structured column/row data
- MODIFY `app/queries/workspace/appointment_rows_query.rb` — add search, filter, stat counts

Acceptance: queue shows data-dense table with stage badges, row actions (Start Tx, Cashier, Sync), stat chips at top.

---

**T03.02** Add queue search, filters, and stat counters.

Files:
- MODIFY `app/views/workspace/show.html.erb` — add filter bar component: search by HN/name, status dropdown, apply/reset
- MODIFY `app/queries/workspace/appointment_rows_query.rb` — implement search/filter params
- MODIFY `app/controllers/workspace_controller.rb` — accept filter params
- ADD locale keys for filter labels

Acceptance: search by patient name/HN works. Filter by stage works. Stat counters (Total, Screening, In-treatment, Waiting payment) update with filters.

---

**T03.03** Queue polling and Turbo frame refresh.

Files:
- MODIFY `app/views/workspace/show.html.erb` — wrap table in Turbo frame with `data-queue-polling-target`
- MODIFY `app/javascript/controllers/queue_polling_controller.js` — poll every 30s, update Turbo frame
- ADD `app/views/workspace/show.turbo_stream.erb` — stream update for queue table

Acceptance: queue table auto-refreshes every 30s without full page reload. Manual refresh button also works.

---

**T03.04** Rebuild visit detail page with timeline panel.

Files:
- REWRITE `app/views/dental/visits/show.html.erb` — two-panel layout: left = visit card + stage actions, right = transition timeline
- MODIFY `app/helpers/dental/visits_helper.rb` — `stage_action_buttons(visit)`, `timeline_entries(visit)`
- MODIFY `app/controllers/dental/visits_controller.rb` — load timeline entries

Acceptance: visit detail shows current stage with available actions. Timeline shows all transitions with actor + timestamp. Transition buttons fire with confirmation.

---

**T03.05** Check-in and appointment sync UI improvements.

Files:
- MODIFY `app/views/dental/visits/show.html.erb` — check-in confirmation dialog
- MODIFY `app/views/workspace/show.html.erb` — sync appointments button in toolbar
- ADD locale keys for sync and check-in messages

Acceptance: check-in creates queue entry and redirects to visit detail. Appointment sync populates queue from registered appointments.

---

**T03.06** Queue group gate specs.

Files:
- UPDATE `spec/requests/workspace_spec.rb` — search, filter, stat count assertions
- UPDATE `spec/requests/dental/workflow_queue_registration_spec.rb` — check-in assertions
- NEW `spec/system/queue_dashboard_spec.rb`

Acceptance: `bin/ci` passes. Queue dashboard is fully functional with search, filters, polling, and stage actions.

---

### G04 Tickets — Clinical Forms Rebuild

**T04.01** Build two-column clinical workspace layout.

Files:
- REWRITE `app/views/dental/clinical/workspaces/show.html.erb` — two-column layout: left = patient context card (visit ID, HN, name, stage), right = tabbed form area (Screening, Treatment, Medication, Chart, Images, History)
- MODIFY `app/controllers/dental/clinical/workspaces_controller.rb` — pass patient context data
- ADD locale keys for tab labels

Acceptance: clinical workspace shows patient context on left, tabs on right. Active tab highlighted. Mobile collapses to single column with sticky patient bar.

---

**T04.02** Rebuild screening form to match state-08.

Files:
- REWRITE `app/views/dental/clinical/screening_forms/show.html.erb` — full vitals row (BP, Pulse, Temp, Weight, Height), allergy notes textarea, chief complaint textarea, preliminary findings textarea, sticky save bar with "Save draft" + "Save and continue"
- MODIFY `app/controllers/dental/clinical/screening_forms_controller.rb` — handle save_draft vs save_and_continue actions
- UPDATE locale keys for new field labels

Acceptance: screening form matches state-08 wireframe. All fields present. "Save and continue" triggers screening → ready-for-treatment transition. Missing vitals shows guard error (state-06).

---

**T04.03** Rebuild treatment form as procedure builder (state-09).

Files:
- REWRITE `app/views/dental/clinical/treatment_forms/show.html.erb` — procedure builder: searchable item selector + Add button, data grid (Row, Procedure, Tooth, Surface, Qty, Price, Coverage, Actions[Edit/Void]), notes textarea, action buttons (Save treatment, Send cashier, Complete no-charge, Refer out)
- NEW `app/javascript/controllers/treatment_builder_controller.js` — dynamic row add/edit/void, searchable combobox for procedure items
- MODIFY `app/use_cases/dental/clinical/save_treatment_form.rb` — handle multi-row procedure data
- UPDATE locale keys

Acceptance: treatment form matches state-09 wireframe. Can add procedures via search, edit rows, void rows. Grid shows tooth + surface + pricing columns. "Send cashier" triggers billing confirmation modal.

---

**T04.04** Rebuild medication form with high-alert blocking modal (state-11/12).

Files:
- REWRITE `app/views/dental/clinical/medication_forms/show.html.erb` — medication search + add, usage list grid, dosage/frequency fields
- NEW `app/views/dental/clinical/medication_forms/_high_alert_modal.html.erb` — blocking modal matching state-11 (item name, category, patient ID, dose, confirm/cancel)
- NEW `app/views/dental/clinical/medication_forms/_allergy_warning_modal.html.erb` — blocking warning matching state-12
- MODIFY `app/javascript/controllers/medication_form_controller.js` — trigger modal on high-alert item selection, block until explicit confirm
- MODIFY `app/use_cases/dental/clinical/save_medication_form.rb` — high_alert_confirmed flag

Acceptance: selecting high-alert medication shows blocking modal (state-11). Allergy conflict shows blocking warning (state-12). Confirmation required before saving. Cancel returns to form without changes.

---

**T04.05** Rebuild chart form with visual tooth map.

Files:
- REWRITE `app/views/dental/clinical/chart_forms/show.html.erb` — visual tooth chart component (SVG), click tooth → detail panel (condition, notes, surfaces), condition legend
- MODIFY `app/use_cases/dental/clinical/save_chart_form.rb` — accept tooth-by-tooth structured data
- MODIFY `app/queries/dental/clinical/chart_form_query.rb` — load existing chart data per tooth

Acceptance: chart form shows visual tooth map. Click tooth to record condition. Existing conditions color-coded on chart. Mobile shows scrollable chart.

---

**T04.06** Rebuild image form with upload preview.

Files:
- REWRITE `app/views/dental/clinical/image_forms/show.html.erb` — image type dropdown, file upload with preview, existing images gallery, notes per image
- MODIFY `app/controllers/dental/clinical/image_forms_controller.rb` — Active Storage attachment handling
- MODIFY `app/use_cases/dental/clinical/save_image_form.rb` — validate MIME/size per P04-DL-001

Acceptance: image upload previews before save. MIME validation rejects non-image files. Existing images show in gallery grid.

---

**T04.07** Rebuild history drawer with cumulative timeline.

Files:
- REWRITE `app/views/dental/clinical/history_drawers/show.html.erb` — cumulative tooth map (read-only, shows all historical conditions), visit timeline (expandable entries with procedures/medications per visit), image records section
- MODIFY `app/queries/dental/clinical/cumulative_history_query.rb` — aggregate across all visits for patient

Acceptance: history drawer shows cumulative tooth conditions overlaid on chart. Timeline shows all past visits with form details. Images referenced by visit.

---

**T04.08** Clinical API endpoints and group gate.

Files:
- UPDATE `app/controllers/api/v1/clinical_posts_controller.rb` — ensure all form types supported
- NEW `app/serializers/api/v1/screening_form_serializer.rb`
- NEW `app/serializers/api/v1/treatment_form_serializer.rb`
- NEW `app/serializers/api/v1/medication_form_serializer.rb`
- UPDATE clinical spec files for new UI behavior
- NEW `spec/system/clinical_forms_enterprise_spec.rb`

Acceptance: `bin/ci` passes. All clinical forms match design specs. API returns correct form data. High-alert and allergy flows work end-to-end.

---

### G05 Tickets — Admin Console Full Coverage

**T05.01** Rebuild admin dashboard with KPI cards and audit stream (state-22).

Files:
- REWRITE `app/views/admin/dental/dashboard/show.html.erb` — stat cards row (Master resources count, Pending approvals, Sync warnings, Active items), quick action tiles (Manage procedures, Manage medications, Coverage pricing, Bulk import), recent audit events stream
- MODIFY `app/queries/dental/admin/dashboard_query.rb` — calculate KPI counts
- UPDATE locale keys

Acceptance: admin dashboard matches state-22 wireframe. KPI cards show live counts. Quick actions navigate to correct resource manager.

---

**T05.02** Overhaul procedure items CRUD with slide-over pattern (state-23).

Files:
- REWRITE `app/views/admin/dental/master_data/procedure_items/index.html.erb` — data table with search, status filter, coverage filter, ref count column, slide-over edit form replacing full-page edit
- REWRITE `app/views/admin/dental/master_data/procedure_items/_form.html.erb` — slide-over form with OPD/IPD price fields, require approval checkbox, submit-for-approval action
- MODIFY `app/controllers/admin/dental/master_data/procedure_items_controller.rb` — support Turbo frame for slide-over
- DELETE `app/views/admin/dental/master_data/procedure_items/new.html.erb` — replaced by slide-over
- DELETE `app/views/admin/dental/master_data/procedure_items/edit.html.erb` — replaced by slide-over

Acceptance: procedure items table matches state-23. Slide-over opens for create/edit without page navigation. Deactivation blocked for referenced records (state-38).

---

**T05.03** Add medication profiles CRUD with admin console.

Files:
- NEW `app/controllers/admin/dental/master_data/medication_profiles_controller.rb` — full CRUD
- NEW `app/views/admin/dental/master_data/medication_profiles/index.html.erb` — data table with high-alert badge
- NEW `app/views/admin/dental/master_data/medication_profiles/_form.html.erb` — slide-over form
- NEW `app/policies/admin/dental/master_data/medication_profile_policy.rb`
- MODIFY `config/routes.rb` — add medication profiles routes
- NEW `spec/requests/admin/dental/master_data/medication_profiles_spec.rb`

Acceptance: medication profiles CRUD works. High-alert items visually distinguished. Soft-delete enforced.

---

**T05.04** Add supply categories and items CRUD.

Files:
- NEW `app/controllers/admin/dental/master_data/supply_categories_controller.rb`
- NEW `app/controllers/admin/dental/master_data/supply_items_controller.rb`
- NEW `app/views/admin/dental/master_data/supply_categories/index.html.erb`
- NEW `app/views/admin/dental/master_data/supply_items/index.html.erb`
- NEW `app/views/admin/dental/master_data/supply_categories/_form.html.erb`
- NEW `app/views/admin/dental/master_data/supply_items/_form.html.erb`
- NEW `app/policies/admin/dental/master_data/supply_category_policy.rb`
- NEW `app/policies/admin/dental/master_data/supply_item_policy.rb`
- MODIFY `config/routes.rb` — add supply routes
- NEW `spec/requests/admin/dental/master_data/supply_categories_spec.rb`
- NEW `spec/requests/admin/dental/master_data/supply_items_spec.rb`

Acceptance: supply categories and items fully manageable. Categories contain items. Soft-delete for referenced items.

---

**T05.05** Add reference data CRUD (tooth, surface, root, piece, image types).

Files:
- NEW `app/controllers/admin/dental/master_data/references_controller.rb` — polymorphic CRUD for all reference tables (tooth, surface, root, piece, image type)
- NEW `app/views/admin/dental/master_data/references/index.html.erb` — tabbed table for each reference type
- NEW `app/views/admin/dental/master_data/references/_form.html.erb` — slide-over form (code, name, sort_order, active)
- NEW `app/policies/admin/dental/master_data/reference_policy.rb`
- MODIFY `config/routes.rb` — add reference routes
- NEW `spec/requests/admin/dental/master_data/references_spec.rb`

Acceptance: all reference types (tooth, surface, root, piece, image type) manageable via tabbed UI. Sort order editable. Soft-delete only.

---

**T05.06** Add coverage management and maker-checker workflow.

Files:
- NEW `app/controllers/admin/dental/master_data/coverages_controller.rb` — manage procedure + supply coverages
- NEW `app/views/admin/dental/master_data/coverages/index.html.erb` — coverage list with effective dates, copay display
- NEW `app/views/admin/dental/master_data/coverages/_form.html.erb` — coverage form with eligibility code, effective dates, copay (amount OR percent), price
- MODIFY `app/use_cases/admin/dental/master_data/submit_price_change_request.rb` — wire maker-checker for coverage changes
- NEW `spec/requests/admin/dental/master_data/coverages_spec.rb`

Acceptance: coverages manageable with effective date ranges. Mutually exclusive copay fields enforced. Price-sensitive changes go to maker-checker pending state. Approval flow works.

---

**T05.07** Admin API endpoints and group gate.

Files:
- NEW `app/controllers/api/v1/admin/procedure_items_controller.rb` — CRUD API
- NEW `app/controllers/api/v1/admin/medication_profiles_controller.rb` — CRUD API
- NEW `app/controllers/api/v1/admin/supply_items_controller.rb` — CRUD API
- NEW `app/serializers/api/v1/admin/procedure_item_serializer.rb`
- NEW `app/serializers/api/v1/admin/medication_profile_serializer.rb`
- NEW `app/serializers/api/v1/admin/supply_item_serializer.rb`
- NEW `spec/requests/api/v1/admin/procedure_items_spec.rb`
- NEW `spec/system/admin_console_enterprise_spec.rb`

Acceptance: `bin/ci` passes. All admin entities have CRUD via HTML and API. Maker-checker works. Bulk import works.

---

### G06 Tickets — Supply, Requisition & Billing

**T06.01** Add usage deduction model and state machine (pending_deduct → deducted / failed).

Files:
- NEW migration — `create_dental_usage_records` (visit_id, supply_item_id, quantity, status, idempotency_key, deducted_at, failed_reason)
- NEW `app/models/dental_usage_record.rb` — validations, state scopes
- NEW `app/domains/dental/supply/usage_state_machine.rb` — 3-state machine: pending_deduct → deducted, pending_deduct → failed, failed → pending_deduct (retry)
- NEW `spec/domains/dental/supply/usage_state_machine_spec.rb`
- NEW `spec/models/dental_usage_record_spec.rb`

Acceptance: usage record model persists. State machine enforces valid transitions. Failed → retry path works.

---

**T06.02** Add stock movement posting with idempotency.

Files:
- NEW migration — `create_dental_stock_movements` (supply_item_id, direction, quantity, source, reference_type, reference_id, idempotency_key)
- NEW `app/models/dental_stock_movement.rb`
- NEW `app/use_cases/dental/supply/post_stock_movement.rb` — idempotent posting with idempotency_key check
- NEW `spec/use_cases/dental/supply/post_stock_movement_spec.rb`

Acceptance: stock movements post correctly. Duplicate idempotency_key skipped without error. Direction (in/out) resolves correct quantity adjustment.

---

**T06.03** Add deduction failure and void/retry handling.

Files:
- NEW `app/use_cases/dental/supply/execute_deduction.rb` — deduction flow: check stock → post movement → update usage status
- NEW `app/use_cases/dental/supply/void_usage.rb` — reverse deduction and post compensating movement
- NEW `app/use_cases/dental/supply/retry_deduction.rb` — retry failed deductions
- NEW `spec/use_cases/dental/supply/execute_deduction_spec.rb`
- NEW `spec/use_cases/dental/supply/void_usage_spec.rb`

Acceptance: deduction posts stock-out movement. Void reverses with stock-in. Retry transitions failed → pending_deduct → deducted. Insufficient stock fails gracefully (state-13).

---

**T06.04** Add requisition model and lifecycle transitions.

Files:
- NEW migration — `create_dental_requisitions` (visit_id, requested_by, approved_by, status, items_json, requested_at, approved_at, dispensed_at, received_at, cancelled_at)
- NEW `app/models/dental_requisition.rb`
- NEW `app/domains/dental/supply/requisition_state_machine.rb` — 5-state: requested → approved → dispensed → received / cancelled
- NEW `app/use_cases/dental/supply/create_requisition.rb`
- NEW `app/use_cases/dental/supply/approve_requisition.rb`
- NEW `app/use_cases/dental/supply/dispense_requisition.rb`
- NEW `app/use_cases/dental/supply/receive_requisition.rb`
- NEW `app/use_cases/dental/supply/cancel_requisition.rb`
- NEW `spec/domains/dental/supply/requisition_state_machine_spec.rb`

Acceptance: requisition lifecycle works end-to-end. Self-approval blocked (state-16). Dispense guard enforced (state-17). Receive triggers stock-in (state-18).

---

**T06.05** Add self-approval guard and dispense enforcement.

Files:
- MODIFY `app/use_cases/dental/supply/approve_requisition.rb` — reject when approved_by == requested_by
- MODIFY `app/use_cases/dental/supply/dispense_requisition.rb` — verify all items have available stock before dispensing
- NEW `app/policies/dental/requisition_policy.rb` — approve?, dispense?, receive?, cancel? by role
- NEW `spec/policies/dental/requisition_policy_spec.rb`

Acceptance: self-approval returns specific error (state-16). Dispense with insufficient stock returns guard error (state-17). Policy respects role hierarchy.

---

**T06.06** Add billing line-item builder and invoice creation.

Files:
- NEW migration — `create_dental_invoices` (visit_id, total_amount, status, items_json, created_at)
- NEW `app/models/dental_invoice.rb`
- NEW `app/use_cases/dental/billing/create_invoice.rb` — aggregate procedures + medications + supplies → invoice
- NEW `app/use_cases/dental/billing/sync_payment.rb` — callback handler for payment confirmation
- NEW `spec/use_cases/dental/billing/create_invoice_spec.rb`
- NEW `spec/use_cases/dental/billing/sync_payment_spec.rb`

Acceptance: invoice created from visit procedures with coverage-aware pricing. Payment sync updates invoice status and triggers visit auto-complete when fully paid (state-21).

---

**T06.07** Build waiting-payment board and supply/requisition UI (state-19).

Files:
- NEW `app/controllers/dental/billing/waiting_payments_controller.rb`
- NEW `app/views/dental/billing/waiting_payments/index.html.erb` — board matching state-19 wireframe
- NEW `app/controllers/dental/supply/requisitions_controller.rb` — index, show, create, approve, dispense, receive, cancel
- NEW `app/views/dental/supply/requisitions/index.html.erb` — requisition list (state-15)
- NEW `app/views/dental/supply/requisitions/show.html.erb` — requisition detail with lifecycle actions
- MODIFY `config/routes.rb` — add billing + supply routes under dental namespace
- NEW `app/javascript/controllers/payment_polling_controller.js` — auto-refresh every 30s

Acceptance: waiting-payment board shows pending/partial/paid invoices with sync action. Requisition list shows all requisitions with lifecycle actions. Auto-refresh works.

---

**T06.08** Supply/billing API endpoints and group gate.

Files:
- NEW `app/controllers/api/v1/requisitions_controller.rb`
- NEW `app/controllers/api/v1/invoices_controller.rb`
- NEW `app/controllers/api/v1/billing/sync_controller.rb` — payment callback endpoint
- NEW `app/serializers/api/v1/requisition_serializer.rb`
- NEW `app/serializers/api/v1/invoice_serializer.rb`
- NEW `spec/requests/api/v1/requisitions_spec.rb`
- NEW `spec/requests/api/v1/invoices_spec.rb`
- NEW `spec/system/supply_billing_spec.rb`

Acceptance: `bin/ci` passes. All supply/requisition/billing flows work via HTML and API. State machines enforce valid transitions. Idempotency holds.

---

### G07 Tickets — Integration/AuthZ/Audit Hardening

**T07.01** Complete Pundit policy matrix for all 9 roles.

Files:
- MODIFY `app/policies/dental/visit_policy.rb` — role-specific gates: DENTIST can transition clinical stages, REGISTRATION handles check-in, CASHIER handles payment stages
- MODIFY `app/policies/dental/clinical_policy.rb` — DENTIST + DENTAL_ASSISTANT can write, others read-only
- MODIFY `app/policies/dental/requisition_policy.rb` — PHARMACIST approves/dispenses
- NEW `app/policies/dental/billing_policy.rb` — CASHIER manages payment
- NEW `app/policies/dental/print_policy.rb` — all clinical roles can print
- MODIFY `app/integrations/backend/mappers/session_snapshot_mapper.rb` — map JWT roles to policy permissions
- NEW `spec/policies/dental/full_policy_matrix_spec.rb` — exhaustive role × action matrix

Acceptance: every dental action has explicit policy for all 9 roles. Unauthorized actions return `403`. Matrix spec covers all combinations.

---

**T07.02** Provider mapper fixture-based contract parity tests.

Files:
- NEW `spec/fixtures/contracts/dental/*.json` — canonical fixtures for each provider response shape
- MODIFY `spec/integrations/backend/dental/provider_contracts_spec.rb` — verify mapper output matches fixture for all provider methods
- MODIFY `app/integrations/backend/providers/dental/*.rb` — ensure each provider method returns `Result` with consistent shape

Acceptance: every provider method has a fixture-based parity test. Mapper drift is caught by test failure.

---

**T07.03** JWT claims-to-policy context binding.

Files:
- MODIFY `app/integrations/backend/mappers/session_snapshot_mapper.rb` — map `authorization.roles` → BFF permissions when remote API provides roles
- MODIFY `app/domains/security/principal.rb` — add `dental_roles` field
- NEW `spec/integrations/backend/mappers/jwt_role_mapping_spec.rb` — test role → permission mapping for all 9 roles

Acceptance: when JWT provides roles, they map correctly to BFF permissions. Empty roles still get default authenticated permissions. Permission injection is deterministic.

---

**T07.04** Expand audit trail across all actions.

Files:
- MODIFY `app/use_cases/admin/dental/audit_logger.rb` — add event types for workflow transitions, clinical saves, stock movements, requisition changes, print events
- MODIFY `app/models/dental_admin_audit_event.rb` — add event_type scopes
- MODIFY `app/views/admin/dental/audit_events/index.html.erb` — add filter by event type
- NEW `spec/use_cases/admin/dental/audit_trail_coverage_spec.rb`

Acceptance: all significant actions (workflow transition, clinical save, stock movement, admin change, print) are audit-logged. Audit event list filterable by type.

---

**T07.05** Bounded retry strategy and integration error surfaces, group gate.

Files:
- MODIFY `app/integrations/backend/http_client.rb` — bounded retry (max 2 retries, exponential backoff, only on 5xx/timeout)
- MODIFY `app/integrations/backend/errors.rb` — add `RetryExhaustedError`, `CircuitOpenError`
- NEW `spec/integrations/backend/http_client_retry_spec.rb`
- UPDATE all integration specs for retry behavior

Acceptance: `bin/ci` passes. HTTP client retries on transient errors. Permanent errors (4xx) fail fast. Retry count is bounded. Integration failures never corrupt workflow state.

---

### G08 Tickets — Print & Release Gate

**T08.01** Add print preview route and printable CSS shell (state-25).

Files:
- NEW `app/controllers/dental/print/previews_controller.rb` — show action with `:visit_id` and `:type` params
- NEW `app/views/dental/print/previews/show.html.erb` — print preview layout: on-screen controls (language toggle, print button, export PDF), printable page area
- NEW `app/views/layouts/print.html.erb` — minimal layout for printable content (no nav, A4 sizing)
- NEW `app/assets/stylesheets/print.css` — @media print styles, A4 sizing, page breaks
- MODIFY `config/routes.rb` — add print routes
- NEW `app/controllers/api/v1/print/documents_controller.rb` — API endpoint for print data
- NEW `spec/requests/dental/print/previews_spec.rb`

Acceptance: print preview matches state-25 wireframe. Print button opens browser print dialog. Printable area renders correctly at A4 size.

---

**T08.02** Add treatment summary and certificate print templates.

Files:
- NEW `app/views/dental/print/previews/_treatment_summary.html.erb` — bilingual template: diagnosis, procedures table, medications, totals, dentist signature line
- NEW `app/views/dental/print/previews/_certificate.html.erb` — dental certificate template with official layout
- NEW `app/queries/dental/print/treatment_summary_query.rb` — aggregate visit data for print
- NEW `spec/queries/dental/print/treatment_summary_query_spec.rb`

Acceptance: treatment summary shows all visit procedures, medications, and pricing. Certificate renders with proper official layout. Both support EN/TH toggle.

---

**T08.03** Add dental chart print template.

Files:
- NEW `app/views/dental/print/previews/_dental_chart.html.erb` — tooth chart with conditions marked, legend, patient demographics
- NEW `app/queries/dental/print/dental_chart_query.rb` — cumulative chart data for print

Acceptance: printed chart shows all tooth conditions. Legend is clear. Print renders correctly on A4.

---

**T08.04** Add legal/provisional watermark and print policy checks.

Files:
- MODIFY `app/views/dental/print/previews/show.html.erb` — watermark overlay toggle (PROVISIONAL / FINAL / INTERNAL USE)
- MODIFY `app/controllers/dental/print/previews_controller.rb` — authorize print access per `Dental::PrintPolicy`
- MODIFY `app/policies/dental/print_policy.rb` — check `print:read` permission, blocked stages (state-26)
- NEW `spec/policies/dental/print_policy_spec.rb`

Acceptance: unauthorized users see forbidden page (state-26). Provisional watermark appears on non-finalized visits. Final prints have no watermark. Watermark cannot be removed by CSS manipulation.

---

**T08.05** Release gate and final quality checks.

Files:
- RUN `bin/ci` — full verification pass
- RUN `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error` — zero security warnings
- RUN `bin/bundler-audit` — no known vulnerabilities
- RUN `bin/importmap audit` — clean
- RUN `bundle exec i18n-tasks health` — no missing/unused keys
- VERIFY all 38 UI states have corresponding implementation
- VERIFY all 7 flows execute end-to-end
- VERIFY all API endpoints documented and tested

Acceptance: all quality gates pass. Full system is production-ready. Admin.s/123 can access all flows.

---

## API Route Summary

```ruby
# config/routes.rb addition
namespace :api do
  namespace :v1 do
    resources :queues, only: [:index, :create]
    resources :visits, only: [:show] do
      member { patch :transition; post :check_in }
      resources :clinical_posts, only: [:index, :create], module: :visits
    end
    namespace :admin do
      resources :procedure_items, except: :show
      resources :medication_profiles, except: :show
      resources :supply_items, except: :show
      resources :supply_categories, except: :show
      resources :references, only: [:index, :create, :update, :destroy]
      resources :coverages, except: :show
    end
    resources :requisitions, only: [:index, :show, :create] do
      member { post :approve; post :dispense; post :receive; post :cancel }
    end
    resources :invoices, only: [:index, :show]
    namespace :billing do
      post :sync, to: "sync#create"
    end
    namespace :print do
      get ":visit_id/:type", to: "documents#show", as: :document
    end
  end
end
```

## Runtime State Block

```text
BOARD_MODE: SINGLE_FILE
BOARD_VERSION: 2
REQUIREMENTS_MUTABILITY: FROZEN

CURRENT_GROUP: G01
GROUP_STATUS: NOT_STARTED
NEXT_TICKET: T01.01

LAST_COMPLETED_TICKET: NONE (v2 fresh start)
LAST_COMMIT_SHA: NONE
LAST_CHECKS_PASSED: INIT
LAST_UPDATED_UTC: 2026-04-11T00:00:00Z

PRESERVED_BASELINE:
- Auth: COMPLETE (remote JWT + refresh)
- Domain: COMPLETE (state machine, enums, errors, typed IDs)
- Models: COMPLETE (24 models, 10 migrations)
- Use cases: COMPLETE (19 use cases)
- Queries: COMPLETE (12 queries)
- Policies: COMPLETE (11 policies, basic set)
- Integration: COMPLETE (13 files, provider stubs)
- Tests: 198+ specs passing

UAT_GATE_STATUS:
- G01: PENDING
- G02: PENDING
- G03: PENDING
- G04: PENDING
- G05: PENDING
- G06: PENDING
- G07: PENDING
- G08: PENDING
```

## Stop Gate Request Template

```
Group completed: Gxx
Tickets done: Txx.01 to Txx.nn
Checks passed: rubocop, rspec, ci
Please click-test:
- [ ] HTML view behavior matches design wireframe
- [ ] API endpoint returns correct JSON
- [ ] Policy enforcement works for authorized/unauthorized users
- [ ] Mobile responsive layout acceptable
Reply: APPROVE Gxx / REJECT Gxx with findings
```
