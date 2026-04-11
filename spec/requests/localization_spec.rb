require "rails_helper"

RSpec.describe "Localization", type: :request do
  it "redirects / to /en" do
    get "/"

    expect(response).to redirect_to("/en")
  end

  it "routes signed-in English users from /en to workspace" do
    post "/en/session", params: { username: "clinician.test", password: "secret" }
    get "/en"

    expect(response).to redirect_to("/en/workspace")
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Clinical Workspace")
    expect(response.body).to include("Appointment Queue")
    expect(response.body).not_to include("Admin dashboard")
  end

  it "routes signed-in Thai users from /th to workspace" do
    post "/th/session", params: { username: "clinician.test", password: "secret" }
    get "/th"

    expect(response).to redirect_to("/th/workspace")
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("พื้นที่ทำงานคลินิก")
    expect(response.body).to include("คิวนัดหมาย")
    expect(response.body).not_to include("แดชบอร์ดผู้ดูแลระบบ")
  end

  it "redirects unsupported locale root to /en" do
    get "/jp"

    expect(response).to redirect_to("/en")
  end

  it "redirects unsupported locale path to /en path" do
    get "/jp/about"

    expect(response).to redirect_to("/en/about")
  end

  it "renders permission-denied guidance on localized home" do
    post "/en/session", params: { username: "clinician.test", password: "secret" }
    get "/en", params: { reason: "workspace_denied" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Workspace permission denied")
    expect(response.body).to include("Request workspace:read permission from your administrator.")
  end
end
