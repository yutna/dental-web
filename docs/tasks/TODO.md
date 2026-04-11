# Dental Web - E2E Tests for Demo

Complete end-to-end test coverage for all application features.
These tests serve as both quality gates and executable demos.

**Status**: Planning & Implementation  
**Current Date**: April 2026  
**Run Tests**: `BACKEND_API_BASE_URL=https://your-backend bin/rspec spec/system`

---

## Core Authentication & Navigation

- [ ] **Sign In Flow** - User authentication with valid/invalid credentials
  - [ ] Sign in with valid credentials → redirects to workspace
  - [ ] Sign in with invalid credentials → shows error
  - [ ] Sign out → redirects to sign-in page
  - Location: `spec/system/authentication_spec.rb` (✓ Exists - may need enhancement)

---

## Queue Dashboard (Visit Management Hub)

- [ ] **Queue Dashboard Core**
  - [ ] Display list of all queued visits with patient info, HN, status
  - [ ] Search by HN (Medical Record Number)
  - [ ] Search by patient name
  - [ ] Filter by visit status (scheduled, checked-in, screening, treatment, completed)
  - [ ] Filter by source (manual, appointment_sync)
  - [ ] Pagination of queue results
  - Location: `spec/system/queue_dashboard_spec.rb` (✓ Exists - expand test coverage)

---

## Visit Workflow

### 1. Check-In Process

- [ ] **Manual Check-In**
  - [ ] Create visit via check-in endpoint with patient details
  - [ ] Visit appears on queue dashboard
  - [ ] Visit status shows as "checked-in"
  - [ ] Patient name, HN, VN, service type are captured
  - Location: `spec/system/dental/workflow_end_to_end_spec.rb` (✓ Partial)

### 2. Visit Transitions (Stage Management)

- [ ] **Visit Stage Transitions**
  - [ ] View current visit details and stage
  - [ ] Transition from checked-in → screening
  - [ ] Transition from screening → treatment
  - [ ] Transition from treatment → completed
  - [ ] Guard validations prevent invalid transitions
  - [ ] Cannot skip stages (e.g., checked-in → treatment must have screening)

### 3. Appointment Sync

- [ ] **Sync Appointments from Backend**
  - [ ] Trigger appointment sync endpoint
  - [ ] System creates registered visits from appointment list
  - [ ] Synced visits appear on queue dashboard
  - [ ] Filter results by source "appointment_sync"
  - [ ] Show count of created, skipped, and error records
  - Location: `spec/system/dental/workflow_end_to_end_spec.rb` (✓ Exists)

---

## Clinical Forms (Diagnostic & Treatment Data Entry)

### 1. Screening Form

- [ ] **Screening Data Entry**
  - [ ] Open screening form for visit
  - [ ] Enter patient vitals (blood pressure, pulse, weight, temperature)
  - [ ] Record presenting symptoms/chief complaint
  - [ ] Save screening data
  - [ ] Data persists and appears in clinical history
  - Location: `spec/system/clinical_forms_enterprise_spec.rb` (✓ Partial)

### 2. Treatment Form

- [ ] **Treatment Procedures Entry**
  - [ ] Open treatment form for visit
  - [ ] Add procedure items with procedure code
  - [ ] Assign tooth numbers
  - [ ] Select tooth surfaces (buccal, lingual, occlusal, mesial, distal)
  - [ ] Set quantity per procedure
  - [ ] Save treatment procedures
  - [ ] Procedures appear in clinical history and dental chart
  - Location: `spec/system/clinical_forms_enterprise_spec.rb` (✓ Partial)

### 3. Medication Form (with Safety Checks)

- [ ] **Medication Prescription Entry**
  - [ ] Open medication form for visit
  - [ ] Add medication with code and quantity
  - [ ] Save basic medication
  - Location: `spec/system/clinical_forms_enterprise_spec.rb` (✓ Partial)

