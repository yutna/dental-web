require "rails_helper"

RSpec.describe Dental::Workflow::QueueEntriesQuery do
  it "returns loading state" do
    result = described_class.call(loading: true)

    expect(result[:state]).to eq("loading")
    expect(result[:rows]).to eq([])
    expect(result[:error]).to be(false)
  end

  it "returns empty state when provider has no rows" do
    result = described_class.call(rows_provider: -> { [] })

    expect(result[:state]).to eq("empty")
    expect(result[:rows]).to eq([])
    expect(result[:summary]).to eq(total: 0, in_progress: 0, ready: 0, waiting_payment: 0, completed: 0)
  end

  it "returns populated state when provider has rows" do
    rows = [
      { id: "AP-1", status: "in_progress" },
      { id: "AP-2", status: "ready" }
    ]

    result = described_class.call(rows_provider: -> { rows })

    expect(result[:state]).to eq("populated")
    expect(result[:rows]).to eq(rows)
    expect(result[:summary]).to eq(total: 2, in_progress: 1, ready: 1, waiting_payment: 0, completed: 0)
  end

  it "filters rows by source and status" do
    rows = [
      { id: "AP-1", status: "in_progress", source: "walk_in" },
      { id: "AP-2", status: "in_progress", source: "appointment_sync" },
      { id: "AP-3", status: "completed", source: "walk_in" }
    ]

    result = described_class.call(rows_provider: -> { rows }, status: "in_progress", source: "walk_in")

    expect(result[:state]).to eq("populated")
    expect(result[:rows]).to contain_exactly({ id: "AP-1", status: "in_progress", source: "walk_in" })
    expect(result[:filters]).to eq(search: "", status: "in_progress", source: "walk_in")
  end

  it "returns error state when provider raises" do
    result = described_class.call(rows_provider: -> { raise "backend unavailable" })

    expect(result[:state]).to eq("error")
    expect(result[:rows]).to eq([])
    expect(result[:error]).to be(true)
    expect(result[:error_message]).to eq("backend unavailable")
  end
end
