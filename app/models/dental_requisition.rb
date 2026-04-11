class DentalRequisition < ApplicationRecord
  ALLOWED_TRANSITIONS = {
    "pending" => %w[approved cancelled],
    "approved" => %w[dispensed cancelled],
    "dispensed" => %w[received],
    "received" => [],
    "cancelled" => []
  }.freeze

  ITEM_TYPES = %w[medication supply].freeze

  has_many :line_items, class_name: "DentalRequisitionLineItem", dependent: :destroy

  validates :requisition_id, presence: true, uniqueness: true
  validates :requester_id, presence: true
  validates :status, presence: true, inclusion: { in: Dental::Enums::RequisitionStatus.allowed_values }
  validate :cancel_reason_required_when_cancelled

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :dispensed, -> { where(status: "dispensed") }
  scope :received, -> { where(status: "received") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :active, -> { where.not(status: "cancelled") }
  scope :for_visit, ->(visit_id) { where(visit_id: visit_id) }

  def pending?
    status == "pending"
  end

  def approved?
    status == "approved"
  end

  def dispensed?
    status == "dispensed"
  end

  def received?
    status == "received"
  end

  def cancelled?
    status == "cancelled"
  end

  def terminal?
    received? || cancelled?
  end

  def allowed_transitions
    ALLOWED_TRANSITIONS.fetch(status, [])
  end

  def can_transition_to?(target_status)
    allowed_transitions.include?(target_status)
  end

  def approve!(approver_id:)
    guard_transition!("approved")
    guard_self_approval!(approver_id)

    update!(
      status: "approved",
      approver_id: approver_id,
      approved_at: Time.current
    )
  end

  def dispense!(dispenser_id:, dispense_number:)
    guard_transition!("dispensed")
    guard_dispense_number!(dispense_number)

    update!(
      status: "dispensed",
      dispenser_id: dispenser_id,
      dispense_number: dispense_number,
      dispensed_at: Time.current
    )
  end

  def receive!(receiver_id:)
    guard_transition!("received")

    update!(
      status: "received",
      receiver_id: receiver_id,
      received_at: Time.current
    )
  end

  def cancel!(reason:, actor_id: nil)
    guard_transition!("cancelled")

    update!(
      status: "cancelled",
      cancel_reason: reason,
      canceller_id: actor_id,
      cancelled_at: Time.current
    )
  end

  private

  def guard_transition!(target_status)
    return if can_transition_to?(target_status)

    raise Dental::Errors::InvalidTransition.new(
      details: {
        requisition_id: requisition_id,
        current_status: status,
        attempted: target_status
      }
    )
  end

  def guard_self_approval!(approver_id)
    return unless approver_id == requester_id

    raise Dental::Errors::GuardViolation.new(
      details: {
        requisition_id: requisition_id,
        message: "requester cannot approve own requisition",
        requester_id: requester_id,
        approver_id: approver_id
      }
    )
  end

  def guard_dispense_number!(dispense_number)
    return if dispense_number.present?

    raise Dental::Errors::GuardViolation.new(
      details: {
        requisition_id: requisition_id,
        message: "dispense number is required"
      }
    )
  end

  def cancel_reason_required_when_cancelled
    return unless cancelled? && cancel_reason.blank?

    errors.add(:cancel_reason, "is required when cancelling a requisition")
  end
end
