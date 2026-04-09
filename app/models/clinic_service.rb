class ClinicService < ApplicationRecord
  before_validation :normalize_code

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :default_duration_minutes, numericality: { only_integer: true, greater_than: 0 }

  scope :active, -> { where(active: true) }

  private

  def normalize_code
    self.code = code.to_s.strip.upcase.presence
  end
end
