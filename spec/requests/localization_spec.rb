require "rails_helper"

RSpec.describe "Localization", type: :request do
  it "redirects / to /en" do
    get "/"

    expect(response).to redirect_to("/en")
  end

  it "renders English content at /en" do
    get "/en"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Welcome to Dental Web")
    expect(response.body).to include("Tailwind CSS active")
    expect(response.body).to include("Official Tailwind plugin examples")
    expect(response.body).to include("form-input")
    expect(response.body).to include("prose")
    expect(response.body).to include("aspect-w-16")
    expect(response.body).to include('href="/th"')
  end

  it "renders Thai content at /th" do
    get "/th"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ยินดีต้อนรับสู่เดนทัล เว็บ")
    expect(response.body).to include("Tailwind CSS พร้อมใช้งาน")
    expect(response.body).to include("ตัวอย่างปลั๊กอินทางการของ Tailwind")
    expect(response.body).to include("form-input")
    expect(response.body).to include("prose")
    expect(response.body).to include("aspect-w-16")
    expect(response.body).to include('href="/en"')
  end

  it "redirects unsupported locale root to /en" do
    get "/jp"

    expect(response).to redirect_to("/en")
  end

  it "redirects unsupported locale path to /en path" do
    get "/jp/about"

    expect(response).to redirect_to("/en/about")
  end
end
