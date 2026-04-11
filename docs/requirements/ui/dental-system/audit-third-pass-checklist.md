# Third-Pass Audit Checklist (Strict)

Scope:

- Requirement source: docs/tasks/dental-system/test-scenarios.md
- Design artifacts audited: docs/ui/dental-system/flow-*.md and docs/ui/dental-system/state-*.md
- Audit style: one-to-one scenario traceability (strict checklist)

Legend:

- PASS = scenario has explicit design coverage and transition path
- PARTIAL = partially represented, needs explicit state/branch
- FAIL = no design evidence
- ACCEPTED-OOS = explicitly out of scope by requirement

## Scenario checklist

| ID | Priority | Scenario | Verdict | Evidence (flow/state) | Notes |
| --- | --- | --- | --- | --- | --- |
| S01 | @must | Create dental visit from registration intake | PASS | state-27-check-in-created.md, flow-01-visit-workflow-lifecycle.md | Includes VN/HN + queue placement |
| S02 | @must | Transition checked-in to screening with room assignment | PASS | state-28-room-assignment-unavailable.md, state-08-screening-form-entry.md, flow-01-visit-workflow-lifecycle.md | Covers room available/unavailable branches |
| S03 | @must | Transition ready-for-treatment to in-treatment with assigned dentist | PASS | state-35-dentist-assignment-required.md, state-09-treatment-form-in-progress.md, flow-01-visit-workflow-lifecycle.md | Includes assignment guard and success path |
| S04 | @must | Enforce guarded stage transition from screening to ready-for-treatment | PASS | state-06-transition-guard-vitals.md, state-08-screening-form-entry.md, flow-01-visit-workflow-lifecycle.md | Explicit missing-vitals rejection |
| S05 | @must | Complete treatment with payable items | PASS | state-09-treatment-form-in-progress.md, state-19-billing-waiting-payment.md, flow-05-billing-and-payment-sync.md | in-treatment -> waiting-payment covered |
| S06 | @must | Auto-complete visit when payment is fully paid | PASS | state-21-payment-paid-auto-complete.md, state-19-billing-waiting-payment.md, flow-05-billing-and-payment-sync.md | Auto-transition shown in timeline |
| S07 | @must | Handle payment sync failure without corrupting workflow state | PASS | state-20-payment-sync-failure.md, state-19-billing-waiting-payment.md, flow-05-billing-and-payment-sync.md | Explicit "stage unchanged" branch |
| S08 | @must | Complete visit directly when payment is not required | PASS | state-37-no-charge-completed.md, state-09-treatment-form-in-progress.md, flow-01-visit-workflow-lifecycle.md | no-charge completion terminal state |
| S09 | @must | Refer out from in-treatment | PASS | state-29-referred-out-summary.md, state-09-treatment-form-in-progress.md, flow-01-visit-workflow-lifecycle.md | Referral terminal path covered |
| S10 | @must | Cancel visit from registered stage | PASS | state-30-cancelled-visit-summary.md, flow-01-visit-workflow-lifecycle.md | Cancel terminal state covered |
| S11 | @must | Cancel visit from checked-in stage | PASS | state-30-cancelled-visit-summary.md, flow-01-visit-workflow-lifecycle.md | Checked-in cancel branch included |
| S12 | @must | Reject invalid workflow transition | PASS | state-07-invalid-transition-blocked.md, flow-01-visit-workflow-lifecycle.md | INVALID_STAGE_TRANSITION with allowed actions |
| S13 | @must | Save dental procedure with tooth-level constraints | PASS | state-10-procedure-validation-error.md, state-09-treatment-form-in-progress.md, flow-02-clinical-forms-and-history.md | Missing tooth/surface enforcement |
| S14 | @must | Save medication usage with high-alert warning | PASS | state-11-medication-high-alert-dialog.md, flow-02-clinical-forms-and-history.md | Confirm-before-save warning pattern |
| S15 | @must | Mark usage deducted after successful stock deduction | PASS | state-14-usage-deducted-success.md, flow-03-usage-stock-deduction.md | Deducted status + movement reference |
| S16 | @must | Fail stock deduction when insufficient balance | PASS | state-13-usage-deduction-failed.md, flow-03-usage-stock-deduction.md | Insufficient-stock failure branch |
| S17 | @must | Rollback usage when source post is voided | PASS | state-14-usage-deducted-success.md, state-13-usage-deduction-failed.md, flow-03-usage-stock-deduction.md | Compensation/rollback branch present |
| S18 | @must | Requisition approval guard blocks self-approval | PASS | state-16-requisition-self-approval-blocked.md, flow-04-requisition-lifecycle.md | STATE_GUARD_VIOLATION explicit |
| S19 | @must | Approve requisition with different approver | PASS | state-15-requisition-list-populated.md, flow-04-requisition-lifecycle.md | Pending -> approved path represented |
| S20 | @must | Reject dispense without dispense number | PASS | state-17-requisition-dispense-guard.md, flow-04-requisition-lifecycle.md | Missing dispense number blocked |
| S21 | @must | Requisition receive records stock-in movement | PASS | state-18-requisition-received-success.md, flow-04-requisition-lifecycle.md | Received + stock-in references shown |
| S22 | @must | Cancel approved requisition before dispense | PASS | state-36-requisition-cancelled.md, flow-04-requisition-lifecycle.md | Approved -> cancelled terminal branch |
| S23 | @must | Master data soft-delete guard | PASS | state-38-master-data-soft-delete-guard.md, state-23-admin-master-data-crud.md, flow-06-admin-master-data-governance.md | Hard delete blocked, deactivate allowed |
| S24 | @must | Policy denies unauthorized workflow transition | PASS | state-05-workflow-permission-denied.md, flow-01-visit-workflow-lifecycle.md | Forbidden branch explicit |
| S25 | @must | Return not found when visit ID does not exist | PASS | state-31-visit-not-found.md | NOT_FOUND UX state explicit |
| S26 | @must | Prevent concurrent stage update race condition | PASS | state-32-stage-update-conflict.md | Stale update conflict UX explicit |
| S27 | @must | Locale behavior remains URL-scoped | PASS | README.md, state-08-screening-form-entry.md, state-25-print-preview-ready.md | All routes expressed as /[locale]/... |
| S28 | @should | Appointment sync creates registered queue entries for today | PASS | state-33-appointment-sync-registered-queue.md | Created/skipped/error sync summary represented |
| S29 | @should | Coverage expiry fallback | PASS | state-34-coverage-expiry-fallback-pricing.md | Expired coverage -> master price fallback |
| S30 | @should | Drug allergy warning for medication order | PASS | state-12-medication-allergy-warning.md, flow-02-clinical-forms-and-history.md | Blocking warning + override path |
| S31 | @could | Bulk coverage update with optimistic lock conflict handling | PASS | state-24-admin-bulk-import-conflict.md, flow-06-admin-master-data-governance.md | Conflict handling and overwrite path |
| S32 | @wont | Implement non-dental module internal business logic | ACCEPTED-OOS | README.md | Explicitly out of scope by requirement |

## Verdict summary

- @must: 27/27 PASS
- @should: 3/3 PASS
- @could: 1/1 PASS
- @wont: 1/1 ACCEPTED-OOS
- Overall coverage result: FULL for in-scope requirement scenarios

## Additional compliance checks

- Every state file has a Visual direction section: PASS
- Responsive intent present across all state artifacts: PASS
- Policy/forbidden branches represented: PASS
- Admin dashboard + governance coverage represented: PASS
