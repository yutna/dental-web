require "rails_helper"

RSpec.describe "API v1 Clinical Posts", type: :request do
  let(:headers) { api_auth_headers }
  let(:visit_id) { "VISIT-CLIN-1" }

  before do
    DentalQueueEntry.create!(
      visit_id: visit_id, patient_name: "Clinical Patient",
      mrn: "HN3333", service: "Scaling", starts_at: "09:00",
      status: "in_progress", source: "walk_in"
    )
  end

  describe "GET /api/v1/visits/:visit_id/clinical_posts" do
    it "returns empty collection when no posts" do
      get "/api/v1/visits/#{visit_id}/clinical_posts", headers: headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"]).to eq([])
    end

    context "with existing posts" do
      before do
        DentalClinicalPost.create!(
          visit_id: visit_id, patient_hn: "HN3333",
          form_type: "screening",
          payload_json: { chief_complaint: "Toothache" }.to_json,
          posted_by_id: "test-user-1",
          posted_at: Time.current
        )
        DentalClinicalPost.create!(
          visit_id: visit_id, patient_hn: "HN3333",
          form_type: "treatment",
          payload_json: {
            procedures: [ { procedure_item_code: "PROC-100", quantity: 1 } ],
            diagnoses: [ "PULPITIS" ],
            extra_field: "ignored"
          }.to_json,
          posted_by_id: "test-user-1",
          posted_at: Time.current
        )

        DentalClinicalPost.create!(
          visit_id: visit_id, patient_hn: "HN3333",
          form_type: "medication",
          payload_json: {
            medications: [ { medication_code: "AMOX-500", quantity: 1 } ],
            confirm_high_alert: true,
            allergies: [ { medication_code: "NSAID", reaction: "rash" } ],
            allergy_override_reason: "benefit outweighs risk",
            extra_field: "ignored"
          }.to_json,
          posted_by_id: "test-user-1",
          posted_at: Time.current
        )
      end

      it "returns all posts for visit" do
        get "/api/v1/visits/#{visit_id}/clinical_posts", headers: headers

        body = response.parsed_body
        expect(body["data"].length).to eq(3)
      end

      it "filters by form_type" do
        get "/api/v1/visits/#{visit_id}/clinical_posts", headers: headers,
          params: { form_type: "screening" }

        body = response.parsed_body
        expect(body["data"].length).to eq(1)
        expect(body["data"][0]["form_type"]).to eq("screening")
      end

      it "returns correct serialized shape" do
        get "/api/v1/visits/#{visit_id}/clinical_posts", headers: headers

        post_data = response.parsed_body["data"][0]
        expect(post_data).to include(
          "visit_id", "patient_hn", "form_type", "payload",
          "posted_by_id", "posted_at", "created_at"
        )
      end

      it "serializes treatment payload via treatment form serializer" do
        get "/api/v1/visits/#{visit_id}/clinical_posts", headers: headers,
          params: { form_type: "treatment" }

        payload = response.parsed_body.dig("data", 0, "payload")
        expect(payload).to include(
          "procedures" => [ include("procedure_item_code" => "PROC-100", "quantity" => 1) ],
          "diagnoses" => [ "PULPITIS" ]
        )
        expect(payload).not_to have_key("extra_field")
      end

      it "serializes medication payload via medication form serializer" do
        get "/api/v1/visits/#{visit_id}/clinical_posts", headers: headers,
          params: { form_type: "medication" }

        payload = response.parsed_body.dig("data", 0, "payload")
        expect(payload).to include(
          "medications" => [ include("medication_code" => "AMOX-500", "quantity" => 1) ],
          "confirm_high_alert" => true,
          "allergies" => [ include("medication_code" => "NSAID", "reaction" => "rash") ],
          "allergy_override_reason" => "benefit outweighs risk"
        )
        expect(payload).not_to have_key("extra_field")
      end
    end
  end

  describe "POST /api/v1/visits/:visit_id/clinical_posts" do
    let(:valid_params) do
      {
        patient_hn: "HN3333",
        form_type: "screening",
        payload: { chief_complaint: "Toothache", bp: "120/80" }
      }
    end

    it "creates a clinical post" do
      post "/api/v1/visits/#{visit_id}/clinical_posts", headers: headers,
        params: valid_params

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["data"]["form_type"]).to eq("screening")
      expect(body["data"]["payload"]).to include("chief_complaint" => "Toothache")
    end

    it "returns validation error for missing form_type" do
      post "/api/v1/visits/#{visit_id}/clinical_posts", headers: headers,
        params: { patient_hn: "HN3333" }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
