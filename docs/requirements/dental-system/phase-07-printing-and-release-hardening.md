# Phase 07 - Printing, Hardening, and Ready-to-Implement Signoff

## Goal

Close production gaps, finalize acceptance evidence, and reach implementation readiness:

- Print flows required by TOR category 6
- Final performance and concurrency checks
- Cross-locale content verification
- End-to-end regression pack
- Regulatory audit package and signoff checklist

## Scenarios covered

- `@must` print journey access and output routes
- `@must` regulator-audit traceability completeness
- `@should` performance targets met under expected load

## Scope (files/directories)

- `app/controllers/dental/print/*`
- `app/views/dental/print/*`
- `app/policies/dental/print_policy.rb`
- `spec/system/dental/*`
- `spec/requests/dental/print/*`
- `docs/tasks/dental-system/*` (final audit adjustments)

## Implementation details carried from specifications

- Implement print surfaces:
  - appointment print
  - medical certificate print (dental)
  - treatment summary print
  - dental chart print
- Ensure role constraints from permission matrix are enforced.
- Include bilingual output checks where required.
- Package TOR traceability and test evidence for audit review.

## Risk notes and guard conditions

- Risk: legal templates not finalized for government acceptance.
  - Guard: block production release until legal template approval flag is complete.
- Risk: missing test evidence for "100% coverage" claim.
  - Guard: verify traceability rows all map to passing tests before signoff.

TODO markers to preserve in implementation:

- TODO (P07-DL-001): confirm official print form numbers, signature blocks, and stamp placement requirements.
- TODO (P07-DL-001): confirm archival retention and watermarking obligations for printed/printed-to-PDF outputs.

## Decision log (phase 07)

| Decision ID | Temporary decision | Scope | Fallback | Exit criteria |
|---|---|---|---|---|
| P07-DL-001 | Print outputs are marked provisional and restricted to internal validation environments until legal signoff. | Appointment/certificate/treatment/chart print flows. | If legal template unavailable, hide production print actions by feature flag. | Legal authority approves official templates and mandatory metadata. |
| P07-DL-002 | Release gate requires zero open `@must` traceability gaps and passing CI + i18n health. | Final go-live decision for dental feature slice. | Block release and auto-generate unresolved gap report. | Governance approves exception waiver (if any). |
| P07-DL-003 | Performance hardening uses measured baseline before optimization refactors. | Queue, pricing, deduction, and print generation paths. | Keep functionality-first path and record SLA misses for phase follow-up. | Performance targets are met in repeatable environment test runs. |

## Tests to add/update in this phase

- System specs for critical dental workflows end-to-end.
- Request and policy specs for print/report permissions.
- Contract regression pack across all integration boundaries.
- i18n health check for all newly added locale keys.
