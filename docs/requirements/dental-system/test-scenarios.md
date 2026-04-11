# Test Scenarios: Dental System

## Gherkin scenarios

```gherkin
Feature: Dental Module End-to-End Service Delivery
  As a dental care team
  I want to run clinical, stock, billing, and admin workflows safely
  So that all TOR requirements are fulfilled with auditable outcomes

  Definitions:
    - Clinical post: visit-linked record with formType and structured form data
    - Runtime pricing: per-item resolution from eligibility coverage or master fallback
    - Requisition: stock request lifecycle pending -> approved -> dispensed -> received

  @must
  Scenario: Create dental visit from registration intake
    Given a patient has an active VN and HN
    When staff performs dental check-in
    Then the system creates a dental workflow in checked-in stage
    And the queue entry is visible on the daily dashboard

  @must
  Scenario: Transition checked-in to screening with room assignment
    Given a visit is in checked-in stage
    And an examination room is available
    When staff starts screening
    Then stage changes to screening
    And timeline records the transition

  @must
  Scenario: Transition ready-for-treatment to in-treatment with assigned dentist
    Given a visit is in ready-for-treatment stage
    And a dentist is assigned
    When dentist starts treatment
    Then stage changes to in-treatment
    And queue status updates to in-progress

  @must
  Scenario: Enforce guarded stage transition from screening to ready-for-treatment
    Given a visit is in screening stage
    And vital signs are incomplete
    When user attempts transition to ready-for-treatment
    Then the transition is rejected with a vital-signs-required message

  @must
  Scenario: Complete treatment with payable items
    Given a visit is in in-treatment stage with chargeable procedure records
    When dentist sends the visit to cashier
    Then invoice is created and linked
    And stage changes to waiting-payment
    And payment status becomes pending

  @must
  Scenario: Auto-complete visit when payment is fully paid
    Given a visit is in waiting-payment stage
    And cashier sync returns paid
    When payment sync job runs
    Then payment status becomes paid
    And stage becomes completed automatically

  @must
  Scenario: Handle payment sync failure without corrupting workflow state
    Given a visit is in waiting-payment stage
    And payment sync provider is unavailable
    When sync job runs
    Then payment status remains unchanged
    And workflow stage remains waiting-payment
    And an operational error is logged for retry

  @must
  Scenario: Complete visit directly when payment is not required
    Given a visit is in in-treatment stage
    And payment status is not-required
    When dentist completes treatment
    Then stage changes to completed
    And no invoice is created

  @must
  Scenario: Refer out from in-treatment
    Given a visit is in in-treatment stage
    And referral destination details are provided
    When dentist submits refer out
    Then stage changes to referred-out
    And timeline records referral transition

  @must
  Scenario: Cancel visit from registered stage
    Given a visit is in registered stage
    When staff cancels the visit with reason
    Then stage changes to cancelled
    And queue status changes to cancelled

  @must
  Scenario: Cancel visit from checked-in stage
    Given a visit is in checked-in stage
    When staff cancels the visit with reason
    Then stage changes to cancelled
    And timeline records cancellation

  @must
  Scenario: Reject invalid workflow transition
    Given a visit is in registered stage
    When user attempts to transition directly to completed
    Then response is INVALID_STAGE_TRANSITION
    And allowed transitions are returned

  @must
  Scenario: Save dental procedure with tooth-level constraints
    Given a procedure item requires tooth and surface selection
    When dentist submits procedure without selected surfaces
    Then validation error is shown
    And no clinical post is persisted

  @must
  Scenario: Save medication usage with high-alert warning
    Given medication profile is marked high-alert
    When dentist confirms usage after warning dialog
    Then medication usage record is created
    And stock deduction flow starts

  @must
  Scenario: Mark usage deducted after successful stock deduction
    Given a usage record is pending_deduct
    And stock balance is sufficient
    When deduction runs
    Then usage status becomes deducted
    And deducted timestamp is stored

  @must
  Scenario: Fail stock deduction when insufficient balance
    Given usage record is pending_deduct
    And available stock is lower than requested quantity
    When deduction runs
    Then usage status becomes failed
    And deduct_error is recorded

  @must
  Scenario: Rollback usage when source post is voided
    Given medication and supply usages were created from a clinical post
    When the clinical post is voided
    Then usage records are voided/re-synced according to policy
    And stock movements are compensated with reverse movements

  @must
  Scenario: Requisition approval guard blocks self-approval
    Given requisition status is pending and requester is user A
    When user A attempts approval
    Then state transition is rejected with guard violation

  @must
  Scenario: Approve requisition with different approver
    Given requisition status is pending and requester is user A
    When user B approves requisition
    Then status changes to approved
    And approval metadata is stored

  @must
  Scenario: Reject dispense without dispense number
    Given requisition status is approved
    When pharmacist attempts dispense without dispense number
    Then response is STATE_GUARD_VIOLATION
    And status remains approved

  @must
  Scenario: Requisition receive records stock-in movement
    Given requisition status is dispensed
    When authorized receiver confirms receipt
    Then requisition becomes received
    And stock movement direction in is recorded for each item

  @must
  Scenario: Cancel approved requisition before dispense
    Given requisition status is approved
    When authorized user cancels requisition with reason
    Then status changes to cancelled
    And no dispense or receive action is allowed afterwards

  @must
  Scenario: Master data soft-delete guard
    Given a procedure group is referenced by procedure items
    When admin attempts deletion
    Then hard delete is blocked
    And resource can only be deactivated

  @must
  Scenario: Policy denies unauthorized workflow transition
    Given user role is dental assistant without workflow transition permission
    When user calls transition endpoint
    Then response is forbidden

  @must
  Scenario: Return not found when visit ID does not exist
    Given visit ID does not exist
    When user requests workflow details
    Then response is NOT_FOUND

  @must
  Scenario: Prevent concurrent stage update race condition
    Given two users edit the same workflow concurrently
    When second user submits stale updatedAt
    Then response indicates conflict
    And user is asked to reload latest state

  @must
  Scenario: Locale behavior remains URL-scoped
    Given user is operating in /th
    When user receives validation and guard messages
    Then user-facing text resolves from Thai locale keys

  @should
  Scenario: Appointment sync creates registered queue entries for today
    Given confirmed dental appointments exist for current date
    When sync job executes
    Then registered workflows and queue entries are created

  @should
  Scenario: Coverage expiry fallback
    Given coverage record is expired
    When runtime pricing resolves for an item
    Then system falls back to master opd/ipd price

  @should
  Scenario: Drug allergy warning for medication order
    Given patient has known drug allergy
    When dentist attempts medication order
    Then warning is shown before final confirmation

  @could
  Scenario: Bulk coverage update with optimistic lock conflict handling
    Given admin selects many coverage rows
    When stale updatedAt values are submitted
    Then conflict response asks user to reload or overwrite

  @wont
  Scenario: Implement non-dental module internal business logic
    # Explicitly out of scope for this feature decomposition
```