- [ ] **Medication Safety Validations**
  - [ ] High-alert medications require explicit confirmation
  - [ ] Display warning: "High-alert drug - confirm to proceed"
  - [ ] Allergy conflicts detected and blocked
  - [ ] Override confirmation required for allergy conflicts
  - [ ] Cannot prescribe if user hasn't confirmed/overridden
  - [ ] Error handling and retry flow
  - Location: `spec/system/clinical_forms_enterprise_spec.rb` (✓ Exists)

### 4. Dental Chart Form

- [ ] **Dental Chart Entry**
  - [ ] Open dental chart form for visit
  - [ ] Display 2D tooth map (32-tooth FDI numbering)
  - [ ] Click teeth to select/mark for procedures
  - [ ] Record tooth conditions/findings per tooth
  - [ ] Visualize procedures applied to specific teeth
  - [ ] Save chart data

### 5. Clinical Images/Photos

- [ ] **Clinical Image Upload & Management**
  - [ ] Open image form for visit
  - [ ] Upload clinical photos (intra-oral, extra-oral)
  - [ ] Assign image type (intra-oral, extra-oral, panoramic, etc.)
  - [ ] View thumbnail gallery of uploaded images
  - [ ] Link images to specific teeth or procedures
  - [ ] Save image metadata

### 6. Cumulative Clinical History

- [ ] **View Complete Treatment History**
  - [ ] Open history drawer for visit
  - [ ] Display timeline of all clinical entries:
    screening, treatment, medication, and procedures
  - [ ] Show cumulative tooth chart with all procedures
  - [ ] List all medications prescribed
  - [ ] Chronological sorting of entries
  - [ ] Print history report
  - Location: `spec/system/clinical_forms_enterprise_spec.rb` (✓ Partial)

---

## Billing & Payments

### 1. Invoice Generation

- [ ] **Create Invoice from Visit Charges**
  - [ ] Generate invoice when visit complete
  - [ ] Auto-calculate totals from procedures, supplies, medications
  - [ ] Generate invoice ID (INV-*)
  - [ ] Set payment status to "pending"
  - [ ] Store line items (procedures, supplies, adjustments)
  - [ ] Include patient, visit, and service details

### 2. Waiting Board (Unpaid Visits)

- [ ] **View Unpaid Visits**
  - [ ] Display list of visits with unpaid balances
  - [ ] Show total outstanding amount per visit
  - [ ] Show invoice ID and visit date
  - [ ] Filter by date range
  - [ ] Search by patient name or HN
  - [ ] Show invoice details and itemization

- [ ] **Waiting Board Rendering**
  - [ ] Access waiting board at `/en/dental/billing/waiting`
  - [ ] Load all pending invoices
  - [ ] Display in list or card view
  - [ ] Sort by amount due, patient name, date

### 3. Waiting Payments Dashboard

- [ ] **Waiting Payments View**
  - [ ] Access waiting payments board at `/en/dental/billing/waiting_payments`
  - [ ] Display payment-pending visits
  - [ ] Show amounts due per visit with breakdown
  - [ ] Patient contact info and visit details
  - [ ] Filter by service type or date
  - Location: `spec/system/supply_billing_spec.rb` (✓ Partial)

### 4. Payment Status Sync (Backend Integration)

- [ ] **Payment Status Update Request**
  - [ ] Backend sends payment status updates to BFF
  - [ ] Include invoice ID, new status (paid, cancelled, partial)
  - [ ] HMAC signature for security verification

- [ ] **HMAC Signature Validation**
  - [ ] Validate signature using shared secret key
  - [ ] Reject requests with invalid signatures (403 Forbidden)
  - [ ] Prevent tampering of payment data

- [ ] **Payment Sync Processing**
  - [ ] Receive payment status update
  - [ ] Validate signature (HMAC-SHA256)
  - [ ] Update invoice payment_status in database
  - [ ] Record paid_at timestamp
  - [ ] Mark as "paid" or update accordingly
  - [ ] Handle idempotent requests (same payment sync twice)
  - [ ] Log all payment sync events

