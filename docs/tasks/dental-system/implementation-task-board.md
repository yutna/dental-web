# Dental System Companion Implementation Task Board

Purpose: companion execution board for AI-driven implementation with strict atomic commits, deterministic checks, and human UAT stop-gates between smallest playable feature groups.

Source coverage target: 100% of files in docs/tasks/dental-system and docs/ui/dental-system.

Total source files covered: 59.

- Requirements set: 11 files.
- UI design/flows/states set: 48 files.

## Execution Contract (Mandatory)

- Atomic rule: 1 task = 1 commit only.
- Quality rule: every task must pass lint + tests before commit.
- Group rule: AI runs tasks sequentially until group done, then STOP for human click-test on real web app.
- Continue rule: proceed to next group only after human approves current group.
- No task skipping and no parallel coding across tasks in the same group.

Per-task mandatory checks:

1. bin/rubocop
2. bin/rspec task-related-specs
3. bundle exec i18n-tasks health when locale keys changed

Per-group mandatory checks:

1. bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"
2. bin/rspec spec/system/group-related
3. bin/ci

Definition of Done for every task:

- Code implemented for that ticket only.
- Related tests added or updated and passing.
- Lint clean.
- No unrelated file churn.
- Commit message format: [Txx.yy] short summary.

Knowledge graph contract:

1. Requirements knowledge graph is available at docs/tasks/dental-system/knowledge-graph.json.
2. Design UI knowledge graph is available at docs/ui/dental-system/knowledge-graph.json.
3. AI must treat this task board as execution source of truth and use both graphs for consistency and coverage verification.
4. If board content and graph content conflict, AI must stop and report blocker instead of guessing.

## Group Roadmap (Smallest Playable Feature Slices)

### G01 Foundation and Contract Skeleton

Outcome: security baseline, locale-scoped dental routes, canonical errors/enums, base policies/controllers, provider skeletons.

Stop Gate 1 playable check: user can navigate locale dental endpoints and see correct auth, forbidden, and not-found behavior.

### G02 Master Data and Admin Console

Outcome: admin dashboard, CRUD, soft-delete guards, bulk import conflict flow, maker-checker, audit events.

Stop Gate 2 playable check: admin can manage master data end-to-end safely.

### G03 Visit Workflow and Queue

Outcome: queue states, visit state machine, guard rails, timeline, payment-bridge hooks.

Stop Gate 3 playable check: staff can move a visit through lifecycle with valid or invalid transition feedback.

### G04 Clinical Forms and History

Outcome: form save flows, validation errors, high-alert and allergy warnings, cumulative history views.

Stop Gate 4 playable check: dentist can enter forms and see history projections.

### G05 Supply, Requisition, Billing Sync

Outcome: usage deduction states, requisition lifecycle guards, cashier waiting-payment and auto-complete sync.

Stop Gate 5 playable check: stock and billing workflows execute with proper failure handling.

### G06 Integration/AuthZ/Audit Hardening

Outcome: mapper parity, policy matrix for all roles, signed callbacks, retry boundaries, complete privileged audit trails.

Stop Gate 6 playable check: role-based boundaries and integration failure paths are reliable.

### G07 Print and Release Hardening

Outcome: print previews, forbidden print state, legal/provisional controls, release traceability gate.

Stop Gate 7 playable check: printable outputs are correct and release gate passes.

## Atomic Task Tickets

Notes:

- IDs are issue-sized.
- Each ticket is one focused commit.
- Acceptance checks are executable.

### G01 Tickets

- T01.01 Add dental error taxonomy and enum value objects.
- T01.02 Add dental base controller and policy base with deny-by-default.
- T01.03 Create dental provider interfaces and typed result contracts.
- T01.04 Add locale-scoped routes for dental and admin-dental namespaces.
- T01.05 Add dental base domain entities/use-case base and typed IDs.
- T01.06 Add initial dental locale dictionary in en/th.
- T01.07 Add foundation request specs for forbidden/not-found/invalid-transition.
- T01.08 Group gate and decision log for foundation.

Acceptance checks for G01 tickets:

- Relevant domain/request/policy/integration specs added and passing.
- Forbidden, not-found, and invalid-transition contracts deterministic.
- T01.08 must pass bin/ci.

### G02 Tickets

- T02.01 Add master-data models and migrations for procedure/medication/supply/reference catalogs.
- T02.02 Add coverage models and runtime pricing fallback resolver.
- T02.03 Build admin dental dashboard query and screen.
- T02.04 Build admin CRUD screens and endpoints with optimistic lock support.
- T02.05 Add soft-delete and referenced-record deactivation guards.
- T02.06 Implement bulk import with conflict detection/resolution.
- T02.07 Implement maker-checker flow for sensitive pricing/coverage changes.
- T02.08 Add append-only admin audit events and filtered query views.
- T02.09 Group gate and system specs for admin flows.

Acceptance checks for G02 tickets:

- state-22/state-23/state-24/state-38 behavior reproducible.
- Targeted request/model/use-case/policy specs pass per ticket.
- T02.09 must pass bin/ci.

### G03 Tickets

- T03.01 Add visit workflow state machine with allowed transitions.
- T03.02 Add queue entry model/query for loading, empty, populated, and error states.
- T03.03 Add transition guard validations for vitals, room, and dentist assignment.
- T03.04 Add append-only workflow timeline entries.
- T03.05 Build queue dashboard, filters, and polling UI.
- T03.06 Build workflow show/transition endpoints and optimistic conflict handling.
- T03.07 Add check-in and appointment-sync queue registration path.
- T03.08 Add payment bridge hooks for waiting-payment/no-charge/referred/cancelled.
- T03.09 Add end-to-end workflow system specs.
- T03.10 Group gate for queue/workflow.

Acceptance checks for G03 tickets:

- state-01 to state-07 and state-27 to state-37 mapped and testable.
- Guard failures and invalid transitions return deterministic contract errors.
- T03.10 must pass bin/ci.

### G04 Tickets

