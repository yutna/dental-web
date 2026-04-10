class DentalSupplyItem < ApplicationRecord
  before_validation :normalize_code

  belongs_to :supply_category,
             class_name: "DentalSupplyCategory",
             inverse_of: :supply_items

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :unit, presence: true

  scope :active, -> { where(active: true) }

  private

  def normalize_code
    self.code = code.to_s.strip.upcase.presence
  end
end
