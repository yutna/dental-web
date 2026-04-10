require "rails_helper"

RSpec.describe Dental::BasePolicy do
  subject(:policy) { described_class.new(principal, :dental_namespace) }

  let(:principal) do
    Security::Principal.new(
      id: "user-1",
      email: "user@example.com",
      display_name: "User",
      roles: [ "dental_staff" ],
      permissions: [ "dental:read" ]
    )
  end

  it "denies namespace access by default" do
    expect(policy.access?).to be(false)
  end

  it "denies CRUD actions by default" do
    expect(policy.index?).to be(false)
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end