- [ ] **Billing Test Scenarios**
  - [ ] Create invoice and show on waiting board
  - [ ] Sync valid payment with correct signature → invoice marked paid
  - [ ] Reject sync with invalid signature → invoice remains pending
  - [ ] Idempotent sync (re-process same payment) → no errors
  - Location: `spec/system/dental/supply_billing_gate_spec.rb` (✓ Exists)

### 5. Billing Sync Endpoint

- [ ] **Sync Billing Data from Backend**
  - [ ] Trigger billing sync via `/en/dental/billing/waiting/sync` POST
  - [ ] Pull invoice updates from backend API
  - [ ] Display sync results (created, updated, skipped)

---

## Supply Management & Requisitions

### 1. Supply Requisitions (Full Lifecycle)

- [ ] **Create Requisition**
  - [ ] Initiate new supply requisition with line items
  - [ ] Add multiple supply items with quantities
  - [ ] Set requester info and notes
  - [ ] Submit for approval
  - [ ] System generates requisition ID (REQ-*)

- [ ] **View Requisitions List**
  - [ ] Display all supply requisitions with status:
    pending, approved, dispatched, received, cancelled
  - [ ] Show requisition ID, status, requester, request date, items count
  - [ ] Sort by date, status, requester
  - [ ] Search by requisition ID or requester name
  - [ ] Location: `spec/system/supply_billing_spec.rb` (✓ Exists)

- [ ] **View Requisition Details**
  - [ ] Open individual requisition
  - [ ] Display all line items (item code, name, quantity, unit, cost)
  - [ ] Show total items and quantities and estimated cost
  - [ ] View requestor and current approval status
  - [ ] Access approval/dispense buttons if authorized
  - [ ] Location: `spec/system/supply_billing_spec.rb` (✓ Exists)

### 2. Requisition Approval & Workflow

- [ ] **Approve Requisition**
  - [ ] Approver views pending requisitions
  - [ ] Cannot self-approve (different user required)
  - [ ] Click approve button
  - [ ] Record approver ID and timestamp
  - [ ] Requisition status changes to "approved"
  - [ ] Email/notification sent to requester

- [ ] **Reject/Cancel Requisition**
  - [ ] Approver can reject pending requisitions
  - [ ] Requester can cancel after approval (if not yet dispatched)
  - [ ] Record cancel reason in system
  - [ ] Store canceller ID and date

- [ ] **Dispense Requisition**
  - [ ] Dispenser enters dispense number (receipt/tracking ID)
  - [ ] Validate all line items are present
  - [ ] Mark as "dispatched"
  - [ ] Record dispenser ID and timestamp

- [ ] **Receive Requisition**
  - [ ] Receiver confirms stock arrival
  - [ ] Generate stock-in movements for each line item
  - [ ] Mark requisition as "received"
  - [ ] Create inventory records

### 3. Supply Stock Management (Inventory)

- [ ] **Stock Movements Tracking**
  - [ ] Record all stock in/out transactions
  - [ ] Track source (requisition, usage, adjustment)
  - [ ] Direction: "in" (receive) or "out" (deduct)
  - [ ] Quantity tracking per transaction
  - [ ] Timestamp and actor ID

- [ ] **Supply Usage Records**
  - [ ] Record when supplies are used during visits
  - [ ] Track usage per visit, per item, quantity consumed
  - [ ] Status progression: pending_deduct → deducted → voided
  - [ ] Automatic stock deduction on usage confirmation
  - [ ] Deduction failure handling (insufficient stock)

- [ ] **Stock Deduction Workflow**
  - [ ] Deduct supplies from inventory on usage
  - [ ] Prevent deduction if insufficient stock (raise error)
  - [ ] Mark usage as "deducted" on success
  - [ ] Mark usage as "failed" on stock error
  - [ ] Support retry of failed deductions
  - [ ] Audit trail of all deduction attempts

- [ ] **Void Usage (Compensating Transactions)**
  - [ ] Reverse supply usage after deduction
  - [ ] Create compensating stock-in movement
  - [ ] Restore inventory to previous level
  - [ ] Record reason for void
  - [ ] Maintain audit trail

