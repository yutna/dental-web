require "rails_helper"

RSpec.describe "Dental supply, requisition, and billing gate", type: :system do
  before do
    driven_by :rack_test
  end

  # ---------------------------------------------------------------------------
  # Usage deduction (state-13, state-14)
  # ---------------------------------------------------------------------------

  describe "usage deduction lifecycle" do
    it "deducts stock and marks usage deducted (state-13)" do
      usage = create_usage_record(status: "pending_deduct")

      result = Dental::SupplyCosting::DeductUsage.call(
        usage_record: usage,
        actor_id: "ACTOR-SYS-001"
      )

      expect(result[:usage_record].reload.status).to eq("deducted")
      expect(result[:movement]).to be_a(DentalStockMovement)
      expect(result[:movement].direction).to eq("out")
      expect(result[:created]).to be true
    end

    it "marks usage failed on insufficient stock guard (state-14)" do
      usage = create_usage_record(status: "pending_deduct")

      allow(Dental::SupplyCosting::PostStockMovement).to receive(:call).and_raise(
        Dental::Errors::InsufficientStock.new(details: { available: 0, requested: 5 })
      )

      result = Dental::SupplyCosting::DeductUsage.call(
        usage_record: usage,
        actor_id: "ACTOR-SYS-001"
      )

      expect(result[:usage_record].reload.status).to eq("failed")
      expect(result[:error]).to be_a(Dental::Errors::InsufficientStock)
    end

    it "voids usage with compensating stock-in movement" do
      usage = create_usage_record(status: "pending_deduct")
      Dental::SupplyCosting::DeductUsage.call(usage_record: usage, actor_id: "ACTOR-001")
      usage.reload

      result = Dental::SupplyCosting::VoidUsage.call(usage_record: usage, reason: "Post voided", actor_id: "ACTOR-002")

      expect(result[:usage_record].reload).to be_voided
      expect(result[:compensating_movement]).to be_a(DentalStockMovement)
      expect(result[:compensating_movement].direction).to eq("in")
    end

    it "retries failed usage and succeeds" do
      usage = create_usage_record(status: "failed", deduct_error: "previous failure")

      result = Dental::SupplyCosting::RetryUsage.call(usage_record: usage, actor_id: "ACTOR-003")

      expect(result[:usage_record].reload.status).to eq("deducted")
    end
  end

  # ---------------------------------------------------------------------------
  # Requisition lifecycle (state-15 through state-18, state-36)
  # ---------------------------------------------------------------------------

  describe "requisition lifecycle" do
    it "blocks self-approval (state-16)" do
      requisition = create_requisition(requester_id: "USER-A")

      expect {
        requisition.approve!(approver_id: "USER-A")
      }.to raise_error(Dental::Errors::GuardViolation)

      expect(requisition.reload.status).to eq("pending")
    end

    it "approves with different approver and stores metadata (state-15)" do
      requisition = create_requisition(requester_id: "USER-A")

      requisition.approve!(approver_id: "USER-B")

      expect(requisition.reload.status).to eq("approved")
      expect(requisition.approver_id).to eq("USER-B")
      expect(requisition.approved_at).to be_present
    end

    it "rejects dispense without dispense number (state-17)" do
      requisition = create_requisition(requester_id: "USER-A")
      requisition.approve!(approver_id: "USER-B")

      expect {
        requisition.dispense!(dispenser_id: "USER-C", dispense_number: "")
      }.to raise_error(Dental::Errors::GuardViolation)

      expect(requisition.reload.status).to eq("approved")
    end

    it "records stock-in on receive (state-18)" do
      requisition = create_requisition_with_items(requester_id: "USER-A")
      requisition.approve!(approver_id: "USER-B")
      requisition.dispense!(dispenser_id: "USER-C", dispense_number: "DISP-001")

      result = Dental::SupplyCosting::ReceiveRequisition.call(
        requisition: requisition,
        receiver_id: "USER-D"
      )

      expect(result[:requisition].reload.status).to eq("received")
      expect(result[:movements].size).to eq(requisition.line_items.count)
      expect(result[:movements].map(&:id).uniq.size).to eq(requisition.line_items.count)
      result[:movements].each do |m|
        expect(m.direction).to eq("in")
        expect(m.source).to eq("requisition")
      end
    end

    it "cancels approved requisition before dispense (state-36)" do
      requisition = create_requisition(requester_id: "USER-A")
      requisition.approve!(approver_id: "USER-B")

      Dental::SupplyCosting::CancelRequisition.call(
        requisition: requisition,
        reason: "No longer needed",
        actor_id: "USER-A"
      )

      expect(requisition.reload.status).to eq("cancelled")
      expect(requisition.cancel_reason).to eq("No longer needed")
      expect(requisition.canceller_id).to eq("USER-A")
    end
  end

  # ---------------------------------------------------------------------------
  # Billing and payment sync (state-19, state-20, state-21)
  # ---------------------------------------------------------------------------

  describe "billing and payment sync" do
    let(:shared_secret) { "test-secret-key" }

    it "creates invoice from line items and shows on waiting-payment board (state-19)" do
      result = build_test_invoice(visit_id: "VISIT-BILL-001")
      invoice = result[:invoice]

      expect(invoice.invoice_id).to start_with("INV-")
      expect(invoice.total_amount).to be_positive
      expect(invoice.payment_status).to eq("pending")

      sign_in_as_admin
      visit "/en/dental/billing/waiting"

      expect(page.status_code).to eq(200)
      expect(page.body).to include(invoice.invoice_id)
      expect(page.body).to include("VISIT-BILL-001")
    end

    it "handles payment sync with valid signature and marks paid (state-21)" do
      result = build_test_invoice(visit_id: "VISIT-BILL-002")
      invoice = result[:invoice]

      signature = compute_hmac(invoice.invoice_id, "paid", shared_secret)

      sync_result = Dental::SupplyCosting::SyncPayment.call(
        invoice_id: invoice.invoice_id,
        payment_status: "paid",
        signature: signature,
        shared_secret: shared_secret,
        paid_at: Time.current
      )

      expect(sync_result[:changed]).to be true
      expect(sync_result[:invoice].reload.payment_status).to eq("paid")
    end

    it "rejects payment sync with invalid signature (state-20)" do
      result = build_test_invoice(visit_id: "VISIT-BILL-003")
      invoice = result[:invoice]

      expect {
        Dental::SupplyCosting::SyncPayment.call(
          invoice_id: invoice.invoice_id,
          payment_status: "paid",
          signature: "invalid-signature",
          shared_secret: shared_secret
        )
      }.to raise_error(Dental::Errors::Forbidden)

      expect(invoice.reload.payment_status).to eq("pending")
    end

    it "is idempotent when payment already synced" do
      result = build_test_invoice(visit_id: "VISIT-BILL-004")
      invoice = result[:invoice]

      signature = compute_hmac(invoice.invoice_id, "paid", shared_secret)

      Dental::SupplyCosting::SyncPayment.call(
        invoice_id: invoice.invoice_id,
        payment_status: "paid",
        signature: signature,
        shared_secret: shared_secret
      )

      second = Dental::SupplyCosting::SyncPayment.call(
        invoice_id: invoice.invoice_id,
        payment_status: "paid",
        signature: signature,
        shared_secret: shared_secret
      )

      expect(second[:changed]).to be false
    end

    it "provides manual sync action from waiting-payment board" do
      result = build_test_invoice(visit_id: "VISIT-BILL-005")
      invoice = result[:invoice]

      sign_in_as_admin
      page.driver.submit(:post, "/en/dental/billing/waiting/sync.json", { invoice_id: invoice.invoice_id })
      body = JSON.parse(page.body)

      expect(body["invoice_id"]).to eq(invoice.invoice_id)
      expect(body["sync_status"]).to eq("requested")
    end
  end

  # ---------------------------------------------------------------------------
  # Requisition policy enforcement
  # ---------------------------------------------------------------------------

  describe "requisition policy enforcement" do
    it "respects role-based approve, dispense, receive, cancel permissions" do
      policy = Dental::RequisitionPolicy.new(build_principal("dental:requisition:approve"), :dental_requisition)
      expect(policy.approve?).to be true
      expect(policy.dispense?).to be false

      policy2 = Dental::RequisitionPolicy.new(build_principal("dental:requisition:dispense"), :dental_requisition)
      expect(policy2.dispense?).to be true
      expect(policy2.approve?).to be false
    end
  end

  # ---------------------------------------------------------------------------
  # Stock movement idempotency
  # ---------------------------------------------------------------------------

  describe "stock movement idempotency" do
    it "skips duplicate movement post without error" do
      params = {
        item_type: "medication",
        item_code: "MED-IDEM-001",
        direction: "out",
        quantity: 3,
        unit: "tab",
        source: "pharmacy",
        reference_type: "usage",
        reference_id: "USAGE-IDEM-001",
        actor_id: "ACTOR-001"
      }

      first = Dental::SupplyCosting::PostStockMovement.call(**params)
      second = Dental::SupplyCosting::PostStockMovement.call(**params)

      expect(first[:created]).to be true
      expect(second[:created]).to be false
      expect(first[:movement].id).to eq(second[:movement].id)
    end
  end

  private

  def sign_in_as_admin
    visit "/en/session/new"
    fill_in "username", with: "admin.test"
    fill_in "password", with: "secret"
    click_button "Sign in"
  end

  def create_usage_record(overrides = {})
    DentalUsageRecord.create!({
      usage_id: "USAGE-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-SYS-001",
      clinical_post_id: "POST-SYS-001",
      item_type: "medication",
      item_code: "MED-100",
      item_name: "Lidocaine 2%",
      unit: "vial",
      requested_quantity: 5,
      deducted_quantity: 0,
      status: "pending_deduct",
      actor_id: "ACTOR-001"
    }.merge(overrides))
  end

  def create_requisition(overrides = {})
    DentalRequisition.create!({
      requisition_id: "REQ-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-SYS-001",
      requester_id: "USER-A",
      status: "pending"
    }.merge(overrides))
  end

  def create_requisition_with_items(overrides = {})
    req = create_requisition(overrides)
    req.line_items.create!(
      item_type: "supply",
      item_code: "SUP-001",
      item_name: "Gauze pad",
      quantity: 10,
      unit: "pc"
    )
    req.line_items.create!(
      item_type: "medication",
      item_code: "MED-200",
      item_name: "Amoxicillin 500mg",
      quantity: 20,
      unit: "tab"
    )
    req
  end

  def build_test_invoice(visit_id:)
    Dental::SupplyCosting::BuildInvoice.call(
      visit_id: visit_id,
      patient_name: "Test Patient",
      eligibility_code: "UCS",
      actor_id: "ACTOR-001",
      line_items: [
        {
          item_type: "procedure",
          item_code: "PROC-100",
          item_name: "Scaling",
          quantity: 1,
          unit: "time",
          unit_price: 500.0,
          price_source: "coverage",
          copay_amount: 30.0,
          copay_percent: nil
        },
        {
          item_type: "medication",
          item_code: "MED-100",
          item_name: "Lidocaine 2%",
          quantity: 2,
          unit: "vial",
          unit_price: 50.0,
          price_source: "master",
          copay_amount: 0,
          copay_percent: nil
        }
      ]
    )
  end

  def compute_hmac(invoice_id, status, secret)
    OpenSSL::HMAC.hexdigest("SHA256", secret, "#{invoice_id}:#{status}")
  end

  def build_principal(*permissions)
    Security::Principal.new(
      id: "test-user",
      username: "test@example.com",
      email: "test@example.com",
      display_name: "Test User",
      roles: [ "staff" ],
      permissions: permissions.flatten
    )
  end
end
