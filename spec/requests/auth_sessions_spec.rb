require "rails_helper"

RSpec.describe "Auth sessions", type: :request do
  # ─── GET new ──────────────────────────────────────────────────────
  describe "GET /en/session/new" do
    it "renders sign-in form with username field" do
      get "/en/session/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('name="username"')
      expect(response.body).to include('type="text"')
      expect(response.body).not_to include('name="email"')
    end

    it "redirects to home page when already signed in" do
      sign_in_locally
      get "/en/session/new"

      expect(response).to redirect_to("/en")
    end
  end

  # ─── POST create ──────────────────────────────────────────────────
  describe "POST /en/session" do
    context "with local provider (default in test)" do
      it "creates session and redirects to home page" do
        post "/en/session", params: { username: "clinician.test", password: "secret" }

        expect(response).to redirect_to("/en")
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "renders error on invalid credentials" do
        allow_any_instance_of(Security::SignIn)
          .to receive(:call).and_raise(Security::SignIn::InvalidCredentialsError)

        post "/en/session", params: { username: "bad", password: "wrong" }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Invalid username or password.")
        expect(response.body).to include('role="alert"')
      end

      it "retains submitted username on error" do
        allow_any_instance_of(Security::SignIn)
          .to receive(:call).and_raise(Security::SignIn::InvalidCredentialsError)

        post "/en/session", params: { username: "admin.s", password: "wrong" }

        expect(response.body).to include('value="admin.s"')
      end

      it "renders service_unavailable error when backend is unreachable" do
        allow_any_instance_of(Security::SignIn)
          .to receive(:call).and_raise(Security::SignIn::ServiceUnavailableError)

        post "/en/session", params: { username: "x", password: "y" }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("temporarily unavailable")
      end
    end

    context "Thai locale" do
      it "shows error in Thai when credentials invalid" do
        allow_any_instance_of(Security::SignIn)
          .to receive(:call).and_raise(Security::SignIn::InvalidCredentialsError)

        post "/th/session", params: { username: "bad", password: "wrong" }

        expect(response.body).to include("ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง")
      end
    end
  end

  # ─── DELETE destroy ───────────────────────────────────────────────
  describe "DELETE /en/session" do
    it "clears session and redirects to root, then to login" do
      sign_in_locally
      delete "/en/session"

      expect(response).to redirect_to("/en")
      follow_redirect!  # /en is protected → redirects to login
      expect(response).to redirect_to("/en/session/new")
    end
  end

  # ─── Home page guard ──────────────────────────────────────────────
  describe "home page access guard" do
    it "redirects to login when not signed in" do
      get "/en"
      expect(response).to redirect_to("/en/session/new")
    end

    it "renders home page when signed in" do
      sign_in_locally
      get "/en"
      expect(response).to have_http_status(:ok)
    end
  end

  # ─── Workspace guard ──────────────────────────────────────────────
  describe "workspace access guard" do
    it "redirects to login when not signed in" do
      get "/en/workspace"
      expect(response).to redirect_to("/en/session/new")
    end
  end

  # ─── Token refresh ────────────────────────────────────────────────
  describe "token refresh" do
    it "redirects to login when RefreshSession raises RefreshFailedError" do
      sign_in_locally
      allow_any_instance_of(Security::RefreshSession)
        .to receive(:call).and_raise(Security::RefreshSession::RefreshFailedError, "expired")

      get "/en"

      expect(response).to redirect_to("/en/session/new")
      follow_redirect!
      expect(response.body).to include("session has expired")
    end
  end

  private

  def sign_in_locally
    post "/en/session", params: { username: "clinician.test", password: "secret" }
    expect(response).to redirect_to("/en")
  end
end
