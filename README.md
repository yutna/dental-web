# Dental Web

## Setup

```bash
bin/setup
```

## Development

```bash
bin/dev
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