---

## Test scenario mapping

| Scenario | Priority | Request spec | Policy spec | Contract spec | System spec |
|---|---|---|---|---|---|
| Create dental visit from registration intake | @must | Yes | Yes | Yes (registration contract) | Yes |
| Transition checked-in to screening with room assignment | @must | Yes | Yes | No | Yes |
| Transition ready-for-treatment to in-treatment with assigned dentist | @must | Yes | Yes | No | Yes |
| Guard screening -> ready-for-treatment | @must | Yes | Yes | No | Yes |
| Send to cashier and set waiting-payment | @must | Yes | Yes | Yes (cashier contract) | Yes |
| Auto-complete on paid sync | @must | Yes | Yes | Yes (cashier status mapping) | Yes |
| Handle payment sync failure without corrupting workflow state | @must | Yes | Yes | Yes (cashier status mapping) | Optional |
| Complete visit directly when payment is not required | @must | Yes | Yes | No | Yes |
| Refer out from in-treatment | @must | Yes | Yes | Yes (refer integration) | Yes |
| Cancel visit from registered stage | @must | Yes | Yes | No | Yes |
| Cancel visit from checked-in stage | @must | Yes | Yes | No | Yes |
| Reject invalid workflow transition | @must | Yes | Yes | No | Yes |
| Procedure validation for required selections | @must | Yes | Yes | No | Yes |
| High-alert medication usage warning flow | @must | Yes | Yes | Yes (medication profile mapping) | Yes |
| Mark usage deducted after successful stock deduction | @must | Yes | Yes | Yes (stock contract) | Optional |
| Insufficient stock deduction failure | @must | Yes | Yes | Yes (stock contract) | Optional |
| Void post rollback for usage/stock | @must | Yes | Yes | Yes (rollback payload parity) | Optional |
| Requisition self-approval guard | @must | Yes | Yes | No | Optional |
| Approve requisition with different approver | @must | Yes | Yes | No | Optional |
| Reject dispense without dispense number | @must | Yes | Yes | No | Optional |
| Requisition receive creates stock-in | @must | Yes | Yes | Yes (requisition + stock contracts) | Optional |
| Cancel approved requisition before dispense | @must | Yes | Yes | No | Optional |
| Master data soft-delete guard | @must | Yes | Yes | No | Optional |
| Unauthorized workflow transition forbidden | @must | Yes | Yes | No | Optional |
| Return not found when visit ID does not exist | @must | Yes | Yes | No | Optional |
| Prevent concurrent stage update race condition | @must | Yes | Yes | No | Optional |
| Locale-scoped Thai behavior | @must | Yes | Yes | No | Yes |
| Appointment sync for today | @should | Yes | Yes | Yes (appointment contract) | Optional |
| Coverage expiry fallback | @should | Yes | No | Yes (coverage resolve contract) | Optional |
| Drug allergy warning | @should | Yes | Yes | Yes (allergy source contract) | Yes |
| Bulk coverage optimistic lock conflict | @could | Optional | Optional | No | Optional |
| Non-dental internal logic | @wont | N/A | N/A | N/A | N/A |

