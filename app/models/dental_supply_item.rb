class DentalSupplyItem < ApplicationRecord
  before_validation :normalize_code

  belongs_to :supply_category,
             class_name: "DentalSupplyCategory",
             inverse_of: :supply_items
  has_many :coverages,
           class_name: "DentalSupplyItemCoverage",
           foreign_key: :supply_item_id,
           inverse_of: :supply_item,
           dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :unit, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  private

  def normalize_code
    self.code = code.to_s.strip.upcase.presence
  end
end
