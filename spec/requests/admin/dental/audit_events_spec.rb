require "rails_helper"

RSpec.describe "Admin dental audit events", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en/workspace")
  end

  it "shows audit events for admin users and applies actor and action filters" do
    create(:dental_admin_audit_event, actor_id: "actor-a", action: "procedure_item.updated")
    create(:dental_admin_audit_event, actor_id: "actor-b", action: "procedure_item.created")
    create(:dental_admin_audit_event, actor_id: "actor-a", action: "procedure_item.created")

    sign_in_as(username: "admin.test")

    get "/en/admin/dental/audit_events", params: {
      actor_id: "actor-a",
      event_action: "procedure_item.created"
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("actor-a")
    expect(response.body).to include("procedure_item.created")
    expect(response.body).not_to include("procedure_item.updated")
    expect(response.body).not_to include("actor-b")
  end

  it "denies non-admin users" do
    sign_in_as(username: "clinician.test")

    get "/en/admin/dental/audit_events"

    expect(response).to redirect_to("/en")
  end
end
