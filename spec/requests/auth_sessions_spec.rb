require "rails_helper"

RSpec.describe "Auth sessions", type: :request do
  it "renders sign-in form" do
    get "/en/session/new"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Sign in to continue")
    expect(response.body).to include("Display options")
    expect(response.body).to include("Active theme:")
  end

  it "rejects blank credentials" do
    post "/en/session", params: { email: "clinician@example.com", password: "" }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Invalid email or password.")
    expect(response.body).to include("role=\"alert\"")
  end

  it "creates a local session and opens workspace" do
    post "/en/session", params: { email: "clinician@example.com", password: "secret" }

    expect(response).to redirect_to("/en/workspace")
    follow_redirect!

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Clinical Workspace")
    expect(response.body).to include("Appointment queue")
  end

  it "signs out cleanly after sign-in" do
    post "/en/session", params: { email: "clinician@example.com", password: "secret" }
    expect(response).to redirect_to("/en/workspace")

    delete "/en/session"

    expect(response).to redirect_to("/en")
    follow_redirect!
    expect(response.body).to include("Signed out successfully.")
  end

  it "redirects workspace access when not signed in" do
    get "/en/workspace"

    expect(response).to redirect_to("/en/session/new")
  end
end
