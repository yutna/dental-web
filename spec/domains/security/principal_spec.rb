require "rails_helper"

RSpec.describe Security::Principal do
  describe ".from_h" do
    it "maps username field" do
      principal = described_class.from_h(
        "id" => "1", "username" => "admin.s",
        "email" => "a@b.com", "display_name" => "Admin",
        "roles" => [], "permissions" => []
      )
      expect(principal.username).to eq("admin.s")
    end

    it "includes username in to_h" do
      principal = described_class.new(
        id: "1", username: "admin.s", email: "a@b.com",
        display_name: "Admin", roles: [], permissions: []
      )
      expect(principal.to_h["username"]).to eq("admin.s")
    end

    it "returns nil username for guest" do
      expect(described_class.guest.username).to be_nil
    end
  end
end
