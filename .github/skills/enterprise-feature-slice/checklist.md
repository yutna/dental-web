# Enterprise feature slice checklist

## Contract
- Canonical request/response shape defined
- Error payload and status behavior defined
- Local and remote mapping expectations documented

## Authorization
- Pundit policy exists for changed surfaces
- No direct role checks in controllers/views

## UX and localization
- Light/dark parity considered
- Keyboard/focus behavior preserved
- EN/TH i18n keys added and normalized

## Tests
- Request behavior covered
- Policy behavior covered
- Contract/mapping behavior covered
- Regression test added for fixed bug (if applicable)

## Verification
- RuboCop passes
- RSpec passes
- i18n-tasks health passes
- bin/ci passes
