---
name: spec-to-qa-readiness
description: Converts requirements into contract, implementation, and QA verification matrices for this repository.
---

Convert requirement text into an implementation + QA-ready delivery package.

Inputs:
- Requirement document excerpt: ${input:req_excerpt}
- In-scope screens/flows: ${input:scope}
- Out-of-scope items: ${input:out_of_scope}
- Priority/risk areas: ${input:risk_areas}

Tasks:

1. Produce a requirements-to-contract matrix:
   - requirement item
   - canonical payload fields
   - policy requirements
   - expected error behavior
2. Produce a test matrix:
   - request specs
   - policy specs
   - integration/contract parity specs
   - system specs (only critical journeys)
3. Produce QA checklist:
   - happy path
   - edge cases
   - auth/authz checks
   - locale checks (`/en`, `/th`)
   - light/dark UI behavior
4. Identify missing implementation artifacts in this repository.
5. Generate an execution order minimizing rework risk.

Constraints:
- Keep architecture aligned with BFF conventions in `.github/copilot-instructions.md`.
- Keep recommendations directly actionable and repository-specific.
