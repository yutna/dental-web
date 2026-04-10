require "rails_helper"

RSpec.describe "Localization", type: :request do
  it "redirects / to /en" do
    get "/"

    expect(response).to redirect_to("/en")
  end

  it "renders English content at /en" do
    post "/en/session", params: { username: "clinician.test", password: "secret" }
    get "/en"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Welcome, Clinician Test")
    expect(response.body).to include("Access clinical workspace and manage your profile.")
    expect(response.body).to include("Clinical workspace")
    expect(response.body).to include("Admin dashboard")
  end

  it "renders Thai content at /th" do
    post "/th/session", params: { username: "clinician.test", password: "secret" }
    get "/th"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ยินดีต้อนรับ Clinician Test")
    expect(response.body).to include("เข้าถึงพื้นที่ทำงานคลินิกและจัดการโปรไฟล์ของคุณ")
    expect(response.body).to include("พื้นที่ทำงานคลินิก")
    expect(response.body).to include("แดชบอร์ดผู้ดูแลระบบ")
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
