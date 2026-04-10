require "rails_helper"
require "json"
require "tmpdir"

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

  describe Backend::Providers::DualCompare::SessionProvider do
    it "writes mismatch artifact and raises when local and remote contracts differ" do
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

      Dir.mktmpdir do |directory|
        reporter = Backend::ContractMismatchReporter.new(output_dir: directory)
        provider = described_class.new(local_provider:, remote_provider:, reporter:)

        expect do
        provider.sign_in(username: "admin@example.com", password: "secret")
        end.to raise_error(Backend::Errors::ContractMismatchError, /report:/)

        report_paths = Dir.glob(File.join(directory, "*.json"))
        expect(report_paths).not_to be_empty

        report_payload = JSON.parse(File.read(report_paths.first))
        difference_fields = report_payload.fetch("differences").map { |difference| difference.fetch("field") }
        expect(difference_fields).to include("principal.permissions")
      end
    end
  end
end
