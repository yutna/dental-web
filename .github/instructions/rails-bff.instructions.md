---
applyTo: "app/controllers/**/*.rb,app/use_cases/**/*.rb,app/integrations/**/*.rb,app/domains/**/*.rb,app/policies/**/*.rb,config/routes.rb,config/application.rb"
---

# Rails BFF implementation instructions

- Build each feature against the Rails-owned canonical contract, then map provider-specific payloads in adapters/mappers.
- Keep controllers thin; place orchestration in use cases and keep contract translation in integration layers.
- Do not branch feature behavior by provider mode in views/controllers; provider switching must stay in `Backend::ProviderRegistry` and provider classes.
- Enforce authorization through Pundit policies; do not hardcode role checks in controllers.
- Preserve locale-scoped routes and `default_url_options` behavior for all user-facing paths.
- Prefer explicit domain errors over silent fallbacks; if a contract mismatch occurs, surface it with a clear message and deterministic flow.
- For backend calls, keep timeout/retry behavior centralized in `Backend::HttpClient`.
- For new feature slices, include request specs and contract/policy tests in the same change.
