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

```bash
# One-off Tailwind build
bin/rails tailwindcss:build

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