- T04.01 Add clinical post model and projection models for chart/procedure/image history.
- T04.02 Build screening form save/load with validation.
- T04.03 Build treatment/procedure form save/load with tooth/surface validation.
- T04.04 Build medication form with high-alert confirmation flow.
- T04.05 Build allergy warning blocking flow for medication conflicts.
- T04.06 Build remaining clinical form endpoints and server-side validators.
- T04.07 Build cumulative history/tooth map query and UI drawer.
- T04.08 Group gate and clinical form system specs.

Acceptance checks for G04 tickets:

- state-08/state-09/state-10/state-11/state-12 reproducible.
- Clinical history projection accuracy verified by specs.
- T04.08 must pass bin/ci.

### G05 Tickets

- T05.01 Add usage model state machine for pending_deduct/deducted/failed.
- T05.02 Add stock movement posting and idempotency reference handling.
- T05.03 Add deduction failure and recovery handling on void/retry.
- T05.04 Add requisition model and lifecycle transitions.
- T05.05 Add self-approval and dispense-guard enforcement.
- T05.06 Add receive/cancel transitions with stock-in side effects.
- T05.07 Add billing line-item builder and invoice creation use case.
- T05.08 Add payment sync callback with signature and idempotency checks.
- T05.09 Build waiting-payment dashboard and manual sync action.
- T05.10 Group gate and supply/requisition/billing system specs.

Acceptance checks for G05 tickets:

- state-13 to state-21 and state-36 fully reproducible.
- flow-03/flow-04/flow-05 path assertions in system tests.
- T05.10 must pass bin/ci.

### G06 Tickets

- T06.01 Finalize provider mappers with fixture-based contract parity tests.
- T06.02 Complete Pundit policy matrix for all dental actions and 9 roles.
- T06.03 Add JWT principal mapping and claims-to-policy context binding.
- T06.04 Expand privileged audit coverage across workflow/clinical/stock/admin/print actions.
- T06.05 Add bounded retry strategy and deterministic integration error surfaces.
- T06.06 Group gate and integration/authz regression suite.

Acceptance checks for G06 tickets:

- Policy-denied scenarios consistently return forbidden contract state.
- Integration outages do not corrupt workflow states.
- T06.06 must pass bin/ci.

### G07 Tickets

- T07.01 Build print preview route/screen and printable CSS shell.
- T07.02 Add treatment summary print payload and template.
- T07.03 Add certificate and dental chart print payload/template.
- T07.04 Add print forbidden state and policy checks.
- T07.05 Add legal/provisional watermark controls and release flagging.
- T07.06 Final release gate for traceability completeness, performance, and contract checks.

Acceptance checks for G07 tickets:

- state-25/state-26 reproducible.
- flow-07 conditions enforced.
- T07.06 must pass bin/ci and release checklist.

## AI Loop Protocol (Exact Sequence)

For each group Gxx:

1. Run tickets in order from Txx.01 to Txx.nn.
2. For each ticket, implement only that scope.
3. Run lint and targeted tests.
4. Commit once.
5. After final ticket, run full group checks and bin/ci.
6. STOP and request human click-test for that group.
7. Continue only if human replies APPROVE Gxx.

Stop-gate request template:

- Group completed: Gxx
- Tickets done: Txx.01 to Txx.nn
- Checks passed: rubocop, rspec, ci
- Please click-test this group checklist
- Reply format: APPROVE Gxx or REJECT Gxx with findings

## Single-File Progress and Resume Control

This section is the operational source of truth for implementation progress.
If requirements are fixed for this release track, AI can resume from this file alone.

Update rules:

1. Update this section immediately after each successful ticket commit.
2. Never mark a ticket done unless checks for that ticket passed.
3. Only one value is allowed for Next Ticket.
4. When a group is complete, set group status to WAITING_UAT.
5. Move to next group only after explicit APPROVE G0X.

### Runtime State Block

Keep this block updated during execution.

```text
BOARD_MODE: SINGLE_FILE
REQUIREMENTS_MUTABILITY: FROZEN

CURRENT_GROUP: G04
GROUP_STATUS: IN_PROGRESS
NEXT_TICKET: T04.05

LAST_COMPLETED_TICKET: T04.04
LAST_COMMIT_SHA: 0d1e65c
LAST_CHECKS_PASSED: rubocop, rspec
LAST_UPDATED_UTC: 2026-04-10T17:29:19Z

ACTIVE_PR_URL: NONE
ACTIVE_PR_STATUS: NONE
ACTIVE_CI_STATUS: NONE
CI_RETRY_COUNT: 0
CI_RETRY_LIMIT: 5

UAT_GATE_STATUS:
- G01: APPROVED
- G02: APPROVED
- G03: APPROVED
- G04: PENDING
- G05: PENDING
- G06: PENDING
- G07: PENDING
```

### G01 Runtime Snapshots (Ready-to-Copy Examples)

Use one snapshot at a time by copying values into the Runtime State Block.

Snapshot A: start G01 now

```text
CURRENT_GROUP: G01
GROUP_STATUS: IN_PROGRESS
NEXT_TICKET: T01.01
LAST_COMPLETED_TICKET: NONE
LAST_COMMIT_SHA: NONE
LAST_CHECKS_PASSED: INIT
ACTIVE_PR_URL: NONE
ACTIVE_PR_STATUS: NONE
ACTIVE_CI_STATUS: NONE
CI_RETRY_COUNT: 0
CI_RETRY_LIMIT: 5
```

Snapshot B: all G01 tickets done, PR opened, waiting CI

```text
CURRENT_GROUP: G01
GROUP_STATUS: IN_PROGRESS
NEXT_TICKET: NONE
LAST_COMPLETED_TICKET: T01.08
LAST_COMMIT_SHA: <replace-with-real-sha>
LAST_CHECKS_PASSED: rubocop, rspec, bin/ci
ACTIVE_PR_URL: <replace-with-pr-url>
ACTIVE_PR_STATUS: OPEN
ACTIVE_CI_STATUS: RUNNING
CI_RETRY_COUNT: 0
CI_RETRY_LIMIT: 5
```

