FactoryBot.define do
  factory :dental_procedure_group do
    sequence(:code) { |n| "PROC-GRP-#{n}" }
    sequence(:name) { |n| "Procedure Group #{n}" }
    active { true }
  end

  factory :dental_procedure_item do
    association :procedure_group, factory: :dental_procedure_group
    sequence(:code) { |n| "PROC-#{n}" }
    sequence(:name) { |n| "Procedure #{n}" }
    price_opd { 100.0 }
    price_ipd { 120.0 }
    active { true }
  end

  factory :dental_medication_profile do
    sequence(:code) { |n| "MED-#{n}" }
    sequence(:name) { |n| "Medication #{n}" }
    category { "general" }
    active { true }
  end

  factory :dental_supply_category do
    sequence(:code) { |n| "SUPCAT-#{n}" }
    sequence(:name) { |n| "Supply Category #{n}" }
    active { true }
  end

  factory :dental_supply_item do
    association :supply_category, factory: :dental_supply_category
    sequence(:code) { |n| "SUP-#{n}" }
    sequence(:name) { |n| "Supply #{n}" }
    unit { "piece" }
    unit_price { 12.0 }
    active { true }
  end

  factory :dental_procedure_item_coverage do
    association :procedure_item, factory: :dental_procedure_item
    eligibility_code { "UCS" }
    effective_from { Date.new(2026, 1, 1) }
    effective_to { Date.new(2026, 12, 31) }
    price_opd { 80.0 }
    price_ipd { 90.0 }
    copay_amount { nil }
    copay_percent { nil }
    active { true }
  end

  factory :dental_supply_item_coverage do
    association :supply_item, factory: :dental_supply_item
    eligibility_code { "UCS" }
    effective_from { Date.new(2026, 1, 1) }
    effective_to { Date.new(2026, 12, 31) }
    unit_price { 9.5 }
    copay_amount { nil }
    copay_percent { nil }
    active { true }
  end

  factory :dental_admin_audit_event do
    actor_id { "local-admin" }
    action { "procedure_item.updated" }
    resource_type { "DentalProcedureItem" }
    resource_id { 1 }
    metadata_json { { key: "value" }.to_json }
    created_at { Time.current }
  end
end
