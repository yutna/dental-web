class DentalClinicalPost < ApplicationRecord
  FORM_TYPES = %w[
    screening
    treatment
    procedure
    medication
    dental_chart
    dental_image
    referral
    lab
    radiology
    pharmacy
  ].freeze

  has_many :chart_records,
           class_name: "DentalClinicalChartRecord",
           foreign_key: :clinical_post_id,
           dependent: :destroy,
           inverse_of: :clinical_post
  has_many :procedure_records,
           class_name: "DentalClinicalProcedureRecord",
           foreign_key: :clinical_post_id,
           dependent: :destroy,
           inverse_of: :clinical_post
  has_many :image_records,
           class_name: "DentalClinicalImageRecord",
           foreign_key: :clinical_post_id,
           dependent: :destroy,
           inverse_of: :clinical_post

  validates :visit_id, :patient_hn, :form_type, :posted_by_id, :posted_at, presence: true
  validates :form_type, inclusion: { in: FORM_TYPES }

  scope :active, -> { where(voided_at: nil) }
  scope :chronological, -> { order(posted_at: :asc, id: :asc) }

  def payload
    JSON.parse(payload_json.presence || "{}")
  rescue JSON::ParserError
    {}
  end
end