Snapshot C: G01 CI green and ready for human UAT

```text
CURRENT_GROUP: G01
GROUP_STATUS: WAITING_UAT
NEXT_TICKET: NONE
LAST_COMPLETED_TICKET: T01.08
LAST_COMMIT_SHA: <replace-with-real-sha>
LAST_CHECKS_PASSED: rubocop, rspec, bin/ci, pr-ci
ACTIVE_PR_URL: <replace-with-pr-url>
ACTIVE_PR_STATUS: READY_FOR_REVIEW
ACTIVE_CI_STATUS: GREEN
CI_RETRY_COUNT: <replace-with-final-count>
CI_RETRY_LIMIT: 5
UAT_GATE_STATUS:
- G01: READY
- G02: PENDING
- G03: PENDING
- G04: PENDING
- G05: PENDING
- G06: PENDING
- G07: PENDING
```

### Ticket Completion Ledger

Mark each ticket with one status only:

- TODO
- IN_PROGRESS
- DONE
- BLOCKED

Use this template:

```text
G01
- T01.01: DONE
- T01.02: DONE
- T01.03: DONE
- T01.04: DONE
- T01.05: DONE
- T01.06: DONE
- T01.07: DONE
- T01.08: DONE

G02
- T02.01: DONE
- T02.02: DONE
- T02.03: DONE
- T02.04: DONE
- T02.05: DONE
- T02.06: DONE
- T02.07: DONE
- T02.08: DONE
- T02.09: DONE

G03
- T03.01: DONE
- T03.02: DONE
- T03.03: DONE
- T03.04: DONE
- T03.05: DONE
- T03.06: DONE
- T03.07: DONE
- T03.08: DONE
- T03.09: DONE
- T03.10: DONE

G04
- T04.01: DONE
- T04.02: DONE
- T04.03: DONE
- T04.04: DONE
- T04.05: TODO
- T04.06: TODO
- T04.07: TODO
- T04.08: TODO

G05
- T05.01: TODO
- T05.02: TODO
- T05.03: TODO
- T05.04: TODO
- T05.05: TODO
- T05.06: TODO
- T05.07: TODO
- T05.08: TODO
- T05.09: TODO
- T05.10: TODO

G06
- T06.01: TODO
- T06.02: TODO
- T06.03: TODO
- T06.04: TODO
- T06.05: TODO
- T06.06: TODO

G07
- T07.01: TODO
- T07.02: TODO
- T07.03: TODO
- T07.04: TODO
- T07.05: TODO
- T07.06: TODO
```

### Resume Protocol (No Extra Attachments)

When work restarts after interruption, AI must do this order:

1. Read Runtime State Block.
2. Read Ticket Completion Ledger.
3. Validate Next Ticket matches first non-DONE item in current group.
4. Resume exactly from Next Ticket.
5. After commit, update Runtime State Block and Ticket Completion Ledger.

If mismatch is found:

- Set GROUP_STATUS to BLOCKED.
- Write a one-line blocker note in the Recovery Log.
- Do not continue until mismatch is resolved.

### Recovery Log

Append one line per significant event:

```text
YYYY-MM-DDTHH:MM:SSZ | EVENT | GROUP | TICKET | RESULT | NOTE
```

Examples:

```text
2026-04-10T11:00:00Z | START | G01 | T01.01 | OK | begin implementation
2026-04-10T11:25:00Z | CHECKS | G01 | T01.01 | OK | rubocop and rspec passed
2026-04-10T11:30:00Z | COMMIT | G01 | T01.01 | OK | sha=abc1234
2026-04-10T11:35:00Z | RESUME | G01 | T01.02 | OK | restored after interruption
```

Current run entries:

