FactoryBot.define do
  factory :clinic_service do
    sequence(:code) { |n| "SRV-#{n.to_s.rjust(3, "0")}" }
    sequence(:name) { |n| "Service #{n}" }
    default_duration_minutes { 30 }
    active { true }
  end
end
