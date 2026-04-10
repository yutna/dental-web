# Release readiness checklist

- `bin/ci` passed
- no unresolved contract mismatch in BFF mappings
- contract mismatch artifacts reviewed when present (`tmp/contract_diffs` / CI artifact)
- auth flow works (sign-in/sign-out/workspace access)
- admin access policy gates verified
- critical locale paths (`/en`, `/th`) behave correctly
- i18n health normalized
- bug-fix PRs include defect feedback loop updates to instructions/skills/prompts
- no known blocking bug left for QA scenarios
