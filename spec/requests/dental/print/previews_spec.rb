require "rails_helper"

RSpec.describe "Dental print previews", type: :request do
  let(:visit_id) { "VISIT-PRINT-001" }

  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }

    DentalQueueEntry.create!(
      visit_id: visit_id,
      patient_name: "Somchai Jaidee",
      mrn: "HN0045",
      service: "General Consultation",
      starts_at: "09:00",
      status: "in_progress",
      source: "walk_in",
      metadata_json: "{}"
    )

    DentalWorkflowTimelineEntry.create!(
      visit_id: visit_id,
      from_stage: "checked-in",
      to_stage: "in-treatment",
      event_type: "stage_transition",
      actor_id: "admin.test",
      metadata_json: "{}"
    )

    DentalClinicalPost.create!(
      visit_id: visit_id,
      patient_hn: "HN0045",
      form_type: "screening",
      payload_json: { preliminary_findings: "Mild gingivitis" }.to_json,
      posted_by_id: "admin.test",
      posted_at: Time.current
    )

    DentalClinicalProcedureRecord.create!(
      visit_id: visit_id,
      patient_hn: "HN0045",
      clinical_post: DentalClinicalPost.last,
      procedure_item_code: "PROC-001",
      quantity: 1,
      occurred_at: Time.current
    )

    invoice = DentalInvoice.create!(
      invoice_id: "INV-PRINT-001",
      visit_id: visit_id,
      payment_status: "pending",
      total_amount: 500,
      copay_amount: 0
    )

    DentalInvoiceLineItem.create!(
      dental_invoice: invoice,
      item_type: "procedure",
      item_code: "PROC-001",
      item_name: "Scaling",
      quantity: 1,
      unit_price: 500,
      amount: 500
    )

    DentalClinicalChartRecord.create!(
      visit_id: visit_id,
      patient_hn: "HN0045",
      clinical_post: DentalClinicalPost.last,
      tooth_code: "11",
      charting_code: "C",
      occurred_at: Time.current
    )
  end

  it "renders treatment summary print preview" do
    get "/en/dental/print/#{visit_id}/treatment_summary"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Treatment Summary")
    expect(response.body).to include("Somchai Jaidee")
    expect(response.body).to include("window.print")
  end

  it "renders certificate print preview" do
    get "/en/dental/print/#{visit_id}/certificate"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Dental Certificate")
    expect(response.body).to include("Somchai Jaidee")
  end

  it "renders dental chart print preview" do
    get "/en/dental/print/#{visit_id}/dental_chart"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Dental Chart")
    expect(response.body).to include("11")
  end

  it "supports locale-based language toggle" do
    get "/th/dental/print/#{visit_id}/treatment_summary"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("สรุปการรักษา")
  end

  it "shows provisional watermark for non-finalized stages" do
    get "/en/dental/print/#{visit_id}/treatment_summary"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("data-watermark-lock")
    expect(response.body).to include("PROVISIONAL")
  end

  it "hides watermark for completed stage" do
    DentalWorkflowTimelineEntry.where(visit_id: visit_id).delete_all
    DentalWorkflowTimelineEntry.create!(
      visit_id: visit_id,
      from_stage: "waiting-payment",
      to_stage: "completed",
      event_type: "stage_transition",
      actor_id: "admin.test",
      metadata_json: "{}"
    )

    get "/en/dental/print/#{visit_id}/treatment_summary"

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("data-watermark-lock")
  end

  it "returns not found for unknown type" do
    get "/en/dental/print/#{visit_id}/unknown_type"

    expect(response).to have_http_status(:not_found)
  end

  it "forbids users without print permission" do
    delete "/en/session"
    post "/en/session", params: { username: "clinician.test", password: "secret" }

    get "/en/dental/print/#{visit_id}/treatment_summary"

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to include("403 Forbidden")
  end

  it "blocks printing in registered stage" do
    DentalWorkflowTimelineEntry.where(visit_id: visit_id).delete_all

    get "/en/dental/print/#{visit_id}/treatment_summary"

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to include("Required permission")
  end
end
