class DentalMedicationProfile < ApplicationRecord
  before_validation :normalize_code

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :category, presence: true

  scope :active, -> { where(active: true) }

  private

  def normalize_code
    self.code = code.to_s.strip.upcase.presence
  end
end
