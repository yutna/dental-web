class DentalToothSurfaceReference < ApplicationRecord
  before_validation :normalize_code

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :sort_order, numericality: { only_integer: true }

  scope :active, -> { where(active: true) }

  private

  def normalize_code
    self.code = code.to_s.strip.upcase.presence
  end
end
