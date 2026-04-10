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
    active { true }
  end
end
