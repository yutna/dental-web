---
applyTo: "spec/**/*.rb,config/ci.rb,bin/ci,.github/workflows/**/*.yml"
---

# Testing and quality instructions

- `bin/ci` is the authoritative quality gate; changes should keep it green end-to-end.
- Prefer request specs for controller/BFF behavior, policy specs for authorization, and service/query specs for domain logic.
- Add regression specs for every bug fix that changes behavior.
- Keep specs deterministic and isolated; avoid order-dependent or environment-dependent assumptions.
- Use Factory Bot and shared helpers from `spec/support` instead of ad-hoc setup duplication.
- For i18n changes, keep keys normalized and verify `bundle exec i18n-tasks health`.
- For contract-sensitive features, include parity checks between local and remote provider mappings.
- For bug/defect/regression fixes, update at least one Copilot guardrail artifact (`instructions`, `skills/checklists`, or prompt templates) to prevent repeat defects.
