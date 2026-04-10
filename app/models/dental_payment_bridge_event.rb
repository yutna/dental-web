class DentalPaymentBridgeEvent < ApplicationRecord
  HOOK_TYPES = %w[send_to_cashier complete_no_charge refer_out cancel_visit].freeze
  STATUSES = %w[pending sent failed].freeze

  validates :visit_id, :hook_type, :from_stage, :to_stage, :status, presence: true
  validates :hook_type, inclusion: { in: HOOK_TYPES }
  validates :status, inclusion: { in: STATUSES }

  before_update :block_mutation
  before_destroy :block_mutation

  def payload
    JSON.parse(payload_json.presence || "{}")
  rescue JSON::ParserError
    {}
  end

  private

  def block_mutation
    errors.add(:base, "append_only")
    throw(:abort)
  end
end
