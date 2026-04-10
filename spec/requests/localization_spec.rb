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
    expect(response.body).to include("Welcome to Dental Web")
    expect(response.body).to include("Dashboard access")
    expect(response.body).to include("Open sign-in flow")
    expect(response.body).to include("Open clinical workspace")
  end

  it "renders Thai content at /th" do
    post "/th/session", params: { username: "clinician.test", password: "secret" }
    get "/th"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ยินดีต้อนรับสู่เดนทัล เว็บ")
    expect(response.body).to include("การเข้าถึงแดชบอร์ด")
    expect(response.body).to include("เปิดหน้าลงชื่อเข้าใช้")
    expect(response.body).to include("เปิดพื้นที่ทำงานคลินิก")
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
