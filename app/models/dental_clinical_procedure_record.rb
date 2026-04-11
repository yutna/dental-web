class DentalClinicalProcedureRecord < ApplicationRecord
  belongs_to :clinical_post,
             class_name: "DentalClinicalPost",
             inverse_of: :procedure_records

  validates :visit_id, :patient_hn, :procedure_item_code, :occurred_at, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  def surface_codes
    JSON.parse(surface_codes_json.presence || "[]")
  rescue JSON::ParserError
    []
  end
end
