# Authentication + Dashboard Shell UI Design

## Summary

- Feature slug: `authentication-dashboard-shell`
- Intent: design a locale-aware sign-in experience and a future-ready dental dashboard shell with profile dropdown controls at top-right.
- Scope: authentication states, workspace shell baseline states, profile dropdown (theme/language/logout/profile snippet).
- Out of scope: clinical CRUD detail screens, admin service management CRUD, provider-specific payload mapping.

## Source used

- No `docs/tasks/<feature>/` package exists yet.
- Source requirement inferred from:
  - Existing routes/controllers/views for auth and workspace shell
  - Existing i18n strings (`en`, `th`)
  - `config/ui_component_specs.yml` loading/accessibility/data-grid contracts
  - User request for top-right profile dropdown with theme/language/logout/profile detail

## Step 1.5 UI element inventory

Forms & data entry:

- [x] Primary forms: sign-in form (email, password)
- [x] Shared/imported forms: workspace search + status filter
- [ ] Search/selector drawers: none in this feature baseline
- [ ] Inline edit affordances: none

Overlays:

- [ ] Confirmation dialogs: none in baseline
- [ ] Warning/blocked-action dialogs: none in baseline
- [ ] Error-specific modals: none (inline banners + inline alert region)
- [x] Side drawers: none; replaced with profile dropdown overlay popover

Data displays:

- [x] KPI/stat cards: dashboard summary strip
- [x] Data tables: appointment queue columns (`id`, `patient_name`, `mrn`, `service`, `dentist`, `starts_at`, `status`)
- [ ] Detail panels: none
- [ ] Timeline/activity areas: reserved empty block in shell
- [ ] Print/export surfaces: not in scope

Cross-cutting:

- [x] Role-differentiated views: admin nav item visibility only
- [x] Permission-conditioned actions: workspace policy gate (`workspace:read`)
- [x] Async/integration feedback states: skeleton loading, invalid credentials, contract mismatch, queue fetch error
- [x] Locale-sensitive copy areas (`en`, `th`)

Depth classification:

- **Standard** (forms + overlay dropdown + differentiated error states + policy-gated route)

## Step 2 Page pattern + density

- Primary layout pattern: **workspace/list-detail hybrid** (left shell nav + right content stream).
- Density: **cozy** (readable in mixed clinical context, still data-dense in queue table).
- Required page regions:
  - app shell (left nav desktop; compact top shell mobile)
  - page header (title, subtitle, global actions)
  - filters row
  - primary content (KPI strip + queue table / empty/error state)
  - side context slot (future widgets, currently placeholder panel)
- Accessibility focus:
  - keyboard path: skip-to-content -> top-right profile trigger -> nav -> filters -> data grid
  - visible focus ring on every interactive control
  - reduced motion: shimmer and transitions respect reduced motion
  - contrast target: WCAG AA using semantic app tokens

## Step 3 Route map (Rails)

| Route | Controller#action | Turbo behavior | Auth boundary |
| --- | --- | --- | --- |
| `/en` `/th` | `HomeController#index` | full-page | public |
| `/[locale]/session/new` | `Auth::SessionsController#new` | full-page | public (redirect to workspace if already signed in) |
| `POST /[locale]/session` | `Auth::SessionsController#create` | full-page submit | public |
| `DELETE /[locale]/session` | `Auth::SessionsController#destroy` | standard delete action | signed-in |
| `/[locale]/workspace` | `WorkspaceController#show` | filter submits into `turbo-frame#appointments_grid` | signed-in + policy-gated (`workspace:show?`) |

Notes:

- Locale must be URL-scoped (`/en`, `/th`) for all user-facing routes.
- Invalid locale route redirects to default locale.
- Profile dropdown is a top-right overlay popover (no route change, Stimulus-like behavior).

## Step 3.5 Complete state/overlay inventory

1. Mandatory page states:
   - loading: `state-04-dashboard-loading-skeleton.md`
   - empty: `state-05-dashboard-empty-first-login.md`
   - error: `state-09-dashboard-queue-error-inline.md`
   - permission-denied: `state-10-workspace-permission-denied.md`
   - populated: `state-06-dashboard-populated.md`
2. Workflow stage states:
   - sign-in default: `state-01-sign-in-default.md`
   - sign-in invalid credentials: `state-02-sign-in-invalid-credentials.md`
   - sign-in contract mismatch: `state-03-sign-in-contract-mismatch.md`
3. Tab/view variants:
   - shell nav highlight overview vs queue in populated state
4. Modal/dialog variants:
   - none in baseline
5. Drawer/selector variants:
   - profile dropdown open: `state-07-profile-dropdown-open.md`
   - profile dropdown theme/language action feedback: `state-08-profile-dropdown-theme-language.md`
6. Inline feedback/integration variants:
   - auth alert variants (`invalid_credentials`, `contract_mismatch`)
   - queue data-fetch error inline banner + retry action
7. Print/export trigger states:
   - not in scope

Gate check:

- [x] Every form has at least one wireframe
- [x] Every modal/dialog has an overlay wireframe (none defined)
- [x] Every drawer/selector has a wireframe
- [x] Every distinct error state has a wireframe
- [x] Every tab/view variant has a wireframe

## Step 5.5 Traceability matrix

| Requirement item | Category | Wireframed? | State/flow file | Notes |
| --- | --- | --- | --- | --- |
| Locale-scoped sign-in route | route/auth | Yes | `state-01`, `flow-01` | `/en` and `/th` copy variants represented |
| Invalid credentials feedback | error/auth | Yes | `state-02`, `flow-01` | inline alert + preserved email |
| Contract mismatch feedback | error/integration | Yes | `state-03`, `flow-01` | explicit backend mismatch message |
| Workspace shell baseline | dashboard/layout | Yes | `state-04`, `state-05`, `state-06` | loading/empty/populated states |
| Policy-denied workspace access | authorization | Yes | `state-10`, `flow-02` | redirect + alert path represented |
| Top-right profile dropdown | global nav/profile | Yes | `state-07`, `state-08`, `flow-02` | includes profile snippet, theme/language/logout |
| Theme switch options Light/Dark/System | personalization | Yes | `state-08`, `flow-02` | semantic token parity required |
| Language switcher in dropdown | localization | Yes | `state-08`, `flow-02` | toggle EN/TH without losing context |
| Logout action in dropdown | auth/session | Yes | `state-07`, `flow-02` | delete session, redirect to sign-in/home flow |
| Queue data grid required columns | data contract | Yes | `state-06`, `state-09` | all required columns included |

Required checks:

- [x] Every required form is represented
- [x] Every required overlay is represented
- [x] Every required table column/KPI is represented
- [x] Every distinct error/permission state is represented
- [x] Every locale-sensitive state is represented where user-facing
- [x] Every state file contains a Visual direction section

## Artifact index

Flow files:

- `flow-01-authentication.md`
- `flow-02-dashboard-shell-profile.md`

State files:

- `state-01-sign-in-default.md`
- `state-02-sign-in-invalid-credentials.md`
- `state-03-sign-in-contract-mismatch.md`
- `state-04-dashboard-loading-skeleton.md`
- `state-05-dashboard-empty-first-login.md`
- `state-06-dashboard-populated.md`
- `state-07-profile-dropdown-open.md`
- `state-08-profile-dropdown-theme-language.md`
- `state-09-dashboard-queue-error-inline.md`
- `state-10-workspace-permission-denied.md`