```text
2026-04-10T14:25:00Z | START | G01 | T01.01 | OK | begin implementation
2026-04-10T14:47:00Z | CHECKS | G01 | T01.01 | OK | rubocop and rspec passed
2026-04-10T14:48:00Z | COMMIT | G01 | T01.01 | OK | sha=68fa19f
2026-04-10T14:49:16Z | RESUME | G01 | T01.02 | OK | runtime block updated
2026-04-10T14:49:30Z | START | G01 | T01.02 | OK | begin implementation
2026-04-10T14:51:20Z | CHECKS | G01 | T01.02 | OK | rubocop and rspec passed
2026-04-10T14:52:00Z | COMMIT | G01 | T01.02 | OK | sha=70e28e8
2026-04-10T14:52:28Z | RESUME | G01 | T01.03 | OK | runtime block updated
2026-04-10T14:52:40Z | START | G01 | T01.03 | OK | begin implementation
2026-04-10T14:54:20Z | CHECKS | G01 | T01.03 | OK | rubocop and rspec passed
2026-04-10T14:54:45Z | COMMIT | G01 | T01.03 | OK | sha=f3e12cc
2026-04-10T14:54:52Z | RESUME | G01 | T01.04 | OK | runtime block updated
2026-04-10T14:55:00Z | START | G01 | T01.04 | OK | begin implementation
2026-04-10T14:56:10Z | CHECKS | G01 | T01.04 | OK | rubocop and rspec passed
2026-04-10T14:56:20Z | COMMIT | G01 | T01.04 | OK | sha=8f28259
2026-04-10T14:56:22Z | RESUME | G01 | T01.05 | OK | runtime block updated
2026-04-10T14:56:30Z | START | G01 | T01.05 | OK | begin implementation
2026-04-10T14:57:15Z | CHECKS | G01 | T01.05 | OK | rubocop and rspec passed
2026-04-10T14:57:20Z | COMMIT | G01 | T01.05 | OK | sha=e194e2a
2026-04-10T14:57:25Z | RESUME | G01 | T01.06 | OK | runtime block updated
2026-04-10T14:57:35Z | START | G01 | T01.06 | OK | begin implementation
2026-04-10T14:58:50Z | CHECKS | G01 | T01.06 | OK | rubocop and rspec passed, i18n health green
2026-04-10T14:59:00Z | COMMIT | G01 | T01.06 | OK | sha=23e87e5
2026-04-10T14:59:03Z | RESUME | G01 | T01.07 | OK | runtime block updated
2026-04-10T14:59:12Z | START | G01 | T01.07 | OK | begin implementation
2026-04-10T15:00:50Z | CHECKS | G01 | T01.07 | OK | rubocop and rspec passed
2026-04-10T15:00:55Z | COMMIT | G01 | T01.07 | OK | sha=fc16713
2026-04-10T15:00:57Z | RESUME | G01 | T01.08 | OK | runtime block updated
2026-04-10T15:01:05Z | START | G01 | T01.08 | OK | begin implementation
2026-04-10T15:02:55Z | CHECKS | G01 | T01.08 | OK | rubocop, rspec, system spec, and bin/ci passed
2026-04-10T15:03:10Z | COMMIT | G01 | T01.08 | OK | sha=d2728d4
2026-04-10T15:03:16Z | GATE | G01 | T01.08 | OK | group set to WAITING_UAT and READY
2026-04-10T15:07:34Z | PR_OPEN | G01 | T01.08 | OK | pr=https://github.com/yutna/dental-web/pull/12 ci=running
2026-04-10T15:09:00Z | CI_GREEN | G01 | T01.08 | OK | pr-ci all checks successful
2026-04-10T15:17:07Z | UAT_APPROVE | G01 | T01.08 | OK | user approved G01
2026-04-10T15:17:07Z | RESUME | G02 | T02.01 | OK | move to next group per handoff contract
2026-04-10T15:24:30Z | START | G02 | T02.01 | OK | begin implementation
2026-04-10T15:26:00Z | CHECKS | G02 | T02.01 | OK | rubocop and targeted model specs passed
2026-04-10T15:26:06Z | COMMIT | G02 | T02.01 | OK | sha=fe527ee
2026-04-10T15:26:06Z | RESUME | G02 | T02.02 | OK | runtime block updated
2026-04-10T15:29:10Z | START | G02 | T02.02 | OK | begin implementation
2026-04-10T15:28:20Z | CHECKS | G02 | T02.02 | OK | rubocop and targeted coverage tests passed
2026-04-10T15:28:30Z | COMMIT | G02 | T02.02 | OK | sha=df345e0
2026-04-10T15:28:42Z | RESUME | G02 | T02.03 | OK | runtime block updated
2026-04-10T15:29:00Z | START | G02 | T02.03 | OK | begin implementation
2026-04-10T15:30:20Z | CHECKS | G02 | T02.03 | OK | rubocop, targeted tests, and i18n health passed
2026-04-10T15:30:25Z | COMMIT | G02 | T02.03 | OK | sha=c319651
2026-04-10T15:30:27Z | RESUME | G02 | T02.04 | OK | runtime block updated
2026-04-10T15:31:00Z | START | G02 | T02.04 | OK | begin implementation
2026-04-10T15:34:20Z | CHECKS | G02 | T02.04 | OK | rubocop, targeted request specs, and i18n health passed
2026-04-10T15:34:23Z | COMMIT | G02 | T02.04 | OK | sha=47d7800
2026-04-10T15:34:25Z | RESUME | G02 | T02.05 | OK | runtime block updated
2026-04-10T15:35:00Z | START | G02 | T02.05 | OK | begin implementation
2026-04-10T15:35:30Z | CHECKS | G02 | T02.05 | OK | rubocop, targeted request specs, and i18n health passed
2026-04-10T15:35:35Z | COMMIT | G02 | T02.05 | OK | sha=9aa555a
2026-04-10T15:35:37Z | RESUME | G02 | T02.06 | OK | runtime block updated
2026-04-10T15:38:30Z | START | G02 | T02.06 | OK | begin implementation
2026-04-10T15:37:15Z | CHECKS | G02 | T02.06 | OK | rubocop and targeted bulk import specs passed
2026-04-10T15:37:22Z | COMMIT | G02 | T02.06 | OK | sha=83f2c8e
2026-04-10T15:37:27Z | RESUME | G02 | T02.07 | OK | runtime block updated
2026-04-10T15:38:35Z | START | G02 | T02.07 | OK | begin implementation
2026-04-10T15:40:30Z | CHECKS | G02 | T02.07 | OK | rubocop, targeted request specs, and i18n health passed
2026-04-10T15:40:45Z | COMMIT | G02 | T02.07 | OK | sha=f5b1c71
2026-04-10T15:40:50Z | RESUME | G02 | T02.08 | OK | runtime block updated
2026-04-10T15:41:00Z | START | G02 | T02.08 | OK | begin implementation
2026-04-10T15:43:55Z | CHECKS | G02 | T02.08 | OK | rubocop, targeted specs, and i18n health passed
2026-04-10T15:44:10Z | COMMIT | G02 | T02.08 | OK | sha=3731564
2026-04-10T15:44:17Z | RESUME | G02 | T02.09 | OK | runtime block updated
2026-04-10T15:44:30Z | START | G02 | T02.09 | OK | begin implementation
2026-04-10T15:46:45Z | CHECKS | G02 | T02.09 | OK | rubocop, group rspec non-system, dental system specs, and bin/ci passed
2026-04-10T15:46:58Z | COMMIT | G02 | T02.09 | OK | sha=04ce49b
2026-04-10T15:47:02Z | GATE | G02 | T02.09 | OK | group set to WAITING_UAT and READY
2026-04-10T15:47:40Z | PR_OPEN | G02 | T02.09 | OK | pr=https://github.com/yutna/dental-web/pull/13 ci=running
2026-04-10T15:49:01Z | CI_GREEN | G02 | T02.09 | OK | pr-ci all checks successful
2026-04-10T15:49:20Z | COMMIT | G02 | T02.09 | OK | sha=f996d7b (board ci metadata)
2026-04-10T15:50:19Z | CI_GREEN | G02 | T02.09 | OK | pr-ci all checks successful on latest head
2026-04-10T16:27:00Z | COMMIT | G02 | T02.08 | OK | sha=4428ea2 (audit filter regression fix)
2026-04-10T16:28:30Z | COMMIT | G02 | T02.09 | OK | sha=e5d51c4 (system gate assertion alignment)
2026-04-10T16:31:27Z | CI_GREEN | G02 | T02.09 | OK | pr-ci all checks successful on latest head
2026-04-10T16:31:27Z | UAT_APPROVE | G02 | T02.09 | OK | user approved G02
2026-04-10T16:31:27Z | RESUME | G03 | T03.01 | OK | move to next group per handoff contract
2026-04-10T16:33:00Z | START | G03 | T03.01 | OK | begin implementation
2026-04-10T16:36:30Z | CHECKS | G03 | T03.01 | OK | rubocop and targeted request/domain specs passed
2026-04-10T16:37:19Z | COMMIT | G03 | T03.01 | OK | sha=d9cf4a3
2026-04-10T16:37:19Z | RESUME | G03 | T03.02 | OK | runtime block updated
2026-04-10T16:38:00Z | START | G03 | T03.02 | OK | begin implementation
2026-04-10T16:39:00Z | CHECKS | G03 | T03.02 | OK | rubocop and targeted query specs passed
2026-04-10T16:39:19Z | COMMIT | G03 | T03.02 | OK | sha=541d53f
2026-04-10T16:39:19Z | RESUME | G03 | T03.03 | OK | runtime block updated
2026-04-10T16:40:00Z | START | G03 | T03.03 | OK | begin implementation
2026-04-10T16:41:20Z | CHECKS | G03 | T03.03 | OK | rubocop and targeted request specs passed
2026-04-10T16:41:44Z | COMMIT | G03 | T03.03 | OK | sha=33099f7
2026-04-10T16:41:44Z | RESUME | G03 | T03.04 | OK | runtime block updated
2026-04-10T16:45:30Z | CHECKS | G03 | T03.04 | OK | rubocop and targeted model/request specs passed
2026-04-10T16:45:50Z | COMMIT | G03 | T03.04 | OK | sha=675cabc
2026-04-10T16:46:07Z | RESUME | G03 | T03.05 | OK | runtime block updated
2026-04-10T16:51:40Z | CHECKS | G03 | T03.05 | OK | rubocop and targeted query/request specs passed
2026-04-10T16:51:50Z | COMMIT | G03 | T03.05 | OK | sha=57f9589
2026-04-10T16:52:07Z | RESUME | G03 | T03.06 | OK | runtime block updated
2026-04-10T16:54:45Z | CHECKS | G03 | T03.06 | OK | rubocop and targeted workflow request/domain specs passed
2026-04-10T16:54:58Z | COMMIT | G03 | T03.06 | OK | sha=48a4ffe
2026-04-10T16:55:05Z | RESUME | G03 | T03.07 | OK | runtime block updated
2026-04-10T16:57:20Z | CHECKS | G03 | T03.07 | OK | rubocop and targeted queue registration specs passed
2026-04-10T16:57:32Z | COMMIT | G03 | T03.07 | OK | sha=b3365d8
2026-04-10T16:57:38Z | RESUME | G03 | T03.08 | OK | runtime block updated
2026-04-10T16:59:15Z | CHECKS | G03 | T03.08 | OK | rubocop and targeted workflow hook specs passed
2026-04-10T16:59:22Z | COMMIT | G03 | T03.08 | OK | sha=ff810a2
2026-04-10T16:59:29Z | RESUME | G03 | T03.09 | OK | runtime block updated
2026-04-10T17:00:40Z | CHECKS | G03 | T03.09 | OK | rubocop and targeted workflow system specs passed
2026-04-10T17:00:48Z | COMMIT | G03 | T03.09 | OK | sha=f1621ab
2026-04-10T17:00:54Z | RESUME | G03 | T03.10 | OK | runtime block updated
2026-04-10T17:01:35Z | CHECKS | G03 | T03.10 | OK | bin/ci passed
2026-04-10T17:01:38Z | HOLD | G03 | T03.10 | OK | group set to WAITING_UAT and gate READY
2026-04-10T17:03:01Z | PR_OPEN | G03 | T03.10 | OK | pr=https://github.com/yutna/dental-web/pull/14 ci=running
2026-04-10T17:19:12Z | UAT_APPROVE | G03 | T03.10 | OK | user approved G03
2026-04-10T17:19:12Z | RESUME | G04 | T04.01 | OK | move to next group per handoff contract
2026-04-10T17:22:40Z | CHECKS | G04 | T04.01 | OK | rubocop and targeted model specs passed
2026-04-10T17:22:55Z | COMMIT | G04 | T04.01 | OK | sha=6f989d2
2026-04-10T17:23:05Z | RESUME | G04 | T04.02 | OK | runtime block updated
2026-04-10T17:24:40Z | CHECKS | G04 | T04.02 | OK | rubocop and targeted clinical request/routing specs passed
2026-04-10T17:24:55Z | COMMIT | G04 | T04.02 | OK | sha=5ff1be0
2026-04-10T17:25:02Z | RESUME | G04 | T04.03 | OK | runtime block updated
2026-04-10T17:26:05Z | CHECKS | G04 | T04.03 | OK | rubocop and targeted treatment request/routing specs passed
2026-04-10T17:26:10Z | COMMIT | G04 | T04.03 | OK | sha=c479253
2026-04-10T17:26:15Z | RESUME | G04 | T04.04 | OK | runtime block updated
2026-04-10T17:29:04Z | CHECKS | G04 | T04.04 | OK | rubocop and targeted medication request/routing specs passed
2026-04-10T17:29:19Z | COMMIT | G04 | T04.04 | OK | sha=0d1e65c
2026-04-10T17:29:19Z | RESUME | G04 | T04.05 | OK | runtime block updated
```

