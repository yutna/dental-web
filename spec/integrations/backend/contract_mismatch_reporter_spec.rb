require "rails_helper"
require "json"
require "tmpdir"

RSpec.describe Backend::ContractMismatchReporter do
  it "writes a redacted mismatch report with explicit differences" do
    local_snapshot = Security::SessionSnapshot.new(
      access_token: "local-token-123456",
      refresh_token: "local-refresh-123456",
      principal: Security::Principal.new(
        id: "1",
        email: "admin@example.com",
        display_name: "Admin",
        roles: [ "admin" ],
        permissions: [ "workspace:read", "admin:access" ]
      )
    )
    remote_snapshot = Security::SessionSnapshot.new(
      access_token: "remote-token-123456",
      refresh_token: "remote-refresh-123456",
      principal: Security::Principal.new(
        id: "2",
        email: "admin@example.com",
        display_name: "Admin",
        roles: [ "admin" ],
        permissions: [ "workspace:read" ]
      )
    )

    Dir.mktmpdir do |directory|
      reporter = described_class.new(output_dir: directory)
      report_path = reporter.write(local_snapshot:, remote_snapshot:)

      expect(report_path).to start_with(directory)
      payload = JSON.parse(File.read(report_path))

      expect(payload["canonical_contract"]).to eq("session_snapshot.v1")
      expect(payload.dig("local_snapshot", "access_token")).to eq("local-...3456 (len=18)")
      expect(payload.dig("remote_snapshot", "refresh_token")).to eq("remote...3456 (len=21)")
      expect(payload.fetch("differences").map { |difference| difference.fetch("field") }).to include("principal.permissions")
    end
  end
end
