---
name: enterprise-feature-slice
description: Implements a full feature slice with canonical contract, policy, and QA-ready verification artifacts.
---

Implement a production-grade feature slice in this Rails BFF repository.

Inputs:
- Feature name: ${input:feature_name}
- Requirement summary: ${input:requirement_summary}
- Acceptance criteria: ${input:acceptance_criteria}
- Authorization rule(s): ${input:authorization_rules}
- Canonical contract fields: ${input:contract_fields}

Instructions:

1. Confirm scope boundaries and assumptions.
2. Propose canonical request/response shape and error semantics.
3. Implement by architecture layer:
   - domain/use_case/query/integration/policy/controller/view
4. Keep provider mapping isolated; do not leak provider-specific field names to views.
5. Add tests:
   - request spec
   - policy spec
   - contract parity/mapping spec if integration is affected
6. Update i18n keys (`en` and `th`) for user-facing strings.
7. Run and report results from:
   - `bin/rubocop`
   - `bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"`
   - `bundle exec i18n-tasks health`
   - `bin/ci`

Output format:
- Summary of implemented layers
- Contract details
- Test coverage added
- Validation results
- Remaining risks or follow-ups
