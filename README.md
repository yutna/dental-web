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

This Rails app is the front-end team's BFF host. The UI contract is canonical and provider-backed:

- `BFF_PROVIDER_MODE=local` (default): full local Rails implementation
- `BFF_PROVIDER_MODE=remote`: calls real backend API
- `BFF_PROVIDER_MODE=dual_compare`: compares local/remote contract output

Backend connection settings:

- `BACKEND_API_BASE_URL` (default `http://localhost:3001`)
- `BACKEND_API_OPEN_TIMEOUT` (default `2`)
- `BACKEND_API_READ_TIMEOUT` (default `5`)

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
