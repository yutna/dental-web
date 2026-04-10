require "rails_helper"

RSpec.describe WorkspacePolicy do
  subject(:policy) { described_class.new(principal, :workspace) }

  context "when principal has workspace:read permission" do
    let(:principal) do
      Security::Principal.new(
        id: "user-1",
        email: "user@example.com",
        display_name: "User",
        roles: [ "clinician" ],
        permissions: [ "workspace:read" ]
      )
    end

    it "allows access" do
      expect(policy.show?).to be(true)
    end
  end

  context "when principal is missing workspace:read permission" do
    let(:principal) do
      Security::Principal.new(
        id: "user-1",
        email: "user@example.com",
        display_name: "User",
        roles: [ "clinician" ],
        permissions: []
      )
    end

    it "denies access" do
      expect(policy.show?).to be(false)
    end
  end
end
