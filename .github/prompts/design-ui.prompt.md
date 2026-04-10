---
name: design-ui
description: Generate Rails Hotwire ASCII wireframes and UI design artifacts from task specs.
---

# /design-ui

Generate ASCII wireframes and design-ready UI artifacts for this Rails BFF repository.
Output should cover all meaningful UI states and map directly to Rails routes and component decisions.

## Behavioral mode

- You are in UI design mode only.
- Do not write implementation code.
- Produce design artifacts and handoff notes only.

## Inputs

- Feature slug (kebab-case): `${input:feature_slug}`
- Source requirement path or summary: `${input:source}`
- In-scope screens/flows: `${input:scope}`
- Out-of-scope items: `${input:out_of_scope}`

## Repository context (must follow)

- Stack: Rails 8.1 + Hotwire (Turbo + Stimulus via importmap), not Next.js route/runtime semantics.
- Routing: user-facing screens are locale-scoped (`/en`, `/th`).
- Authorization: policy-first with Pundit; include unauthorized/forbidden states in design where relevant.
- UI baseline: `config/ui_component_specs.yml` (accessibility, skeleton loading, data grid/searchable select contracts).
- Design system: semantic app tokens (`--color-app-*`) from `app/assets/tailwind/tokens.generated.css`.
- UI implementation conventions: `.github/instructions/ui-hotwire.instructions.md`.

## Prepared tools and assets to use

1. Specs from `docs/tasks/<feature>/` (especially `00-specifications.md`, `01-overview.md`).
2. UI contracts in `config/ui_component_specs.yml`.
3. Existing prompt assets:
   - `.github/prompts/decompose-requirements.prompt.md` (if requirement is not yet decomposed)
   - `.github/prompts/spec-to-qa-readiness.prompt.md` (for QA handoff structure)
4. Custom agents for downstream handoff:
   - `bff-implementer` (implementation)
   - `release-hardening` (release/QA readiness)

---

## Step 1: Read source spec

- Prefer `docs/tasks/<feature>/` if available.
- Extract: feature intent, state machine states/transitions, acceptance criteria, roles, and data surfaces.
- If no task spec exists, first require decomposition via `decompose-requirements`.

## Step 1.5: UI element inventory (required)

Build a manifest for every UI surface from source material:

```txt
Forms & data entry:
[ ] Primary forms
[ ] Shared/imported forms
[ ] Search/selector drawers
[ ] Inline edit affordances

Overlays:
[ ] Confirmation dialogs
[ ] Warning/blocked-action dialogs
[ ] Error-specific modals
[ ] Side drawers

Data displays:
[ ] KPI/stat cards
[ ] Data tables (with required columns)
[ ] Detail panels
[ ] Timeline/activity areas
[ ] Print/export surfaces

Cross-cutting:
[ ] Role-differentiated views
[ ] Permission-conditioned actions
[ ] Async/integration feedback states
[ ] Locale-sensitive copy areas (`en`, `th`)
```

Classify depth:

- Lite: simple pages with minimal overlays
- Standard: forms + overlays/drawers + error differentiation
- Full: multi-tab workflows, shared forms, integration feedback, role-specific variants

## Step 2: Select page pattern + density

Declare:

- Primary layout pattern (dashboard/workspace/list-detail/form-centric)
- Density (`compact` or `cozy`)
- Required page regions (app shell, page header, filters, primary content, side context)
- Accessibility focus (keyboard path, focus visibility, reduced motion, contrast)

## Step 3: Route map using Rails semantics

Map route states in Rails terms:

- List every route as `/[locale]/...`
- Note controller/action ownership
- Note Turbo Frame/modal/drawer behavior if used
- Note auth boundary for each route (`public`, `signed-in`, policy-gated)

Do not use Next.js-specific constructs (`(public)/(private)`, `@slot`, intercepting routes).

## Step 3.5: Complete state and overlay inventory

Enumerate all wireframes to render:

1. Mandatory page states: loading, empty, error, permission-denied, populated
2. Workflow stage states from source transitions
3. Tab/view variants
4. Modal/dialog variants (including blocked actions)
5. Drawer/selector variants
6. Inline feedback and integration status variants
7. Print/export trigger states where applicable

Gate before rendering:

```txt
[ ] Every form has at least one wireframe
[ ] Every modal/dialog has an overlay wireframe
[ ] Every drawer/selector has a wireframe
[ ] Every distinct error state has a wireframe
[ ] Every tab/view variant has a wireframe
```

## Step 4: Render ASCII wireframes

Rules:

- Render full page context (app shell + active nav + page header + content).
- Render each state from Step 3.5 as a separate state artifact.
- Overlay rule: modals/drawers must be shown over underlying page state.
- Width target: approximately 90 characters.
- Use realistic fake data, not placeholders.

Annotate each wireframe with:

- Route and locale context
- Core components and interactions
- Trigger → transition notes
- Permission/policy constraints if applicable

Selector guidance:

- Prefer accessible roles/labels in notes.
- Include `data-testid` only when the feature/test plan explicitly requires it.

Each state file must include:

- `## Visual direction` (3-7 lines on layout, emphasis, token usage, motion, responsive intent)

Visual direction must reference repository styling constraints:

- Use semantic app tokens (`app-*`), not hardcoded colors.
- Preserve light/dark parity.
- Prefer skeleton/inline progress over blocking full-page spinners.

## Step 5: Render flow diagram

Create an ASCII flow showing success and failure paths:

```txt
[Entry] -> [Action] -> [State] -> [Action] -> [State]
                           \-> [Error action] -> [Error state]
```

## Step 5.5: Completeness verification

Create traceability matrix:

```txt
| Requirement item | Category | Wireframed? | State/flow file | Notes |
|------------------|----------|-------------|-----------------|-------|
```

Required checks:

```txt
[ ] Every required form is represented
[ ] Every required overlay is represented
[ ] Every required table column/KPI is represented
[ ] Every distinct error/permission state is represented
[ ] Every locale-sensitive state is represented where user-facing
[ ] Every state file contains a Visual direction section
```

Do not finalize artifacts until all checks pass.

## Step 6: Write artifacts

Write all files under:

`docs/ui/<feature-slug>/`

Required outputs:

- `docs/ui/<feature-slug>/README.md`
  - Summary, route map, state inventory, grouping index
- `docs/ui/<feature-slug>/flow-<nn>-<slug>.md`
  - One file per major user flow
- `docs/ui/<feature-slug>/state-<nn>-<slug>.md`
  - One file per UI state (with wireframe + Visual direction + transitions)

Use deterministic zero-padded numbering (`01`, `02`, ...).

## Step 7: Chat summary format

Return concise summary with:

```txt
Pattern:  [selected pattern]
Density:  compact|cozy
Routes:   /[locale]/...
States:   loading, empty, error, permission-denied, populated, ...
Files:    docs/ui/<feature-slug>/README.md
          docs/ui/<feature-slug>/flow-01-...
          docs/ui/<feature-slug>/state-01-...
```

## Rules

- Show all critical states, not only happy path.
- Keep artifacts design-only (no React/Rails implementation code).
- Keep output repository-specific and handoff-ready for prepared implementation and QA tooling.
