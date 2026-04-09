require "rails_helper"

RSpec.describe "Backend session contract" do
  describe Backend::Providers::Local::SessionProvider do
    it "returns canonical session snapshot fields" do
      snapshot = described_class.new.sign_in(email: "admin@example.com", password: "secret")

      expect(snapshot).to be_a(Security::SessionSnapshot)
      expect(snapshot.access_token).to be_present
      expect(snapshot.principal.email).to eq("admin@example.com")
      expect(snapshot.principal.permissions).to include("workspace:read")
    end
  end

  describe Backend::Mappers::SessionSnapshotMapper do
    it "maps remote camelCase payload to canonical contract" do
      payload = {
        "accessToken" => "access-token",
        "refreshToken" => "refresh-token",
        "user" => {
          "id" => "remote-1",
          "email" => "dentist@example.com",
          "displayName" => "Dentist",
          "roles" => [ "clinician" ]
        },
        "permissions" => [ "workspace:read" ]
      }

      snapshot = described_class.from_remote(payload)

      expect(snapshot).to be_a(Security::SessionSnapshot)
      expect(snapshot.principal.display_name).to eq("Dentist")
      expect(snapshot.principal.permissions).to include("workspace:read")
    end
  end

  describe Backend::Providers::DualCompare::SessionProvider do
    it "raises when local and remote contracts differ" do
      local_snapshot = Security::SessionSnapshot.new(
        access_token: "local-token",
        refresh_token: "local-refresh",
        principal: Security::Principal.new(
          id: "1",
          email: "admin@example.com",
          display_name: "Admin",
          roles: [ "admin" ],
          permissions: [ "workspace:read", "admin:access" ]
        )
      )
      remote_snapshot = Security::SessionSnapshot.new(
        access_token: "remote-token",
        refresh_token: "remote-refresh",
        principal: Security::Principal.new(
          id: "2",
          email: "admin@example.com",
          display_name: "Admin",
          roles: [ "admin" ],
          permissions: [ "workspace:read" ]
        )
      )

      local_provider = instance_double(Backend::Providers::Local::SessionProvider, sign_in: local_snapshot)
      remote_provider = instance_double(Backend::Providers::Remote::SessionProvider, sign_in: remote_snapshot)

      provider = described_class.new(local_provider:, remote_provider:)

      expect do
        provider.sign_in(email: "admin@example.com", password: "secret")
      end.to raise_error(Backend::Errors::ContractMismatchError)
    end
  end
end