### Group Handoff Contract

At group boundary:

1. Set GROUP_STATUS to WAITING_UAT.
2. Set NEXT_TICKET to NONE.
3. Set UAT_GATE_STATUS for that group to READY.
4. Stop execution and wait for APPROVE or REJECT.

On APPROVE G0X:

1. Set current group UAT_GATE_STATUS to APPROVED.
2. Move CURRENT_GROUP to next group.
3. Set GROUP_STATUS to IN_PROGRESS.
4. Set NEXT_TICKET to first ticket of next group.

On REJECT G0X:

1. Set current group UAT_GATE_STATUS to REJECTED.
2. Set GROUP_STATUS to IN_PROGRESS.
3. Set NEXT_TICKET to defect-fix ticket in same group.
4. Resume in the same group only.

## PR and CI Gate Policy (One Group = One PR)

Execution policy:

1. Exactly one PR per group.
2. PR scope must include only tickets from active group.
3. AI may fix CI failures only if fixes remain inside active group scope.
4. AI must not auto-merge. Human approval is mandatory.

PR lifecycle per group:

1. Complete all tickets in active group with per-ticket checks.
2. Open one PR for that group and set ACTIVE_PR_STATUS to OPEN.
3. Wait for CI, set ACTIVE_CI_STATUS to RUNNING.
4. If CI fails, fix failures and push updates to same PR.
5. Increase CI_RETRY_COUNT on each failed CI cycle.
6. If CI_RETRY_COUNT exceeds CI_RETRY_LIMIT, set GROUP_STATUS to BLOCKED and stop.
7. When CI is fully green, set ACTIVE_CI_STATUS to GREEN.
8. Set GROUP_STATUS to WAITING_UAT and stop for human click-test.

