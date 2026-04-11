class DentalClinicalImageRecord < ApplicationRecord
  belongs_to :clinical_post,
             class_name: "DentalClinicalPost",
             inverse_of: :image_records

  validates :visit_id, :patient_hn, :image_type_code, :image_ref, :captured_at, presence: true
end
