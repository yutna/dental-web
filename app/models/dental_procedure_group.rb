class DentalProcedureGroup < ApplicationRecord
  before_validation :normalize_code

  has_many :procedure_items,
           class_name: "DentalProcedureItem",
           foreign_key: :procedure_group_id,
           inverse_of: :procedure_group,
           dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }

  private

  def normalize_code
    self.code = code.to_s.strip.upcase.presence
  end
end