Required status updates in Runtime State Block:

- ACTIVE_PR_URL: PR link for current group
- ACTIVE_PR_STATUS: NONE, OPEN, READY_FOR_REVIEW, BLOCKED
- ACTIVE_CI_STATUS: NONE, RUNNING, FAILED, GREEN
- CI_RETRY_COUNT: integer count for current group PR
- CI_RETRY_LIMIT: max retry cycles before forced stop

Forced stop conditions:

1. CI retry limit reached.
2. Out-of-scope changes are required to fix CI.
3. Required secrets/permissions for CI or PR operations are missing.

Human handoff format after CI green:

1. Group: G0X
2. PR: link
3. CI: GREEN
4. Tickets completed: list
5. UAT checklist: group checklist
6. Awaiting decision: APPROVE G0X or REJECT G0X

## GitHub MCP Operation Contract

Use this contract for remote execution with GitHub MCP when running one group as one PR.

Preconditions:

1. MCP has permission to push branch, create PR, and read check runs.
2. Active group and next ticket are already set in Runtime State Block.
3. Local checks for current ticket are green before any push.

Step-by-step execution:

1. Create or reuse group branch.
2. Implement one ticket only.
3. Run per-ticket checks and commit.
4. Repeat steps 2 to 3 until group tickets are complete.
5. Push branch and open one PR for this group.
6. Wait for CI check runs.
7. If CI fails, fix only in-group issues and push to same PR.
8. Repeat step 6 and step 7 until CI is green or retry limit reached.
9. When CI is green, move group to WAITING_UAT and stop.

Runtime State Block updates by step:

1. At branch ready:
   - ACTIVE_PR_URL: NONE
   - ACTIVE_PR_STATUS: NONE
   - ACTIVE_CI_STATUS: NONE
   - CI_RETRY_COUNT: 0
2. After PR created:
   - ACTIVE_PR_URL: real-pr-url
   - ACTIVE_PR_STATUS: OPEN
   - ACTIVE_CI_STATUS: RUNNING
3. On CI failed cycle:
   - ACTIVE_CI_STATUS: FAILED
   - CI_RETRY_COUNT: previous + 1
   - LAST_CHECKS_PASSED: local checks for current fix commit
4. On CI green:
   - ACTIVE_CI_STATUS: GREEN
   - ACTIVE_PR_STATUS: READY_FOR_REVIEW
   - GROUP_STATUS: WAITING_UAT
   - NEXT_TICKET: NONE
   - UAT_GATE_STATUS for active group: READY
5. On retry limit exceeded:
   - GROUP_STATUS: BLOCKED
   - ACTIVE_PR_STATUS: BLOCKED
   - ACTIVE_CI_STATUS: FAILED

Allowed CI-fix scope:

1. Test fixes for tickets in active group.
2. Lint fixes caused by active group changes.
3. Contract or policy fixes directly tied to active group acceptance checks.

Disallowed CI-fix scope:

1. Starting work from the next group.
2. Refactors unrelated to failing checks.
3. Merging PR automatically.

Operational stop gates:

1. Missing MCP permissions or GitHub API access.
2. CI_RETRY_COUNT > CI_RETRY_LIMIT.
3. Required fix is out of active group scope.

Mandatory handoff payload when stopped for UAT:

1. CURRENT_GROUP value
2. ACTIVE_PR_URL value
3. ACTIVE_CI_STATUS value
4. Completed ticket list for that group
5. Exact UAT checklist section for that group
6. Required human decision: APPROVE G0X or REJECT G0X

## Human UAT Stop-Gate Checklists

### Gate 1 after G01

- Locale routes work in en and th.
- Unauthorized access blocked.
- Forbidden and not-found states display correctly.

### Gate 2 after G02

- Admin dashboard loads and shows KPIs.
- CRUD, soft-delete guard, bulk import conflict, maker-checker are usable.

### Gate 3 after G03

- Queue states and visit transitions operate correctly.
- Guard failures block invalid actions with clear messages.

### Gate 4 after G04

- Clinical forms save, validate, and project to history correctly.
- High-alert and allergy warning flows work as designed.

### Gate 5 after G05

- Usage deduction success/failure, requisition lifecycle, and billing sync behave correctly.

