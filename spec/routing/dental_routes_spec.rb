require "rails_helper"

RSpec.describe "Dental routes", type: :routing do
  it "routes localized dental root" do
    expect(get: "/en/dental").to route_to("dental/home#show", locale: "en")
    expect(get: "/th/dental").to route_to("dental/home#show", locale: "th")
  end

  it "routes localized dental visit show and transition" do
    expect(get: "/en/dental/visits/VISIT-1").to route_to(
      "dental/visits#show",
      locale: "en",
      id: "VISIT-1"
    )

    expect(patch: "/en/dental/visits/VISIT-1/transition").to route_to(
      "dental/visits#transition",
      locale: "en",
      id: "VISIT-1"
    )

    expect(post: "/en/dental/visits/check_in").to route_to(
      "dental/visits#check_in",
      locale: "en"
    )

    expect(post: "/en/dental/visits/sync_appointments").to route_to(
      "dental/visits#sync_appointments",
      locale: "en"
    )

    expect(get: "/en/dental/clinical/visits/VISIT-1/screening").to route_to(
      "dental/clinical/screening_forms#show",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(patch: "/en/dental/clinical/visits/VISIT-1/screening").to route_to(
      "dental/clinical/screening_forms#update",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(get: "/en/dental/clinical/visits/VISIT-1/treatment").to route_to(
      "dental/clinical/treatment_forms#show",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(patch: "/en/dental/clinical/visits/VISIT-1/treatment").to route_to(
      "dental/clinical/treatment_forms#update",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(get: "/en/dental/clinical/visits/VISIT-1/medication").to route_to(
      "dental/clinical/medication_forms#show",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(patch: "/en/dental/clinical/visits/VISIT-1/medication").to route_to(
      "dental/clinical/medication_forms#update",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(get: "/en/dental/clinical/visits/VISIT-1/chart").to route_to(
      "dental/clinical/chart_forms#show",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(patch: "/en/dental/clinical/visits/VISIT-1/chart").to route_to(
      "dental/clinical/chart_forms#update",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(get: "/en/dental/clinical/visits/VISIT-1/images").to route_to(
      "dental/clinical/image_forms#show",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(patch: "/en/dental/clinical/visits/VISIT-1/images").to route_to(
      "dental/clinical/image_forms#update",
      locale: "en",
      visit_id: "VISIT-1"
    )

    expect(get: "/en/dental/clinical/visits/VISIT-1/history").to route_to(
      "dental/clinical/history_drawers#show",
      locale: "en",
      visit_id: "VISIT-1"
    )
  end

  it "routes localized admin dental root" do
    expect(get: "/en/admin/dental").to route_to("admin/dental/dashboard#show", locale: "en")
    expect(get: "/th/admin/dental").to route_to("admin/dental/dashboard#show", locale: "th")
  end
end
