class DentalProcedureItemCoverage < ApplicationRecord
  belongs_to :procedure_item,
             class_name: "DentalProcedureItem",
             inverse_of: :coverages

  validates :eligibility_code, presence: true
  validates :effective_from, presence: true
  validates :price_opd, numericality: { greater_than_or_equal_to: 0 }
  validates :price_ipd, numericality: { greater_than_or_equal_to: 0 }
  validates :copay_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :copay_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validate :effective_window_valid
  validate :copay_mode_valid

  scope :active, -> { where(active: true) }

  def effective_on?(date)
    date = date.to_date
    return false if effective_from > date
    return true if effective_to.nil?

    effective_to >= date
  end

  private

  def effective_window_valid
    return if effective_to.blank?
    return if effective_to >= effective_from

    errors.add(:effective_to, "must be on or after effective_from")
  end

  def copay_mode_valid
    return if copay_amount.blank? || copay_percent.blank?

    errors.add(:base, "copay_amount and copay_percent are mutually exclusive")
  end
end