### Gate 6 after G06

- Role matrix permissions and integration failure behavior are correct.

### Gate 7 after G07

- Print outputs and forbidden state are correct.
- Release gate checklist is complete.

## Full Source Traceability Matrix (100% File Coverage)

### Requirement files

| Source file | Covered by tickets |
|---|---|
| docs/tasks/dental-system/00-specifications.md | T01.01, T01.02, T01.03, T01.05, T03.01, T05.01 |
| docs/tasks/dental-system/01-overview.md | T01.02, T01.04, T01.08, T06.02, T07.06 |
| docs/tasks/dental-system/knowledge-graph.json | T01.01, T01.03, T02.01, T02.02, T06.01 |
| docs/tasks/dental-system/phase-01-foundation.md | T01.01 to T01.08 |
| docs/tasks/dental-system/phase-02-master-data-and-admin.md | T02.01 to T02.09 |
| docs/tasks/dental-system/phase-03-workflow-and-queue.md | T03.01 to T03.10 |
| docs/tasks/dental-system/phase-04-clinical-forms-and-history.md | T04.01 to T04.08 |
| docs/tasks/dental-system/phase-05-supply-costing-and-billing.md | T05.01 to T05.10 |
| docs/tasks/dental-system/phase-06-integration-authz-and-audit.md | T06.01 to T06.06 |
| docs/tasks/dental-system/phase-07-printing-and-release-hardening.md | T07.01 to T07.06 |
| docs/tasks/dental-system/test-scenarios.md | T01.07, T02.09, T03.09, T04.08, T05.10, T06.06, T07.06 |

### UI files

| Source file | Covered by tickets |
|---|---|
| docs/ui/dental-system/README.md | T01.04, T02.03, T03.05, T07.01 |
| docs/ui/dental-system/knowledge-graph.json | T01.03, T03.05, T07.06 |
| docs/ui/dental-system/audit-third-pass-checklist.md | T02.08, T06.04, T07.06 |
| docs/ui/dental-system/flow-01-visit-workflow-lifecycle.md | T03.01, T03.06, T03.09 |
| docs/ui/dental-system/flow-02-clinical-forms-and-history.md | T04.01 to T04.08 |
| docs/ui/dental-system/flow-03-usage-stock-deduction.md | T05.01 to T05.03 |
| docs/ui/dental-system/flow-04-requisition-lifecycle.md | T05.04 to T05.06 |
| docs/ui/dental-system/flow-05-billing-and-payment-sync.md | T05.07 to T05.09 |
| docs/ui/dental-system/flow-06-admin-master-data-governance.md | T02.03 to T02.07 |
| docs/ui/dental-system/flow-07-print-and-release-readiness.md | T07.01 to T07.06 |
| docs/ui/dental-system/state-01-queue-loading.md | T03.02, T03.05 |
| docs/ui/dental-system/state-02-queue-empty.md | T03.02, T03.05 |
| docs/ui/dental-system/state-03-queue-populated.md | T03.02, T03.05 |
| docs/ui/dental-system/state-04-queue-error-inline.md | T03.02, T03.05 |
| docs/ui/dental-system/state-05-workflow-permission-denied.md | T01.07, T06.02 |
| docs/ui/dental-system/state-06-transition-guard-vitals.md | T03.03 |
| docs/ui/dental-system/state-07-invalid-transition-blocked.md | T03.01, T03.06 |
| docs/ui/dental-system/state-08-screening-form-entry.md | T04.02 |
| docs/ui/dental-system/state-09-treatment-form-in-progress.md | T04.03 |
| docs/ui/dental-system/state-10-procedure-validation-error.md | T04.03 |
| docs/ui/dental-system/state-11-medication-high-alert-dialog.md | T04.04 |
| docs/ui/dental-system/state-12-medication-allergy-warning.md | T04.05 |
| docs/ui/dental-system/state-13-usage-deduction-failed.md | T05.01, T05.03 |
| docs/ui/dental-system/state-14-usage-deducted-success.md | T05.01, T05.02 |
| docs/ui/dental-system/state-15-requisition-list-populated.md | T05.04 |
| docs/ui/dental-system/state-16-requisition-self-approval-blocked.md | T05.05 |
| docs/ui/dental-system/state-17-requisition-dispense-guard.md | T05.05 |
| docs/ui/dental-system/state-18-requisition-received-success.md | T05.06 |
| docs/ui/dental-system/state-19-billing-waiting-payment.md | T05.09 |
| docs/ui/dental-system/state-20-payment-sync-failure.md | T05.08 |
| docs/ui/dental-system/state-21-payment-paid-auto-complete.md | T05.08 |
| docs/ui/dental-system/state-22-admin-dashboard-overview.md | T02.03 |
| docs/ui/dental-system/state-23-admin-master-data-crud.md | T02.04 |
| docs/ui/dental-system/state-24-admin-bulk-import-conflict.md | T02.06 |
| docs/ui/dental-system/state-25-print-preview-ready.md | T07.01, T07.02, T07.03 |
| docs/ui/dental-system/state-26-print-forbidden.md | T07.04 |
| docs/ui/dental-system/state-27-check-in-created.md | T03.07 |
| docs/ui/dental-system/state-28-room-assignment-unavailable.md | T03.03 |
| docs/ui/dental-system/state-29-referred-out-summary.md | T03.08 |
| docs/ui/dental-system/state-30-cancelled-visit-summary.md | T03.08 |
| docs/ui/dental-system/state-31-visit-not-found.md | T01.07, T03.06 |
| docs/ui/dental-system/state-32-stage-update-conflict.md | T03.06 |
| docs/ui/dental-system/state-33-appointment-sync-registered-queue.md | T03.07 |
| docs/ui/dental-system/state-34-coverage-expiry-fallback-pricing.md | T02.02 |
| docs/ui/dental-system/state-35-dentist-assignment-required.md | T03.03 |
| docs/ui/dental-system/state-36-requisition-cancelled.md | T05.06 |
| docs/ui/dental-system/state-37-no-charge-completed.md | T03.08 |
| docs/ui/dental-system/state-38-master-data-soft-delete-guard.md | T02.05 |

