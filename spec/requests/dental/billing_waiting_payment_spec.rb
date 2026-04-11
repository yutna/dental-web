require "rails_helper"

RSpec.describe "Dental billing waiting payment", type: :request do
  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }
  end

  def create_invoice(overrides = {})
    DentalInvoice.create!({
      invoice_id: "INV-2026-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-001",
      patient_name: "Preecha N.",
      payment_status: "pending",
      total_amount: 2450,
      copay_amount: 0
    }.merge(overrides))
  end

  describe "GET /en/dental/billing/waiting" do
    it "renders the waiting payment board" do
      create_invoice
      get "/en/dental/billing/waiting"
      expect(response).to have_http_status(:ok)
    end

    it "returns JSON with invoice list and summary" do
      create_invoice(payment_status: "pending")
      create_invoice(payment_status: "pending")

      get "/en/dental/billing/waiting", as: :json
      expect(response).to have_http_status(:ok)

      body = response.parsed_body
      expect(body["invoices"].size).to eq(2)
      expect(body["summary"]["pending"]).to eq(2)
    end

    it "excludes paid invoices from default view" do
      create_invoice(payment_status: "pending")
      create_invoice(payment_status: "paid", paid_at: Time.current)

      get "/en/dental/billing/waiting", as: :json
      body = response.parsed_body
      expect(body["invoices"].size).to eq(1)
    end
  end

  describe "POST /en/dental/billing/waiting/sync" do
    it "requests sync for a pending invoice" do
      invoice = create_invoice

      post "/en/dental/billing/waiting/sync", params: { invoice_id: invoice.invoice_id }, as: :json
      expect(response).to have_http_status(:ok)

      body = response.parsed_body
      expect(body["invoice_id"]).to eq(invoice.invoice_id)
      expect(body["sync_status"]).to eq("requested")
    end

    it "returns not found for missing invoice" do
      post "/en/dental/billing/waiting/sync", params: { invoice_id: "INV-MISSING" }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