- [ ] **Stock Balance & Reporting**
  - [ ] View current stock levels per supply item
  - [ ] Track stock movement history
  - [ ] Alert on low stock conditions
  - [ ] Generate stock reports (day, month, cumulative)

---

## Admin Features

### 1. Admin Dashboard

- [ ] **Admin Overview**
  - [ ] Access admin dashboard at `/en/admin`
  - [ ] Display key metrics (today's visits, pending tasks, etc.)
  - [ ] Navigation to admin modules
  - [ ] Role verification (admin-only)

### 2. Admin - Clinic Services Management

- [ ] **Clinic Services List**
  - [ ] Display all clinic services (Scaling, Filling, Crown, etc.)
  - [ ] Create new service
  - [ ] Edit existing service
  - [ ] Delete service (with confirmation)
  - [ ] Search and filter services

### 3. Dental Admin Dashboard

- [ ] **Dental Admin Overview**
  - [ ] Access dental admin dashboard
  - [ ] Display clinic-specific metrics
  - [ ] Navigation to dental master data modules

### 4. Audit Events Log

- [ ] **View Audit Trail**
  - [ ] Display all system audit events
  - [ ] Show event type, user, timestamp, affected records
  - [ ] Filter by event type
  - [ ] Search by user or record ID
  - [ ] Page through audit log

### 5. Master Data Management (Dental Admin)

#### 5.1 Procedure Items

- [ ] **Procedure Items Catalog**
  - [ ] Display list of all dental procedures (scaling, extraction, crown, etc.)
  - [ ] Show procedure code, name, category, base price
  - [ ] Search by procedure name/code
  - [ ] Create new procedure item
  - [ ] Edit procedure details and pricing
  - [ ] Bulk import procedures (upload CSV)
  - [ ] Preview import before applying

- [ ] **Price Change Approval**
  - [ ] View price change requests
  - [ ] Approve new pricing
  - [ ] Price change history

#### 5.2 Medication Profiles

- [ ] **Medication Master Data**
  - [ ] List all medication profiles in system
  - [ ] Show medication code, name, category (high-alert, antibiotic, etc.)
  - [ ] View contraindications and warnings
  - [ ] Create new medication profile
  - [ ] Edit medication details
  - [ ] Mark medications as active/inactive
  - [ ] Bulk import medications

#### 5.3 Supply Categories

- [ ] **Supply Category Management**
  - [ ] List supply categories (gloves, bibs, masks, instruments, etc.)
  - [ ] Create new category
  - [ ] Edit category details
  - [ ] Delete category

#### 5.4 Supply Items

- [ ] **Supply Items Catalog**
  - [ ] Display all supply items with category, code, unit, price
  - [ ] Link to supply category
  - [ ] Create new supply item
  - [ ] Edit supply item details
  - [ ] Set pricing and unit (piece, box, dozen, etc.)
  - [ ] Bulk import supply items

#### 5.5 References (Lookup Tables)

- [ ] **Reference Data Management**
  - [ ] Manage tooth surface codes (M, O, L, D, I)
  - [ ] Manage procedure categories
  - [ ] Manage medication categories
  - [ ] Manage visit statuses
  - [ ] Manage image types

#### 5.6 Coverages

- [ ] **Insurance Coverage Management**
  - [ ] List all insurance plans/coverages
  - [ ] Show coverage limits and procedures covered
  - [ ] Create new coverage plan
  - [ ] Edit coverage details
  - [ ] Assign procedures to coverage
  - [ ] Set coverage percentages

---

## Master Data Change Requests

- [ ] **Price Change Requests**
  - [ ] Flag when procedure/supply item price changes
  - [ ] Create change request record with old/new price
  - [ ] Admin review and approve price changes
  - [ ] View all pending change requests
  - [ ] Historical audit of all price changes
  - [ ] Prevent old prices from being used after approval

- [ ] **Data Validation Audit Trail**
  - [ ] Track all master data changes
  - [ ] Log user who made change, timestamp, old/new values
  - [ ] Support rollback of changes
  - [ ] Compliance reporting of master data modifications

---

## API Integration Tests

- [ ] **Queue API (v1)**
  - [ ] GET /api/v1/queues - List queues
  - [ ] POST /api/v1/queues - Create queue entry

- [ ] **Visits API (v1)**
  - [ ] GET /api/v1/visits/:id - Fetch visit details
  - [ ] PATCH /api/v1/visits/:id/transition - Transition visit stage
  - [ ] POST /api/v1/visits/check_in - Check in visit
  - [ ] GET /api/v1/visits/:id/clinical_posts - Fetch clinical posts
  - [ ] POST /api/v1/visits/:id/clinical_posts - Create clinical post

- [ ] **Print Documents API (v1)**
  - [ ] GET /api/v1/print/documents/:visit_id/:type - Generate clinical report PDF

- [ ] **Requisitions API (v1)**
  - [ ] GET /api/v1/requisitions - List requisitions
  - [ ] GET /api/v1/requisitions/:id - Fetch requisition details

- [ ] **Invoices API (v1)**
  - [ ] GET /api/v1/invoices - List invoices
  - [ ] GET /api/v1/invoices/:id - Fetch invoice details

- [ ] **Admin Master Data API (v1)**
  - [ ] GET /api/v1/admin/procedure_items - Fetch all procedures
  - [ ] GET /api/v1/admin/medication_profiles - Fetch all medications
  - [ ] GET /api/v1/admin/supply_items - Fetch all supplies

- [ ] **Billing Sync API (v1)**
  - [ ] POST /api/v1/billing/sync - Process payment status updates with HMAC validation

---

## Access Control & Permissions

- [ ] **Authentication & Session Management**
  - [ ] Session creation on login
  - [ ] Session validity and expiration
  - [ ] Secure cookie handling
  - [ ] CSRF protection on forms
  - [ ] Location: `spec/system/authentication_spec.rb` (✓ Exists)

- [ ] **Authorization & Policies (Pundit)**
  - [ ] Admin users can access admin dashboard
  - [ ] Dental users can access dental workspace
  - [ ] Cannot access restricted pages without permission
  - [ ] 403 Forbidden on unauthorized access
  - [ ] Location: `spec/system/dental/foundation_gate_spec.rb` (✓ Exists)

- [ ] **Role-Based Access**
  - [ ] Admin role for system administration
  - [ ] Operator/Clinician roles for clinical work
  - [ ] Finance role for billing operations
  - [ ] Each role has restricted feature set

- [ ] **Policy-First Authorization**
  - [ ] Use Pundit for all authorization checks
  - [ ] Gate admin routes with `admin:access` policy
  - [ ] Gate workspace routes with `workspace:read` policy
  - [ ] Enforce in controllers, not views

---

## Document Generation & Print

- [ ] **Print Clinical Report**
  - [ ] View print preview for treatment report
  - [ ] Generate PDF of clinical history
  - [ ] Include patient info, vitals, procedures, medications
  - [ ] Print-friendly formatting

- [ ] **Print Invoice/Receipt**
  - [ ] Generate invoice for visit charges
  - [ ] Include itemized procedures and costs
  - [ ] Payment status

---

## Localization & Multi-Language

- [ ] **Thai Language Support**
  - [ ] Switch app to Thai locale (`/th`)
  - [ ] All labels display in Thai
  - [ ] Patient name displays correctly (Thai characters)
  - [ ] Navigation and buttons translated

- [ ] **English Language Support**
  - [ ] Switch app to English locale (`/en`)
  - [ ] All labels display in English
  - [ ] Default locale works correctly

---

## Error Handling & Edge Cases

- [ ] **Guard Validations**
  - [ ] Cannot transition visit without completing required form
  - [ ] Cannot add treatment without screening completion
  - [ ] Medication safety checks and overrides
  - [ ] Cannot self-approve requisitions
  - [ ] Prevent deduction with insufficient stock

- [ ] **Data Persistence & Concurrency**
  - [ ] All entered data persists after page refresh
  - [ ] Form state is maintained during navigation
  - [ ] No data loss on form submission
  - [ ] Concurrent edits don't overwrite data
  - [ ] Optimistic locking on critical updates

- [ ] **Permission/Authorization**
  - [ ] Unauthorized users cannot access admin pages
  - [ ] Users without workspace permissions see error
  - [ ] Policy-based access control enforced
  - [ ] API requests with invalid tokens rejected (401/403)

- [ ] **Data Validation**
  - [ ] Vitals ranges validated (systolic < diastolic for BP)
  - [ ] Tooth codes valid (FDI numbering 1-32, 51-82)
  - [ ] Surface codes valid (M, O, D, L, I)
  - [ ] Quantities must be positive numbers
  - [ ] Field length limits enforced

- [ ] **Network & Timeout Handling**
  - [ ] Backend API timeout handled gracefully
  - [ ] Network errors show user-friendly message
  - [ ] Retry mechanism for failed requests
  - [ ] Partial form submission recovery

---

## Data Quality & Audit

- [ ] **Audit Trail Completeness**
  - [ ] All master data changes logged
  - [ ] User ID recorded for every change
  - [ ] Timestamp precision (to seconds)
  - [ ] Old vs new values tracked
  - [ ] Searchable by user, timestamp, record type

- [ ] **Data Consistency**
  - [ ] Foreign key references valid
  - [ ] No orphaned records
  - [ ] Inventory stock counts accurate
  - [ ] Invoice amounts match line items
  - [ ] Visit transitions follow rules

---

## Performance & Scalability

- [ ] **Dashboard Performance**
  - [ ] Queue dashboard loads < 2 seconds
  - [ ] Pagination works with 1000+ records
  - [ ] Search/filter responsive
  - [ ] No N+1 queries

- [ ] **Form Performance**
  - [ ] Clinical forms load without lag
  - [ ] Chart rendering smooth with 32 teeth
  - [ ] Image gallery responsive with 50+ photos
  - [ ] Dropdown lists searchable (medication, procedures)

- [ ] **API Response Times**
  - [ ] List endpoints respond < 1 second
  - [ ] Detail endpoints respond < 500ms
  - [ ] Bulk operations optimized

---

## Future Enhancements (Not in MVP)

- [ ] **PWA Support**
  - [ ] Service worker registration
  - [ ] Offline capability for critical data
  - [ ] Push notifications for appointments
  - [ ] Install to home screen

- [ ] **Advanced Reporting**
  - [ ] Clinical outcome reports
  - [ ] Revenue analysis by service/dentist
  - [ ] Patient acquisition funnel
  - [ ] Medication usage trends

- [ ] **Mobile UI Optimization**
  - [ ] Touch-friendly buttons and spacing
  - [ ] Mobile forms simplified
  - [ ] Bottom sheet navigation (mobile)
  - [ ] Responsive dental chart

---

## Implementation Notes

### Test Structure

```text
spec/system/
├── authentication_spec.rb            ✓ Exists
├── queue_dashboard_spec.rb           ✓ Exists  
├── clinical_forms_enterprise_spec.rb ✓ Exists (partial - expand)
├── supply_billing_spec.rb            ✓ Exists (partial - expand)
├── admin_console_enterprise_spec.rb  ✓ Exists (review)
└── dental/
    ├── workflow_end_to_end_spec.rb              ✓ Exists (partial - expand)
    ├── clinical_forms_and_history_spec.rb       ✓ Exists (review)
    ├── admin_master_data_gate_spec.rb           ✓ Exists (review & expand)
    ├── supply_billing_gate_spec.rb              ✓ Exists (review & expand)
    ├── foundation_gate_spec.rb                  ✓ Exists (review)
    ├── billing_and_payments_spec.rb             (create - NEW)
    ├── stock_management_spec.rb                 (create - NEW)
    ├── requisition_lifecycle_spec.rb            (create - NEW)
    └── access_control_spec.rb                   (create - NEW)

spec/requests/
├── api_v1_queues_spec.rb             (create - API tests)
├── api_v1_visits_spec.rb             (create - API tests)
├── api_v1_billing_spec.rb            (create - API tests)
└── api_v1_master_data_spec.rb        (create - API tests)
```

### Test Data Helpers

- Use existing `sign_in_as_admin` helper
- Use existing `patch_json` helper for API calls
- Enhance `create_queue_entry` for comprehensive test data
- Create clinical form builders for complex scenarios
- Create requisition builders with line items
- Create invoice builders with line items
- Create medication profile seeder

### Test Execution Commands

```bash
# All system tests (non-API)
bin/rspec spec/system

# Specific test file
bin/rspec spec/system/dental/workflow_end_to_end_spec.rb

# With visual browser (headless Chrome)
BACKEND_API_BASE_URL=https://your-backend bin/rspec spec/system/authentication_spec.rb

# API tests (request specs)
bin/rspec spec/requests/api_v1_visits_spec.rb

# Full CI verification
bin/ci

# Generate HTML report
bin/rspec spec/system --format html --out spec/system_test_report.html
```

### Prerequisites

- Backend API URL: `BACKEND_API_BASE_URL=https://your-backend`
- Test database seeded with reference data
- Selenium headless Chrome driver
- Test users configured (admin.test/secret, clinician.test/secret)

### Test Data Requirements

```yaml
# Reference Data (Must be in DB before tests)
procedure_groups:
  - PROC-GRP-100
  - PROC-GRP-200

procedure_items:
  - PROC-100, PROC-200 (various categories)

medication_profiles:
  - MED-100, AMOX-500 (including high-alert)

supply_categories:
  - Gloves, Instruments, etc.

supply_items:
  - SUP-1, SUP-2, etc.

image_types:
  - XRAY, INTRA_ORAL, EXTRA_ORAL

tooth_references:
  - FDI 1-32, 51-82 (complete tooth set)

surface_references:
  - M (Mesial), O (Occlusal), D (Distal), L (Lingual), I (Incisal)
```

---

## Demo Scenario Script

**For Customer Live Presentation (30-45 minutes):**

### Scene 1: Authentication (2 min)

1. Show login page `/en/session/new`
2. Sign in with demo credentials
3. Redirect to workspace dashboard

### Scene 2: Queue Management (5 min)

1. Open queue dashboard `/en/workspace`
2. Show list of patients with HN, name, status
3. Search by HN → show filtered results
4. Filter by status → show progression
5. Click a patient to view details

### Scene 3: Patient Check-In (3 min)

1. Manual check-in of new patient
2. Enter patient name, HN, VN, service type
3. Patient appears on queue (checked-in status)
4. Show check-in status transition

### Scene 4: Clinical Workflow (15 min)

1. **Screening** - Open screening form
   - Enter vitals (BP, pulse, weight)
   - Record symptoms
   - Save form

2. **Treatment** - Open treatment form
   - Select procedures
   - Assign to tooth numbers
   - Select tooth surfaces
   - Save

3. **Medication** - Open medication form
   - Try high-alert medication
   - Show confirmation dialog
   - Save with confirmation

4. **Dental Chart** - Show chart with procedures
   - Visual tooth map FDI numbered
   - Procedures highlighted

5. **Clinical History** - View cumulative record
   - Timeline of all entries
   - Combined tooth map
   - All procedures listed

### Scene 5: Billing (5 min)

1. Show waiting payments board `/en/dental/billing/waiting_payments`
2. List of unpaid visits
3. Show invoice details
4. Explain payment sync workflow

### Scene 6: Admin Features (5 min)

1. Go to admin dashboard `/en/admin/dental`
2. Show master data:
   - Procedure items list
   - Create new procedure
   - Medication profiles
   - Supply management
3. Show audit trail `/en/admin/dental/audit_events`
   - List all changes
   - User and timestamp tracked

### Scene 7: Localization (3 min)

1. Change URL to `/th`
2. Show Thai language interface
3. Show Thai patient names display correctly

### Scene 8: Summary & Questions (2 min)

- Recap main features shown
- Address customer questions
- Schedule next steps

---

## Priority Levels

### Phase 1: MVP Demo (High Priority)

These tests validate core functionality for customer demo.

#### Group 1A - Foundation (Week 1)

- [ ] Authentication & Login
- [ ] Queue Dashboard (list, search, filter)
- [ ] Visit creation (check-in)
- [ ] Visit transitions (stage flow)
- Location: Expand `authentication_spec.rb`, `queue_dashboard_spec.rb`, `workflow_end_to_end_spec.rb`

#### Group 1B - Clinical Core (Week 2)

- [ ] Screening form entry & save
- [ ] Treatment form entry & procedures
- [ ] Medication form & basic save
- [ ] Dental chart visualization
- [ ] Clinical history view
- Location: Expand `clinical_forms_enterprise_spec.rb`, `clinical_forms_and_history_spec.rb`

#### Group 1C - Admin Core (Week 3)

- [ ] Admin dashboard access
- [ ] Master data lists (procedures, medications)
- [ ] Create/edit master data
- [ ] Audit events viewing
- [ ] Localization (EN/TH)
- Location: Expand `admin_console_enterprise_spec.rb`, `admin_master_data_gate_spec.rb`

### Phase 2: Core Features (Medium Priority)

These add business logic and compliance.

#### Group 2A - Clinical Safety (Week 4)

- [ ] Medication high-alert validation
- [ ] Allergy conflict detection
- [ ] Medication override confirmation
- [ ] Guard validations on transitions
- Location: Create `clinical_safety_spec.rb`

#### Group 2B - Supply and Billing (Week 5)

- [ ] Supply requisition full lifecycle (approve, dispense, receive)
- [ ] Stock movement tracking
- [ ] Invoice generation
- [ ] Payment sync (HMAC validation)
- [ ] Waiting board display
- Location: Create/expand `supply_billing_gate_spec.rb`,
  `billing_and_payments_spec.rb`, `stock_management_spec.rb`

#### Group 2C - API Integration (Week 6)

- [ ] All v1 API endpoints tested
- [ ] Bearer token authentication
- [ ] Error responses (401, 403, 404)
- [ ] Request payload validation
- Location: Create `spec/requests/api_v1_*.rb` files

### Phase 3: Enhancement and Polish (Low Priority)

These improve robustness and user experience.

#### Group 3A - Error Handling and Edge Cases

- [ ] Data validation (ranges, formats)
- [ ] Network timeouts and retries
- [ ] Concurrent operations
- [ ] Permission edge cases
- Location: Create `error_handling_spec.rb`

#### Group 3B - Performance and Compliance

- [ ] Dashboard load times < 2s
- [ ] Pagination with large datasets
- [ ] Data audit trail completeness
- [ ] Inventory accuracy
- Location: Create `performance_spec.rb`, `data_quality_spec.rb`

#### Group 3C - Bulk Operations

- [ ] Master data bulk import (CSV)
- [ ] Bulk price changes
- [ ] Bulk medication updates
- [ ] Import preview and validation
- Location: Create `bulk_operations_spec.rb`

### Test Implementation Strategy

1. **Start with existing test files** - Review and expand what's already there
2. **Follow BFF conventions** - Use existing helpers and patterns
3. **Data-driven scenarios** - Use factories for predictable test data
4. **One feature per spec file** - Focused, maintainable tests
5. **Assertion clarity** - Clear failure messages for debugging
6. **Comprehensive descriptions** - Each test documents feature behavior

---

**Created**: April 11, 2026  
**Last Updated**: April 11, 2026  
**Status**: Comprehensive E2E test plan created and ready for implementation  
**Next Step**: Begin Phase 1 implementation,
starting with Group 1A (Foundation tests)
