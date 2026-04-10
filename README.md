# Dental Web

## Setup

```bash
bin/setup
```

## Development

```bash
bin/dev
```

## BFF foundation

This Rails app is the front-end team's BFF host. The UI contract is canonical and backend-API-backed.

- Runtime (development/production): calls real backend APIs
- Test suite: uses deterministic in-process providers for isolated verification

Backend connection settings:

- `BACKEND_API_BASE_URL` (default `http://localhost:3001`)
- `BACKEND_API_OPEN_TIMEOUT` (default `2`)
- `BACKEND_API_READ_TIMEOUT` (default `5`)
- `BFF_CONTRACT_DIFF_DIR` (default `tmp/contract_diffs`)

Recommended architecture boundaries:

- `app/domains/*` for domain objects
- `app/use_cases/*` for write/orchestration logic
- `app/queries/*` for read/query logic
- `app/integrations/backend/*` for API adapters and mappers
- `app/policies/*` for Pundit authorization

## Gem rollout phases

1. Foundation now: `pundit`, `faraday`, `faraday-retry`, `pagy`, `ransack`
2. Optional workflow complexity: `state_machines-activerecord`
3. Admin ergonomics (if needed later): evaluate `administrate` against current custom `/admin` namespace

## UI/UX baseline (2026+)

- Clinical SaaS shell (sidebar + top app bar + data-dense workspace)
- Accessible by default (focus states, keyboard navigation, contrast)
- Skeleton-first loading for async updates
- Data grid + searchable combobox baseline components
- Semantic color token usage via `app-*` variables
- Global scrollbar styling is token-based, cross-browser (`scrollbar-color/width` + `::-webkit-scrollbar*`), and theme-aware

Detailed component contracts live in `config/ui_component_specs.yml`.

## Contract testing baseline

- Local/remote contract parity specs: `spec/integrations/backend/session_contract_spec.rb`
- Auth orchestration specs: `spec/use_cases/security/sign_in_spec.rb`
- Policy and request-level access control specs in `spec/policies` and `spec/requests`
- Contract mismatch reports: JSON artifacts under `tmp/contract_diffs`

## Copilot enterprise workflow

- Repository-wide instructions: `.github/copilot-instructions.md`
- Path-specific instructions: `.github/instructions/*.instructions.md`
- Custom agents (CLI + cloud agent): `.github/agents/*.agent.md`
- Project skills: `.github/skills/*/SKILL.md`
- Guardrail hooks: `.github/hooks/safety-guardrails.json` (uses `script/copilot_hooks/pre_tool_use_guard.rb`)
- Prompt templates for IDE surfaces: `.github/prompts/*.prompt.md`
- PR gate template: `.github/pull_request_template.md`
- QA defect loop issue template: `.github/ISSUE_TEMPLATE/qa-defect-feedback.yml`

Recommended usage:

```bash
# In Copilot CLI
/skills list
/agent
/mcp show

# In local CI checks
ruby script/ci/validate_copilot_assets.rb
bash script/ci/contract_guardian
```

## Verification

```bash
bin/ci
bin/rspec spec/system
```

## Tailwind CSS

- Source file: `app/assets/tailwind/application.css`
- Build output: `app/assets/builds/tailwind.css`
- `bin/dev` runs Rails + `bin/rails tailwindcss:watch` via `Procfile.dev`
- Official plugins enabled: `@tailwindcss/forms`, `@tailwindcss/typography`, `@tailwindcss/aspect-ratio`
- Tailwind v4 includes container queries and line clamp in core utilities (no plugin install needed)
- Theme switching supports `light`, `dark`, and `system` (follows device preference) on the homepage
- Brand token source: `config/design_tokens/brand_tokens.json`
- Generated theme tokens: `app/assets/tailwind/tokens.generated.css` via `bin/rails design_tokens:build`

```bash
# One-off Tailwind build
bin/rails tailwindcss:build

# Regenerate Tailwind color tokens from design source
bin/rails design_tokens:build

# Production-style asset precompile check
SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
```

## Localization (English + Thai)

- Locale is required in the URL path: `/en`, `/th`
- Unprefixed root `/` redirects to `/en`
- Health check remains locale-agnostic at `/up`
- Translation files:
  - `config/locales/en.yml`
  - `config/locales/th.yml`

### I18n workflow

```bash
bundle exec i18n-tasks health
bundle exec i18n-tasks missing
bundle exec i18n-tasks normalize
```
