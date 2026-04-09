# Dental Web

## Setup

```bash
bin/setup
```

## Verification

```bash
bin/ci
bin/rspec spec/system
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