## Scenario-Level Coverage Audit (from test-scenarios.md)

| Scenario | Priority | Covered by tickets |
|---|---|---|
| Create dental visit from registration intake | @must | T03.07, T03.09 |
| Transition checked-in to screening with room assignment | @must | T03.03, T03.06, T03.09 |
| Transition ready-for-treatment to in-treatment with assigned dentist | @must | T03.03, T03.06, T03.09 |
| Enforce guarded stage transition from screening to ready-for-treatment | @must | T03.03, T03.06, T03.09 |
| Complete treatment with payable items | @must | T03.08, T05.07, T05.10 |
| Auto-complete visit when payment is fully paid | @must | T03.08, T05.08, T05.10 |
| Handle payment sync failure without corrupting workflow state | @must | T05.08, T06.05, T06.06 |
| Complete visit directly when payment is not required | @must | T03.08, T03.09 |
| Refer out from in-treatment | @must | T03.08, T03.09 |
| Cancel visit from registered stage | @must | T03.06, T03.09 |
| Cancel visit from checked-in stage | @must | T03.06, T03.09 |
| Reject invalid workflow transition | @must | T03.01, T03.06, T03.09 |
| Save dental procedure with tooth-level constraints | @must | T04.03, T04.08 |
| Save medication usage with high-alert warning | @must | T04.04, T04.08 |
| Mark usage deducted after successful stock deduction | @must | T05.01, T05.02, T05.10 |
| Fail stock deduction when insufficient balance | @must | T05.01, T05.03, T05.10 |
| Rollback usage when source post is voided | @must | T05.03, T05.10 |
| Requisition approval guard blocks self-approval | @must | T05.05, T05.10 |
| Approve requisition with different approver | @must | T05.04, T05.10 |
| Reject dispense without dispense number | @must | T05.05, T05.10 |
| Requisition receive records stock-in movement | @must | T05.06, T05.10 |
| Cancel approved requisition before dispense | @must | T05.06, T05.10 |
| Master data soft-delete guard | @must | T02.05, T02.09 |
| Policy denies unauthorized workflow transition | @must | T01.07, T06.02, T06.06 |
| Return not found when visit ID does not exist | @must | T01.07, T03.06, T03.09 |
| Prevent concurrent stage update race condition | @must | T03.06, T03.09 |
| Locale behavior remains URL-scoped | @must | T01.04, T01.06, T01.07 |
| Appointment sync creates registered queue entries for today | @should | T03.07, T03.10 |
| Coverage expiry fallback | @should | T02.02, T02.09 |
| Drug allergy warning for medication order | @should | T04.05, T04.08 |
| Bulk coverage update with optimistic lock conflict handling | @could | T02.06, T02.09 |
| Implement non-dental module internal business logic | @wont | Explicitly out of scope, no implementation ticket |

## Decision and External TODO Audit (from knowledge-graph.json)

### Decision traceability

| Decision ID | Decision name | Owned by tickets |
|---|---|---|
| DL-001 | Deny-by-default permissions | T01.02, T06.02 |
| DL-002 | In-module maker-checker approvals | T02.07, T06.02 |
| DL-003 | Signed callback with idempotency key | T05.08, T06.05 |
| DL-004 | BFF-level row access control for SQLite | T06.02, T06.03 |
| DL-005 | Polling baseline at 30s | T03.05, T03.10 |
| DL-006 | Provisional bilingual legal templates | T07.03, T07.05 |

### External dependency TODO traceability

| TODO ID | External dependency | Tracking ticket or action |
|---|---|---|
| T-001 | Confirm IAM source-of-truth payload | T06.03 plus external API contract signoff required |
| T-002 | Confirm approval architecture | T02.07 plus architecture decision record |
| T-003 | Confirm legal print signature metadata | T07.05 plus legal signoff required |
| T-004 | Confirm external VN/HN identifier format | T03.07 plus registration API contract signoff |
| T-005 | Confirm callback payload identifier types | T05.08 plus cashier API contract signoff |
| T-006 | Confirm stock reference ID type | T05.02 plus stock API contract signoff |
| T-007 | Confirm approval role boundaries | T02.07 and T06.02 |
| T-008 | Confirm denormalized sync cadence | T03.05 and T03.07 |
| T-009 | Confirm queue refresh transport | T03.05 baseline polling, realtime deferred |
| T-010 | Confirm room allocation source | T03.03 plus room service contract signoff |
| T-011 | Confirm image backend retention policy | T04.06 plus security/compliance signoff |
| T-012 | Confirm DICOM viewer and MIME policy | T04.06 plus imaging platform signoff |
| T-013 | Confirm payment callback auth standard | T05.08 and T06.05 |
| T-014 | Confirm invoice cancellation after partial payment | T05.07 and T05.08 |
| T-015 | Confirm JWT claim and permissions payload | T06.03 and T06.02 |
| T-016 | Confirm RLS strategy for SQLite runtime | T06.02 and T06.03 |
| T-017 | Confirm official print form and signature requirements | T07.03 and T07.05 |
| T-018 | Confirm archival retention and watermark obligations | T07.05 and T07.06 |

Audit conclusion:

- File-level source coverage: complete.
- Scenario-level coverage: complete (32 scenarios including @wont explicitly tracked).
- Decision-level coverage: complete (DL-001 to DL-006).
- External dependency TODO visibility: complete (T-001 to T-018 tracked).

## Suggested Agent Order

1. Complete G01 then stop for Gate 1.
2. Complete G02 then stop for Gate 2.
3. Complete G03 then stop for Gate 3.
4. Complete G04 then stop for Gate 4.
5. Complete G05 then stop for Gate 5.
6. Complete G06 then stop for Gate 6.
7. Complete G07 then run final release gate.

This board is designed so each stop point is a real clickable feature slice for human validation before continuing.
