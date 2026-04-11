class DentalUsageRecord < ApplicationRecord
  ITEM_TYPES = %w[medication supply].freeze

  validates :usage_id, presence: true, uniqueness: true
  validates :visit_id, presence: true
  validates :item_type, presence: true, inclusion: { in: ITEM_TYPES }
  validates :item_code, presence: true
  validates :item_name, presence: true
  validates :unit, presence: true
  validates :requested_quantity, presence: true, numericality: { greater_than: 0 }
  validates :deducted_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: Dental::Enums::UsageStatus.allowed_values }
  validate :void_reason_required_when_voided

  scope :pending, -> { where(status: "pending_deduct") }
  scope :deducted, -> { where(status: "deducted") }
  scope :failed, -> { where(status: "failed") }
  scope :for_visit, ->(visit_id) { where(visit_id: visit_id) }

  def pending_deduct?
    status == "pending_deduct"
  end

  def deducted?
    status == "deducted"
  end

  def failed?
    status == "failed"
  end

  def voided?
    voided_at.present?
  end

  def mark_deducted!(movement_ref:, quantity: requested_quantity)
    raise Dental::Errors::InvalidTransition.new(
      details: { usage_id: usage_id, current_status: status, attempted: "deducted" }
    ) unless pending_deduct? || failed?

    update!(
      status: "deducted",
      deducted_quantity: quantity,
      movement_ref: movement_ref,
      deducted_at: Time.current,
      deduct_error: nil,
      failed_at: nil
    )
  end

  def mark_failed!(error_message:)
    raise Dental::Errors::InvalidTransition.new(
      details: { usage_id: usage_id, current_status: status, attempted: "failed" }
    ) unless pending_deduct?

    update!(
      status: "failed",
      deduct_error: error_message,
      failed_at: Time.current
    )
  end

  def mark_pending_for_retry!
    raise Dental::Errors::InvalidTransition.new(
      details: { usage_id: usage_id, current_status: status, attempted: "pending_deduct" }
    ) unless failed?

    update!(
      status: "pending_deduct",
      deduct_error: nil,
      failed_at: nil
    )
  end

  def void!(reason:)
    raise Dental::Errors::GuardViolation.new(
      details: { usage_id: usage_id, message: "already voided" }
    ) if voided?

    update!(
      voided_at: Time.current,
      void_reason: reason
    )
  end

  private

  def void_reason_required_when_voided
    return unless voided_at.present? && void_reason.blank?

    errors.add(:void_reason, "is required when voiding a usage record")
  end
end
