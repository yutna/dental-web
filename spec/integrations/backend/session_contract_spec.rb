require "rails_helper"

RSpec.describe "Backend session contract" do
  describe Backend::Providers::Local::SessionProvider do
    it "returns canonical principal fields for admin sign-in" do
      snapshot = described_class.new.sign_in(username: "admin@example.com", password: "secret")
      expected_principal = json_fixture("contracts/session/local_admin_principal.json")

      expect(snapshot).to be_a(Security::SessionSnapshot)
      expect(snapshot.access_token).to be_present
      expect(snapshot.principal.to_h).to eq(expected_principal)
    end
  end

  describe Backend::Mappers::SessionSnapshotMapper do
    it "maps remote payload fixture to canonical contract fixture" do
      payload = json_fixture("contracts/session/remote_sign_in_payload.json")
      expected_snapshot = json_fixture("contracts/session/canonical_snapshot.json")

      snapshot = described_class.from_remote(payload)

      expect(snapshot).to be_a(Security::SessionSnapshot)
      expect(snapshot.to_h).to eq(expected_snapshot)
    end
  end
end
