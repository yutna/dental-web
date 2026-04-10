class DentalSupplyCategory < ApplicationRecord
  before_validation :normalize_code

  has_many :supply_items,
           class_name: "DentalSupplyItem",
           foreign_key: :supply_category_id,
           inverse_of: :supply_category,
           dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }

  private

  def normalize_code
    self.code = code.to_s.strip.upcase.presence
  end
end
