class DentalMasterDataChangeRequest < ApplicationRecord
  STATUSES = %w[pending approved rejected].freeze

  validates :resource_type, presence: true
  validates :resource_id, presence: true
  validates :change_type, presence: true
  validates :payload_json, presence: true
  validates :requested_by_id, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }

  def payload
    JSON.parse(payload_json)
  rescue JSON::ParserError
    {}
  end

  def approve!(approver_id:)
    if approver_id.to_s == requested_by_id.to_s
      errors.add(:base, "self_approval_not_allowed")
      return false
    end

    update!(status: "approved", approved_by_id: approver_id, approved_at: Time.current)
  end
end
