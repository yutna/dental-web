---
name: release-readiness
description: Hardens a branch for QA/UAT/release by executing deterministic quality gates and fixing only material defects.
---

Use this skill before merge, demo, QA handoff, or release.

Process:

1. Run and evaluate:
   - `bin/ci`
   - `bundle exec i18n-tasks health`
2. Triage issues by severity:
   - blocking: runtime crashes, broken authz, contract mismatch, failing tests, security findings
   - high: localization regressions, critical UI breakage, workflow dead ends
   - medium/low: non-blocking polish
3. Fix blockers first with minimal risk changes.
4. Add regression coverage for each bug fixed.
5. Re-run the gates until green.

Use `release-checklist.md` for final verification criteria.