Locale coverage expectation:

- All user-visible scenarios must be validated for both `/en` and `/th` paths where text output is user-facing.

---

## Transition coverage audit

| State machine | Transition | Covered scenario |
|---|---|---|
| Workflow | registered -> checked-in | Create dental visit from registration intake |
| Workflow | checked-in -> screening | Transition checked-in to screening with room assignment |
| Workflow | screening -> ready-for-treatment | Enforce guarded stage transition from screening to ready-for-treatment |
| Workflow | ready-for-treatment -> in-treatment | Transition ready-for-treatment to in-treatment with assigned dentist |
| Workflow | in-treatment -> waiting-payment | Complete treatment with payable items |
| Workflow | in-treatment -> completed (not-required) | Complete visit directly when payment is not required |
| Workflow | waiting-payment -> completed (paid) | Auto-complete visit when payment is fully paid |
| Workflow | in-treatment -> referred-out | Refer out from in-treatment |
| Workflow | registered -> cancelled | Cancel visit from registered stage |
| Workflow | checked-in -> cancelled | Cancel visit from checked-in stage |
| Requisition | pending -> approved | Approve requisition with different approver |
| Requisition | approved -> dispensed | Reject dispense without dispense number (guard check) |
| Requisition | dispensed -> received | Requisition receive records stock-in movement |
| Requisition | pending -> cancelled | Requisition approval guard blocks self-approval (pending control path) |
| Requisition | approved -> cancelled | Cancel approved requisition before dispense |
| Usage | pending_deduct -> deducted | Mark usage deducted after successful stock deduction |
| Usage | pending_deduct -> failed | Fail stock deduction when insufficient balance |
| Usage | deducted/failed -> pending_deduct (rollback/retry) | Rollback usage when source post is voided |
