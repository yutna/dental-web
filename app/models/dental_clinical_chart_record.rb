class DentalClinicalChartRecord < ApplicationRecord
  belongs_to :clinical_post,
             class_name: "DentalClinicalPost",
             inverse_of: :chart_records

  validates :visit_id, :patient_hn, :tooth_code, :charting_code, :occurred_at, presence: true

  def surface_codes
    decode_array(surface_codes_json)
  end

  def root_codes
    decode_array(root_codes_json)
  end

  def piece_codes
    decode_array(piece_codes_json)
  end

  private

  def decode_array(value)
    JSON.parse(value.presence || "[]")
  rescue JSON::ParserError
    []
  end
end
