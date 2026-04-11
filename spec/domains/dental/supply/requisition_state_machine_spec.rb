require "rails_helper"

RSpec.describe Dental::Supply::RequisitionStateMachine do
  it "supports pending to approved transition" do
    expect(described_class.valid_transition?(from_status: "pending", to_status: "approved")).to be(true)
    expect(described_class.valid_transition?(from_status: "pending", to_status: "received")).to be(false)
  end
end
