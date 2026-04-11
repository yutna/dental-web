require "rails_helper"

RSpec.describe Dental::Print::TreatmentSummaryQuery do
  let(:visit_id) { "VISIT-TSQ-001" }

  before do
    DentalQueueEntry.create!(
      visit_id: visit_id,
      patient_name: "Anan Dee",
      mrn: "HN-9001",
      service: "Scaling",
      starts_at: "09:30",
      status: "in_progress",
      source: "walk_in",
      metadata_json: "{}"
    )

    post = DentalClinicalPost.create!(
      visit_id: visit_id,
      patient_hn: "HN-9001",
      form_type: "screening",
      payload_json: { preliminary_findings: "Gingivitis" }.to_json,
      posted_by_id: "dentist-1",
      posted_at: Time.current
    )

    DentalClinicalProcedureRecord.create!(
      clinical_post: post,
      visit_id: visit_id,
      patient_hn: "HN-9001",
      procedure_item_code: "PROC-100",
      tooth_code: "11",
      surface_codes_json: [ "M" ].to_json,
      quantity: 1,
      occurred_at: Time.current
    )

    invoice = DentalInvoice.create!(
      invoice_id: "INV-TSQ-001",
      visit_id: visit_id,
      payment_status: "pending",
      total_amount: 750,
      copay_amount: 100
    )

    DentalInvoiceLineItem.create!(
      dental_invoice: invoice,
      item_type: "procedure",
      item_code: "PROC-100",
      item_name: "Scaling",
      quantity: 1,
      unit_price: 750,
      amount: 750
    )
  end

  it "aggregates patient, clinical, procedure, and billing data" do
    result = described_class.call(visit_id: visit_id)

    expect(result[:visit_id]).to eq(visit_id)
    expect(result[:patient_name]).to eq("Anan Dee")
    expect(result[:patient_hn]).to eq("HN-9001")
    expect(result.dig(:screening, "preliminary_findings")).to eq("Gingivitis")
    expect(result[:procedures].first[:procedure_item_code]).to eq("PROC-100")
    expect(result[:line_items].first[:item_name]).to eq("Scaling")
    expect(result[:total_amount].to_d).to eq(750.to_d)
  end

  it "returns safe defaults when invoice is missing" do
    DentalInvoice.where(visit_id: visit_id).destroy_all

    result = described_class.call(visit_id: visit_id)

    expect(result[:invoice_id]).to be_nil
    expect(result[:line_items]).to eq([])
    expect(result[:total_amount]).to eq(0)
  end
end
