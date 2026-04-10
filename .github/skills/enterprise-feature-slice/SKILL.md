---
name: enterprise-feature-slice
description: Implements a requirement as a full Rails BFF feature slice with canonical contracts, policy enforcement, and regression coverage.
---

Use this skill when a user asks to implement a feature end-to-end.

Execution checklist:

1. Clarify feature boundaries and acceptance criteria.
2. Define/confirm canonical contract fields and error semantics.
3. Implement by layer:
   - domain object(s)
   - use case(s)
   - integration mapper/provider updates
   - policy updates
   - controller/view updates
4. Add tests:
   - request spec for user-facing behavior
   - policy spec for authz
   - contract/mapper parity spec where relevant
5. Verify with repository gates:
   - `bin/rubocop`
   - `bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"`
   - `bundle exec i18n-tasks health` for i18n changes
   - `bin/ci` for final pass

Use the detailed checklist in `checklist.md` from this skill directory.
