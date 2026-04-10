class DentalProcedureItem < ApplicationRecord
  before_validation :normalize_code

  belongs_to :procedure_group,
             class_name: "DentalProcedureGroup",
             inverse_of: :procedure_items
  has_many :coverages,
           class_name: "DentalProcedureItemCoverage",
           foreign_key: :procedure_item_id,
           inverse_of: :procedure_item,
           dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price_opd, numericality: { greater_than_or_equal_to: 0 }
  validates :price_ipd, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  private

  def normalize_code
    self.code = code.to_s.strip.upcase.presence
  end
end
